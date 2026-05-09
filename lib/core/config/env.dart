// All values injected via --dart-define or --dart-define-from-file at build time.

class Env {
	Env._();

	/// Base URL for the Cloudflare Worker API.
	/// Example: https://dukaan-ai-worker.your-account.workers.dev
	static const String workerBaseUrl = String.fromEnvironment(
		'WORKER_BASE_URL',
		defaultValue: 'http://localhost:8787',
	);

	/// Firebase project ID (same value used in google-services.json).
	static const String firebaseProjectId = String.fromEnvironment(
		'FIREBASE_PROJECT_ID',
		defaultValue: '',
	);
}