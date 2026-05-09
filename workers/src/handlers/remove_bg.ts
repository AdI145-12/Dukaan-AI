import { extractAndVerifyToken } from '../middleware/auth';
import { corsHeaders } from '../middleware/cors';
import { checkRateLimit } from '../middleware/rate_limit';
import { removeBackgroundFromImage } from '../services/ai_engine';
import type { Env } from '../types/env';
import { jsonError, jsonSuccess } from '../utils/response';

interface RemoveBgBody {
	imageBase64?: string;
}

export async function handleRemoveBg(
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

	const limited = await checkRateLimit('remove-bg', userId, 10, env);
	if (limited) {
		return jsonError(
			'Aaj ka limit khatam ho gaya. Kal dobara try karein.',
			429,
		);
	}

	let body: RemoveBgBody;
	try {
		body = (await request.json()) as RemoveBgBody;
	} catch (_) {
		return jsonError('Invalid JSON body', 400);
	}

	if (!body.imageBase64) {
		return jsonError('imageBase64 required', 400);
	}

	if (body.imageBase64.length > 10_000_000) {
		return jsonError('Image too large. Maximum 10MB supported.', 413);
	}

	try {
		const resultBase64 = await removeBackgroundFromImage(
			body.imageBase64,
			env.AIENGINEAPIKEY,
		);

		return jsonSuccess({
			resultBase64,
			creditsUsed: 1,
		});
	} catch (error) {
		console.error('remove-bg', error);
		return jsonError('Kuch gadbad ho gayi. Dobara try karein.', 500);
	}
}