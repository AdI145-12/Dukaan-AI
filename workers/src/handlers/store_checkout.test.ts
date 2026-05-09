/// <reference path="../types/vitest-shim.d.ts" />

import { beforeEach, describe, expect, it, vi } from 'vitest';

import type { Env } from '../types/env';
import { handleCreateStoreOrder } from './createStoreOrder';
import { handleVerifyStorePayment } from './verifyStorePayment';
import { checkRateLimit } from '../middleware/rate_limit';
import { createRazorpayOrder, fetchRazorpayPayment, verifyRazorpaySignature } from '../services/razorpay_service';
import { fetchStoreData } from '../services/store_page';
import { firestoreCreate, firestorePatch, firestoreQuery } from '../utils/firestore_admin';

vi.mock('../middleware/rate_limit', () => ({
	checkRateLimit: vi.fn(),
}));

vi.mock('../services/razorpay_service', () => ({
	createRazorpayOrder: vi.fn(),
	fetchRazorpayPayment: vi.fn(),
	verifyRazorpaySignature: vi.fn(),
}));

vi.mock('../services/store_page', () => ({
	fetchStoreData: vi.fn(),
}));

vi.mock('../utils/firestore_admin', () => ({
	firestoreCreate: vi.fn(),
	firestorePatch: vi.fn(),
	firestoreQuery: vi.fn(),
	strVal: (fields: Record<string, { stringValue?: string }>, key: string) =>
		fields[key]?.stringValue ?? null,
}));

type MockedFunction = {
	mockResolvedValue(value: unknown): void;
	mockClear(): void;
	mockImplementation(fn: (...args: unknown[]) => unknown): void;
	mock: {
		calls: unknown[][];
	};
};

const mockedCheckRateLimit = checkRateLimit as unknown as MockedFunction;
const mockedCreateRazorpayOrder = createRazorpayOrder as unknown as MockedFunction;
const mockedFetchRazorpayPayment = fetchRazorpayPayment as unknown as MockedFunction;
const mockedVerifyRazorpaySignature =
	verifyRazorpaySignature as unknown as MockedFunction;
const mockedFetchStoreData = fetchStoreData as unknown as MockedFunction;
const mockedFirestoreCreate = firestoreCreate as unknown as MockedFunction;
const mockedFirestorePatch = firestorePatch as unknown as MockedFunction;
const mockedFirestoreQuery = firestoreQuery as unknown as MockedFunction;

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

describe('store checkout handlers', () => {
	beforeEach(() => {
		vi.resetAllMocks();
		mockedCheckRateLimit.mockResolvedValue(false);
		mockedCreateRazorpayOrder.mockResolvedValue({
			id: 'order_test_123',
			amount: 64000,
			currency: 'INR',
		});
		mockedFetchStoreData.mockResolvedValue({
			shop: {
				userId: 'seller-1',
				shopName: 'Ramu Store',
				slug: 'ramu-store',
				city: 'Lucknow',
				storeBannerUrl: '',
				storeDescription: 'Fresh products',
				phone: '9876543210',
				storeViewsCount: 0,
				storeWhatsappClicks: 0,
			},
			products: [
				{
					id: '11111111-1111-4111-8111-111111111111',
					name: 'Aata 5kg',
					price: 320,
					imageUrl: 'https://img.example/aata.jpg',
					stockStatus: 'inStock',
				},
			],
		});
		mockedFirestoreCreate.mockResolvedValue({ id: 'doc-1' });
		mockedFirestorePatch.mockResolvedValue(undefined);
		mockedFirestoreQuery.mockResolvedValue([
			{
				id: 'tx-1',
				fields: {
					orderSlipId: { stringValue: 'slip-1' },
					userId: { stringValue: 'seller-1' },
					storeSlug: { stringValue: 'ramu-store' },
				},
			},
		]);
		mockedVerifyRazorpaySignature.mockResolvedValue(true);
		mockedFetchRazorpayPayment.mockResolvedValue({
			id: 'pay_123',
			order_id: 'order_test_123',
			status: 'captured',
			captured: true,
			method: 'upi',
		});
	});

	it('creates a pending store order and transaction', async () => {
		const request = new Request('https://example.com/api/store/create-order', {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
				'CF-Connecting-IP': '1.2.3.4',
			},
			body: JSON.stringify({
				storeSlug: 'ramu-store',
				items: [
					{
						productId: '11111111-1111-4111-8111-111111111111',
						quantity: 2,
					},
				],
				customer: {
					name: 'Aman Gupta',
					phone: '9876543210',
					address: 'Lucknow',
				},
			}),
		});

		const response = await handleCreateStoreOrder(request, createEnv());
		const body = (await response.json()) as {
			success?: boolean;
			data?: { razorpayOrderId?: string; sellerName?: string };
		};

		expect(response.status).toBe(200);
		expect(body.success).toBe(true);
		expect(body.data?.razorpayOrderId).toBe('order_test_123');
		expect(body.data?.sellerName).toBe('Ramu Store');
		expect(mockedFirestoreCreate.mock.calls.length).toBe(2);
	});

	it('marks store payment successful and updates the linked order slip', async () => {
		const request = new Request('https://example.com/api/store/verify-payment', {
			method: 'POST',
			headers: { 'Content-Type': 'application/json' },
			body: JSON.stringify({
				razorpayOrderId: 'order_test_123',
				razorpayPaymentId: 'pay_123',
				razorpaySignature: 'valid-signature',
			}),
		});

		const response = await handleVerifyStorePayment(request, createEnv());
		const body = (await response.json()) as {
			success?: boolean;
			data?: { status?: string; orderSlipId?: string };
		};

		expect(response.status).toBe(200);
		expect(body.success).toBe(true);
		expect(body.data?.status).toBe('success');
		expect(body.data?.orderSlipId).toBe('slip-1');
		expect(mockedFirestorePatch.mock.calls.length).toBe(2);
	});

	it('marks the transaction failed when signature is invalid', async () => {
		mockedVerifyRazorpaySignature.mockResolvedValue(false);

		const request = new Request('https://example.com/api/store/verify-payment', {
			method: 'POST',
			headers: { 'Content-Type': 'application/json' },
			body: JSON.stringify({
				razorpayOrderId: 'order_test_123',
				razorpayPaymentId: 'pay_123',
				razorpaySignature: 'bad-signature',
			}),
		});

		const response = await handleVerifyStorePayment(request, createEnv());
		expect(response.status).toBe(400);
		expect(mockedFirestorePatch.mock.calls.length).toBe(1);
	});
});
