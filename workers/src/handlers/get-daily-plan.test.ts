/// <reference path="../types/vitest-shim.d.ts" />

import { beforeEach, describe, expect, it, vi } from 'vitest';

import { extractAndVerifyToken } from '../middleware/auth';
import { checkRateLimit } from '../middleware/rate_limit';
import { buildFallbackDailyPlan, generateDailyPlanWithGpt } from '../services/daily_plan';
import type { Env } from '../types/env';
import { handleGetDailyPlan } from './get-daily-plan';

vi.mock('../middleware/auth', () => ({
  extractAndVerifyToken: vi.fn(),
}));

vi.mock('../middleware/rate_limit', () => ({
  checkRateLimit: vi.fn(),
}));

vi.mock('../services/daily_plan', () => ({
  generateDailyPlanWithGpt: vi.fn(),
  buildFallbackDailyPlan: vi.fn(),
}));

type MockedFunction = {
  mockResolvedValue(value: unknown): void;
  mockRejectedValue(value: unknown): void;
  mockReturnValue(value: unknown): void;
  mockClear(): void;
  mock: {
    calls: unknown[][];
  };
};

const mockedExtractAndVerifyToken =
  extractAndVerifyToken as unknown as MockedFunction;
const mockedCheckRateLimit = checkRateLimit as unknown as MockedFunction;
const mockedGenerateDailyPlanWithGpt =
  generateDailyPlanWithGpt as unknown as MockedFunction;
const mockedBuildFallbackDailyPlan =
  buildFallbackDailyPlan as unknown as MockedFunction;

function createEnv(cachedValue: string | null = null): Env & {
  __puts: Array<{ key: string; value: string }>;
} {
  const puts: Array<{ key: string; value: string }> = [];

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
    RATE_LIMIT_KV: {
      get: async () => null,
      put: async () => {},
    },
    CACHEKV: {
      get: async () => cachedValue,
      put: async (key: string, value: string) => {
        puts.push({ key, value });
      },
    },
    __puts: puts,
  };
}

function makeRequest(body: Record<string, unknown>): Request {
  return new Request('https://example.com/api/get-daily-plan', {
    method: 'POST',
    headers: {
      Authorization: 'Bearer token',
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(body),
  });
}

async function parseJson(response: Response): Promise<Record<string, unknown>> {
  return (await response.json()) as Record<string, unknown>;
}

describe('handleGetDailyPlan', () => {
  beforeEach(() => {
    vi.resetAllMocks();
    mockedExtractAndVerifyToken.mockResolvedValue('user-1');
    mockedCheckRateLimit.mockResolvedValue(false);
    mockedGenerateDailyPlanWithGpt.mockResolvedValue({
      title: 'Aaj kurta reel banao',
      reason: 'Shaam me reach better aata hai.',
      captionIdea: 'Kurta pe launch offer + WhatsApp CTA do.',
      callToAction: 'Abhi post banao',
      suggestedProductName: 'Cotton Kurta',
      suggestedProductImageUrl: 'https://example.com/kurta.jpg',
      festivalTag: 'Holi',
    });
    mockedBuildFallbackDailyPlan.mockReturnValue({
      title: 'Fallback plan',
      reason: 'Fallback reason',
      captionIdea: 'Fallback caption',
      callToAction: 'Fallback CTA',
    });
    mockedGenerateDailyPlanWithGpt.mockClear();
  });

  it('returns cached payload without calling OpenAI service', async () => {
    const cachedPayload = JSON.stringify({
      title: 'Cached plan',
      reason: 'Cached reason',
      captionIdea: 'Cached caption',
      callToAction: 'Cached CTA',
      date: '2026-08-21',
      fallback: false,
      cached: false,
    });

    const response = await handleGetDailyPlan(
      makeRequest({
        businessCategory: 'clothing',
        products: [{ name: 'Kurta', stock: 4 }],
      }),
      createEnv(cachedPayload),
    );

    const body = await parseJson(response);
    const data = body.data as Record<string, unknown>;

    expect(response.status).toBe(200);
    expect(data.title).toBe('Cached plan');
    expect(data.cached).toBe(true);
    expect(mockedGenerateDailyPlanWithGpt.mock.calls.length).toBe(0);
  });

  it('generates and caches payload on cache miss', async () => {
    const env = createEnv();

    const response = await handleGetDailyPlan(
      makeRequest({
        businessCategory: 'clothing',
        festival: 'Holi',
        products: [
          { name: 'Cotton Kurta', stock: 3, category: 'clothing' },
          { name: 'Out Product', stock: 0, category: 'clothing' },
        ],
      }),
      env,
    );

    const body = await parseJson(response);
    const data = body.data as Record<string, unknown>;

    expect(response.status).toBe(200);
    expect(data.fallback).toBe(false);
    expect(data.cached).toBe(false);
    expect(data.title).toBe('Aaj kurta reel banao');
    expect(mockedGenerateDailyPlanWithGpt.mock.calls.length).toBe(1);
    expect(env.__puts.length).toBe(1);
  });

  it('returns fallback payload when OpenAI service fails', async () => {
    mockedGenerateDailyPlanWithGpt.mockRejectedValue(new Error('OpenAI down'));

    const env = createEnv();
    const response = await handleGetDailyPlan(
      makeRequest({
        businessCategory: 'food',
        products: [{ name: 'Samosa', stock: 7 }],
      }),
      env,
    );

    const body = await parseJson(response);
    const data = body.data as Record<string, unknown>;

    expect(response.status).toBe(200);
    expect(data.fallback).toBe(true);
    expect(data.title).toBe('Fallback plan');
    expect(env.__puts.length).toBe(1);
  });
});
