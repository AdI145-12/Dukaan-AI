import type { Env } from '../types/env';

interface OpenRouterResponse {
	choices?: Array<{
		message?: {
			content?: string;
		};
	}>;
}

function fallbackCopy(input: {
	language: 'hinglish' | 'english';
	shopName: string;
	productSummary: string;
}): string {
	const shopName = input.shopName.trim() || 'aapki dukaan';
	const productSummary = input.productSummary.trim();

	if (input.language === 'english') {
		return productSummary
			? `Thank you! Your order for ${productSummary} has been placed with ${shopName}. We will confirm it on WhatsApp soon.`
			: `Thank you! Your order has been placed with ${shopName}. We will confirm it on WhatsApp soon.`;
	}

	return productSummary
		? `Shukriya! Aapka ${productSummary} ka order ${shopName} pe place ho gaya. Hum jaldi aapko WhatsApp pe confirm karenge.`
		: `Shukriya! Aapka order ${shopName} pe place ho gaya. Hum jaldi aapko WhatsApp pe confirm karenge.`;
}

export async function generateOrderConfirmationCopy(
	input: {
		language: 'hinglish' | 'english';
		shopName: string;
		productSummary: string;
	},
	env: Env,
): Promise<string> {
	const apiKey = env.OPENROUTER_API_KEY?.trim();
	const model = env.OPENROUTER_MODEL?.trim() || 'meta-llama/3.1-8b-instruct:free';
	if (!apiKey) {
		return fallbackCopy(input);
	}

	try {
		const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
			method: 'POST',
			headers: {
				Authorization: `Bearer ${apiKey}`,
				'Content-Type': 'application/json',
			},
			body: JSON.stringify({
				model,
				messages: [
					{
						role: 'system',
						content:
							'Write one short order confirmation line for an Indian small business storefront. Keep it warm, simple, and natural. No markdown, no emojis, no hashtags.',
					},
					{
						role: 'user',
						content: `Language: ${input.language}\nShop: ${input.shopName}\nProducts: ${input.productSummary}\nGoal: mention the order is placed and WhatsApp confirmation will come soon.`,
					},
				],
				temperature: 0.6,
				max_tokens: 80,
			}),
		});

		if (!response.ok) {
			return fallbackCopy(input);
		}

		const data = (await response.json()) as OpenRouterResponse;
		const content = data.choices?.[0]?.message?.content?.trim() ?? '';
		return content || fallbackCopy(input);
	} catch {
		return fallbackCopy(input);
	}
}
