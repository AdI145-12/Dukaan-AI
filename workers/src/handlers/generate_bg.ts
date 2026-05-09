import { extractAndVerifyToken } from '../middleware/auth';
import { corsHeaders } from '../middleware/cors';
import { checkRateLimit } from '../middleware/rate_limit';
import { generateWithFluxSchnell } from '../services/replicate';
import type { Env } from '../types/env';
import { buildStylePrompt } from '../utils/prompt_builder';
import { jsonError, jsonSuccess } from '../utils/response';

interface GenerateBgBody {
  productBase64?: string;
  style?: string;
  customPrompt?: string;
}

export async function handleGenerateBg(
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

  const limited = await checkRateLimit('generate-bg', userId, 5, env);
  if (limited) {
    return jsonError('Aaj ka limit khatam ho gaya. Kal dobara try karein.', 429);
  }

  let body: GenerateBgBody;
  try {
    body = (await request.json()) as GenerateBgBody;
  } catch (_) {
    return jsonError('Invalid JSON body', 400);
  }

  if (!body.style) {
    return jsonError('style is required', 400);
  }

  if (body.customPrompt && body.customPrompt.length > 200) {
    return jsonError('customPrompt too long (max 200 characters)', 400);
  }

  const prompt = buildStylePrompt(body.style, body.customPrompt);

  try {
    const resultUrl = await generateWithFluxSchnell(prompt, env.REPLICATEAPITOKEN);

    return jsonSuccess({
      resultUrl,
      styleUsed: body.style,
    });
  } catch (error) {
    console.error('generate-bg', error);
    return jsonError('Kuch gadbad ho gayi. Dobara try karein.', 500);
  }
}
