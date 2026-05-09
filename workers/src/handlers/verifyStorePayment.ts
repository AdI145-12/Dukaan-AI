import {
	fetchRazorpayPayment,
	verifyRazorpaySignature,
} from '../services/razorpay_service';
import type { Env } from '../types/env';
import {
	firestoreCreate,
	firestorePatch,
	firestoreQuery,
	strVal,
	type FirestoreFilter,
} from '../utils/firestore_admin';
import { jsonError, jsonSuccess } from '../utils/response';
import { isRecord, readTrimmedString } from '../utils/validators';

interface VerifyBody {
	razorpayOrderId: string;
	razorpayPaymentId: string;
	razorpaySignature: string;
}

function readBody(value: unknown): VerifyBody | null {
	if (!isRecord(value)) {
		return null;
	}

	const razorpayOrderId = readTrimmedString(value.razorpayOrderId, { maxLength: 80 });
	const razorpayPaymentId = readTrimmedString(value.razorpayPaymentId, { maxLength: 80 });
	const razorpaySignature = readTrimmedString(value.razorpaySignature, {
		maxLength: 200,
	});

	if (!razorpayOrderId || !razorpayPaymentId || !razorpaySignature) {
		return null;
	}

	return { razorpayOrderId, razorpayPaymentId, razorpaySignature };
}

async function findStoreTransaction(
	orderId: string,
	env: Env,
) {
	const filters: FirestoreFilter[] = [
		{
			field: { fieldPath: 'orderId' },
			op: 'EQUAL',
			value: { stringValue: orderId },
		},
		{
			field: { fieldPath: 'planId' },
			op: 'EQUAL',
			value: { stringValue: 'store-order' },
		},
	];

	const results = await firestoreQuery('transactions', filters, 1, env);
	return results[0] ?? null;
}

export async function handleVerifyStorePayment(
	request: Request,
	env: Env,
): Promise<Response> {
	if (request.method !== 'POST') {
		return jsonError('Method not allowed', 405);
	}

	let body: VerifyBody | null = null;
	try {
		body = readBody((await request.json()) as unknown);
	} catch {
		return jsonError('Invalid JSON body', 400);
	}

	if (!body) {
		return jsonError('Invalid payment payload', 400);
	}

	try {
		const transaction = await findStoreTransaction(body.razorpayOrderId, env);
		if (!transaction) {
			return jsonError('Store transaction not found', 404);
		}

		const transactionDocPath = `transactions/${transaction.id}`;
		const orderSlipId = strVal(transaction.fields, 'orderSlipId') ?? '';
		if (!orderSlipId) {
			return jsonError('Order slip not found', 404);
		}

		const signatureValid = await verifyRazorpaySignature({
			orderId: body.razorpayOrderId,
			paymentId: body.razorpayPaymentId,
			signature: body.razorpaySignature,
			env,
		});

		if (!signatureValid) {
			await firestorePatch(
				transactionDocPath,
				{
					status: 'failed',
					failedAt: new Date(),
				},
				env,
			);
			return jsonError('Payment verification failed', 400);
		}

		const payment = await fetchRazorpayPayment(body.razorpayPaymentId, env);
		const captured =
			payment.order_id === body.razorpayOrderId &&
			(payment.status === 'captured' || payment.captured === true);

		if (!captured) {
			await firestorePatch(
				transactionDocPath,
				{
					status: 'failed',
					failedAt: new Date(),
					razorpayPaymentId: body.razorpayPaymentId,
				},
				env,
			);
			return jsonError('Payment verification failed', 400);
		}

		await firestorePatch(
			transactionDocPath,
			{
				status: 'success',
				verifiedAt: new Date(),
				razorpayPaymentId: body.razorpayPaymentId,
				paymentMethod: payment.method ?? 'online',
			},
			env,
		);

		await firestorePatch(
			`orderSlips/${orderSlipId}`,
			{
				paymentMode: 'upi',
				updatedAt: new Date(),
			},
			env,
		);

		await firestoreCreate(
			'usageEvents',
			{
				userId: strVal(transaction.fields, 'userId') ?? '',
				eventType: 'storeOrderCreated',
				orderSlipId,
				storeSlug: strVal(transaction.fields, 'storeSlug') ?? '',
				createdAt: new Date(),
			},
			env,
		);

		return jsonSuccess({
			status: 'success',
			orderSlipId,
		});
	} catch (error) {
		console.error('store-verify-payment', error);
		return jsonError('Payment verification failed', 500);
	}
}
