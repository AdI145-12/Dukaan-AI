import { corsHeaders } from '../middleware/cors';
import { checkRateLimit } from '../middleware/rate_limit';
import { incrementClickCount } from '../services/store_page';
import type { Env } from '../types/env';
import { jsonSuccess } from '../utils/response';

interface TrackStoreClickBody {
  slug?: string;
}

const SLUG_PATTERN = /^[a-z0-9][a-z0-9\-]{1,28}[a-z0-9]$/;

export async function handleTrackStoreClick(
  request: Request,
  env: Env,
): Promise<Response> {
  if (request.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  if (request.method !== 'POST') {
    return jsonSuccess({ ok: true });
  }

  const clientIp = request.headers.get('CF-Connecting-IP') ?? 'unknown-ip';
  const limited = await checkRateLimit('track-store-click', clientIp, 50, env, 60);
  if (limited) {
    return jsonSuccess({ ok: true });
  }

  let body: TrackStoreClickBody | null = null;
  try {
    body = (await request.json()) as TrackStoreClickBody;
  } catch {
    return jsonSuccess({ ok: true });
  }

  const slug = (body.slug ?? '').trim().toLowerCase();
  if (!SLUG_PATTERN.test(slug)) {
    return jsonSuccess({ ok: true });
  }

  try {
    await incrementClickCount(slug, env);
  } catch {
    // Click tracking is best-effort and should never fail the customer flow.
  }

  return jsonSuccess({ ok: true });
}
