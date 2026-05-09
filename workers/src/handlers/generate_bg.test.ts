/// <reference path="../types/vitest-shim.d.ts" />

import { beforeEach, describe, expect, it, vi } from 'vitest';

import { extractAndVerifyToken } from '../middleware/auth';
import { checkRateLimit } from '../middleware/rate_limit';
import { generateWithFluxSchnell } from '../services/replicate';
import type { Env } from '../types/env';
import { buildStylePrompt } from '../utils/prompt_builder';
import { handleGenerateBg } from './generate_bg';

vi.mock('../middleware/auth', () => ({
  extractAndVerifyToken: vi.fn(),
}));

vi.mock('../middleware/rate_limit', () => ({
  checkRateLimit: vi.fn(),
}));

vi.mock('../services/replicate', () => ({
  generateWithFluxSchnell: vi.fn(),
}));

type MockedFunction = {
  mockResolvedValue(value: unknown): void;
  mockRejectedValue(value: unknown): void;
};

const mockedExtractAndVerifyToken =
  extractAndVerifyToken as unknown as MockedFunction;
const mockedCheckRateLimit = checkRateLimit as unknown as MockedFunction;
const mockedGenerateWithFluxSchnell =
  generateWithFluxSchnell as unknown as MockedFunction;

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
    RATE_LIMIT_KV: {
      get: async () => null,
      put: async () => {},
    },
    CACHEKV: {
      get: async () => null,
      put: async () => {},
    },
  };
}

async function parseJson(response: Response): Promise<Record<string, unknown>> {
  return (await response.json()) as Record<string, unknown>;
}

describe('handleGenerateBg', () => {
  beforeEach(() => {
    vi.resetAllMocks();
  });

  it('returns 401 when Authorization header is missing', async () => {
    const request = new Request('https://example.com/api/generate-background', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ style: 'diwali' }),
    });

    const response = await handleGenerateBg(request, createEnv());

    expect(response.status).toBe(401);
  });

  it('returns 401 when extractAndVerifyToken returns null', async () => {
    mockedExtractAndVerifyToken.mockResolvedValue(null);

    const request = new Request('https://example.com/api/generate-background', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: 'Bearer token',
      },
      body: JSON.stringify({ style: 'diwali' }),
    });

    const response = await handleGenerateBg(request, createEnv());

    expect(response.status).toBe(401);
  });

  it('returns 429 when rate limit exceeded', async () => {
    mockedExtractAndVerifyToken.mockResolvedValue('user-1');
    mockedCheckRateLimit.mockResolvedValue(true);

    const request = new Request('https://example.com/api/generate-background', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: 'Bearer token',
      },
      body: JSON.stringify({ style: 'diwali' }),
    });

    const response = await handleGenerateBg(request, createEnv());
    const body = await parseJson(response);

    expect(response.status).toBe(429);
    expect(String(body.error)).toContain('limit');
  });

  it('returns 400 when style is missing from body', async () => {
    mockedExtractAndVerifyToken.mockResolvedValue('user-1');
    mockedCheckRateLimit.mockResolvedValue(false);

    const request = new Request('https://example.com/api/generate-background', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: 'Bearer token',
      },
      body: JSON.stringify({}),
    });

    const response = await handleGenerateBg(request, createEnv());

    expect(response.status).toBe(400);
  });

  it('returns 400 when customPrompt exceeds 200 characters', async () => {
    mockedExtractAndVerifyToken.mockResolvedValue('user-1');
    mockedCheckRateLimit.mockResolvedValue(false);

    const request = new Request('https://example.com/api/generate-background', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: 'Bearer token',
      },
      body: JSON.stringify({
        style: 'diwali',
        customPrompt: 'a'.repeat(201),
      }),
    });

    const response = await handleGenerateBg(request, createEnv());

    expect(response.status).toBe(400);
  });

  it('returns 200 with resultUrl and styleUsed on success', async () => {
    mockedExtractAndVerifyToken.mockResolvedValue('user-1');
    mockedCheckRateLimit.mockResolvedValue(false);
    mockedGenerateWithFluxSchnell.mockResolvedValue(
      'https://replicate.delivery/generated.jpg',
    );

    const request = new Request('https://example.com/api/generate-background', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: 'Bearer token',
      },
      body: JSON.stringify({ style: 'diwali' }),
    });

    const response = await handleGenerateBg(request, createEnv());
    const body = await parseJson(response);
    const data = body.data as Record<string, unknown>;

    expect(response.status).toBe(200);
    expect(data.resultUrl).toBeTruthy();
    expect(data.styleUsed).toBe('diwali');
  });

  it('returns 500 when Replicate throws an error', async () => {
    mockedExtractAndVerifyToken.mockResolvedValue('user-1');
    mockedCheckRateLimit.mockResolvedValue(false);
    mockedGenerateWithFluxSchnell.mockRejectedValue(new Error('replicate error'));

    const request = new Request('https://example.com/api/generate-background', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: 'Bearer token',
      },
      body: JSON.stringify({ style: 'diwali' }),
    });

    const response = await handleGenerateBg(request, createEnv());
    const body = await parseJson(response);

    expect(response.status).toBe(500);
    expect(String(body.error)).toContain('gadbad');
  });
});

describe('buildStylePrompt', () => {
  it('includes custom prompt when provided', () => {
    const prompt = buildStylePrompt('diwali', 'add sparkles');
    expect(prompt).toContain('sparkles');
  });
});
