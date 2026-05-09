/// <reference path="../types/vitest-shim.d.ts" />

import { beforeEach, describe, expect, it, vi } from 'vitest';

import type { Env } from '../types/env';
import { handleGetStorePage } from '../handlers/get-store-page';
import { fetchStoreData, incrementViewCount } from '../services/store_page';

vi.mock('../services/store_page', () => ({
  fetchStoreData: vi.fn(),
  incrementViewCount: vi.fn(),
}));

type MockedFunction = {
  mockResolvedValue(value: unknown): void;
  mockImplementation(fn: (...args: unknown[]) => unknown): void;
  mockClear(): void;
  mock: {
    calls: unknown[][];
  };
};

const mockedFetchStoreData = fetchStoreData as unknown as MockedFunction;
const mockedIncrementViewCount = incrementViewCount as unknown as MockedFunction;

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

function request(path: string, ip = '10.0.0.1'): Request {
  return new Request(`https://example.com${path}`, {
    method: 'GET',
    headers: {
      'CF-Connecting-IP': ip,
    },
  });
}

const sampleStore = {
  shop: {
    userId: 'user-1',
    shopName: 'Ramu Store',
    storeDescription: 'Best kirana products',
    storeBannerUrl: 'https://img.example/banner.jpg',
    phone: '9876543210',
    storeViewsCount: 10,
    storeWhatsappClicks: 5,
  },
  products: [
    {
      id: 'p1',
      name: 'Aata 5kg',
      price: 320,
      imageUrl: 'https://img.example/aata.jpg',
      description: 'Fresh chakki aata',
      category: 'grocery',
    },
  ],
};

describe('handleGetStorePage', () => {
  beforeEach(() => {
    vi.resetAllMocks();
    mockedFetchStoreData.mockResolvedValue(sampleStore);
    mockedIncrementViewCount.mockResolvedValue(undefined);
    mockedFetchStoreData.mockClear();
    mockedIncrementViewCount.mockClear();
  });

  it('returns valid HTML for a published store with products', async () => {
    const response = await handleGetStorePage(
      request('/api/get-seller-store/ramu-store'),
      createEnv(),
    );
    const html = await response.text();

    expect(response.status).toBe(200);
    expect(html).toContain('<!doctype html>');
    expect(html).toContain('Ramu Store');
    expect(html).toContain('Aata 5kg');
  });

  it('returns styled 404 HTML for unknown slug', async () => {
    mockedFetchStoreData.mockResolvedValue(null);

    const response = await handleGetStorePage(
      request('/api/get-seller-store/missing-store'),
      createEnv(),
    );
    const html = await response.text();

    expect(response.status).toBe(404);
    expect(html).toContain('Yeh store nahi mila');
  });

  it('returns styled 404 HTML for unpublished store', async () => {
    mockedFetchStoreData.mockResolvedValue(null);

    const response = await handleGetStorePage(
      request('/api/get-seller-store/unpublished-shop'),
      createEnv(),
    );
    const html = await response.text();

    expect(response.status).toBe(404);
    expect(html).toContain('Dukaan AI');
  });

  it('enforces IP rate limit where 101st request is blocked', async () => {
    const env = createEnv();

    let lastStatus = 0;
    for (let index = 0; index < 101; index += 1) {
      const response = await handleGetStorePage(
        request('/api/get-seller-store/ramu-store', '44.55.66.77'),
        env,
      );
      lastStatus = response.status;
    }

    expect(lastStatus).toBe(429);
  });

  it('returns 404 for invalid slug format without DB query', async () => {
    const response = await handleGetStorePage(
      request('/api/get-seller-store/Invalid_Slug'),
      createEnv(),
    );

    expect(response.status).toBe(404);
    expect(mockedFetchStoreData.mock.calls.length).toBe(0);
  });

  it('calls incrementViewCount without blocking response', async () => {
    mockedIncrementViewCount.mockImplementation(
      () => new Promise<void>(() => {}),
    );

    const response = await handleGetStorePage(
      request('/api/get-seller-store/ramu-store'),
      createEnv(),
    );

    expect(response.status).toBe(200);
    expect(mockedIncrementViewCount.mock.calls.length).toBe(1);
  });

  it('renders empty state when no products are available', async () => {
    mockedFetchStoreData.mockResolvedValue({
      ...sampleStore,
      products: [],
    });

    const response = await handleGetStorePage(
      request('/api/get-seller-store/ramu-store'),
      createEnv(),
    );
    const html = await response.text();

    expect(response.status).toBe(200);
    expect(html).toContain('Abhi koi product available nahi hai');
  });

  it('returns Cache-Control header on success response', async () => {
    const response = await handleGetStorePage(
      request('/api/get-seller-store/ramu-store'),
      createEnv(),
    );

    expect(response.headers.get('Cache-Control')).toBe(
      'public, max-age=60, stale-while-revalidate=300',
    );
  });
});
