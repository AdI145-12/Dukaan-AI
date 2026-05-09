import 'dart:async';

import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/account/application/payment_service.dart';
import 'package:dukaan_ai/features/account/application/profile_provider.dart';
import 'package:dukaan_ai/features/account/domain/pricing_plans.dart';
import 'package:dukaan_ai/shared/widgets/app_bottom_sheet.dart';
import 'package:dukaan_ai/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PricingScreen extends ConsumerStatefulWidget {
  const PricingScreen({super.key});

  @override
  ConsumerState<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends ConsumerState<PricingScreen> {
  bool _showPlans = true;
  bool _isLoading = false;
  PlanTier? _currentTier;

  @override
  void initState() {
    super.initState();
    unawaited(_loadCurrentTier());
  }

  Future<void> _loadCurrentTier() async {
    final PlanTier tier = await ref.read(accountTierProvider.future);
    if (!mounted) {
      return;
    }
    setState(() => _currentTier = tier);
  }

  Future<void> _handlePlanTap(Plan plan) async {
    if (plan.amountPaise == 0 || _isLoading) {
      return;
    }

    final String userId = FirebaseService.currentUserId ?? '';
    setState(() => _isLoading = true);
    try {
      final PaymentResult result =
          await ref.read(paymentServiceProvider).initiatePayment(
                planId: plan.tier.name,
                amountPaise: plan.amountPaise,
                userId: userId,
              );
      if (!mounted) {
        return;
      }

      switch (result) {
        case PaymentSuccess(:final String transactionId):
          ref.invalidate(accountTierProvider);
          setState(() => _currentTier = plan.tier);
          await _showSuccessSheet(plan.name, transactionId);
        case PaymentFailure(:final String message):
          _showErrorSnack(message);
        case PaymentCancelled():
          break;
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handlePackTap(AdPack pack) async {
    if (_isLoading) {
      return;
    }

    final String userId = FirebaseService.currentUserId ?? '';
    setState(() => _isLoading = true);
    try {
      final PaymentResult result =
          await ref.read(paymentServiceProvider).initiatePayment(
                planId: pack.id,
                amountPaise: pack.amountPaise,
                userId: userId,
              );
      if (!mounted) {
        return;
      }

      switch (result) {
        case PaymentSuccess(:final String transactionId):
          await _showSuccessSheet(pack.name, transactionId);
        case PaymentFailure(:final String message):
          _showErrorSnack(message);
        case PaymentCancelled():
          break;
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showSuccessSheet(String planName, String transactionId) {
    return AppBottomSheet.show<void>(
      context: context,
      title: '',
      isDismissible: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: AppSpacing.xxl + AppSpacing.lg,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '$planName ${AppStrings.paymentSuccessTitle}',
              style: AppTypography.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${AppStrings.transactionIdPrefix}$transactionId',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: AppStrings.paymentSuccessCta,
              onPressed: () {
                Navigator.of(context).pop();
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<PlanTier> tierAsync = ref.watch(accountTierProvider);
    final PlanTier? providerTier = tierAsync.maybeWhen(
      data: (PlanTier tier) => tier,
      orElse: () => null,
    );
    final PlanTier currentTier = _currentTier ?? providerTier ?? PlanTier.free;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          AppStrings.pricingTitle,
          style: AppTypography.headlineLarge,
        ),
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            child: Column(
              children: <Widget>[
                _PlanToggle(
                  showPlans: _showPlans,
                  onChanged: (bool showPlans) {
                    if (_showPlans == showPlans) {
                      return;
                    }
                    setState(() => _showPlans = showPlans);
                  },
                ),
                if (_showPlans)
                  ...kPlans.map(
                    (Plan plan) => _PlanCard(
                      plan: plan,
                      isCurrentPlan: plan.tier == currentTier,
                      onSelect: () => unawaited(_handlePlanTap(plan)),
                    ),
                  )
                else
                  ...kAdPacks.map(
                    (AdPack pack) => _AdPackCard(
                      pack: pack,
                      onBuy: () => unawaited(_handlePackTap(pack)),
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                const _TrustIndicators(),
              ],
            ),
          ),
          if (_isLoading) const _PaymentLoadingOverlay(),
        ],
      ),
    );
  }
}

class _PlanToggle extends StatelessWidget {
  const _PlanToggle({
    required this.showPlans,
    required this.onChanged,
  });

  final bool showPlans;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _ToggleButton(
              label: AppStrings.monthlyPlansTab,
              selected: showPlans,
              onTap: () => onChanged(true),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: _ToggleButton(
              label: AppStrings.adPacksTab,
              selected: !showPlans,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.button),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: selected ? AppColors.surface : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isCurrentPlan,
    required this.onSelect,
  });

  final Plan plan;
  final bool isCurrentPlan;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sheet),
        border: Border.all(
          color: plan.isHighlighted ? AppColors.primary : AppColors.divider,
          width: plan.isHighlighted ? 2 : 1,
        ),
        boxShadow: plan.isHighlighted
            ? <BoxShadow>[
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: AppSpacing.md,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: <Widget>[
          if (plan.isMostPopular)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm - 2),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.sheet - 1),
                  topRight: Radius.circular(AppRadius.sheet - 1),
                ),
              ),
              child: const Text(
                AppStrings.mostPopularBadge,
                style: AppTypography.labelSmall,
                textAlign: TextAlign.center,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(plan.name, style: AppTypography.headlineMedium),
                    const Spacer(),
                    Text(
                      plan.price,
                      style: AppTypography.displayMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    plan.adsPerMonth == 999999
                        ? AppStrings.unlimitedAds
                        : '${plan.adsPerMonth}${AppStrings.adsPerMonthSuffix}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm + 4),
                ...plan.features.map(
                  (String feature) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: AppSpacing.md,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(feature, style: AppTypography.labelSmall),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (isCurrentPlan)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 4),
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                    child: Text(
                      AppStrings.currentPlanLabel,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else if (plan.tier != PlanTier.free)
                  AppButton(
                    label: '${AppStrings.selectPlanPrefix}${plan.price}',
                    onPressed: onSelect,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdPackCard extends StatelessWidget {
  const _AdPackCard({
    required this.pack,
    required this.onBuy,
  });

  final AdPack pack;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: pack.isRecommended ? AppColors.primary : AppColors.divider,
          width: pack.isRecommended ? 2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(pack.name, style: AppTypography.headlineMedium),
                const SizedBox(height: AppSpacing.xs),
                if (pack.badge.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppSpacing.xs),
                    ),
                    child: Text(
                      pack.badge,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  pack.creditsGranted == -1
                      ? AppStrings.sevenDayUnlimited
                      : '${pack.creditsGranted}${AppStrings.adCredits}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            children: <Widget>[
              Text(
                pack.price,
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: 110,
                child: AppButton(
                  label: AppStrings.buyPackButton,
                  onPressed: onBuy,
                  isFullWidth: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrustIndicators extends StatelessWidget {
  const _TrustIndicators();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md - 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _TrustBadge(icon: Icons.lock, text: AppStrings.trustRazorpay),
          _TrustBadge(icon: Icons.support_agent, text: AppStrings.trustSupport),
          _TrustBadge(icon: Icons.replay_outlined, text: AppStrings.trustRefund),
        ],
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  const _TrustBadge({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(icon, color: AppColors.textSecondary),
        const SizedBox(height: AppSpacing.xs),
        Text(
          text,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _PaymentLoadingOverlay extends StatelessWidget {
  const _PaymentLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AbsorbPointer(
        child: Container(
          color: Colors.black.withValues(alpha: 0.6),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: AppSpacing.md),
                Text(
                  AppStrings.paymentInProgress,
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
