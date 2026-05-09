/// <reference path="../types/vitest-shim.d.ts" />

import { beforeEach, describe, expect, it, vi } from 'vitest';

import { handleTrackStoreClick } from '../handlers/track-store-click';
import { incrementClickCount } from '../services/store_page';
import type { Env } from '../types/env';

vi.mock('../services/store_page', () => ({
  incrementClickCount: vi.fn(),
}));

type MockedFunction = {
  mockResolvedValue(value: unknown): void;
  mockClear(): void;
  mock: {
    calls: unknown[][];
  };
};

const mockedIncrementClicks = incrementClickCount as unknown as MockedFunction;

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

function request(body: string, ip = '11.22.33.44'): Request {
  return new Request('https://example.com/api/track-store-click', {
    method: 'POST',
    headers: {
      'CF-Connecting-IP': ip,
      'Content-Type': 'application/json',
    },
    body,
  });
}

describe('handleTrackStoreClick', () => {
  beforeEach(() => {
    vi.resetAllMocks();
    mockedIncrementClicks.mockResolvedValue(undefined);
    mockedIncrementClicks.mockClear();
  });

  it('increments click count and returns ok for valid slug', async () => {
    const response = await handleTrackStoreClick(
      request(JSON.stringify({ slug: 'ramu-store' })),
      createEnv(),
    );

    const body = (await response.json()) as { data?: { ok?: boolean } };
    expect(response.status).toBe(200);
    expect(body.data?.ok).toBe(true);
    expect(mockedIncrementClicks.mock.calls.length).toBe(1);
  });

  it('returns 200 even when slug is missing', async () => {
    const response = await handleTrackStoreClick(
      request(JSON.stringify({})),
      createEnv(),
    );

    const body = (await response.json()) as { data?: { ok?: boolean } };
    expect(response.status).toBe(200);
    expect(body.data?.ok).toBe(true);
  });

  it('returns 200 even when 51st request is rate-limited', async () => {
    const env = createEnv();
    let lastStatus = 0;

    for (let index = 0; index < 51; index += 1) {
      const response = await handleTrackStoreClick(
        request(JSON.stringify({ slug: 'ramu-store' }), '99.88.77.66'),
        env,
      );
      lastStatus = response.status;
    }

    expect(lastStatus).toBe(200);
  });
});
