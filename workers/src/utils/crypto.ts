function toHex(bytes: Uint8Array): string {
	return Array.from(bytes)
		.map((value) => value.toString(16).padStart(2, '0'))
		.join('');
}

export async function createHmacSha256Hex(
	message: string,
	secret: string,
): Promise<string> {
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

	return toHex(new Uint8Array(signatureBuffer));
}

export async function verifyHmacSha256Hex(input: {
	message: string;
	secret: string;
	expectedHex: string;
}): Promise<boolean> {
	const expected = input.expectedHex.trim().toLowerCase();
	if (!expected) {
		return false;
	}

	const actual = await createHmacSha256Hex(input.message, input.secret);
	return actual === expected;
}
