class AppConfig {
	AppConfig._();

	/// Cloudflare Worker base URL.
	/// Set via: --dart-define=WORKER_BASE_URL=https://your-worker
	/// Falls back to local wrangler dev URL in development.
	static const String workerBaseUrl = String.fromEnvironment(
		'WORKER_BASE_URL',
		defaultValue: 'http://localhost:8787',
	);
}