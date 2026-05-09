import { checkRateLimit } from '../middleware/rate_limit';
import { fetchStoreData, incrementViewCount } from '../services/store_page';
import { renderStoreErrorHtml, renderStoreHtml } from '../services/store_html';
import type { Env } from '../types/env';
import { isSafeSlug } from '../utils/validators';

const PAGE_PREFIX = '/s/';
const LEGACY_PREFIX = '/api/get-seller-store/';

function extractSlug(pathname: string): string {
	if (pathname.startsWith(PAGE_PREFIX)) {
		return pathname.slice(PAGE_PREFIX.length).trim().toLowerCase();
	}

	if (pathname.startsWith(LEGACY_PREFIX)) {
		return pathname.slice(LEGACY_PREFIX.length).trim().toLowerCase();
	}

	return '';
}

function htmlResponse(body: string, status: number): Response {
	return new Response(body, {
		status,
		headers: {
			'Content-Type': 'text/html; charset=utf-8',
			'Cache-Control': 'public, max-age=60, stale-while-revalidate=300',
			'X-Robots-Tag': status === 200 ? 'index, follow' : 'noindex, nofollow',
		},
	});
}

export async function handleSellerStorePage(
	request: Request,
	env: Env,
): Promise<Response> {
	if (request.method !== 'GET') {
		return htmlResponse(
			renderStoreErrorHtml('Method not allowed', 'Sirf GET request allowed hai.'),
			405,
		);
	}

	const url = new URL(request.url);
	const slug = extractSlug(url.pathname);
	if (!isSafeSlug(slug)) {
		return htmlResponse(
			renderStoreErrorHtml(
				'Store not found',
				'Yeh store nahi mila. Dukaan AI pe apna store banao.',
			),
			404,
		);
	}

	const clientIp = request.headers.get('CF-Connecting-IP') ?? 'unknown-ip';
	const limited = await checkRateLimit(
		'seller-store-page',
		`${slug}:${clientIp}`,
		100,
		env,
		60,
	);
	if (limited) {
		return htmlResponse(
			renderStoreErrorHtml(
				'Thoda ruk jaiye',
				'Aapne bahut requests bheji hain. 1 minute baad dobara try karein.',
			),
			429,
		);
	}

	const storeData = await fetchStoreData(slug, env);
	if (!storeData) {
		return htmlResponse(
			renderStoreErrorHtml(
				'Yeh store nahi mila',
				'Yeh store abhi available nahi hai ya publish nahi hua.',
			),
			404,
		);
	}

	void incrementViewCount(storeData.shop.userId, env).catch(() => {});

	return htmlResponse(renderStoreHtml(storeData, slug), 200);
}
