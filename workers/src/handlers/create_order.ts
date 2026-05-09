import { firestoreAdd, getAccessToken } from '../lib/firebase-admin';
import { extractAndVerifyToken } from '../middleware/auth';
import type { Env } from '../types/env';
import { jsonError, jsonSuccess } from '../utils/response';

interface CreateOrderBody {
	planId?: string;
	amountPaise?: number;
	userId?: string;
}

interface RazorpayOrderResponse {
	id?: string;
	amount?: number;
	currency?: string;
}

/**
 * Creates a Razorpay order and logs pending transaction metadata in Firestore.
 */
export async function handleCreateOrder(
	request: Request,
	env: Env,
): Promise<Response> {
	if (request.method !== 'POST') {
		return jsonError('Method not allowed', 405);
	}

	const authUserId = await extractAndVerifyToken(request, env);
	if (!authUserId) {
		return jsonError('Unauthorized', 401);
	}

	let body: CreateOrderBody;
	try {
		body = (await request.json()) as CreateOrderBody;
	} catch (_) {
		return jsonError('Invalid JSON body', 400);
	}

	const planId = body.planId?.trim() ?? '';
	const userId = body.userId?.trim() ?? '';
	const amountPaise = body.amountPaise ?? 0;

	if (!planId || !userId || amountPaise <= 0) {
		return jsonError('Missing required fields', 400);
	}

	if (authUserId != userId) {
		return jsonError('Unauthorized', 401);
	}

	const credentials = btoa(`${env.RAZORPAY_KEY_ID}:${env.RAZORPAY_SECRET}`);
	const receipt = `order_${userId.substring(0, 8)}_${Date.now()}`;

	let razorpayOrder: RazorpayOrderResponse;
	try {
		const razorpayResponse = await fetch('https://api.razorpay.com/v1/orders', {
			method: 'POST',
			headers: {
				Authorization: `Basic ${credentials}`,
				'Content-Type': 'application/json',
			},
			body: JSON.stringify({
				amount: amountPaise,
				currency: 'INR',
				receipt,
				notes: { userId, planId },
			}),
		});

		if (!razorpayResponse.ok) {
			const errorText = await razorpayResponse.text();
			console.error('[create-order] Razorpay error:', errorText);
			return jsonError('Order create nahi hua. Dobara try karein.', 502);
		}

		razorpayOrder = (await razorpayResponse.json()) as RazorpayOrderResponse;
	} catch (error) {
		console.error('[create-order] network:', error);
		return jsonError('Order create nahi hua. Dobara try karein.', 502);
	}

	const orderId = razorpayOrder.id ?? '';
	if (!orderId) {
		return jsonError('Order create nahi hua. Dobara try karein.', 502);
	}

	try {
		const accessToken = await getAccessToken({
			projectId: env.FIREBASE_PROJECT_ID,
			clientEmail: env.FIREBASE_CLIENT_EMAIL,
			privateKey: env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
		});

		await firestoreAdd({
			projectId: env.FIREBASE_PROJECT_ID,
			collection: 'transactions',
			accessToken,
			data: {
				userId: { stringValue: userId },
				planId: { stringValue: planId },
				orderId: { stringValue: orderId },
				amountPaise: { integerValue: String(amountPaise) },
				status: { stringValue: 'pending' },
				createdAt: { stringValue: new Date().toISOString() },
			},
		});
	} catch (error) {
		console.error('[create-order] firestore log failed:', error);
	}

	return jsonSuccess({
		orderId,
		amount: razorpayOrder.amount ?? amountPaise,
		currency: razorpayOrder.currency ?? 'INR',
	});
}