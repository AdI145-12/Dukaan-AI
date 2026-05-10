import 'package:dukaan_ai/features/auth/domain/models/user_profile.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
	const factory AuthState.initial() = AuthInitial;

	const factory AuthState.authenticated(UserProfile profile) = AuthAuthenticated;

	const factory AuthState.newUser() = AuthNewUser;

	const factory AuthState.unauthenticated() = AuthUnauthenticated;
}