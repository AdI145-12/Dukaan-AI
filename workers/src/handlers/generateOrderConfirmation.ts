import { checkRateLimit } from '../middleware/rate_limit';
import { generateOrderConfirmationCopy } from '../services/openrouterService';
import type { Env } from '../types/env';
import { jsonError, jsonSuccess } from '../utils/response';
import { isRecord, readTrimmedString } from '../utils/validators';

export async function handleGenerateOrderConfirmation(
	request: Request,
	env: Env,
): Promise<Response> {
	if (request.method !== 'POST') {
		return jsonError('Method not allowed', 405);
	}

	const clientIp = request.headers.get('CF-Connecting-IP') ?? 'unknown-ip';
	const limited = await checkRateLimit(
		'generate-order-confirmation',
		clientIp,
		40,
		env,
		3600,
	);
	if (limited) {
		return jsonError('Too many requests', 429);
	}

	let body: Record<string, unknown>;
	try {
		const parsed = (await request.json()) as unknown;
		if (!isRecord(parsed)) {
			return jsonError('Invalid JSON body', 400);
		}
		body = parsed;
	} catch {
		return jsonError('Invalid JSON body', 400);
	}

	const language =
		readTrimmedString(body.language, { maxLength: 20 }).toLowerCase() === 'english'
			? 'english'
			: 'hinglish';
	const shopName = readTrimmedString(body.shopName, { maxLength: 80 }) || 'aapki dukaan';
	const productSummary = readTrimmedString(body.productSummary, { maxLength: 180 });

	const copy = await generateOrderConfirmationCopy(
		{
			language,
			shopName,
			productSummary,
		},
		env,
	);

	return jsonSuccess({ copy });
}
