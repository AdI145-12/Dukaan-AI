import { handleCreateOrder } from './handlers/create_order';
import { handleCreateStoreOrder } from './handlers/createStoreOrder';
import { handleGenerateOrderConfirmation } from './handlers/generateOrderConfirmation';
import { handleGenerateBg } from './handlers/generate_bg';
import { handleGenerateCaption } from './handlers/generate_caption';
import { handleGetDailyPlan } from './handlers/get-daily-plan';
import { handleGetSellerStore } from './handlers/getSellerStore';
import { handleGetStorePage } from './handlers/get-store-page';
import { handleGenerateProductMetadata } from './handlers/generate_product_metadata';
import { handleRemoveBg } from './handlers/remove_bg';
import { handleSellerStorePage } from './handlers/sellerStorePage';
import { handleSendRestockReminders } from './handlers/send_restock_reminders';
import { sendFestivalNotifications } from './handlers/send-festival-notifications';
import { handleTrackStoreClick } from './handlers/track-store-click';
import { handleVerifyPayment } from './handlers/verify_payment';
import { handleVerifyStorePayment } from './handlers/verifyStorePayment';
import { corsHeaders } from './middleware/cors';
import type { Env } from './types/env';
import { jsonError } from './utils/response';

export default {
	async fetch(request: Request, env: Env): Promise<Response> {
		const url = new URL(request.url);

		if (url.pathname.startsWith('/s/')) {
			return handleSellerStorePage(request, env);
		}

		if (url.pathname.startsWith('/api/get-seller-store/')) {
			return handleGetStorePage(request, env);
		}

		if (url.pathname.startsWith('/api/seller-store/')) {
			return handleGetSellerStore(request, env);
		}

		if (request.method === 'OPTIONS') {
			return new Response(null, { headers: corsHeaders });
		}

		switch (url.pathname) {
			case '/api/generate-background':
				return handleGenerateBg(request, env);
			case '/api/generate-caption':
				return handleGenerateCaption(request, env);
			case '/api/generate-product-metadata':
				return handleGenerateProductMetadata(request, env);
			case '/api/get-daily-plan':
				return handleGetDailyPlan(request, env);
			case '/api/track-store-click':
				return handleTrackStoreClick(request, env);
			case '/api/remove-bg':
				return handleRemoveBg(request, env);
			case '/api/generate-order-confirmation':
				if (request.method === 'POST') {
					return handleGenerateOrderConfirmation(request, env);
				}
				break;
			case '/api/create-order':
				if (request.method === 'POST') {
					return handleCreateOrder(request, env);
				}
				break;
			case '/api/verify-payment':
				if (request.method === 'POST') {
					return handleVerifyPayment(request, env);
				}
				break;
			case '/api/store/create-order':
				if (request.method === 'POST') {
					return handleCreateStoreOrder(request, env);
				}
				break;
			case '/api/store/verify-payment':
				if (request.method === 'POST') {
					return handleVerifyStorePayment(request, env);
				}
				break;
			default:
				return jsonError('Not found', 404);
		}

		return jsonError('Method not allowed', 405);
	},

	async scheduled(
		controller: ScheduledController,
		env: Env,
		ctx: ExecutionContext,
	): Promise<void> {
		void controller;
		ctx.waitUntil(
			(async () => {
				await sendFestivalNotifications(env);
				await handleSendRestockReminders(env);
			})(),
		);
	},
};
