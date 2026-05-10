import 'package:dukaan_ai/core/constants/app_routes.dart';
import 'package:dukaan_ai/features/auth/application/auth_provider.dart';
import 'package:dukaan_ai/features/auth/application/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Central auth redirect guard for GoRouter.
String? authGuard(Ref ref, GoRouterState routerState) {
	if (const bool.fromEnvironment('SKIP_AUTH', defaultValue: false)) {
		return null;
	}

	final AsyncValue<AuthState> authAsync = ref.read(googleAuthProvider);
	final String location = routerState.matchedLocation;
	final List<String> authRoutes = <String>[
		AppRoutes.googleAuth,
		AppRoutes.phoneAuth,
		AppRoutes.onboarding,
		AppRoutes.onboardingPhone,
	];
	final List<String> setupRoutes = <String>[
		AppRoutes.businessSetup,
		AppRoutes.onboardingSetup,
	];
	final bool isAuthRoute = authRoutes.contains(location);
	final bool isSetupRoute = setupRoutes.contains(location);

	return authAsync.when<String?>(
		data: (AuthState state) {
			return state.when(
				initial: () {
					if (!isAuthRoute) {
						return AppRoutes.googleAuth;
					}
					return null;
				},
				authenticated: (_) {
					if (isAuthRoute || isSetupRoute) {
						return AppRoutes.studio;
					}
					return null;
				},
				newUser: () {
					if (!isSetupRoute) {
						return AppRoutes.businessSetup;
					}
					return null;
				},
				unauthenticated: () {
					if (!isAuthRoute) {
						return AppRoutes.googleAuth;
					}
					return null;
				},
			);
		},
		loading: () => null,
		error: (_, __) => null,
	);
}