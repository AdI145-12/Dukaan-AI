import '../constants/app_strings.dart';
import 'app_exception.dart';

import 'package:firebase_auth/firebase_auth.dart';

class ErrorHandler {
	const ErrorHandler._();

	/// Maps a Firebase Auth exception into the project's AppException hierarchy.
	static AppException fromFirebaseAuth(FirebaseAuthException exception) {
		return switch (exception.code) {
			'network-request-failed' => const AppException.network(
				'Internet nahi hai. Dobara try karein.',
			),
			'account-exists-with-different-credential' =>
				const AppException.firebase('accountExistsWithDifferentCredential'),
			'cancelled' => const AppException.cancelled('Sign in cancelled'),
			'credential-already-in-use' => const AppException.firebase(
				'Yeh email pehle se registered hai. Google se login karein.',
			),
			_ => AppException.unknown(exception.message ?? AppStrings.errorGeneric),
		};
	}

	/// Maps a Firestore exception into the project's AppException hierarchy.
	static AppException fromFirestore(FirebaseException exception) {
		return AppException.firebase(exception.message ?? AppStrings.errorGeneric);
	}

	/// Maps any thrown exception to a user-friendly Hinglish string.
	/// Use this in every .when(error:) callback in widgets.
	static String toUserMessage(Object error) {
		return switch (error) {
			CancelledAppException(:final message) => message,
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