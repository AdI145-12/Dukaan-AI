import { checkRateLimit } from '../middleware/rate_limit';
import { createRazorpayOrder } from '../services/razorpay_service';
import { fetchStoreData } from '../services/store_page';
import type { Env } from '../types/env';
import { firestoreCreate } from '../utils/firestore_admin';
import { jsonError, jsonSuccess } from '../utils/response';
import {
	isRecord,
	isSafeSlug,
	isValidIndianPhone,
	isValidUuidLike,
	normalizePhone,
	readOptionalString,
	readPositiveInteger,
	readTrimmedString,
} from '../utils/validators';

interface StoreOrderItemInput {
	productId: string;
	quantity: number;
}

interface StoreOrderCustomerInput {
	name: string;
	phone: string;
	address: string | null;
}

function toPaise(amount: number): number {
	return Math.round((amount + Number.EPSILON) * 100);
}

function toRupees(amountPaise: number): number {
	return Number((amountPaise / 100).toFixed(2));
}

function readItems(value: unknown): StoreOrderItemInput[] {
	if (!Array.isArray(value) || value.length === 0) {
		return [];
	}

	const items: StoreOrderItemInput[] = [];
	for (const entry of value) {
		if (!isRecord(entry)) {
			return [];
		}

		const productId = readTrimmedString(entry.productId);
		const quantity = readPositiveInteger(entry.quantity, { min: 1, max: 50 });
		if (!isValidUuidLike(productId) || quantity < 1) {
			return [];
		}

		items.push({ productId, quantity });
	}

	return items;
}

function readCustomer(value: unknown): StoreOrderCustomerInput | null {
	if (!isRecord(value)) {
		return null;
	}

	const name = readTrimmedString(value.name, { maxLength: 80 });
	const phone = normalizePhone(value.phone);
	const address = readOptionalString(value.address, { maxLength: 300 });
	if (!name || !isValidIndianPhone(phone)) {
		return null;
	}

	return { name, phone, address };
}

export async function handleCreateStoreOrder(
	request: Request,
	env: Env,
): Promise<Response> {
	if (request.method !== 'POST') {
		return jsonError('Method not allowed', 405);
	}

	let body: Record<string, unknown>;
	try {
		const parsed = (await request.json()) as unknown;
		if (!isRecord(parsed)) {
			return jsonError('Invalid JSON body', 400);
		}
		body = parsed;
	} catch {
		return jsonError('Invalid JSON body', 400);
	}

	const storeSlug = readTrimmedString(body.storeSlug, { maxLength: 40 }).toLowerCase();
	const items = readItems(body.items);
	const customer = readCustomer(body.customer);

	if (!isSafeSlug(storeSlug) || items.length === 0 || !customer) {
		return jsonError('Invalid order payload', 400);
	}

	const limited = await checkRateLimit(
		'store-create-order',
		`${storeSlug}:${customer.phone}`,
		20,
		env,
	);
	if (limited) {
		return jsonError('Aaj ke liye checkout limit khatam ho gayi.', 429);
	}

	try {
		const storeData = await fetchStoreData(storeSlug, env);
		if (!storeData) {
			return jsonError('Store not found', 404);
		}

		const productMap = new Map(
			storeData.products.map((product) => [product.id, product] as const),
		);

		let subtotalPaise = 0;
		const lineItems: Array<Record<string, unknown>> = [];
		for (const item of items) {
			const product = productMap.get(item.productId);
			if (!product) {
				return jsonError('One or more products are unavailable.', 400);
			}

			const unitPricePaise = toPaise(product.price);
			const itemSubtotalPaise = unitPricePaise * item.quantity;
			subtotalPaise += itemSubtotalPaise;

			lineItems.push({
				productId: product.id,
				productName: product.name,
				productImageUrl: product.imageUrl ?? null,
				unitPrice: toRupees(unitPricePaise),
				quantity: item.quantity,
				subtotal: toRupees(itemSubtotalPaise),
			});
		}

		if (subtotalPaise <= 0) {
			return jsonError('Invalid order amount', 400);
		}

		const orderSlipId = crypto.randomUUID();
		const transactionId = crypto.randomUUID();
		const createdAt = new Date();
		const slipNumber = `WEB-${createdAt.getFullYear()}-${createdAt.getTime().toString().slice(-6)}`;
		const totalPaise = subtotalPaise;

		await firestoreCreate(
			'orderSlips',
			{
				userId: storeData.shop.userId,
				inquiryId: null,
				slipNumber,
				customerName: customer.name,
				customerPhone: customer.phone,
				customerAddress: customer.address,
				lineItems,
				subtotal: toRupees(subtotalPaise),
				discountAmount: 0,
				deliveryCharge: 0,
				total: toRupees(totalPaise),
				paymentMode: 'pending',
				deliveryNote: null,
				slipImageUrl: null,
				gstEnabled: false,
				source: 'store',
				storeSlug,
				createdAt,
			},
			env,
			orderSlipId,
		);

		const razorpayOrder = await createRazorpayOrder({
			amountPaise: totalPaise,
			receipt: `store-${storeSlug.slice(0, 10)}-${Date.now().toString().slice(-8)}`,
			notes: {
				storeSlug,
				sellerUserId: storeData.shop.userId,
				orderSlipId,
			},
			env,
		});

		await firestoreCreate(
			'transactions',
			{
				userId: storeData.shop.userId,
				orderId: razorpayOrder.id,
				orderSlipId,
				planId: 'store-order',
				amountPaise: totalPaise,
				status: 'pending',
				creditsAdded: 0,
				customerName: customer.name,
				customerPhone: customer.phone,
				storeSlug,
				createdAt,
			},
			env,
			transactionId,
		);

		return jsonSuccess({
			razorpayOrderId: razorpayOrder.id,
			razorpayKeyId: env.RAZORPAY_KEY_ID,
			amountPaise: razorpayOrder.amount,
			currency: razorpayOrder.currency,
			orderSlipId,
			customerName: customer.name,
			customerPhone: customer.phone,
			sellerName: storeData.shop.shopName,
			storeSlug,
		});
	} catch (error) {
		console.error('store-create-order', error);
		return jsonError('Order create nahi hua. Dobara try karein.', 500);
	}
}
