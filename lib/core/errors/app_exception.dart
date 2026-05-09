sealed class AppException implements Exception {
	const AppException(this.message);

	final String message;

	String get userMessage => switch (this) {
		FirebaseAppException() => message,
		StorageAppException() => message,
		NetworkAppException() => message,
		RateLimitAppException() => message,
		CreditsAppException() => message,
		WorkerRateLimitAppException() => message,
		WorkerErrorAppException() => message,
		UnknownAppException() => message,
	};

	const factory AppException.firebase(String message) = FirebaseAppException;
	const factory AppException.storage(String message) = StorageAppException;
	const factory AppException.network(String message) = NetworkAppException;
	const factory AppException.rateLimit(String message) = RateLimitAppException;
	const factory AppException.credits(String message) = CreditsAppException;
	const factory AppException.workerRateLimit(String message) = WorkerRateLimitAppException;
	const factory AppException.workerError(String message) = WorkerErrorAppException;
	const factory AppException.unknown(String message) = UnknownAppException;
}

final class FirebaseAppException extends AppException {
	const FirebaseAppException(super.message);
}

final class StorageAppException extends AppException {
	const StorageAppException(super.message);
}

final class NetworkAppException extends AppException {
	const NetworkAppException(super.message);
}

final class RateLimitAppException extends AppException {
	const RateLimitAppException(super.message);
}

final class CreditsAppException extends AppException {
	const CreditsAppException(super.message);
}

final class WorkerRateLimitAppException extends AppException {
	const WorkerRateLimitAppException(super.message);
}

final class WorkerErrorAppException extends AppException {
	const WorkerErrorAppException(super.message);
}

final class UnknownAppException extends AppException {
	const UnknownAppException(super.message);
}