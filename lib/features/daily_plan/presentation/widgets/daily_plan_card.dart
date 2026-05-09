import 'package:dukaan_ai/core/constants/app_routes.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/providers/firebase_providers.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_shadows.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/daily_plan/application/daily_plan_provider.dart';
import 'package:dukaan_ai/features/daily_plan/domain/models/daily_content_plan.dart';
import 'package:dukaan_ai/features/studio/application/studio_provider.dart';
import 'package:dukaan_ai/shared/widgets/app_button.dart';
import 'package:dukaan_ai/shared/widgets/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DailyPlanCard extends ConsumerWidget {
  const DailyPlanCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DailyContentPlan?> planAsync = ref.watch(dailyPlanProvider);

    return planAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.lg),
        child: _DailyPlanLoadingCard(),
      ),
      error: (Object _, StackTrace __) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: _DailyPlanErrorCard(
            onRetry: () {
              ref.read(dailyPlanDismissedProvider.notifier).reset();
              ref.invalidate(dailyPlanProvider);
            },
            onDismiss: () => ref.read(dailyPlanDismissedProvider.notifier).dismiss(),
          ),
        );
      },
      data: (DailyContentPlan? plan) {
        if (plan == null) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: _DailyPlanContent(
            plan: plan,
            onDismiss: () => ref.read(dailyPlanDismissedProvider.notifier).dismiss(),
            onRefresh: () {
              ref.read(dailyPlanDismissedProvider.notifier).reset();
              ref.invalidate(dailyPlanProvider);
            },
            onApply: () async {
              final String userId = ref.read(currentUserIdProvider);
              if (userId.trim().isNotEmpty) {
                await ref.read(studioRepositoryProvider).trackUsageEvent(
                      userId: userId,
                      eventType: 'daily_plan_applied',
                      metadata: <String, dynamic>{
                        'title': plan.title,
                        'festival': plan.festivalTag,
                        'suggestedProduct': plan.suggestedProductName,
                      },
                    );
              }

              if (!context.mounted) {
                return;
              }
              context.push(AppRoutes.cameraCapture);
            },
          ),
        );
      },
    );
  }
}

class _DailyPlanContent extends StatelessWidget {
  const _DailyPlanContent({
    required this.plan,
    required this.onDismiss,
    required this.onRefresh,
    required this.onApply,
  });

  final DailyContentPlan plan;
  final VoidCallback onDismiss;
  final VoidCallback onRefresh;
  final VoidCallback onApply;

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
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  AppStrings.dailyPlanTitle,
                  style: AppTypography.headlineMedium,
                ),
              ),
              IconButton(
                onPressed: onDismiss,
                tooltip: AppStrings.dailyPlanDismissTooltip,
                icon: const Icon(
                  Icons.close,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (plan.festivalTag != null) ...<Widget>[
            _TagPill(label: plan.festivalTag!),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            plan.title,
            style: AppTypography.headlineLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            plan.reason,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (plan.suggestedProductName != null) ...<Widget>[
            _TagPill(label: '${AppStrings.dailyPlanProductPrefix}${plan.suggestedProductName}'),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            plan.captionIdea,
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: AppButton(
                  label: plan.callToAction.isEmpty
                      ? AppStrings.dailyPlanApplyButton
                      : plan.callToAction,
                  onPressed: onApply,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onRefresh,
              child: const Text(AppStrings.dailyPlanRefresh),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}

class _DailyPlanLoadingCard extends StatelessWidget {
  const _DailyPlanLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ShimmerBox(width: 180, height: 20),
          SizedBox(height: AppSpacing.sm),
          ShimmerBox(width: double.infinity, height: 24),
          SizedBox(height: AppSpacing.xs),
          ShimmerBox(width: double.infinity, height: 16),
          SizedBox(height: AppSpacing.md),
          ShimmerBox(width: double.infinity, height: 48),
        ],
      ),
    );
  }
}

class _DailyPlanErrorCard extends StatelessWidget {
  const _DailyPlanErrorCard({
    required this.onRetry,
    required this.onDismiss,
  });

  final VoidCallback onRetry;
  final VoidCallback onDismiss;

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
          const Expanded(
            child: Text(
              AppStrings.dailyPlanLoadError,
              style: AppTypography.bodyMedium,
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text(AppStrings.retry),
          ),
          IconButton(
            onPressed: onDismiss,
            tooltip: AppStrings.dailyPlanDismissTooltip,
            icon: const Icon(Icons.close, size: 20),
          ),
        ],
      ),
    );
  }
}
