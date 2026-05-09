/// <reference path="../types/vitest-shim.d.ts" />

import { beforeEach, describe, expect, it, vi } from 'vitest';

import { extractAndVerifyToken } from '../middleware/auth';
import { checkRateLimit } from '../middleware/rate_limit';
import {
  buildSystemPrompt,
  buildUserMessage,
  generateCaptionWithGpt,
} from '../services/openai';
import type { Env } from '../types/env';
import { handleGenerateCaption } from './generate_caption';

vi.mock('../middleware/auth', () => ({
  extractAndVerifyToken: vi.fn(),
}));

vi.mock('../middleware/rate_limit', () => ({
  checkRateLimit: vi.fn(),
}));

vi.mock('../services/openai', async () => {
  const actual = await (vi as unknown as { importActual: (path: string) => Promise<unknown> }).importActual(
    '../services/openai',
  );

  return {
    ...(actual as Record<string, unknown>),
    generateCaptionWithGpt: vi.fn(),
  };
});

type MockedFunction = {
  mockResolvedValue(value: unknown): void;
  mockRejectedValue(value: unknown): void;
  mockClear(): void;
  mock: {
    calls: unknown[][];
  };
};

const mockedExtractAndVerifyToken =
  extractAndVerifyToken as unknown as MockedFunction;
const mockedCheckRateLimit = checkRateLimit as unknown as MockedFunction;
const mockedGenerateCaptionWithGpt =
  generateCaptionWithGpt as unknown as MockedFunction;

function createEnv(cachedValue: string | null = null): Env {
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
      put: async () => {},
    },
  };
}

async function parseJson(response: Response): Promise<Record<string, unknown>> {
  return (await response.json()) as Record<string, unknown>;
}

function makeRequest(body: Record<string, unknown>, includeAuth = true): Request {
  return new Request('https://example.com/api/generate-caption', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...(includeAuth ? { Authorization: 'Bearer token' } : {}),
    },
    body: JSON.stringify(body),
  });
}

describe('handleGenerateCaption', () => {
  beforeEach(() => {
    vi.resetAllMocks();
    mockedExtractAndVerifyToken.mockResolvedValue('user-1');
    mockedCheckRateLimit.mockResolvedValue(false);
    mockedGenerateCaptionWithGpt.mockResolvedValue({
      caption: 'Default caption',
      hashtags: ['offer', 'shop', 'india', 'sale', 'deal'],
    });
    mockedGenerateCaptionWithGpt.mockClear();
  });

  it('returns 401 when Authorization header is missing', async () => {
    mockedExtractAndVerifyToken.mockResolvedValue(null);

    const request = makeRequest({ category: 'general' }, false);

    const response = await handleGenerateCaption(request, createEnv());
    const body = await parseJson(response);

    expect(response.status).toBe(401);
    expect(body.error).toBeTruthy();
  });

  it('returns 401 when extractAndVerifyToken returns null', async () => {
    mockedExtractAndVerifyToken.mockResolvedValue(null);

    const response = await handleGenerateCaption(
      makeRequest({ category: 'general' }),
      createEnv(),
    );

    expect(response.status).toBe(401);
  });

  it('returns 429 when rate limit exceeded', async () => {
    mockedCheckRateLimit.mockResolvedValue(true);

    const response = await handleGenerateCaption(
      makeRequest({ category: 'general' }),
      createEnv(),
    );
    const body = await parseJson(response);

    expect(response.status).toBe(429);
    expect(String(body.error)).toContain('limit');
  });

  it('returns cached result without calling OpenAI', async () => {
    const cached = JSON.stringify({
      caption: 'Cached caption',
      hashtags: ['a', 'b', 'c', 'd', 'e'],
      language: 'hinglish',
    });

    const response = await handleGenerateCaption(
      makeRequest({ category: 'general' }),
      createEnv(cached),
    );
    const body = await parseJson(response);
    const data = body.data as Record<string, unknown>;

    expect(response.status).toBe(200);
    expect(data.cached).toBe(true);
    expect(mockedGenerateCaptionWithGpt.mock.calls.length).toBe(0);
  });

  it('returns 200 with caption, hashtags, language on success', async () => {
    mockedGenerateCaptionWithGpt.mockResolvedValue({
      caption: 'Diwali offer!',
      hashtags: ['diwali', 'offer', 'sale', 'shopping', 'india'],
    });

    const response = await handleGenerateCaption(
      makeRequest({ language: 'hinglish', category: 'general' }),
      createEnv(),
    );
    const body = await parseJson(response);
    const data = body.data as Record<string, unknown>;
    const hashtags = ((data.hashtags as unknown[]) ?? []);

    expect(response.status).toBe(200);
    expect(data.caption).toBe('Diwali offer!');
    expect(hashtags.length).toBe(5);
    expect(data.language).toBe('hinglish');
  });

  it('falls back to general category for unknown category value', async () => {
    await handleGenerateCaption(
      makeRequest({ category: 'spaceship', language: 'hinglish' }),
      createEnv(),
    );

    const firstCall = mockedGenerateCaptionWithGpt.mock.calls[0] ?? [];
    expect(firstCall[1]).toBe('general');
  });

  it('falls back to hinglish language for unknown language value', async () => {
    await handleGenerateCaption(
      makeRequest({ category: 'general', language: 'klingon' }),
      createEnv(),
    );

    const firstCall = mockedGenerateCaptionWithGpt.mock.calls[0] ?? [];
    expect(firstCall[2]).toBe('hinglish');
  });

  it('returns 500 when OpenAI throws an error', async () => {
    mockedGenerateCaptionWithGpt.mockRejectedValue(new Error('OpenAI down'));

    const response = await handleGenerateCaption(
      makeRequest({ category: 'general' }),
      createEnv(),
    );
    const body = await parseJson(response);

    expect(response.status).toBe(500);
    expect(String(body.error)).toContain('generate');
  });
});

describe('openai helpers', () => {
  it('buildSystemPrompt includes language description for hinglish', () => {
    const prompt = buildSystemPrompt('hinglish');
    expect(prompt).toContain('Roman/English script');
  });

  it('buildUserMessage includes offer text when offer provided', () => {
    const message = buildUserMessage('Saree', 'clothing', 'FLAT 40% off');
    expect(message).toContain('40%');
  });

  it('buildUserMessage omits offer clause when offer is undefined', () => {
    const message = buildUserMessage('Saree', 'clothing', undefined);
    expect(message.includes('Highlight')).toBe(false);
  });
});