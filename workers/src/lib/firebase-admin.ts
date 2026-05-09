const JWT_EXPIRY_SECONDS = 3600;
const OAUTH_TOKEN_URL = 'https://oauth2.googleapis.com/token';
const FIREBASE_SCOPE = 'https://www.googleapis.com/auth/firebase.messaging';
const FIRESTORE_SCOPE = 'https://www.googleapis.com/auth/datastore';

export interface ServiceAccount {
	projectId: string;
	clientEmail: string;
	privateKey: string;
}

export type FirestoreValue =
	| { stringValue: string }
	| { integerValue: string }
	| { booleanValue: boolean }
	| { nullValue: null }
	| { mapValue: { fields: Record<string, FirestoreValue> } }
	| { arrayValue: { values: FirestoreValue[] } };

export interface FirestoreDocument {
	name: string;
	fields: Record<string, FirestoreValue>;
}

interface OAuthTokenResponse {
	access_token?: string;
}

function base64UrlEncode(value: string): string {
	return btoa(value)
		.replace(/\+/g, '-')
		.replace(/\//g, '_')
		.replace(/=+$/, '');
}

function base64UrlEncodeJson(value: unknown): string {
	return base64UrlEncode(JSON.stringify(value));
}

function base64UrlEncodeBytes(bytes: Uint8Array): string {
	let binary = '';
	for (let index = 0; index < bytes.length; index++) {
		binary += String.fromCharCode(bytes[index]);
	}

	return base64UrlEncode(binary);
}

function decodePem(privateKeyPem: string): Uint8Array {
	const pemBody = privateKeyPem
		.replace('-----BEGIN PRIVATE KEY-----', '')
		.replace('-----END PRIVATE KEY-----', '')
		.replace(/\s/g, '');

	const decoded = atob(pemBody);
	const bytes = new Uint8Array(decoded.length);
	for (let index = 0; index < decoded.length; index++) {
		bytes[index] = decoded.charCodeAt(index);
	}

	return bytes;
}

/**
 * Creates a short-lived Google OAuth access token from service account credentials.
 */
export async function getAccessToken(sa: ServiceAccount): Promise<string> {
	const now = Math.floor(Date.now() / 1000);

	const header = {
		alg: 'RS256',
		typ: 'JWT',
	};
  const payload = {
		iss: sa.clientEmail,
		sub: sa.clientEmail,
		aud: OAUTH_TOKEN_URL,
		iat: now,
		exp: now + JWT_EXPIRY_SECONDS,
		scope: `${FIREBASE_SCOPE} ${FIRESTORE_SCOPE}`,
	};

	const signingInput = `${base64UrlEncodeJson(header)}.${base64UrlEncodeJson(payload)}`;
	const privateKey = decodePem(sa.privateKey);

	const cryptoKey = await crypto.subtle.importKey(
		'pkcs8',
		privateKey.buffer.slice(
			privateKey.byteOffset,
			privateKey.byteOffset + privateKey.byteLength,
		) as ArrayBuffer,
		{ name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
		false,
		['sign'],
	);

	const signatureBytes = await crypto.subtle.sign(
		'RSASSA-PKCS1-v1_5',
		cryptoKey,
		new TextEncoder().encode(signingInput),
	);

	const signature = base64UrlEncodeBytes(new Uint8Array(signatureBytes));
	const assertion = `${signingInput}.${signature}`;

	const tokenResponse = await fetch(OAUTH_TOKEN_URL, {
		method: 'POST',
		headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
		body: new URLSearchParams({
			grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
			assertion,
		}),
	});

	if (!tokenResponse.ok) {
		const errorText = await tokenResponse.text();
		throw new Error(`Failed to get access token: ${errorText}`);
	}

	const tokenData = (await tokenResponse.json()) as OAuthTokenResponse;
	if (!tokenData.access_token) {
		throw new Error('Failed to get access token: missing access_token field');
	}

	return tokenData.access_token;
}

export function getStringField(doc: FirestoreDocument, key: string): string | null {
	const field = doc.fields[key];
	if (
		field &&
		typeof field === 'object' &&
		'stringValue' in field &&
		typeof field.stringValue === 'string'
	) {
		return field.stringValue;
	}

	return null;
}

/**
 * Fetches Firestore documents from a collection path with simple pagination.
 */
export async function firestoreQuery(opts: {
	projectId: string;
	collection: string;
	accessToken: string;
	pageSize?: number;
	pageToken?: string;
}): Promise<{ documents: FirestoreDocument[]; nextPageToken?: string }> {
	const { projectId, collection, accessToken, pageSize = 500, pageToken } = opts;

	const url = new URL(
		`https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/${collection}`,
	);
	url.searchParams.set('pageSize', String(pageSize));
	if (pageToken) {
		url.searchParams.set('pageToken', pageToken);
	}

	const response = await fetch(url.toString(), {
		headers: {
			Authorization: `Bearer ${accessToken}`,
		},
	});

	if (!response.ok) {
		const errorText = await response.text();
		throw new Error(`Firestore query failed: ${errorText}`);
	}

	const data = (await response.json()) as {
		documents?: FirestoreDocument[];
		nextPageToken?: string;
	};

	return {
		documents: data.documents ?? [],
		nextPageToken: data.nextPageToken,
	};
}

/**
 * Writes a single document into the target Firestore collection.
 */
export async function firestoreAdd(opts: {
	projectId: string;
	collection: string;
	data: Record<string, FirestoreValue>;
	accessToken: string;
}): Promise<void> {
	const { projectId, collection, data, accessToken } = opts;

	const response = await fetch(
		`https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/${collection}`,
		{
			method: 'POST',
			headers: {
				Authorization: `Bearer ${accessToken}`,
				'Content-Type': 'application/json',
			},
			body: JSON.stringify({ fields: data }),
		},
	);

	if (!response.ok) {
		const errorText = await response.text();
		throw new Error(`Firestore write failed: ${errorText}`);
	}
}
