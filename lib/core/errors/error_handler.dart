import '../constants/app_strings.dart';
import 'app_exception.dart';

class ErrorHandler {
	const ErrorHandler._();

	/// Maps any thrown exception to a user-friendly Hinglish string.
	/// Use this in every .when(error:) callback in widgets.
	static String toUserMessage(Object error) {
		return switch (error) {
			FirebaseAppException(:final message) => message,
			StorageAppException(:final message) => message,
			NetworkAppException _ => AppStrings.errorNetwork,
			RateLimitAppException _ => AppStrings.errorRateLimit,
			WorkerRateLimitAppException(:final message) => message,
			WorkerErrorAppException(:final message) => message,
			CreditsAppException _ => AppStrings.errorCredits,
			_ => AppStrings.errorGeneric,
		};
	}

}