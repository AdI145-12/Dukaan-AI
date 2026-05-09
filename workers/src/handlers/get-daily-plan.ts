import { getFestivalsForDate } from '../lib/festival-calendar';
import { extractAndVerifyToken } from '../middleware/auth';
import { corsHeaders } from '../middleware/cors';
import { checkRateLimit } from '../middleware/rate_limit';
import {
  buildFallbackDailyPlan,
  generateDailyPlanWithGpt,
} from '../services/daily_plan';
import type {
  DailyPlanProductInput,
  DailyPlanRequest,
  DailyPlanResponse,
} from '../types/catalogue';
import type { Env } from '../types/env';
import { jsonError, jsonSuccess } from '../utils/response';

interface GetDailyPlanBody {
  businessCategory?: string;
  festival?: string;
  products?: unknown;
}

function cleanText(raw: unknown, maxLength: number): string {
  if (typeof raw !== 'string') {
    return '';
  }

  return raw.trim().slice(0, maxLength);
}

function sanitizeProducts(rawProducts: unknown): DailyPlanProductInput[] {
  if (!Array.isArray(rawProducts)) {
    return [];
  }

  return rawProducts
    .filter((entry): entry is Record<string, unknown> =>
      typeof entry === 'object' && entry !== null,
    )
    .map((entry) => {
      const name = cleanText(entry.name, 80);
      const category = cleanText(entry.category, 50);
      const imageUrl = cleanText(entry.imageUrl, 500);
      const stock =
        typeof entry.stock === 'number' && Number.isFinite(entry.stock)
          ? Math.trunc(entry.stock)
          : null;

      return {
        name,
        ...(category ? { category } : {}),
        ...(imageUrl ? { imageUrl } : {}),
        ...(stock != null ? { stock } : {}),
      };
    })
    .filter((product) => product.name.length > 0)
    .slice(0, 6);
}

function todaysFestival(date: string): string | undefined {
  const festivals = getFestivalsForDate(date);
  const todayFestival = festivals.find((festival) => !festival.isReminder);
  return todayFestival?.name;
}

export async function handleGetDailyPlan(
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

  const limited = await checkRateLimit('get-daily-plan', userId, 20, env);
  if (limited) {
    return jsonError('Aaj ka daily plan limit khatam ho gaya. Kal dobara try karein.', 429);
  }

  let body: GetDailyPlanBody;
  try {
    body = (await request.json()) as GetDailyPlanBody;
  } catch (error) {
    console.error('get-daily-plan: invalid-json-body', error);
    return jsonError('Invalid JSON body', 400);
  }

  const date = new Date().toISOString().slice(0, 10);
  const products = sanitizeProducts(body.products);
  const businessCategory = cleanText(body.businessCategory, 50) || 'general';
  const festival =
    cleanText(body.festival, 60) ||
    todaysFestival(date);

  const requestPayload: DailyPlanRequest = {
    date,
    businessCategory,
    products,
    ...(festival ? { festival } : {}),
  };

  const cacheKey = `daily-plan:${userId}:${date}`;
  const cached = await env.CACHEKV.get(cacheKey);
  if (cached) {
    try {
      const parsed = JSON.parse(cached) as DailyPlanResponse & {
        date: string;
        fallback?: boolean;
      };

      return jsonSuccess({
        ...parsed,
        cached: true,
      });
    } catch (error) {
      console.error('get-daily-plan: malformed-cache', error);
      // Ignore malformed cache and regenerate.
    }
  }

  try {
    const plan = await generateDailyPlanWithGpt(requestPayload, env);
    const payload = {
      ...plan,
      date,
      cached: false,
      fallback: false,
    };

    await env.CACHEKV.put(cacheKey, JSON.stringify(payload), {
      expirationTtl: 86400,
    });

    return jsonSuccess(payload);
  } catch (error) {
    console.error('get-daily-plan: generation-failure', error);

    const fallbackPlan = buildFallbackDailyPlan(requestPayload);
    const payload = {
      ...fallbackPlan,
      date,
      cached: false,
      fallback: true,
    };

    await env.CACHEKV.put(cacheKey, JSON.stringify(payload), {
      expirationTtl: 3600,
    });

    return jsonSuccess(payload);
  }
}
