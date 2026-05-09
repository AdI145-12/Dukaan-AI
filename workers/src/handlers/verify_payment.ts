import { firestoreAdd, getAccessToken } from '../lib/firebase-admin';
import { extractAndVerifyToken } from '../middleware/auth';
import type { Env } from '../types/env';
import { jsonError, jsonSuccess } from '../utils/response';

interface VerifyPaymentBody {
	razorpayPaymentId?: string;
	razorpayOrderId?: string;
	razorpaySignature?: string;
	userId?: string;
	planId?: string;
}

/**
 * Verifies Razorpay signature server-side and applies tier/credits update.
 */
export async function handleVerifyPayment(
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

	let body: VerifyPaymentBody;
	try {
		body = (await request.json()) as VerifyPaymentBody;
	} catch (_) {
		return jsonError('Invalid JSON body', 400);
	}

	const razorpayPaymentId = body.razorpayPaymentId?.trim() ?? '';
	const razorpayOrderId = body.razorpayOrderId?.trim() ?? '';
	const razorpaySignature = body.razorpaySignature?.trim() ?? '';
	const userId = body.userId?.trim() ?? '';
	const planId = body.planId?.trim() ?? '';

	if (
		!razorpayPaymentId ||
		!razorpayOrderId ||
		!razorpaySignature ||
		!userId ||
		!planId
	) {
		return jsonError('Missing required fields', 400);
	}

	if (authUserId != userId) {
		return jsonError('Unauthorized', 401);
	}

	const isValidSignature = await _verifyRazorpaySignature(
		{
			orderId: razorpayOrderId,
			paymentId: razorpayPaymentId,
			receivedSignature: razorpaySignature,
			secret: env.RAZORPAY_SECRET,
		},
	);

	if (!isValidSignature) {
		console.error('[verify-payment] signature mismatch');
		return jsonError('Payment verify nahi hua.', 400);
	}

	const creditMap: Record<string, number> = {
		free: 3,
		dukaan: 30,
		dukaan_monthly: 30,
		vyapaar: 100,
		vyapaar_monthly: 100,
		utsav: 500,
		utsav_monthly: 500,
		starter_pack: 10,
		value_pack: 50,
		festival_pack: 500,
		ad_pack_chhota: 10,
		ad_pack_bada: 25,
		ad_pack_super: 50,
	};

	const creditsAdded = creditMap[planId] ?? 10;
	const isSubscription = [
		'free',
		'dukaan',
		'dukaan_monthly',
		'vyapaar',
		'vyapaar_monthly',
		'utsav',
		'utsav_monthly',
	].includes(planId);
	const resolvedTier = _resolveTier(planId);

	try {
		const accessToken = await getAccessToken({
			projectId: env.FIREBASE_PROJECT_ID,
			clientEmail: env.FIREBASE_CLIENT_EMAIL,
			privateKey: env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
		});

		await _patchUserDocument({
			projectId: env.FIREBASE_PROJECT_ID,
			accessToken,
			userId,
			tierValue: resolvedTier,
			creditsRemaining: creditsAdded,
			isSubscription,
		});

		await firestoreAdd({
			projectId: env.FIREBASE_PROJECT_ID,
			collection: 'transactions',
			accessToken,
			data: {
				userId: { stringValue: userId },
				planId: { stringValue: planId },
				razorpayPaymentId: { stringValue: razorpayPaymentId },
				orderId: { stringValue: razorpayOrderId },
				status: { stringValue: 'success' },
				creditsAdded: { integerValue: String(creditsAdded) },
				verifiedAt: { stringValue: new Date().toISOString() },
			},
		});
	} catch (error) {
		console.error('[verify-payment] firestore update failed:', error);
		return jsonError('Payment verify nahi hua.', 500);
	}

	console.log(
		`[verify-payment] verified: userId=${userId} plan=${planId} credits=${creditsAdded}`,
	);

	return jsonSuccess({
		success: true,
		newTier: isSubscription ? resolvedTier : null,
		creditsAdded,
	});
}

function _resolveTier(planId: string): string {
	switch (planId) {
		case 'dukaan_monthly':
			return 'dukaan';
		case 'vyapaar_monthly':
			return 'vyapaar';
		case 'utsav_monthly':
			return 'utsav';
		default:
			return planId;
	}
}

async function _verifyRazorpaySignature({
	orderId,
	paymentId,
	receivedSignature,
	secret,
}: {
	orderId: string;
	paymentId: string;
	receivedSignature: string;
	secret: string;
}): Promise<boolean> {
	const message = `${orderId}|${paymentId}`;
	const encoder = new TextEncoder();

	const cryptoKey = await crypto.subtle.importKey(
		'raw',
		encoder.encode(secret),
		{ name: 'HMAC', hash: 'SHA-256' },
		false,
		['sign'],
	);

	const signatureBuffer = await crypto.subtle.sign(
		'HMAC',
		cryptoKey,
		encoder.encode(message),
	);

	const expectedSignature = Array.from(new Uint8Array(signatureBuffer))
		.map((value) => value.toString(16).padStart(2, '0'))
		.join('');

	return expectedSignature === receivedSignature;
}

async function _patchUserDocument(opts: {
	projectId: string;
	accessToken: string;
	userId: string;
	tierValue: string;
	creditsRemaining: number;
	isSubscription: boolean;
}): Promise<void> {
	const { projectId, accessToken, userId, tierValue, creditsRemaining, isSubscription } =
		opts;

	const updateMask = isSubscription
		? 'updateMask.fieldPaths=tier&updateMask.fieldPaths=creditsRemaining'
		: 'updateMask.fieldPaths=creditsRemaining';

	const response = await fetch(
		`https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/users/${userId}?${updateMask}`,
		{
			method: 'PATCH',
			headers: {
				Authorization: `Bearer ${accessToken}`,
				'Content-Type': 'application/json',
			},
			body: JSON.stringify({
				fields: {
					...(isSubscription ? { tier: { stringValue: tierValue } } : {}),
					creditsRemaining: { integerValue: String(creditsRemaining) },
				},
			}),
		},
	);

	if (!response.ok) {
		const errorText = await response.text();
		throw new Error(`Firestore user update failed: ${errorText}`);
	}
}
