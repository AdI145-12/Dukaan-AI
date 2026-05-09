import 'dart:async';

import 'package:dukaan_ai/core/constants/app_routes.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/onboarding/application/onboarding_notifier.dart';
import 'package:dukaan_ai/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  late final TextEditingController _phoneController;
  late final List<TextEditingController> _otpControllers;
  late final List<FocusNode> _otpFocusNodes;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _phoneController.addListener(_onPhoneChanged);
    _otpControllers = List<TextEditingController>.generate(
      6,
      (_) => TextEditingController(),
    );
    _otpFocusNodes = List<FocusNode>.generate(6, (_) => FocusNode());
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    for (final TextEditingController controller in _otpControllers) {
      controller.dispose();
    }
    for (final FocusNode focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onPhoneChanged() {
    setState(() {});
  }

  String get _phoneNumber {
    return _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
  }

  String get _fullOtp {
    return _otpControllers.map((TextEditingController c) => c.text).join();
  }

  bool get _isPhoneValid => _phoneNumber.length == 10;
  bool get _isOtpValid => _fullOtp.length == 6;

  void _onClosePressed() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.onboarding);
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < _otpFocusNodes.length - 1) {
      _otpFocusNodes[index + 1].requestFocus();
      return;
    }

    if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final OnboardingState state = ref.watch(onboardingNotifierProvider);
    final bool isOtpStep = state.otpSent;

    ref.listen<OnboardingState>(
      onboardingNotifierProvider,
      (OnboardingState? previous, OnboardingState next) async {
        final bool becameVerified =
            (!(previous?.otpVerified ?? false) && next.otpVerified) ||
                (!(previous?.autoVerified ?? false) && next.autoVerified);
        if (!becameVerified) {
          return;
        }

        if (!next.profileSaved && next.isFormValid) {
          await ref.read(onboardingNotifierProvider.notifier).saveShopProfile(
                shopName: next.shopName.trim(),
                category: next.category,
                city: next.city.trim(),
              );

          final OnboardingState latest = ref.read(onboardingNotifierProvider);
          if (latest.error != null) {
            return;
          }
        }

        if (context.mounted) {
          context.go(AppRoutes.studio);
        }
      },
    );

    final VoidCallback? ctaAction = isOtpStep
        ? (_isOtpValid && !state.isLoading
            ? () => unawaited(
                  ref
                      .read(onboardingNotifierProvider.notifier)
                      .verifyOtp(_fullOtp),
                )
            : null)
        : (_isPhoneValid && !state.isLoading
            ? () => unawaited(
                  ref
                      .read(onboardingNotifierProvider.notifier)
                      .sendOtp(_phoneNumber),
                )
            : null);

    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      body: SafeArea(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.lg),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: AppSpacing.md,
                  offset: const Offset(0, AppSpacing.xs),
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: AppSpacing.xl,
                  height: AppSpacing.xs,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary,
                    borderRadius: BorderRadius.circular(AppSpacing.xs),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.sm,
                    AppSpacing.sm,
                  ),
                  child: Row(
                    children: <Widget>[
                      const Expanded(
                        child: Text(
                          AppStrings.phoneAuthTitle,
                          style: AppTypography.headlineLarge,
                        ),
                      ),
                      IconButton(
                        onPressed: _onClosePressed,
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 1,
                  color: AppColors.divider,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const _OnboardingDots(currentIndex: 2, total: 3),
                        const SizedBox(height: AppSpacing.md),
                        _AuthIntroCard(isOtpStep: isOtpStep),
                        const SizedBox(height: AppSpacing.lg),
                        if (!isOtpStep)
                          _PhoneInput(
                            controller: _phoneController,
                          )
                        else
                          _OtpInput(
                            controllers: _otpControllers,
                            focusNodes: _otpFocusNodes,
                            onChanged: _onOtpChanged,
                          ),
                        if (isOtpStep) ...<Widget>[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            AppStrings.otpHint,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          TextButton(
                            onPressed: _isPhoneValid && !state.isLoading
                                ? () => unawaited(
                                      ref
                                          .read(
                                            onboardingNotifierProvider.notifier,
                                          )
                                          .resendOtp(_phoneNumber),
                                    )
                                : null,
                            child: Text(
                              AppStrings.resendOtp,
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                        if (state.error != null)
                          _InlineError(message: state.error!),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: AppButton(
                    label: isOtpStep
                        ? AppStrings.verifyOtpButton
                        : AppStrings.sendOtpButton,
                    isLoading: state.isLoading,
                    onPressed: ctaAction,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthIntroCard extends StatelessWidget {
  const _AuthIntroCard({required this.isOtpStep});

  final bool isOtpStep;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            isOtpStep ? Icons.password_rounded : Icons.phone_android_rounded,
            color: AppColors.primaryDark,
            size: AppSpacing.xl,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  AppStrings.phoneAuthCardTitle,
                  style: AppTypography.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  AppStrings.phoneAuthCardSubtitle,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneInput extends StatelessWidget {
  const _PhoneInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          AppStrings.phoneLabel,
          style: AppTypography.labelLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + AppSpacing.xs,
                  vertical: AppSpacing.md,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                child: const Text(
                  AppStrings.phoneCountryCode,
                  style: AppTypography.bodyLarge,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    hintText: AppStrings.phoneHint,
                    hintStyle: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textHint,
                    ),
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm + AppSpacing.xs,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OtpInput extends StatelessWidget {
  const _OtpInput({
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(int index, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          AppStrings.otpLabel,
          style: AppTypography.labelLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: List<Widget>.generate(6, (int index) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == 5 ? 0 : AppSpacing.xs,
                ),
                child: TextField(
                  controller: controllers[index],
                  focusNode: focusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  maxLength: 1,
                  style: AppTypography.headlineMedium,
                  decoration: const InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppRadius.button),
                      ),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppRadius.button),
                      ),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppRadius.button),
                      ),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (String value) => onChanged(index, value),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.error_outline,
            size: AppSpacing.md,
            color: AppColors.error,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingDots extends StatelessWidget {
  const _OnboardingDots({
    required this.currentIndex,
    required this.total,
  });

  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(total, (int index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          width: index == currentIndex ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == currentIndex ? AppColors.primary : AppColors.divider,
            borderRadius: BorderRadius.circular(AppSpacing.xs),
          ),
        );
      }),
    );
  }
}
