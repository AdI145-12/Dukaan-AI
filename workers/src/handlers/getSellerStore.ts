import { checkRateLimit } from '../middleware/rate_limit';
import { fetchStoreData } from '../services/store_page';
import type { Env } from '../types/env';
import { jsonError, jsonSuccess } from '../utils/response';
import { isSafeSlug } from '../utils/validators';

const PATH_PREFIX = '/api/seller-store/';

function extractSlug(pathname: string): string {
	if (!pathname.startsWith(PATH_PREFIX)) {
		return '';
	}

	return pathname.slice(PATH_PREFIX.length).trim().toLowerCase();
}

export async function handleGetSellerStore(
	request: Request,
	env: Env,
): Promise<Response> {
	if (request.method !== 'GET') {
		return jsonError('Method not allowed', 405);
	}

	const url = new URL(request.url);
	const slug = extractSlug(url.pathname);
	if (!isSafeSlug(slug)) {
		return jsonError('Invalid store slug', 400);
	}

	const clientIp = request.headers.get('CF-Connecting-IP') ?? 'unknown-ip';
	const limited = await checkRateLimit(
		'seller-store-json',
		`${slug}:${clientIp}`,
		120,
		env,
		60,
	);
	if (limited) {
		return jsonError('Too many requests', 429);
	}

	const storeData = await fetchStoreData(slug, env);
	if (!storeData) {
		return jsonError('Store not found', 404);
	}

	return jsonSuccess({
		store: {
			shopName: storeData.shop.shopName,
			slug: storeData.shop.slug,
			city: storeData.shop.city ?? '',
			bannerUrl: storeData.shop.storeBannerUrl ?? '',
			description: storeData.shop.storeDescription ?? '',
		},
		products: storeData.products.map((product) => ({
			id: product.id,
			name: product.name,
			price: product.price,
			imageUrl: product.imageUrl ?? '',
			stockStatus: product.stockStatus,
		})),
	});
}
