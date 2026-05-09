const CATEGORY_MAP: Record<string, string> = {
  // Clothing variants
  kapde: 'clothing',
  kapda: 'clothing',
  clothes: 'clothing',
  clothing: 'clothing',
  kurta: 'clothing',
  saree: 'clothing',
  sari: 'clothing',
  fashion: 'clothing',
  garments: 'clothing',
  // Food variants
  khaana: 'food',
  khana: 'food',
  food: 'food',
  snacks: 'food',
  namkeen: 'food',
  mithai: 'food',
  sweets: 'food',
  // Electronics
  electronics: 'electronics',
  mobile: 'electronics',
  gadgets: 'electronics',
  // Kirana / Grocery
  kirana: 'grocery',
  grocery: 'grocery',
  'general store': 'grocery',
  ration: 'grocery',
  // Beauty
  beauty: 'beauty',
  cosmetics: 'beauty',
  makeup: 'beauty',
  skincare: 'beauty',
  // Jewellery
  jewellery: 'jewellery',
  jewelry: 'jewellery',
  zever: 'jewellery',
  zewar: 'jewellery',
  // Home / Furniture
  home: 'home_decor',
  furniture: 'home_decor',
  'ghar ka samaan': 'home_decor',
};

export function normalizeCategory(raw: string): string {
  const key = raw.trim().toLowerCase();
  return CATEGORY_MAP[key] ?? key;
}
