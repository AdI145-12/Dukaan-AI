import 'package:dukaan_ai/core/constants/app_routes.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/errors/error_handler.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/daily_plan/presentation/widgets/daily_plan_card.dart';
import 'package:dukaan_ai/features/studio/application/studio_provider.dart';
import 'package:dukaan_ai/features/studio/application/studio_state.dart';
import 'package:dukaan_ai/features/studio/domain/quick_create_item.dart';
import 'package:dukaan_ai/features/studio/presentation/widgets/generated_ad_card.dart';
import 'package:dukaan_ai/features/studio/presentation/widgets/quick_create_card.dart';
import 'package:dukaan_ai/features/studio/presentation/widgets/studio_skeleton.dart';
import 'package:dukaan_ai/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StudioScreen extends ConsumerStatefulWidget {
  const StudioScreen({super.key});

  @override
  ConsumerState<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends ConsumerState<StudioScreen>
    with AutomaticKeepAliveClientMixin {
  static const String _cameraCaptureRoute = AppRoutes.cameraCapture;

  static const List<QuickCreateItem> _quickCreate = <QuickCreateItem>[
    QuickCreateItem(
      emoji: '📷',
      label: AppStrings.quickCreatePhoto,
      route: _cameraCaptureRoute,
    ),
    QuickCreateItem(
      emoji: '🎉',
      label: AppStrings.quickCreateFestival,
      route: _cameraCaptureRoute,
    ),
    QuickCreateItem(
      emoji: '📱',
      label: AppStrings.quickCreateWhatsApp,
      route: _cameraCaptureRoute,
    ),
    QuickCreateItem(
      emoji: '🏷️',
      label: AppStrings.quickCreateOffer,
      route: _cameraCaptureRoute,
    ),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final AsyncValue<StudioState> studioAsync = ref.watch(studioProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          AppStrings.appName,
          style: AppTypography.headlineLarge.copyWith(
            color: AppColors.primary,
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: studioAsync.asData != null
                ? _CreditsChip(
                    credits: studioAsync.asData!.value.profile?.creditsRemaining ?? 0,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: studioAsync.when(
        loading: () => const StudioSkeleton(),
        error: (Object error, StackTrace stackTrace) => _ErrorBody(
          message: ErrorHandler.toUserMessage(error),
          onRetry: () => ref.invalidate(studioProvider),
        ),
        data: (StudioState state) => _StudioBody(
          state: state,
          quickCreate: _quickCreate,
          onRefresh: () => ref.read(studioProvider.notifier).refresh(),
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: AppStrings.retry,
              onPressed: onRetry,
              isFullWidth: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _StudioBody extends StatelessWidget {
  const _StudioBody({
    required this.state,
    required this.quickCreate,
    required this.onRefresh,
  });

  final StudioState state;
  final List<QuickCreateItem> quickCreate;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                <Widget>[
                  _HeaderSection(
                    shopName: state.profile?.shopName ?? AppStrings.appName,
                    festival: state.todayFestival,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const DailyPlanCard(),
                  const Text(
                    AppStrings.sectionQuickCreate,
                    style: AppTypography.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _QuickCreateRow(quickCreate: quickCreate),
                  const SizedBox(height: AppSpacing.lg),
                  const _RecentAdsHeader(),
                  const SizedBox(height: AppSpacing.sm),
                  if (state.recentAds.isEmpty)
                    const _EmptyAdsState()
                  else
                    ...state.recentAds.map(
                      (ad) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: GeneratedAdCard(
                          ad: ad,
                          onShare: () {
                            // TODO: Implement sharing in Task 1.8.
                          },
                          onDownload: () {
                            // TODO: Implement download in Task 1.8.
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.shopName,
    required this.festival,
  });

  final String shopName;
  final String? festival;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '${AppStrings.greetingPrefix}$shopName!',
          style: AppTypography.headlineLarge,
        ),
        if (festival != null) ...<Widget>[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Aaj hai: $festival',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ],
    );
  }
}

class _QuickCreateRow extends StatelessWidget {
  const _QuickCreateRow({required this.quickCreate});

  final List<QuickCreateItem> quickCreate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: quickCreate.map((QuickCreateItem item) {
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: QuickCreateCard(
              item: item,
              onTap: () {
                context.push(item.route);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RecentAdsHeader extends StatelessWidget {
  const _RecentAdsHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const Text(
          AppStrings.sectionRecentAds,
          style: AppTypography.headlineMedium,
        ),
        TextButton(
          onPressed: () => context.go(AppRoutes.myAds),
          child: Text(
            AppStrings.seeAll,
            style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _CreditsChip extends StatelessWidget {
  const _CreditsChip({required this.credits});

  final int credits;

  @override
  Widget build(BuildContext context) {
    final bool hasCredits = credits > 0;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.chip),
        color: hasCredits
            ? AppColors.primaryLight
            : AppColors.error.withValues(alpha: 0.1),
      ),
      child: Text(
        '$credits ${AppStrings.creditsLabel}',
        style: AppTypography.labelSmall.copyWith(
          color: hasCredits ? AppColors.primary : AppColors.error,
        ),
      ),
    );
  }
}

class _EmptyAdsState extends StatelessWidget {
  const _EmptyAdsState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.auto_awesome_outlined,
            size: AppSpacing.xxl,
            color: AppColors.textHint,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.emptyAds,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}