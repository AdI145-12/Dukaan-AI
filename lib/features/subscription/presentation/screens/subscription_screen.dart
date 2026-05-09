import 'dart:async';

import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_shadows.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/features/account/application/payment_service.dart';
import 'package:dukaan_ai/features/subscription/application/subscription_provider.dart';
import 'package:dukaan_ai/shared/widgets/app_button.dart';
import 'package:dukaan_ai/shared/widgets/app_error_view.dart';
import 'package:dukaan_ai/shared/widgets/app_snackbar.dart';
import 'package:dukaan_ai/shared/widgets/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

const String _rupeeSymbol = '\u20B9';

const List<_SubscriptionPlan> _monthlyPlans = <_SubscriptionPlan>[
  _SubscriptionPlan(
    id: 'free',
    tierValue: 'free',
    title: AppStrings.subscriptionPlanFree,
    priceLabel: '${_rupeeSymbol}0',
    amountPaise: 0,
    adsPerMonth: 3,
    perks: <String>[
      AppStrings.subscriptionPerkBasicBg,
      AppStrings.subscriptionPerkWatermark,
    ],
  ),
  _SubscriptionPlan(
    id: 'dukaan_monthly',
    tierValue: 'dukaan',
    title: AppStrings.subscriptionPlanDukaan,
    priceLabel: '${_rupeeSymbol}99/mo',
    amountPaise: 9900,
    adsPerMonth: 30,
    perks: <String>[
      AppStrings.subscriptionPerkAllBg,
      AppStrings.subscriptionPerkHindiCaptions,
    ],
  ),
  _SubscriptionPlan(
    id: 'vyapaar_monthly',
    tierValue: 'vyapaar',
    title: AppStrings.subscriptionPlanVyapaar,
    priceLabel: '${_rupeeSymbol}199/mo',
    amountPaise: 19900,
    adsPerMonth: 100,
    perks: <String>[
      AppStrings.subscriptionPerkKhata,
      AppStrings.subscriptionPerkCatalogue,
    ],
    isMostPopular: true,
  ),
  _SubscriptionPlan(
    id: 'utsav_monthly',
    tierValue: 'utsav',
    title: AppStrings.subscriptionPlanUtsav,
    priceLabel: '${_rupeeSymbol}499/mo',
    amountPaise: 49900,
    adsPerMonth: 500,
    perks: <String>[AppStrings.subscriptionPerkBulkWhatsapp],
  ),
];

