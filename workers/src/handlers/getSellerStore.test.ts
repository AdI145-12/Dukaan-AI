/// <reference path="../types/vitest-shim.d.ts" />

import { beforeEach, describe, expect, it, vi } from 'vitest';

import { handleGetSellerStore } from './getSellerStore';
import { fetchStoreData } from '../services/store_page';
import type { Env } from '../types/env';

vi.mock('../services/store_page', () => ({
	fetchStoreData: vi.fn(),
}));

type MockedFunction = {
	mockResolvedValue(value: unknown): void;
	mockClear(): void;
};

const mockedFetchStoreData = fetchStoreData as unknown as MockedFunction;

function createMemoryKv(): {
	get(key: string): Promise<string | null>;
	put(key: string, value: string): Promise<void>;
} {
	const map = new Map<string, string>();
	return {
		get: async (key: string) => map.get(key) ?? null,
		put: async (key: string, value: string) => {
			map.set(key, value);
		},
	};
}

function createEnv(): Env {
	return {
		FIREBASE_PROJECT_ID: 'dukaan-ai-prod',
		FIREBASE_API_KEY: 'firebase-key',
		FIREBASE_CLIENT_EMAIL: 'firebase-admin@dukaan-ai-prod.iam.gserviceaccount.com',
		FIREBASE_PRIVATE_KEY:
			'-----BEGIN PRIVATE KEY-----\\nTEST\\n-----END PRIVATE KEY-----\\n',
		AIENGINEAPIKEY: 'ai-engine-key',
		REPLICATEAPITOKEN: 'replicate-token',
		OPENAIAPIKEY: 'openai-key',
		RAZORPAY_KEY_ID: 'rzp_test_key',
		RAZORPAY_SECRET: 'rzp_secret',
		RATE_LIMIT_KV: createMemoryKv(),
		CACHEKV: createMemoryKv(),
	};
}

describe('handleGetSellerStore', () => {
	beforeEach(() => {
		vi.resetAllMocks();
		mockedFetchStoreData.mockResolvedValue({
			shop: {
				userId: 'seller-1',
				shopName: 'Ramu Store',
				slug: 'ramu-store',
				city: 'Lucknow',
				storeBannerUrl: 'https://img.example/banner.jpg',
				storeDescription: 'Fresh daily products',
				phone: '9876543210',
				storeViewsCount: 1,
				storeWhatsappClicks: 2,
			},
			products: [
				{
					id: 'p1',
					name: 'Aata',
					price: 320,
					imageUrl: 'https://img.example/aata.jpg',
					stockStatus: 'inStock',
				},
			],
		});
		mockedFetchStoreData.mockClear();
	});

	it('returns public store payload for a valid slug', async () => {
		const request = new Request('https://example.com/api/seller-store/ramu-store', {
			method: 'GET',
			headers: { 'CF-Connecting-IP': '1.2.3.4' },
		});

		const response = await handleGetSellerStore(request, createEnv());
		const body = (await response.json()) as {
			success?: boolean;
			data?: { store?: { shopName?: string }; products?: Array<{ id: string }> };
		};

		expect(response.status).toBe(200);
		expect(body.success).toBe(true);
		expect(body.data?.store?.shopName).toBe('Ramu Store');
		expect(body.data?.products?.[0]?.id).toBe('p1');
	});

	it('returns 400 for invalid slug format', async () => {
		const request = new Request('https://example.com/api/seller-store/Bad_Slug', {
			method: 'GET',
		});

		const response = await handleGetSellerStore(request, createEnv());
		expect(response.status).toBe(400);
	});
});
