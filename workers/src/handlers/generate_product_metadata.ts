import { extractAndVerifyToken } from '../middleware/auth';
import { corsHeaders } from '../middleware/cors';
import { checkRateLimit } from '../middleware/rate_limit';
import { generateProductMetadata } from '../services/openai';
import type { ProductMetadataRequest } from '../types/catalogue';
import type { Env } from '../types/env';
import { normalizeCategory } from '../utils/category_normalizer';
import { jsonError, jsonSuccess } from '../utils/response';

interface GenerateProductMetadataBody extends Partial<ProductMetadataRequest> {
  imageBase64?: string;
}

function sanitizeVariants(rawVariants: unknown): Array<{ type: string; options: string[] }> {
  if (!Array.isArray(rawVariants)) {
    return [];
  }

  return rawVariants
    .filter((entry): entry is { type?: unknown; options?: unknown } =>
      typeof entry === 'object' && entry !== null,
    )
    .map((entry) => {
      const type = typeof entry.type === 'string' ? entry.type.trim() : '';
      const options = Array.isArray(entry.options)
        ? entry.options
            .map((option) => String(option).trim())
            .filter((option) => option.length > 0)
        : [];

      return { type, options };
    })
    .filter((entry) => entry.type.length > 0 && entry.options.length > 0);
}

export async function handleGenerateProductMetadata(
  request: Request,
  env: Env,
): Promise<Response> {
  if (request.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  if (request.method !== 'POST') {
    return jsonError('Method not allowed', 405);
  }

  const userId = await extractAndVerifyToken(request, env);
  if (!userId) {
    return jsonError('Unauthorized', 401);
  }

  const limited = await checkRateLimit('generate-product-metadata', userId, 20, env);
  if (limited) {
    return jsonError('Aaj ka metadata limit khatam ho gaya. Kal dobara try karein.', 429);
  }

  let body: GenerateProductMetadataBody;
  try {
    body = (await request.json()) as GenerateProductMetadataBody;
  } catch (error) {
    console.error('generate-product-metadata: invalid-json-body', error);
    return jsonError('Invalid JSON body', 400);
  }

  const productName = (body.productName ?? '').trim().slice(0, 120);
  if (!productName) {
    return jsonError('productName is required', 400);
  }

  const category = normalizeCategory(body.category ?? '') || 'general';
  const price =
    typeof body.price === 'number' && Number.isFinite(body.price) && body.price >= 0
      ? body.price
      : 0;
  const variants = sanitizeVariants(body.variants);

  const requestPayload: ProductMetadataRequest = {
    productName,
    category,
    price,
    ...(variants.length > 0 ? { variants } : {}),
  };

  console.log(
    `generate-product-metadata: userId=${userId} category=${category} name=${productName}`,
  );

  const imageBase64 = (body.imageBase64 ?? '').trim();
  void imageBase64;

  const cacheKey = `product-meta:${category}:${productName.toLowerCase()}`;
  const cached = await env.CACHEKV.get(cacheKey);
  if (cached) {
    try {
      return jsonSuccess({
        ...(JSON.parse(cached) as Record<string, unknown>),
        cached: true,
      });
    } catch (error) {
      console.error('generate-product-metadata: malformed-cache', error);
      // Ignore malformed cache and regenerate.
    }
  }

  try {
    const metadata = await generateProductMetadata(requestPayload, env);

    if (
      typeof metadata.description !== 'string' ||
      !Array.isArray(metadata.tags) ||
      !Array.isArray(metadata.suggestedCaptions)
    ) {
      console.error('generate-product-metadata: schema mismatch', metadata);
      return jsonError('Invalid metadata format returned.', 500);
    }

    const payload = {
      description: metadata.description,
      tags: metadata.tags,
      caption: metadata.suggestedCaptions[0] ?? '',
      suggestedCaptions: metadata.suggestedCaptions,
    };

    await env.CACHEKV.put(cacheKey, JSON.stringify(payload), {
      expirationTtl: 3600,
    });

    return jsonSuccess(payload);
  } catch (error) {
    console.error('generate-product-metadata: openai-failure', error);

    if (error instanceof Error && error.message === 'METADATA_SCHEMA_MISMATCH') {
      return jsonError('Invalid metadata format returned.', 500);
    }

    return jsonError('Metadata generate nahi hua. Dobara try karein.', 500);
  }
}
