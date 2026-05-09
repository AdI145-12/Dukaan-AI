import type {
  DailyPlanProductInput,
  DailyPlanRequest,
  DailyPlanResponse,
} from '../types/catalogue';
import type { Env } from '../types/env';

interface OpenAiChatResponse {
  choices?: Array<{
    message?: {
      content?: string;
    };
  }>;
}

function buildSystemPrompt(): string {
  return (
    'You are a social media planner for Indian small businesses. ' +
    'Generate one practical daily posting plan in Hinglish. ' +
    'Return ONLY valid JSON with keys: ' +
    '"title", "reason", "captionIdea", "callToAction", ' +
    '"suggestedProductName", "suggestedProductImageUrl", "festivalTag". ' +
    'Keep title under 80 chars and captionIdea under 180 chars.'
  );
}

function buildUserMessage(input: DailyPlanRequest): string {
  const productLines = input.products
    .slice(0, 6)
    .map((product, index) => {
      const stockText =
        typeof product.stock === 'number' ? `, stock=${product.stock}` : '';
      const categoryText = product.category ? `, category=${product.category}` : '';
      return `${index + 1}. ${product.name}${categoryText}${stockText}`;
    })
    .join('\n');

  return [
    `Date: ${input.date}`,
    `Business category: ${input.businessCategory || 'general'}`,
    `Festival today: ${input.festival || 'none'}`,
    `In-stock products:`,
    productLines || 'none',
    '',
    'Give one strong post idea for today.',
  ].join('\n');
}

function cleanText(raw: unknown, fallback: string, maxLength: number): string {
  if (typeof raw !== 'string') {
    return fallback;
  }

  const value = raw.trim();
  if (!value) {
    return fallback;
  }

  return value.slice(0, maxLength);
}

function pickPrimaryProduct(
  products: DailyPlanProductInput[],
): DailyPlanProductInput | null {
  const inStock = products.find(
    (product) =>
      typeof product.name === 'string' &&
      product.name.trim().length > 0 &&
      (product.stock == null || product.stock > 0),
  );

  if (inStock) {
    return inStock;
  }

  const first = products.find(
    (product) => typeof product.name === 'string' && product.name.trim().length > 0,
  );

  return first ?? null;
}

export function buildFallbackDailyPlan(input: DailyPlanRequest): DailyPlanResponse {
  const product = pickPrimaryProduct(input.products);
  const festival = (input.festival ?? '').trim();

  if (festival) {
    return {
      title: `${festival} ke liye aaj ka post`,
      reason: 'Festival ke din customer attention high hota hai.',
      captionIdea: product
        ? `${product.name} ko festive angle ke saath highlight karo. Offer + urgency add karo.`
        : 'Festival special offer ko simple image aur clear CTA ke saath post karo.',
      callToAction: 'Aaj ka festive ad banao',
      suggestedProductName: product?.name,
      suggestedProductImageUrl: product?.imageUrl,
      festivalTag: festival,
    };
  }

  if (product) {
    return {
      title: `Aaj ${product.name} ko feature karo`,
      reason: 'Roz ek focused product post karne se response better aata hai.',
      captionIdea:
        `${product.name} ke 2 clear benefits likho, price mention karo, aur WhatsApp inquiry CTA do.`,
      callToAction: 'Is product ka ad banao',
      suggestedProductName: product.name,
      suggestedProductImageUrl: product.imageUrl,
      festivalTag: undefined,
    };
  }

  const category = input.businessCategory.trim() || 'business';
  return {
    title: 'Aaj ka simple content plan',
    reason: 'Consistent posting se trust aur repeat buyers dono badhte hain.',
    captionIdea:
      `${category} category ka best-selling item choose karo, price + limited stock angle ke saath post karo.`,
    callToAction: 'Aaj ka ad banao',
    suggestedProductName: undefined,
    suggestedProductImageUrl: undefined,
    festivalTag: undefined,
  };
}

function normalizePlan(
  candidate: Partial<DailyPlanResponse>,
  fallback: DailyPlanResponse,
): DailyPlanResponse {
  const title = cleanText(candidate.title, fallback.title, 80);
  const reason = cleanText(candidate.reason, fallback.reason, 180);
  const captionIdea = cleanText(candidate.captionIdea, fallback.captionIdea, 180);
  const callToAction = cleanText(candidate.callToAction, fallback.callToAction, 50);

  const suggestedProductName =
    typeof candidate.suggestedProductName === 'string' &&
    candidate.suggestedProductName.trim().length > 0
      ? candidate.suggestedProductName.trim().slice(0, 80)
      : fallback.suggestedProductName;

  const suggestedProductImageUrl =
    typeof candidate.suggestedProductImageUrl === 'string' &&
    candidate.suggestedProductImageUrl.trim().length > 0
      ? candidate.suggestedProductImageUrl.trim()
      : fallback.suggestedProductImageUrl;

  const festivalTag =
    typeof candidate.festivalTag === 'string' && candidate.festivalTag.trim().length > 0
      ? candidate.festivalTag.trim().slice(0, 60)
      : fallback.festivalTag;

  return {
    title,
    reason,
    captionIdea,
    callToAction,
    suggestedProductName,
    suggestedProductImageUrl,
    festivalTag,
  };
}

export async function generateDailyPlanWithGpt(
  input: DailyPlanRequest,
  env: Pick<Env, 'OPENAIAPIKEY'>,
): Promise<DailyPlanResponse> {
  const response = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${env.OPENAIAPIKEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: 'gpt-4o-mini',
      messages: [
        { role: 'system', content: buildSystemPrompt() },
        { role: 'user', content: buildUserMessage(input) },
      ],
      response_format: { type: 'json_object' },
      max_tokens: 280,
      temperature: 0.6,
    }),
  });

  if (!response.ok) {
    const errText = await response.text();
    throw new Error(`OpenAI API error: ${response.status} - ${errText}`);
  }

  const data = (await response.json()) as OpenAiChatResponse;
  const content = data.choices?.[0]?.message?.content;
  if (!content) {
    throw new Error('OpenAI returned empty response');
  }

  let parsed: Partial<DailyPlanResponse>;
  try {
    parsed = JSON.parse(content) as Partial<DailyPlanResponse>;
  } catch {
    throw new Error(`OpenAI returned non-JSON content: ${content.slice(0, 120)}`);
  }

  const fallback = buildFallbackDailyPlan(input);
  return normalizePlan(parsed, fallback);
}
