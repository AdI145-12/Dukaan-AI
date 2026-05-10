import 'package:dukaan_ai/core/errors/app_exception.dart';
import 'package:dukaan_ai/features/auth/application/auth_state.dart';
import 'package:dukaan_ai/features/auth/domain/models/user_profile.dart';
import 'package:dukaan_ai/features/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
class GoogleAuthNotifier extends _$GoogleAuthNotifier {
	@override
	Future<AuthState> build() async {
		final User? currentUser = FirebaseAuth.instance.currentUser;
		if (currentUser == null) {
			return const AuthState.initial();
		}

		try {
			final UserProfile? profile = await ref
					.read(authRepositoryProvider)
					.getProfile(currentUser.uid);
			if (profile == null) {
				return const AuthState.newUser();
			}
			return AuthState.authenticated(profile);
		} on AppException {
			return const AuthState.unauthenticated();
		}
	}

	/// Starts Google sign-in and publishes the resulting auth state.
	Future<void> signInWithGoogle() async {
		state = const AsyncLoading<AuthState>();
		try {
			final UserProfile? profile = await ref
					.read(authRepositoryProvider)
					.signInWithGoogle();
			state = AsyncData<AuthState>(
				profile == null
						? const AuthState.newUser()
						: AuthState.authenticated(profile),
			);
		} on AppException catch (error, stackTrace) {
			if (error is CancelledAppException) {
				state = const AsyncData<AuthState>(AuthState.initial());
				return;
			}
			state = AsyncError<AuthState>(_mapHinglishMessage(error), stackTrace);
		}
	}

	/// Sends a phone OTP through Firebase Auth.
	Future<void> sendPhoneOtp(String phoneNumber) async {
		state = const AsyncLoading<AuthState>();
		try {
			await ref.read(authRepositoryProvider).sendPhoneOtp(phoneNumber);
			state = const AsyncData<AuthState>(AuthState.initial());
		} on AppException catch (error, stackTrace) {
			state = AsyncError<AuthState>(_mapHinglishMessage(error), stackTrace);
		}
	}

	/// Verifies the phone OTP and publishes the resulting auth state.
	Future<void> verifyPhoneOtp(String smsCode) async {
		state = const AsyncLoading<AuthState>();
		try {
			final UserProfile? profile = await ref
					.read(authRepositoryProvider)
					.verifyPhoneOtp(smsCode);
			state = AsyncData<AuthState>(
				profile == null
						? const AuthState.newUser()
						: AuthState.authenticated(profile),
			);
		} on AppException catch (error, stackTrace) {
			state = AsyncError<AuthState>(_mapHinglishMessage(error), stackTrace);
		}
	}

	/// Signs the current user out of Firebase and Google.
	Future<void> signOut() async {
		state = const AsyncLoading<AuthState>();
		try {
			await ref.read(authRepositoryProvider).signOut();
			state = const AsyncData<AuthState>(AuthState.unauthenticated());
		} on AppException catch (error, stackTrace) {
			state = AsyncError<AuthState>(_mapHinglishMessage(error), stackTrace);
		}
	}

	String _mapHinglishMessage(AppException exception) {
		return switch (exception) {
			NetworkAppException() => 'Internet nahi hai. Dobara try karein.',
			FirebaseAppException(message: 'accountExistsWithDifferentCredential') =>
				'Yeh email pehle se registered hai. Google se login karein.',
			FirebaseAppException() => exception.message,
			UnknownAppException() => 'Kuch gadbad ho gayi. Thodi der baad try karein.',
			_ => exception.userMessage,
		};
	}
}