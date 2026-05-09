/// <reference path="../types/vitest-shim.d.ts" />

import { describe, expect, it } from 'vitest';

import { normalizeCategory } from './category_normalizer';

describe('normalizeCategory', () => {
  it('normalizes common Hinglish and English variants', () => {
    expect(normalizeCategory('kapde')).toBe('clothing');
    expect(normalizeCategory('Clothes')).toBe('clothing');
    expect(normalizeCategory('CLOTHING')).toBe('clothing');
    expect(normalizeCategory('kurta')).toBe('clothing');
    expect(normalizeCategory('mithai')).toBe('food');
    expect(normalizeCategory('electronics')).toBe('electronics');
    expect(normalizeCategory('kirana')).toBe('grocery');
    expect(normalizeCategory('general store')).toBe('grocery');
    expect(normalizeCategory('cosmetics')).toBe('beauty');
    expect(normalizeCategory('jewelry')).toBe('jewellery');
    expect(normalizeCategory('ghar ka samaan')).toBe('home_decor');
  });

  it('returns trimmed lowercase fallback for unknown categories', () => {
    expect(normalizeCategory('  Fancy Items  ')).toBe('fancy items');
    expect(normalizeCategory('')).toBe('');
  });
});
