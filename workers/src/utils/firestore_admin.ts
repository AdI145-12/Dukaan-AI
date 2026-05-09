import type { Env } from '../types/env';
import { getFirebaseAdminToken } from '../middleware/auth';

const FIRESTORE_BASE = (projectId: string): string =>
  `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents`;

function extractDocumentId(name: string | undefined): string {
  if (!name) {
    return '';
  }

  const parts = name.split('/');
  return parts[parts.length - 1] ?? '';
}

function buildWhere(filters: FirestoreFilter[]): Record<string, unknown> | undefined {
  if (filters.length === 0) {
    return undefined;
  }

  if (filters.length === 1) {
    return { fieldFilter: filters[0] };
  }

  return {
    compositeFilter: {
      op: 'AND',
      filters: filters.map((filter) => ({ fieldFilter: filter })),
    },
  };
}

export async function firestoreQuery(
  collectionId: string,
  filters: FirestoreFilter[],
  limit: number,
  env: Env,
): Promise<FirestoreQueryResult[]> {
  const token = await getFirebaseAdminToken(env);
  const where = buildWhere(filters);

  const response = await fetch(
    `${FIRESTORE_BASE(env.FIREBASE_PROJECT_ID)}:runQuery`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        structuredQuery: {
          from: [{ collectionId }],
          ...(where ? { where } : {}),
          limit,
        },
      }),
    },
  );

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Firestore runQuery failed: ${errorText}`);
  }

  const rows = (await response.json()) as FirestoreQueryRow[];

  return rows
    .filter((row) => row.document?.fields)
    .map((row) => ({
      id: extractDocumentId(row.document?.name),
      fields: row.document?.fields ?? {},
    }));
}

export async function firestoreCreate(
  collectionId: string,
  data: Record<string, unknown>,
  env: Env,
  documentId?: string,
): Promise<{ id: string }> {
  const token = await getFirebaseAdminToken(env);
  const baseUrl = `${FIRESTORE_BASE(env.FIREBASE_PROJECT_ID)}/${collectionId}`;
  const targetUrl = documentId
    ? `${baseUrl}?documentId=${encodeURIComponent(documentId)}`
    : baseUrl;

  const response = await fetch(targetUrl, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      fields: toFirestoreFields(data),
    }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Firestore create failed: ${errorText}`);
  }

  const doc = (await response.json()) as FirestoreDocument;
  return { id: extractDocumentId(doc.name) };
}

export async function firestorePatch(
  docPath: string,
  data: Record<string, unknown>,
  env: Env,
): Promise<void> {
  const token = await getFirebaseAdminToken(env);
  const url = new URL(`${FIRESTORE_BASE(env.FIREBASE_PROJECT_ID)}/${docPath}`);
  for (const key of Object.keys(data)) {
    url.searchParams.append('updateMask.fieldPaths', key);
  }

  const response = await fetch(url.toString(), {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      fields: toFirestoreFields(data),
    }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Firestore patch failed: ${errorText}`);
  }
}

export async function firestoreGet(
  docPath: string,
  env: Env,
): Promise<Record<string, FirestoreValue> | null> {
  const token = await getFirebaseAdminToken(env);
  const response = await fetch(
    `${FIRESTORE_BASE(env.FIREBASE_PROJECT_ID)}/${docPath}`,
    {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    },
  );

  if (response.status === 404) {
    return null;
  }

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Firestore get failed: ${errorText}`);
  }

  const doc = (await response.json()) as FirestoreDocument;
  return doc.fields ?? null;
}

export async function firestoreIncrement(
  docPath: string,
  fieldPath: string,
  amount: number,
  env: Env,
): Promise<void> {
  const token = await getFirebaseAdminToken(env);
  const fullDocPath =
    `projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents/${docPath}`;

  const response = await fetch(
    `https://firestore.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents:commit`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        writes: [
          {
            transform: {
              document: fullDocPath,
              fieldTransforms: [
                {
                  fieldPath,
                  increment: { integerValue: String(amount) },
                },
              ],
            },
          },
        ],
      }),
    },
  );

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Firestore increment failed: ${errorText}`);
  }
}

export function strVal(
  fields: Record<string, FirestoreValue>,
  key: string,
): string | null {
  return fields[key]?.stringValue ?? null;
}

export function boolVal(
  fields: Record<string, FirestoreValue>,
  key: string,
): boolean {
  return fields[key]?.booleanValue ?? false;
}

export function intVal(
  fields: Record<string, FirestoreValue>,
  key: string,
): number {
  return Number.parseInt(fields[key]?.integerValue ?? '0', 10);
}

export function numVal(
  fields: Record<string, FirestoreValue>,
  key: string,
): number {
  return Number.parseFloat(
    fields[key]?.doubleValue ?? fields[key]?.integerValue ?? '0',
  );
}

export interface FirestoreFilter {
  field: { fieldPath: string };
  op: 'EQUAL' | 'LESS_THAN' | 'GREATER_THAN' | 'ARRAY_CONTAINS' | 'IN';
  value: FirestoreValue;
}

export interface FirestoreValue {
  stringValue?: string;
  integerValue?: string;
  doubleValue?: string;
  booleanValue?: boolean;
  nullValue?: null;
  timestampValue?: string;
  mapValue?: { fields?: Record<string, FirestoreValue> };
  arrayValue?: { values?: FirestoreValue[] };
}

export interface FirestoreQueryResult {
  id: string;
  fields: Record<string, FirestoreValue>;
}

interface FirestoreDocument {
  name?: string;
  fields?: Record<string, FirestoreValue>;
}

interface FirestoreQueryRow {
  document?: FirestoreDocument;
}

export function toFirestoreFields(
  data: Record<string, unknown>,
): Record<string, FirestoreValue> {
  return Object.fromEntries(
    Object.entries(data).map(([key, value]) => [key, toFirestoreValue(value)]),
  );
}

export function toFirestoreValue(value: unknown): FirestoreValue {
  if (value === null || value === undefined) {
    return { nullValue: null };
  }

  if (typeof value === 'string') {
    return { stringValue: value };
  }

  if (typeof value === 'boolean') {
    return { booleanValue: value };
  }

  if (typeof value === 'number') {
    if (!Number.isFinite(value)) {
      return { nullValue: null };
    }
    return Number.isInteger(value)
      ? { integerValue: String(value) }
      : { doubleValue: String(value) };
  }

  if (value instanceof Date) {
    return { timestampValue: value.toISOString() };
  }

  if (Array.isArray(value)) {
    return {
      arrayValue: {
        values: value.map((item) => toFirestoreValue(item)),
      },
    };
  }

  if (typeof value === 'object') {
    const objectValue = value as Record<string, unknown>;
    return {
      mapValue: {
        fields: toFirestoreFields(objectValue),
      },
    };
  }

  return { stringValue: String(value) };
}