const List<_AdPackOption> _adPacks = <_AdPackOption>[
  _AdPackOption(
    id: 'ad_pack_chhota',
    title: AppStrings.subscriptionPackChhota,
    priceLabel: '${_rupeeSymbol}29',
    amountPaise: 2900,
    credits: 10,
  ),
  _AdPackOption(
    id: 'ad_pack_bada',
    title: AppStrings.subscriptionPackBada,
    priceLabel: '${_rupeeSymbol}59',
    amountPaise: 5900,
    credits: 25,
  ),
  _AdPackOption(
    id: 'ad_pack_super',
    title: AppStrings.subscriptionPackSuper,
    priceLabel: '${_rupeeSymbol}99',
    amountPaise: 9900,
    credits: 50,
  ),
];

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen>
    with AutomaticKeepAliveClientMixin<SubscriptionScreen> {
  static final Logger _logger = Logger();

  bool _showMonthly = true;
  bool _showFullHistory = false;
  bool _isPaying = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final AsyncValue<SubscriptionData> state = ref.watch(subscriptionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          AppStrings.subscriptionTitle,
          style: AppTypography.headlineLarge,
        ),
      ),
      body: state.when(
        data: (SubscriptionData data) => _buildLoadedState(context, data),
        loading: () => const _SubscriptionLoadingState(),
        error: (Object error, StackTrace stackTrace) {
          return AppErrorView(
            message: AppStrings.subscriptionPlansLoadError,
            onRetry: () => ref.invalidate(subscriptionProvider),
          );
        },
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, SubscriptionData data) {
    final String normalizedTier = _normalizeTier(data.tier);
    final _SubscriptionPlan currentPlan = _resolveCurrentPlan(normalizedTier);
    final String billingLabel = _billingLabel(data.tier);

    return Stack(
      children: <Widget>[
        RefreshIndicator(
          onRefresh: _refreshSubscription,
          color: AppColors.primary,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: <Widget>[
              _CurrentPlanCard(
                planName: currentPlan.title,
                creditsRemaining: data.creditsRemaining,
                billingLabel: billingLabel,
              ),
              const SizedBox(height: AppSpacing.md),
              _PlansToggle(
                showMonthly: _showMonthly,
                onChanged: (bool showMonthly) {
                  if (_showMonthly == showMonthly) {
                    return;
                  }
                  setState(() {
                    _showMonthly = showMonthly;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              if (_showMonthly)
                ..._monthlyPlans.map(
                  (_SubscriptionPlan plan) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _PlanCard(
                      plan: plan,
                      isCurrentPlan: plan.tierValue == normalizedTier,
                      onSelect: () => _onPlanSelected(plan),
                    ),
                  ),
                )
              else
                ..._adPacks.map(
                  (_AdPackOption pack) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _AdPackCard(
                      pack: pack,
                      onBuy: () => _onPackSelected(pack),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              _TransactionHistoryCard(
                transactions: data.transactions,
                showAll: _showFullHistory,
                onToggle: _toggleHistory,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
        if (_isPaying) const _PaymentLoadingOverlay(),
      ],
    );
  }

  Future<void> _refreshSubscription() async {
    ref.invalidate(subscriptionProvider);
    await ref.read(subscriptionProvider.future);
  }

  Future<void> _onPlanSelected(_SubscriptionPlan plan) async {
    if (plan.amountPaise <= 0 || _isPaying) {
      return;
    }
    await _startPayment(
      planId: plan.id,
      amountPaise: plan.amountPaise,
      displayName: plan.title,
    );
  }

  Future<void> _onPackSelected(_AdPackOption pack) async {
    if (_isPaying) {
      return;
    }
    await _startPayment(
      planId: pack.id,
      amountPaise: pack.amountPaise,
      displayName: pack.title,
    );
  }

  Future<void> _startPayment({
    required String planId,
    required int amountPaise,
    required String displayName,
  }) async {
    final String? userId = FirebaseService.currentUserId;
    if (userId == null || userId.trim().isEmpty) {
      _showSnack(message: AppStrings.errorAuth, type: AppSnackBarType.error);
      return;
    }

    setState(() {
      _isPaying = true;
    });

    try {
      final PaymentResult result =
          await ref.read(paymentServiceProvider).initiatePayment(
                planId: planId,
                amountPaise: amountPaise,
                userId: userId,
              );

      if (!mounted) {
        return;
      }

      switch (result) {
        case PaymentSuccess():
          ref.invalidate(subscriptionProvider);
          _showSnack(
            message: '$displayName ${AppStrings.paymentSuccessTitle}',
            type: AppSnackBarType.success,
          );
        case PaymentFailure(:final String message):
          _showSnack(message: message, type: AppSnackBarType.error);
        case PaymentCancelled():
          _showSnack(
            message: AppStrings.paymentCancelled,
            type: AppSnackBarType.warning,
          );
      }
    } catch (error, stackTrace) {
      _logger.e(
        'subscription_payment_failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        _showSnack(
          message: AppStrings.paymentSupportMessage,
          type: AppSnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPaying = false;
        });
      }
    }
  }

  void _showSnack({
    required String message,
    required AppSnackBarType type,
  }) {
    if (!mounted) {
      return;
    }

    AppSnackBar.show(
      context,
      message: message,
      type: type,
    );
  }

  void _toggleHistory() {
    setState(() {
      _showFullHistory = !_showFullHistory;
    });
  }

  _SubscriptionPlan _resolveCurrentPlan(String normalizedTier) {
    for (final _SubscriptionPlan plan in _monthlyPlans) {
      if (plan.tierValue == normalizedTier) {
        return plan;
      }
    }
    return _monthlyPlans.first;
  }

  String _billingLabel(String tier) {
    final String normalizedTier = tier.trim().toLowerCase();
    if (normalizedTier.startsWith('ad_pack') ||
        normalizedTier.contains('pack')) {
      return AppStrings.subscriptionOneTimePack;
    }
    return AppStrings.subscriptionMonthlyReset;
  }

  String _normalizeTier(String tier) {
    final String normalized = tier.trim().toLowerCase();
    if (normalized == 'dukaan_monthly') {
      return 'dukaan';
    }
    if (normalized == 'vyapaar_monthly') {
      return 'vyapaar';
    }
    if (normalized == 'utsav_monthly') {
      return 'utsav';
    }
    return normalized;
  }
}

class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard({
    required this.planName,
    required this.creditsRemaining,
    required this.billingLabel,
  });

  final String planName;
  final int creditsRemaining;
  final String billingLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            child: Text(
              planName,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.surface,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$creditsRemaining${AppStrings.subscriptionCreditsSuffix}',
            style: AppTypography.headlineLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            billingLabel,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlansToggle extends StatelessWidget {
  const _PlansToggle({
    required this.showMonthly,
    required this.onChanged,
  });

  final bool showMonthly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              selected: showMonthly,
              onTap: () => onChanged(true),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: _ToggleButton(
              label: AppStrings.adPacksTab,
              selected: !showMonthly,
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
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.sm,
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

  final _SubscriptionPlan plan;
  final bool isCurrentPlan;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isCurrentPlan ? AppColors.primaryLight : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (plan.isMostPopular)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.card),
                  topRight: Radius.circular(AppRadius.card),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(plan.title, style: AppTypography.headlineMedium),
                    const Spacer(),
                    Text(
                      plan.priceLabel,
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${plan.adsPerMonth}${AppStrings.adsPerMonthSuffix}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...plan.perks.map(
                  (String perk) => Padding(
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
                          child: Text(perk, style: AppTypography.labelSmall),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (isCurrentPlan)
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                    child: const Text(
                      AppStrings.currentPlanLabel,
                      style: AppTypography.labelLarge,
                      textAlign: TextAlign.center,
                    ),
                  )
                else if (plan.amountPaise > 0)
                  AppButton(
                    label: '${AppStrings.selectPlanPrefix}${plan.priceLabel}',
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

  final _AdPackOption pack;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(pack.title, style: AppTypography.headlineMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${pack.credits}${AppStrings.adCredits}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            pack.priceLabel,
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 110,
            child: AppButton(
              label: AppStrings.buyPackButton,
              isFullWidth: true,
              onPressed: onBuy,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionHistoryCard extends StatelessWidget {
  const _TransactionHistoryCard({
    required this.transactions,
    required this.showAll,
    required this.onToggle,
  });

  final List<SubscriptionTransaction> transactions;
  final bool showAll;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final List<SubscriptionTransaction> visibleTransactions =
        showAll ? transactions : transactions.take(5).toList(growable: false);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text(
                AppStrings.subscriptionHistoryTitle,
                style: AppTypography.headlineMedium,
              ),
              const Spacer(),
              if (transactions.length > 5)
                TextButton(
                  onPressed: onToggle,
                  child: Text(
                    showAll
                        ? AppStrings.subscriptionViewLess
                        : AppStrings.subscriptionViewMore,
                  ),
                ),
            ],
          ),
          if (visibleTransactions.isEmpty)
            Text(
              AppStrings.subscriptionNoTransactions,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            ...visibleTransactions.map(
              (SubscriptionTransaction transaction) => RepaintBoundary(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _planLabel(transaction.planId),
                              style: AppTypography.labelLarge,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              DateFormat('dd MMM yyyy')
                                  .format(transaction.createdAt),
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _amountLabel(transaction),
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _planLabel(String planId) {
    const Map<String, String> labels = <String, String>{
      'free': AppStrings.subscriptionPlanFree,
      'dukaan': AppStrings.subscriptionPlanDukaan,
      'dukaan_monthly': AppStrings.subscriptionPlanDukaan,
      'vyapaar': AppStrings.subscriptionPlanVyapaar,
      'vyapaar_monthly': AppStrings.subscriptionPlanVyapaar,
      'utsav': AppStrings.subscriptionPlanUtsav,
      'utsav_monthly': AppStrings.subscriptionPlanUtsav,
      'starter_pack': AppStrings.subscriptionPackChhota,
      'value_pack': AppStrings.subscriptionPackSuper,
      'festival_pack': AppStrings.subscriptionPackFestival,
      'ad_pack_chhota': AppStrings.subscriptionPackChhota,
      'ad_pack_bada': AppStrings.subscriptionPackBada,
      'ad_pack_super': AppStrings.subscriptionPackSuper,
    };

    return labels[planId] ?? planId;
  }

  String _amountLabel(SubscriptionTransaction transaction) {
    final int? explicitAmount = transaction.amountPaise;
    if (explicitAmount != null) {
      return _formatAmount(explicitAmount);
    }

    return _formatAmount(_fallbackAmount(transaction.planId));
  }

  int _fallbackAmount(String planId) {
    const Map<String, int> amountMap = <String, int>{
      'free': 0,
      'dukaan': 9900,
      'dukaan_monthly': 9900,
      'vyapaar': 24900,
      'vyapaar_monthly': 19900,
      'utsav': 49900,
      'utsav_monthly': 49900,
      'starter_pack': 2900,
      'value_pack': 9900,
      'festival_pack': 19900,
      'ad_pack_chhota': 2900,
      'ad_pack_bada': 5900,
      'ad_pack_super': 9900,
    };

    return amountMap[planId] ?? 0;
  }

  String _formatAmount(int amountPaise) {
    final double value = amountPaise / 100;
    final bool whole = amountPaise % 100 == 0;
    final String formatted =
        whole ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
    return '$_rupeeSymbol$formatted';
  }
}

class _SubscriptionLoadingState extends StatelessWidget {
  const _SubscriptionLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: const <Widget>[
        ShimmerBox(width: double.infinity, height: 140),
        SizedBox(height: AppSpacing.md),
        ShimmerBox(width: double.infinity, height: 44),
        SizedBox(height: AppSpacing.sm),
        ShimmerBox(width: double.infinity, height: 180),
        SizedBox(height: AppSpacing.sm),
        ShimmerBox(width: double.infinity, height: 180),
        SizedBox(height: AppSpacing.md),
        ShimmerBox(width: double.infinity, height: 220),
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
          color: Colors.black.withValues(alpha: 0.55),
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

class _SubscriptionPlan {
  const _SubscriptionPlan({
    required this.id,
    required this.tierValue,
    required this.title,
    required this.priceLabel,
    required this.amountPaise,
    required this.adsPerMonth,
    required this.perks,
    this.isMostPopular = false,
  });

  final String id;
  final String tierValue;
  final String title;
  final String priceLabel;
  final int amountPaise;
  final int adsPerMonth;
  final List<String> perks;
  final bool isMostPopular;
}

class _AdPackOption {
  const _AdPackOption({
    required this.id,
    required this.title,
    required this.priceLabel,
    required this.amountPaise,
    required this.credits,
  });

  final String id;
  final String title;
  final String priceLabel;
  final int amountPaise;
  final int credits;
}
