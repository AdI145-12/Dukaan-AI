import {
  getAccessToken,
  getStringField,
  type FirestoreDocument,
} from '../lib/firebase-admin';
import type { Env } from '../types/env';

const DAYS_OUT_OF_STOCK = 7;

type QueryRow = {
  document?: FirestoreDocument;
};

type RestockCandidate = {
  userId: string;
  productName: string;
  updatedAt: string;
};

type GroupedRestock = {
  count: number;
  oldestProductName: string;
  oldestUpdatedAt: string;
};

/**
 * Scheduled CRON handler for restock reminders.
 */
export async function handleSendRestockReminders(env: Env): Promise<void> {
  const cutoff = new Date(Date.now() - DAYS_OUT_OF_STOCK * 24 * 60 * 60 * 1000);
  const cutoffIso = cutoff.toISOString();

  const serviceAccount = {
    projectId: env.FIREBASE_PROJECT_ID,
    clientEmail: env.FIREBASE_CLIENT_EMAIL,
    privateKey: env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
  };

  const accessToken = await getAccessToken(serviceAccount);

  let candidates: RestockCandidate[];
  try {
    candidates = await queryOutOfStockProducts(
      serviceAccount.projectId,
      accessToken,
      cutoffIso,
    );
  } catch (error) {
    console.error('restock-reminder: query failed', error);
    return;
  }

  if (candidates.length == 0) {
    console.log('restock-reminder: complete. total_users_notified=0');
    return;
  }

  const grouped = groupByUser(candidates);
  let totalUsersNotified = 0;

  for (const [userId, data] of grouped.entries()) {
    try {
      const fcmToken = await fetchUserFcmToken(
        serviceAccount.projectId,
        accessToken,
        userId,
      );
      if (!fcmToken) {
        continue;
      }

      const title =
        data.count === 1
          ? 'Stock khatam! 📦'
          : `${data.count} products ka stock khatam hai 📦`;
      const body =
        data.count === 1
          ? `${data.oldestProductName} bahut din se out of stock hai. Restock karein?`
          : `${data.count} products restock karein.`;

      await sendFcmMessage({
        accessToken,
        projectId: serviceAccount.projectId,
        fcmToken,
        title,
        body,
        data: {
          screen: 'catalogue',
        },
      });

      totalUsersNotified += 1;
      console.log(
        `restock-reminder: sent to userId=${userId} products=${data.count}`,
      );
    } catch (error) {
      console.error(`restock-reminder: user send failed userId=${userId}`, error);
    }
  }

  console.log(
    `restock-reminder: complete. total_users_notified=${totalUsersNotified}`,
  );
}

async function queryOutOfStockProducts(
  projectId: string,
  accessToken: string,
  cutoffIso: string,
): Promise<RestockCandidate[]> {
  const response = await fetch(
    `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents:runQuery`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        structuredQuery: {
          from: [{ collectionId: 'products' }],
          where: {
            compositeFilter: {
              op: 'AND',
              filters: [
                {
                  fieldFilter: {
                    field: { fieldPath: 'stockStatus' },
                    op: 'EQUAL',
                    value: { stringValue: 'outOfStock' },
                  },
                },
                {
                  fieldFilter: {
                    field: { fieldPath: 'updatedAt' },
                    op: 'LESS_THAN',
                    value: { timestampValue: cutoffIso },
                  },
                },
              ],
            },
          },
          orderBy: [
            {
              field: { fieldPath: 'updatedAt' },
              direction: 'ASCENDING',
            },
          ],
          limit: 500,
        },
      }),
    },
  );

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`restock runQuery failed: ${errorText}`);
  }

  const rows = (await response.json()) as QueryRow[];

  return rows
    .map((row): RestockCandidate | null => {
      const doc = row.document;
      if (!doc?.fields) {
        return null;
      }

      const userId = getStringField(doc, 'userId') ?? '';
      const productName = getStringField(doc, 'name') ?? 'Product';
      const updatedAt = getTimestampField(doc, 'updatedAt') ?? '';
      if (!userId || !updatedAt) {
        return null;
      }

      return {
        userId,
        productName,
        updatedAt,
      };
    })
    .filter((item): item is RestockCandidate => item !== null);
}

function groupByUser(candidates: RestockCandidate[]): Map<string, GroupedRestock> {
  const grouped = new Map<string, GroupedRestock>();

  for (const candidate of candidates) {
    const existing = grouped.get(candidate.userId);
    if (!existing) {
      grouped.set(candidate.userId, {
        count: 1,
        oldestProductName: candidate.productName,
        oldestUpdatedAt: candidate.updatedAt,
      });
      continue;
    }

    const hasOlder =
      Date.parse(candidate.updatedAt) < Date.parse(existing.oldestUpdatedAt);

    grouped.set(candidate.userId, {
      count: existing.count + 1,
      oldestProductName: hasOlder
        ? candidate.productName
        : existing.oldestProductName,
      oldestUpdatedAt: hasOlder
        ? candidate.updatedAt
        : existing.oldestUpdatedAt,
    });
  }

  return grouped;
}

async function fetchUserFcmToken(
  projectId: string,
  accessToken: string,
  userId: string,
): Promise<string | null> {
  const response = await fetch(
    `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/users/${userId}`,
    {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    },
  );

  if (response.status === 404) {
    return null;
  }

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`restock user read failed: ${errorText}`);
  }

  const doc = (await response.json()) as FirestoreDocument;
  return getStringField(doc, 'fcmToken');
}

function getTimestampField(
  doc: FirestoreDocument,
  key: string,
): string | null {
  const raw = doc.fields[key] as
    | { timestampValue?: string; stringValue?: string }
    | undefined;

  if (typeof raw?.timestampValue === 'string' && raw.timestampValue) {
    return raw.timestampValue;
  }

  if (typeof raw?.stringValue === 'string' && raw.stringValue) {
    return raw.stringValue;
  }

  return null;
}

async function sendFcmMessage(opts: {
  accessToken: string;
  projectId: string;
  fcmToken: string;
  title: string;
  body: string;
  data: Record<string, string>;
}): Promise<void> {
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
    throw new Error(`restock fcm send failed: ${errorText}`);
  }
}
