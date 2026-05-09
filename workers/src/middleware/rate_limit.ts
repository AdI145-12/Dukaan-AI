import type { Env } from '../types/env';

export async function checkRateLimit(
	endpoint: string,
	userId: string,
	limit: number,
	env: Env,
	windowSeconds = 86400,
): Promise<boolean> {
	const windowBucket = Math.floor(Date.now() / (windowSeconds * 1000));
	const key = `rate:${endpoint}:${windowSeconds}:${windowBucket}:${userId}`;

	try {
		const countRaw = await env.RATE_LIMIT_KV.get(key);
		const count = Number.parseInt(countRaw ?? '0', 10);

		if (count >= limit) {
			return true;
		}

		await env.RATE_LIMIT_KV.put(key, String(count + 1), {
			expirationTtl: windowSeconds,
		});

		return false;
	} catch (error) {
		console.error('check-rate-limit', error);
		return false;
	}
}