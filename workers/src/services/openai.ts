import type { Env } from '../types/env';
import type { ProductMetadata, ProductMetadataRequest } from '../types/catalogue';

interface OpenAiChatResponse {
  choices?: Array<{
    message?: {
      content?: string;
    };
  }>;
}

export interface CaptionResult {
  caption: string;
  hashtags: string[];
}

const LANGUAGE_DESCRIPTIONS: Record<string, string> = {
  hindi: 'Hindi (written in Devanagari script)',
  english: 'English',
  hinglish:
    'Hinglish (Hindi words in Roman/English script, e.g. "Aaj ki offer amazing hai!")',
};

export function buildSystemPrompt(language: string): string {
  const languageDescription =
    LANGUAGE_DESCRIPTIONS[language] ?? LANGUAGE_DESCRIPTIONS.hinglish;

  return (
    `You are an expert Indian social media marketer who writes viral ad captions ` +
    `for small business owners in ${languageDescription}. ` +
    `Write in a friendly, energetic tone. Use relatable language. Include relevant emojis. ` +
    `Keep it under 150 characters. ` +
    `Return ONLY valid JSON with keys: ` +
    `"caption" (string) and "hashtags" (array of exactly 5 strings WITHOUT the # symbol).`
  );
}

export function buildUserMessage(
  productName: string,
  category: string,
  offer?: string,
): string {
  const trimmedName = productName.trim();
  let message = trimmedName
    ? `Write an ad caption for "${trimmedName}" in the category "${category}".`
    : `Write a general ad caption for a product in the "${category}" category.`;

  if (offer?.trim()) {
    message += ` Highlight this offer: ${offer.trim()}`;
  }

  return message;
}

export async function generateCaptionWithGpt(
  productName: string,
  category: string,
  language: string,
  offer: string | undefined,
  env: Pick<Env, 'OPENAIAPIKEY'>,
): Promise<CaptionResult> {
  const response = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${env.OPENAIAPIKEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: 'gpt-4o-mini',
      messages: [
        {
          role: 'system',
          content: buildSystemPrompt(language),
        },
        {
          role: 'user',
          content: buildUserMessage(productName, category, offer),
        },
      ],
      response_format: { type: 'json_object' },
      max_tokens: 250,
      temperature: 0.8,
    }),
  });

  if (!response.ok) {
    const errText = await response.text();
    throw new Error(`OpenAI API error: ${response.status} - ${errText}`);
  }

  const data = (await response.json()) as OpenAiChatResponse;
  const content = data.choices?.[0]?.message?.content;

  if (!content) {
    throw new Error('OpenAI returned empty response');
  }

  let parsed: { caption?: string; hashtags?: unknown };
  try {
    parsed = JSON.parse(content) as { caption?: string; hashtags?: unknown };
  } catch {
    throw new Error(`OpenAI returned non-JSON content: ${content.slice(0, 100)}`);
  }

  const hashtagList = Array.isArray(parsed.hashtags)
    ? parsed.hashtags.slice(0, 5).map((entry) => String(entry).replace(/^#/, ''))
    : [];

  return {
    caption: typeof parsed.caption === 'string' ? parsed.caption : '',
    hashtags: hashtagList,
  };
}

function buildMetadataSystemPrompt(): string {
  return `You are a product description writer for Indian small business sellers on WhatsApp and Instagram.
Your job is to generate short, punchy, Hinglish product content (mix of Hindi words in English script + English).
Always write from a seller's perspective. Target audience: Indian buyers aged 18-45.
Rules:
- Description: 1-2 sentences max. Friendly, benefit-focused. No corporate language.
- Tags: 4-6 lowercase keywords. Include category, material if known, and occasion.
- Captions: 2 short captions ready to paste on WhatsApp Status or Instagram. Include 1-2 emojis. End with a soft CTA.
- NEVER use: "premium", "high-quality", "best-in-class", "world-class"
- Always output ONLY valid JSON, no prose before or after.`;
}

function buildMetadataUserMessage(input: ProductMetadataRequest): string {
  const variants = input.variants ?? [];
  const variantText =
    variants.length > 0
      ? variants
          .map((variant) => `${variant.type}: ${variant.options.join(', ')}`)
          .join(' | ')
      : 'Not specified';

  return `Product details:
Name: ${input.productName}
Category: ${input.category}
Price: ₹${input.price}
Variants: ${variantText}

Generate product content in this exact JSON format:
{
  "description": "1-2 sentence Hinglish description",
  "tags": ["tag1", "tag2", "tag3", "tag4"],
  "suggestedCaptions": [
    "Caption 1 with emoji and soft CTA",
    "Caption 2 with emoji and soft CTA"
  ]
}`;
}

export async function generateProductMetadata(
  input: ProductMetadataRequest,
  env: Pick<Env, 'OPENAIAPIKEY'>,
): Promise<ProductMetadata> {
  const response = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${env.OPENAIAPIKEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: 'gpt-4o-mini',
      messages: [
        { role: 'system', content: buildMetadataSystemPrompt() },
        {
          role: 'user',
          content: buildMetadataUserMessage(input),
        },
      ],
      response_format: { type: 'json_object' },
      max_tokens: 300,
      temperature: 0.7,
    }),
  });

  if (!response.ok) {
    const errText = await response.text();
    throw new Error(`OpenAI API error: ${response.status} - ${errText}`);
  }

  const data = (await response.json()) as OpenAiChatResponse;
  const content = data.choices?.[0]?.message?.content;
  if (!content) {
    console.error('generate-product-metadata: empty response', data);
    throw new Error('OpenAI returned empty response');
  }

  let parsed: ProductMetadata;
  try {
    parsed = JSON.parse(content) as ProductMetadata;
  } catch {
    console.error('generate-product-metadata: JSON parse failed', data);
    throw new Error('METADATA_JSON_PARSE_FAILED');
  }

  if (
    typeof parsed.description !== 'string' ||
    !Array.isArray(parsed.tags) ||
    !Array.isArray(parsed.suggestedCaptions)
  ) {
    console.error('generate-product-metadata: schema mismatch', parsed);
    throw new Error('METADATA_SCHEMA_MISMATCH');
  }

  const tags = parsed.tags
    .slice(0, 6)
    .map((entry) => String(entry).replace(/^#/, '').trim().toLowerCase())
    .filter((entry) => entry.length > 0);

  const captions = parsed.suggestedCaptions
    .slice(0, 2)
    .map((entry) => String(entry).trim())
    .filter((entry) => entry.length > 0);

  return {
    description: parsed.description.trim(),
    tags,
    suggestedCaptions: captions,
  };
}

export const generateProductMetadataWithGpt = generateProductMetadata;