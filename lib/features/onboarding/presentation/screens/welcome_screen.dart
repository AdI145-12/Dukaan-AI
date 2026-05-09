import 'package:dukaan_ai/core/constants/app_routes.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: <Widget>[
              const SizedBox(height: AppSpacing.xxl),
              RepaintBoundary(
                child: Lottie.asset(
                  'assets/animations/shopkeeper.json',
                  height: 260,
                  fit: BoxFit.contain,
                  repeat: true,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                AppStrings.onboardingHeadline,
                textAlign: TextAlign.center,
                style: AppTypography.displayLarge,
              ),
              const SizedBox(height: AppSpacing.sm + 4),
              Text(
                AppStrings.onboardingSubheadline,
                textAlign: TextAlign.center,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              const _OnboardingDots(currentIndex: 0, total: 3),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: AppStrings.onboardingCta,
                onPressed: () => context.push(AppRoutes.onboardingSetup),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => context.push(AppRoutes.onboardingPhone),
                child: Text(
                  AppStrings.onboardingSkip,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
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
