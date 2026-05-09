import type { Env } from '../types/env';
import { getAccessToken } from '../lib/firebase-admin';

interface FirebaseUser {
	localId: string;
	email?: string;
	phoneNumber?: string;
	disabled?: boolean;
}

interface FirebaseLookupResponse {
	users?: FirebaseUser[];
	error?: { message: string; code: number };
}

/**
 * Returns a Google OAuth access token scoped for Firestore admin REST calls.
 */
export async function getFirebaseAdminToken(env: Env): Promise<string> {
	return getAccessToken({
		projectId: env.FIREBASE_PROJECT_ID,
		clientEmail: env.FIREBASE_CLIENT_EMAIL,
		privateKey: env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
	});
}

/**
 * Verifies a Firebase ID token and returns the user's UID.
 * Returns null if token is invalid or user record is unavailable.
 */
export async function verifyFirebaseToken(
	idToken: string,
	env: Env,
): Promise<string | null> {
	try {
		const response = await fetch(
			`https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=${env.FIREBASE_API_KEY}`,
			{
				method: 'POST',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify({ idToken }),
			},
		);

		if (!response.ok) {
			return null;
		}

		const data = (await response.json()) as FirebaseLookupResponse;
		const user = data.users?.[0];
		if (!user || user.disabled) {
			return null;
		}

		return user.localId;
	} catch {
		return null;
	}
}

/**
 * Extracts and verifies the Bearer token from Authorization header.
 * Returns Firebase UID when valid, otherwise null.
 */
export async function extractAndVerifyToken(
	request: Request,
	env: Env,
): Promise<string | null> {
	const authHeader = request.headers.get('Authorization');
	if (!authHeader?.startsWith('Bearer ')) {
		return null;
	}

	const idToken = authHeader.slice(7).trim();
	if (!idToken) {
		return null;
	}

	return verifyFirebaseToken(idToken, env);
}