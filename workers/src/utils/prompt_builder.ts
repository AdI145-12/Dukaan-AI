const STYLE_PROMPTS: Record<string, string> = {
  white:
    'pure white studio background, seamless, professional product photography, soft shadows, high detail',
  gradient_orange:
    'warm saffron orange gradient background, product photography, Indian festive aesthetic, soft ambient light',
  diwali:
    'festive Diwali setting, golden diyas, fairy lights, marigold flowers, warm golden hour lighting, photorealistic product photography',
  holi:
    'vibrant Holi celebration background, colorful powder dust, cheerful Indian festival aesthetic, photorealistic',
  independence_day:
    'Indian Independence Day theme, tricolor saffron white green, patriotic bokeh, clean professional backdrop',
  wooden:
    'natural wooden texture background, rustic Indian craftsmanship aesthetic, warm tones, product photography',
  bokeh:
    'soft bokeh out-of-focus background, shallow depth of field, studio lighting, professional product photography',
  studio:
    'modern neon-lit dark studio backdrop, blue purple ambient lighting, minimal dark background, premium product photography',
  bazaar:
    'lush Indian bazaar market background, morning sunlight, green foliage, colorful stalls, photorealistic',
  festive_red:
    'rich festive red background, golden decorative elements, Indian celebration aesthetic, luxurious product display',
};

const DEFAULT_PROMPT =
  'high quality product photography background, Indian aesthetic, clean professional backdrop, soft studio lighting';

export function buildStylePrompt(style: string, customPrompt?: string): string {
  const base = STYLE_PROMPTS[style] ?? DEFAULT_PROMPT;

  if (customPrompt && customPrompt.trim().length > 0) {
    return `${base}, ${customPrompt.trim()}`;
  }

  return base;
}
