import {
	firestoreAdd,
	firestoreQuery,
	getAccessToken,
	getStringField,
	type FirestoreDocument,
} from '../lib/firebase-admin';
import {
	getFestivalsForDate,
	type Festival,
	type FestivalWithReminder,
} from '../lib/festival-calendar';
import type { Env } from '../types/env';

const USERS_COLLECTION = 'users';
const USAGE_EVENTS_COLLECTION = 'usageEvents';
const BATCH_SIZE = 100;

type FcmSendResult = 'sent' | 'stale-token';

/**
 * Sends festival notifications for the current UTC date.
 */
export async function sendFestivalNotifications(env: Env): Promise<void> {
	const today = new Date().toISOString().split('T')[0] ?? '';
	const festivals = getFestivalsForDate(today);

	if (festivals.length === 0) {
		console.log(`[festival-cron] ${today}: no festivals today, skipping`);
		return;
	}

	console.log(
		`[festival-cron] ${today}: festivals = ${festivals.map((item) => item.name).join(', ')}`,
	);

	const serviceAccount = {
		projectId: env.FIREBASE_PROJECT_ID,
		clientEmail: env.FIREBASE_CLIENT_EMAIL,
		privateKey: env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
	};

	const accessToken = await getAccessToken(serviceAccount);
	const users = await getAllUsersWithPagination(serviceAccount.projectId, accessToken);
  console.log(`[festival-cron] fetched ${users.length} users`);

	for (const festival of festivals) {
		const notificationCopy = buildNotificationCopy(festival);
		const eligibleUsers = filterUsersForFestival(users, festival);

		console.log(
			`[festival-cron] ${festival.name}: ${eligibleUsers.length} eligible users`,
		);

		let sent = 0;
		let failed = 0;

		for (let index = 0; index < eligibleUsers.length; index += BATCH_SIZE) {
			const batch = eligibleUsers.slice(index, index + BATCH_SIZE);

			const results = await Promise.allSettled(
				batch.map((user) => {
					const fcmToken = getStringField(user, 'fcmToken') ?? '';
					return sendFcmMessage({
						accessToken,
						projectId: serviceAccount.projectId,
						fcmToken,
						title: notificationCopy.title,
						body: notificationCopy.body,
						data: {
							screen: 'studio',
							festival: festival.name,
							deeplink:
								`dukaanai://studio/festival?name=${encodeURIComponent(festival.name)}`,
						},
					});
				}),
			);

			for (const result of results) {
				if (result.status === 'fulfilled' && result.value === 'sent') {
					sent += 1;
					continue;
				}

				failed += 1;
				if (result.status === 'rejected') {
					console.error('[festival-cron] FCM error:', result.reason);
				}
			}
		}

		await firestoreAdd({
			projectId: serviceAccount.projectId,
			collection: USAGE_EVENTS_COLLECTION,
			accessToken,
			data: {
				eventType: { stringValue: 'festival_notification_sent' },
				festival: { stringValue: festival.name },
				date: { stringValue: today },
				isReminder: { booleanValue: festival.isReminder },
				sent: { integerValue: String(sent) },
				failed: { integerValue: String(failed) },
				total: { integerValue: String(eligibleUsers.length) },
				createdAt: { stringValue: new Date().toISOString() },
			},
		});

		console.log(`[festival-cron] ${festival.name}: sent=${sent}, failed=${failed}`);
	}
}

async function getAllUsersWithPagination(
	projectId: string,
	accessToken: string,
): Promise<FirestoreDocument[]> {
	const users: FirestoreDocument[] = [];
	let pageToken: string | undefined;

	do {
		const page = await firestoreQuery({
			projectId,
			collection: USERS_COLLECTION,
			accessToken,
			pageSize: 500,
			pageToken,
		});

		users.push(...page.documents);
		pageToken = page.nextPageToken;
	} while (pageToken);

	return users;
}

export function buildNotificationCopy(festival: FestivalWithReminder): {
	title: string;
	body: string;
} {
	if (festival.isReminder) {
		return {
			title: `${festival.emoji} ${festival.name} 2 din baad hai!`,
			body: 'Abhi se ad banao. Competitors se pehle apne customers tak pahuncho!',
		};
	}

	return {
		title: `${festival.emoji} Aaj hai ${festival.name}!`,
		body: 'Aapke competitors ad post kar rahe hain. 30 seconds mein festive ad banao!',
	};
}

export function filterUsersForFestival(
	users: FirestoreDocument[],
	festival: Festival,
): FirestoreDocument[] {
	return users.filter((user) => {
		const fcmToken = getStringField(user, 'fcmToken');
		if (!fcmToken) {
			return false;
		}

		const tier = getStringField(user, 'tier') ?? 'free';
		if (tier === 'churned') {
			return false;
		}

		if (festival.targetCategories.length === 0) {
			return true;
		}

		const category = getStringField(user, 'category') ?? '';
		return festival.targetCategories.includes(category);
	});
}

async function sendFcmMessage(opts: {
	accessToken: string;
	projectId: string;
	fcmToken: string;
	title: string;
	body: string;
	data: Record<string, string>;
}): Promise<FcmSendResult> {
	const { accessToken, projectId, fcmToken, title, body, data } = opts;

	const response = await fetch(
		`https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
		{
			method: 'POST',
			headers: {
				Authorization: `Bearer ${accessToken}`,
				'Content-Type': 'application/json',
			},
			body: JSON.stringify({
				message: {
					token: fcmToken,
					notification: { title, body },
					data,
					android: {
						priority: 'high',
						notification: {
							channel_id: 'festival_alerts',
							click_action: 'FLUTTER_NOTIFICATION_CLICK',
							icon: 'ic_notification',
							color: '#FF6F00',
						},
					},
				},
			}),
		},
	);

	if (!response.ok) {
		const errorText = await response.text();
		if (
			errorText.includes('UNREGISTERED') ||
			errorText.includes('NOT_FOUND')
		) {
			console.warn(
				`[festival-cron] stale token removed: ${fcmToken.substring(0, 20)}...`,
			);
			return 'stale-token';
		}

		throw new Error(`FCM send failed: ${errorText}`);
	}

	return 'sent';
}