import 'dart:async';

import 'package:dukaan_ai/core/constants/app_routes.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/auth/application/auth_provider.dart';
import 'package:dukaan_ai/features/auth/application/auth_state.dart';
import 'package:dukaan_ai/shared/widgets/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Phone OTP fallback screen.
class PhoneAuthScreen extends ConsumerStatefulWidget {
	const PhoneAuthScreen({super.key});

	@override
	ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
	late final TextEditingController _phoneController;
	late final List<TextEditingController> _otpControllers;
	bool _isOtpStep = false;
	bool _isLoading = false;

	@override
	void initState() {
		super.initState();
		_phoneController = TextEditingController();
		_otpControllers = List<TextEditingController>.generate(
			6,
			(_) => TextEditingController(),
		);
	}

	@override
	void dispose() {
		_phoneController.dispose();
		for (final TextEditingController controller in _otpControllers) {
			controller.dispose();
		}
		super.dispose();
	}

	String get _phoneNumber => _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
	String get _otpCode => _otpControllers.map((TextEditingController controller) => controller.text).join();

	@override
	Widget build(BuildContext context) {
		final AsyncValue<AuthState> authAsync = ref.watch(googleAuthProvider);
		ref.listen<AsyncValue<AuthState>>(googleAuthProvider, (previous, next) {
			next.whenOrNull(
				error: (Object error, StackTrace stackTrace) {
					if (context.mounted) {
						AppSnackBar.showError(context, error.toString());
					}
				},
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
			);
		});

		return Scaffold(
			backgroundColor: AppColors.surface,
			appBar: AppBar(
				title: const Text(AppStrings.phoneAuthTitle),
				backgroundColor: AppColors.surface,
				elevation: 0,
				leading: IconButton(
					onPressed: () => context.pop(),
					icon: const Icon(Icons.arrow_back_rounded),
				),
			),
			body: Padding(
				padding: const EdgeInsets.all(AppSpacing.lg),
				child: Column(
					children: <Widget>[
						Container(
							width: double.infinity,
							padding: const EdgeInsets.all(AppSpacing.md),
							decoration: BoxDecoration(
								color: AppColors.primaryLight,
								borderRadius: BorderRadius.circular(AppRadius.card),
							),
							child: Text(
								AppStrings.phoneAuthCardSubtitle,
								style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
							),
						),
						const SizedBox(height: AppSpacing.lg),
						TextField(
							controller: _phoneController,
							keyboardType: TextInputType.phone,
							decoration: const InputDecoration(
								labelText: AppStrings.phoneLabel,
								prefixText: '${AppStrings.phoneCountryCode} ',
							),
							maxLength: 10,
						),
						const SizedBox(height: AppSpacing.md),
						if (!_isOtpStep)
							SizedBox(
								width: double.infinity,
								height: 52,
								child: ElevatedButton(
									onPressed: _phoneNumber.length == 10 && !_isLoading
										? _sendOtp
										: null,
									style: ElevatedButton.styleFrom(
										backgroundColor: AppColors.primary,
										foregroundColor: AppColors.surface,
										shape: const StadiumBorder(),
									),
									child: _isLoading
										? const SizedBox(
											width: 20,
											height: 20,
											child: CircularProgressIndicator(
												strokeWidth: 2,
												color: AppColors.surface,
											),
										)
										: const Text(AppStrings.sendOtpButton),
								),
							),
						if (_isOtpStep) ...<Widget>[
							Row(
								children: List<Widget>.generate(6, (int index) {
									return Expanded(
										child: Padding(
											padding: EdgeInsets.only(right: index == 5 ? 0 : AppSpacing.xs),
											child: TextField(
												controller: _otpControllers[index],
												keyboardType: TextInputType.number,
												maxLength: 1,
												textAlign: TextAlign.center,
												decoration: const InputDecoration(counterText: ''),
												onChanged: (_) => setState(() {}),
											),
										),
									);
								}),
							),
							const SizedBox(height: AppSpacing.md),
							SizedBox(
								width: double.infinity,
								height: 52,
								child: ElevatedButton(
									onPressed: _otpCode.length == 6 && !_isLoading ? _verifyOtp : null,
									style: ElevatedButton.styleFrom(
										backgroundColor: AppColors.primary,
										foregroundColor: AppColors.surface,
										shape: const StadiumBorder(),
									),
									child: _isLoading
										? const SizedBox(
											width: 20,
											height: 20,
											child: CircularProgressIndicator(
												strokeWidth: 2,
												color: AppColors.surface,
											),
										)
										: const Text(AppStrings.verifyOtpButton),
								),
							),
							TextButton(
								onPressed: !_isLoading ? _sendOtp : null,
								child: const Text(AppStrings.resendOtp),
							),
						],
						if (authAsync.hasError)
							Padding(
								padding: const EdgeInsets.only(top: AppSpacing.sm),
								child: Text(
									authAsync.error.toString(),
									style: AppTypography.labelSmall.copyWith(color: AppColors.error),
								),
							),
					],
				),
			),
		);
	}

	Future<void> _sendOtp() async {
		setState(() => _isLoading = true);
		try {
			await ref.read(googleAuthProvider.notifier).sendPhoneOtp(_phoneNumber);
			if (mounted) {
				setState(() => _isOtpStep = true);
			}
		} catch (error) {
			if (mounted) {
				AppSnackBar.showError(context, error.toString());
			}
		} finally {
			if (mounted) {
				setState(() => _isLoading = false);
			}
		}
	}

	Future<void> _verifyOtp() async {
		setState(() => _isLoading = true);
		try {
			await ref.read(googleAuthProvider.notifier).verifyPhoneOtp(_otpCode);
		} catch (error) {
			if (mounted) {
				AppSnackBar.showError(context, error.toString());
			}
		} finally {
			if (mounted) {
				setState(() => _isLoading = false);
			}
		}
	}
}// Screen 3: +91 input + 6-box OTP