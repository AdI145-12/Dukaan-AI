import type { Env } from '../types/env';
import { verifyHmacSha256Hex } from '../utils/crypto';

export interface RazorpayOrder {
	id: string;
	amount: number;
	currency: string;
	status?: string;
}

export interface RazorpayPayment {
	id: string;
	order_id?: string;
	status?: string;
	captured?: boolean;
	amount?: number;
	currency?: string;
	method?: string;
}

function basicAuth(env: Env): string {
	return btoa(`${env.RAZORPAY_KEY_ID}:${env.RAZORPAY_SECRET}`);
}

export async function createRazorpayOrder(input: {
	amountPaise: number;
	receipt: string;
	notes?: Record<string, string>;
	env: Env;
}): Promise<RazorpayOrder> {
	const response = await fetch('https://api.razorpay.com/v1/orders', {
		method: 'POST',
		headers: {
			Authorization: `Basic ${basicAuth(input.env)}`,
			'Content-Type': 'application/json',
		},
		body: JSON.stringify({
			amount: input.amountPaise,
			currency: 'INR',
			receipt: input.receipt,
			notes: input.notes ?? {},
		}),
	});

	if (!response.ok) {
		const errorText = await response.text();
		throw new Error(`Razorpay order create failed: ${errorText}`);
	}

	const payload = (await response.json()) as Partial<RazorpayOrder>;
	if (!payload.id || typeof payload.amount !== 'number') {
		throw new Error('Razorpay order create failed: malformed response');
	}

	return {
		id: payload.id,
		amount: payload.amount,
		currency: payload.currency ?? 'INR',
		status: payload.status,
	};
}

export async function fetchRazorpayPayment(
	paymentId: string,
	env: Env,
): Promise<RazorpayPayment> {
	const response = await fetch(
		`https://api.razorpay.com/v1/payments/${encodeURIComponent(paymentId)}`,
		{
			headers: {
				Authorization: `Basic ${basicAuth(env)}`,
			},
		},
	);

	if (!response.ok) {
		const errorText = await response.text();
		throw new Error(`Razorpay payment fetch failed: ${errorText}`);
	}

	return (await response.json()) as RazorpayPayment;
}

export async function verifyRazorpaySignature(input: {
	orderId: string;
	paymentId: string;
	signature: string;
	env: Env;
}): Promise<boolean> {
	return verifyHmacSha256Hex({
		message: `${input.orderId}|${input.paymentId}`,
		secret: input.env.RAZORPAY_SECRET,
		expectedHex: input.signature,
	});
}
