export interface RateLimitKv {
	get(key: string): Promise<string | null>;
	put(
		key: string,
		value: string,
		options?: { expirationTtl?: number },
	): Promise<void>;
}

export interface Env {
	FIREBASE_PROJECT_ID: string;
	FIREBASE_API_KEY: string;
	FIREBASE_CLIENT_EMAIL: string;
	FIREBASE_PRIVATE_KEY: string;
	AIENGINEAPIKEY: string;
	REPLICATEAPITOKEN: string;
	OPENAIAPIKEY: string;
	RAZORPAY_KEY_ID: string;
	RAZORPAY_SECRET: string;
	OPENROUTER_API_KEY?: string;
	OPENROUTER_MODEL?: string;
	RATE_LIMIT_KV: RateLimitKv;
	CACHEKV: RateLimitKv;
}
