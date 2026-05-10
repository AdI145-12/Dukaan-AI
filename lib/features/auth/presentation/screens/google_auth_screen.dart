import 'package:dukaan_ai/core/constants/app_routes.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/auth/application/auth_provider.dart';
import 'package:dukaan_ai/features/auth/application/auth_state.dart';
import 'package:dukaan_ai/shared/widgets/app_snack_bar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// Google-first sign-in entry screen.
class GoogleAuthScreen extends ConsumerWidget {
	const GoogleAuthScreen({super.key});

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		final AsyncValue<AuthState> authAsync = ref.watch(googleAuthProvider);

		ref.listen<AsyncValue<AuthState>>(googleAuthProvider, (previous, next) {
			next.whenOrNull(
				data: (AuthState state) {
					state.when(
						initial: () {},
						authenticated: (_) {
							if (context.mounted) {
								context.go(AppRoutes.studio);
							}
						},
						newUser: () {
							if (context.mounted) {
								context.go(AppRoutes.businessSetup);
							}
						},
						unauthenticated: () {},
					);
				},
				error: (Object error, StackTrace stackTrace) {
					if (context.mounted) {
						AppSnackBar.showError(context, error.toString());
					}
				},
			);
		});

		final bool isLoading = authAsync.isLoading;

		return Scaffold(
			backgroundColor: AppColors.surface,
			body: SafeArea(
				child: Padding(
					padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
					child: Column(
						children: <Widget>[
							const SizedBox(height: AppSpacing.xl),
							Center(
								child: ClipRRect(
									borderRadius: BorderRadius.circular(AppRadius.card),
									child: Image.asset(
										'assets/icons/appicon.png',
										width: 80,
										height: 80,
										fit: BoxFit.cover,
										errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
											return Container(
												width: 80,
												height: 80,
												decoration: BoxDecoration(
													color: AppColors.primaryLight,
													borderRadius: BorderRadius.circular(AppRadius.card),
												),
												child: const Icon(Icons.storefront_rounded, color: AppColors.primary),
											);
										},
									),
								),
							),
							const SizedBox(height: AppSpacing.md),
							Text(
								AppStrings.authBrandTitle,
								style: AppTypography.displayMedium.copyWith(
									color: AppColors.primary,
								),
							),
							const SizedBox(height: AppSpacing.xs),
							Text(
								AppStrings.authBrandSubtitle,
								style: AppTypography.bodyMedium.copyWith(
									color: AppColors.textSecondary,
								),
							),
							const Spacer(),
							Text(
								AppStrings.authHeroLine,
								textAlign: TextAlign.center,
								style: AppTypography.bodyLarge.copyWith(
									color: AppColors.textPrimary,
								),
							),
							const SizedBox(height: AppSpacing.lg),
							SizedBox(
								width: double.infinity,
								height: 52,
								child: ElevatedButton(
									onPressed: isLoading
										? null
										: () => ref.read(googleAuthProvider.notifier).signInWithGoogle(),
									style: ElevatedButton.styleFrom(
										backgroundColor: AppColors.primary,
										foregroundColor: AppColors.surface,
										shape: const StadiumBorder(),
										elevation: 0,
									),
									child: isLoading
										? const SizedBox(
											width: 20,
											height: 20,
											child: CircularProgressIndicator(
												color: AppColors.surface,
												strokeWidth: 2,
											),
										)
										: Row(
											mainAxisAlignment: MainAxisAlignment.center,
											mainAxisSize: MainAxisSize.min,
											children: <Widget>[
												Container(
													width: 24,
													height: 24,
													decoration: const BoxDecoration(
														color: AppColors.surface,
														shape: BoxShape.circle,
													),
													padding: const EdgeInsets.all(2),
													child: Image.asset(
														'assets/icons/google_logo.png',
														fit: BoxFit.contain,
														errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
															return const Icon(
																Icons.g_mobiledata_rounded,
																color: AppColors.primary,
																size: 18,
															);
														},
													),
												),
												const SizedBox(width: AppSpacing.sm),
												Text(
													AppStrings.authGoogleButton,
													style: AppTypography.labelLarge.copyWith(
														color: AppColors.surface,
													),
												),
											],
										),
								),
							),
							const SizedBox(height: AppSpacing.md),
							SizedBox(
								width: double.infinity,
								height: 52,
								child: OutlinedButton(
									onPressed: () => context.push(AppRoutes.phoneAuth),
									style: OutlinedButton.styleFrom(
										foregroundColor: AppColors.primary,
										side: const BorderSide(
											color: AppColors.primary,
											width: 1.5,
										),
										shape: const StadiumBorder(),
									),
									child: Text(
										AppStrings.authPhoneButton,
										style: AppTypography.labelLarge.copyWith(
											color: AppColors.primary,
										),
									),
								),
							),
							const SizedBox(height: AppSpacing.lg),
							Text.rich(
								TextSpan(
									style: AppTypography.labelSmall.copyWith(
										color: AppColors.textSecondary,
									),
									children: <TextSpan>[
										const TextSpan(text: AppStrings.authTermsPrefix),
										TextSpan(
											text: AppStrings.authTermsLabel,
											style: const TextStyle(
												decoration: TextDecoration.underline,
												color: AppColors.textSecondary,
											),
											recognizer: TapGestureRecognizer()
											  ..onTap = () async {
												final Uri uri = Uri.parse(AppStrings.authTermsUrl);
												await launchUrl(uri, mode: LaunchMode.externalApplication);
											},
										),
									],
								),
								textAlign: TextAlign.center,
							),
							const SizedBox(height: AppSpacing.xl),
						],
					),
				),
			),
		);
	}
}