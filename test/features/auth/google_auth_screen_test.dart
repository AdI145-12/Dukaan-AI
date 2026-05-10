import 'package:dukaan_ai/features/auth/application/auth_provider.dart';
import 'package:dukaan_ai/features/auth/application/auth_state.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/features/auth/presentation/screens/google_auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockGoogleAuthNotifier extends GoogleAuthNotifier {
	int signInCalls = 0;

	@override
	Future<AuthState> build() async {
		return const AuthState.initial();
	}

	@override
	Future<void> signInWithGoogle() async {
		signInCalls += 1;
		state = const AsyncData<AuthState>(AuthState.initial());
	}
}

void main() {
	testWidgets('renders Continue with Google button', (WidgetTester tester) async {
		final MockGoogleAuthNotifier notifier = MockGoogleAuthNotifier();
		await tester.pumpWidget(
			ProviderScope(
				overrides: [
					googleAuthProvider.overrideWith(() => notifier),
				],
				child: const MaterialApp(home: GoogleAuthScreen()),
			),
		);
		await tester.pumpAndSettle();

		expect(find.text(AppStrings.authGoogleButton), findsOneWidget);
	});

	testWidgets('renders Continue with phone number button', (WidgetTester tester) async {
		final MockGoogleAuthNotifier notifier = MockGoogleAuthNotifier();
		await tester.pumpWidget(
			ProviderScope(
				overrides: [
					googleAuthProvider.overrideWith(() => notifier),
				],
				child: const MaterialApp(home: GoogleAuthScreen()),
			),
		);
		await tester.pumpAndSettle();

		expect(find.text(AppStrings.authPhoneButton), findsOneWidget);
	});

	testWidgets('tap Continue with Google calls signInWithGoogle once', (WidgetTester tester) async {
		final MockGoogleAuthNotifier notifier = MockGoogleAuthNotifier();
		await tester.pumpWidget(
			ProviderScope(
				overrides: [
					googleAuthProvider.overrideWith(() => notifier),
				],
				child: const MaterialApp(home: GoogleAuthScreen()),
			),
		);
		await tester.pumpAndSettle();

		await tester.tap(find.text(AppStrings.authGoogleButton));
		await tester.pump();

		expect(notifier.signInCalls, 1);
	});
}