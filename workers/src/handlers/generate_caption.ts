import { extractAndVerifyToken } from '../middleware/auth';
import { corsHeaders } from '../middleware/cors';
import { checkRateLimit } from '../middleware/rate_limit';
import { generateCaptionWithGpt } from '../services/openai';
import type { Env } from '../types/env';
import { jsonError, jsonSuccess } from '../utils/response';

interface GenerateCaptionBody {
	productName?: string;
	category?: string;
	language?: string;
	offer?: string;
}

const VALID_LANGUAGES = new Set(['hindi', 'english', 'hinglish']);
const VALID_CATEGORIES = new Set([
	'saree',
	'gadget',
	'food',
	'jewelry',
	'clothing',
	'electronics',
	'cosmetics',
	'furniture',
	'books',
	'sports',
	'general',
]);

export async function handleGenerateCaption(
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

	const limited = await checkRateLimit('generate-caption', userId, 20, env);
	if (limited) {
		return jsonError(
			'Aaj ka caption limit khatam ho gaya. Kal dobara try karein.',
			429,
		);
	}

	let body: GenerateCaptionBody;
	try {
		body = (await request.json()) as GenerateCaptionBody;
	} catch {
		return jsonError('Invalid JSON body', 400);
	}

	const productName = (body.productName ?? '').trim().slice(0, 100);
	const category = VALID_CATEGORIES.has(body.category ?? '')
		? (body.category as string)
		: 'general';
	const language = VALID_LANGUAGES.has(body.language ?? '')
		? (body.language as string)
		: 'hinglish';
	const offer = (body.offer ?? '').trim().slice(0, 100) || undefined;

	const cacheKey =
		`caption:${language}:${category}:` +
		`${productName.toLowerCase()}:${offer ?? ''}`;

	const cached = await env.CACHEKV.get(cacheKey);
	if (cached) {
		try {
			return jsonSuccess({
				...(JSON.parse(cached) as Record<string, unknown>),
				cached: true,
			});
		} catch {
			// Ignore bad cache value and regenerate.
		}
	}

	try {
		const result = await generateCaptionWithGpt(
			productName,
			category,
			language,
			offer,
			env,
		);

		const payload = {
			caption: result.caption,
			hashtags: result.hashtags,
			language,
		};

		await env.CACHEKV.put(cacheKey, JSON.stringify(payload), {
			expirationTtl: 3600,
		});

		return jsonSuccess(payload);
	} catch (error) {
		console.error('generate-caption', error);
		return jsonError('Caption generate nahi hua. Dobara try karein.', 500);
	}
}