import 'package:dukaan_ai/core/constants/app_routes.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/errors/error_handler.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_shadows.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/studio/application/studio_provider.dart';
import 'package:dukaan_ai/features/studio/application/studio_state.dart';
import 'package:dukaan_ai/features/studio/domain/quick_create_item.dart';
import 'package:dukaan_ai/features/studio/presentation/widgets/generated_ad_card.dart';
import 'package:dukaan_ai/features/studio/presentation/widgets/quick_create_card.dart';
import 'package:dukaan_ai/shared/widgets/app_button.dart';
import 'package:dukaan_ai/shared/widgets/app_error_view.dart';
import 'package:dukaan_ai/shared/widgets/section_header.dart';
import 'package:dukaan_ai/shared/widgets/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const String _emptyAdsAsset = 'assets/animations/shopkeeper.json';

/// Studio home screen with the refreshed card-based layout.
class StudioHomeScreen extends ConsumerWidget {
	/// Creates a new studio home screen.
	const StudioHomeScreen({super.key});

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
	Widget build(BuildContext context, WidgetRef ref) {
		final AsyncValue<StudioState> studioAsync = ref.watch(studioProvider);
		final int credits = studioAsync.asData?.value.profile?.creditsRemaining ?? 0;

		return Scaffold(
			backgroundColor: AppColors.background,
			appBar: AppBar(
				backgroundColor: AppColors.transparent,
				surfaceTintColor: AppColors.transparent,
				elevation: 0,
				scrolledUnderElevation: 0,
				title: null,
				actions: <Widget>[
					Padding(
						padding: const EdgeInsets.only(right: AppSpacing.sm),
						child: studioAsync.asData != null
								? CreditIndicator(credits: credits)
								: const SizedBox.shrink(),
					),
				],
			),
			body: studioAsync.when(
				loading: () => const _LoadingBody(),
				error: (Object error, StackTrace _) => AppErrorView(
					message: ErrorHandler.toUserMessage(error),
					onRetry: () => ref.invalidate(studioProvider),
				),
				data: (StudioState state) => _DataBody(
					state: state,
					onRefresh: () => ref.read(studioProvider.notifier).refresh(),
				),
			),
			floatingActionButton: FloatingActionButton(
				heroTag: 'studio_camera_fab',
				onPressed: () => context.push(AppRoutes.cameraCapture),
				backgroundColor: AppColors.primary,
				foregroundColor: AppColors.surface,
				tooltip: AppStrings.fabNewAd,
				child: const Icon(Icons.camera_alt),
			),
			floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
		);
	}
}

class _DataBody extends StatelessWidget {
	const _DataBody({
		required this.state,
		required this.onRefresh,
	});

	final StudioState state;
	final Future<void> Function() onRefresh;

	@override
	Widget build(BuildContext context) {
		final String festivalSuggestion = state.todayFestival?.trim() ?? '';
		final bool hasFestivalSuggestion = festivalSuggestion.isNotEmpty;

		return RefreshIndicator(
			color: AppColors.primary,
			onRefresh: onRefresh,
			child: SingleChildScrollView(
				physics: const AlwaysScrollableScrollPhysics(),
				padding: const EdgeInsets.all(AppSpacing.md),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: <Widget>[
						Text(
							AppStrings.greetingPrefix.trim(),
							style: AppTypography.headlineMedium.copyWith(
								color: AppColors.textSecondary,
							),
						),
						Text(
							state.profile?.shopName ?? AppStrings.appName,
							style: AppTypography.displayMedium.copyWith(
								color: AppColors.textPrimary,
								fontWeight: FontWeight.w700,
							),
						),
						const SizedBox(height: AppSpacing.md),
						if (hasFestivalSuggestion) ...<Widget>[
							_FestivalPlanCard(
								festivalSuggestion: festivalSuggestion,
								onAction: () => context.push(AppRoutes.cameraCapture),
							),
							const SizedBox(height: AppSpacing.lg),
						],
						const SectionHeader(title: AppStrings.sectionQuickCreate),
						const SizedBox(height: AppSpacing.sm),
						Row(
							mainAxisAlignment: MainAxisAlignment.spaceEvenly,
							children: StudioHomeScreen._quickCreate
									.map(
										(QuickCreateItem item) => QuickActionCard(
											item: item,
											onTap: () => context.push(item.route),
										),
									)
									.toList(),
						),
						const SizedBox(height: AppSpacing.lg),
						SectionHeader(
							title: AppStrings.sectionRecentAds,
							actionLabel: AppStrings.seeAll,
							onAction: () => context.go(AppRoutes.myAds),
						),
						const SizedBox(height: AppSpacing.sm),
						if (state.recentAds.isEmpty)
							AppEmptyState(
								asset: _emptyAdsAsset,
								title: AppStrings.emptyAds,
								ctaLabel: AppStrings.generateAdButton,
								onTap: () => context.push(AppRoutes.cameraCapture),
							)
						else
							GridView.builder(
								itemCount: state.recentAds.length,
								shrinkWrap: true,
								physics: const NeverScrollableScrollPhysics(),
								gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
									crossAxisCount: 2,
									crossAxisSpacing: AppSpacing.sm,
									mainAxisSpacing: AppSpacing.sm,
									childAspectRatio: 1.82,
								),
								itemBuilder: (BuildContext context, int index) {
									final ad = state.recentAds[index];
									return AdCard(
										ad: ad,
										onShare: () {
											// TODO: Implement sharing in Task 1.8.
										},
										onDownload: () {
											// TODO: Implement download in Task 1.8.
										},
									);
								},
							),
						const SizedBox(height: AppSpacing.xxl),
					],
				),
			),
		);
	}
}

class _FestivalPlanCard extends StatelessWidget {
	const _FestivalPlanCard({
		required this.festivalSuggestion,
		required this.onAction,
	});

	final String festivalSuggestion;
	final VoidCallback onAction;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: const EdgeInsets.all(AppSpacing.md),
			decoration: BoxDecoration(
				color: AppColors.cardSurface,
				borderRadius: BorderRadius.circular(AppRadius.card),
				boxShadow: AppShadows.card,
			),
			child: Row(
				children: <Widget>[
					const Icon(
						Icons.calendar_today_outlined,
						color: AppColors.primary,
						size: AppSpacing.iconMd,
					),
					const SizedBox(width: AppSpacing.sm),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: <Widget>[
								Text(
									AppStrings.dailyPlanTitle,
									style: AppTypography.labelSmall.copyWith(
										color: AppColors.textSecondary,
									),
								),
								const SizedBox(height: AppSpacing.xs),
								Text(
									festivalSuggestion,
									style: AppTypography.bodyLarge.copyWith(
										fontWeight: FontWeight.w600,
									),
								),
							],
						),
					),
					const SizedBox(width: AppSpacing.sm),
					TextButton(
						onPressed: onAction,
						style: TextButton.styleFrom(
							padding: EdgeInsets.zero,
							minimumSize: Size.zero,
							tapTargetSize: MaterialTapTargetSize.shrinkWrap,
							visualDensity: VisualDensity.compact,
						),
						child: Text(
							'${AppStrings.generateAdButton} →',
							style: AppTypography.labelLarge.copyWith(
								color: AppColors.primary,
							),
						),
					),
				],
			),
		);
	}
}

/// Credit pill shown in the app bar.
class CreditIndicator extends StatelessWidget {
	/// Creates a new credit indicator.
	const CreditIndicator({super.key, required this.credits});

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

/// Alias for the existing quick create widget.
class QuickActionCard extends QuickCreateCard {
	/// Creates a new quick action card.
	const QuickActionCard({
		super.key,
		required super.item,
		required super.onTap,
	});
}

/// Alias for the existing generated ad card.
class AdCard extends GeneratedAdCard {
	/// Creates a new ad card.
	const AdCard({
		super.key,
		required super.ad,
		required super.onShare,
		required super.onDownload,
	});
}

/// Skeleton card used while the recent ads list is loading.
class ShimmerAdCard extends StatelessWidget {
	/// Creates a new shimmer ad card.
	const ShimmerAdCard({super.key});

	@override
	Widget build(BuildContext context) {
		return Container(
			height: 88,
			decoration: BoxDecoration(
				color: AppColors.surface,
				borderRadius: BorderRadius.circular(AppRadius.card),
				boxShadow: AppShadows.card,
			),
			child: const Row(
				children: <Widget>[
					ClipRRect(
						borderRadius: BorderRadius.only(
							topLeft: Radius.circular(AppRadius.card),
							bottomLeft: Radius.circular(AppRadius.card),
						),
						child: ShimmerBox(
							width: 120,
							height: 88,
							borderRadius: 0,
						),
					),
					Expanded(
						child: Padding(
							padding: EdgeInsets.symmetric(
								horizontal: AppSpacing.sm,
								vertical: AppSpacing.sm,
							),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: <Widget>[
									ShimmerBox(width: 72, height: 12),
									ShimmerBox(width: 96, height: 12),
									Align(
										alignment: Alignment.centerRight,
										child: Row(
											mainAxisSize: MainAxisSize.min,
											children: <Widget>[
												ShimmerBox(width: 20, height: 20),
												SizedBox(width: AppSpacing.xs),
												ShimmerBox(width: 20, height: 20),
											],
										),
									),
								],
							),
						),
					),
				],
			),
		);
	}
}

/// Empty state shown when there are no recent ads.
class AppEmptyState extends StatelessWidget {
	/// Creates a new empty state.
	const AppEmptyState({
		super.key,
		required this.asset,
		required this.title,
		required this.ctaLabel,
		required this.onTap,
	});

	final String asset;
	final String title;
	final String ctaLabel;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: const EdgeInsets.all(AppSpacing.lg),
			child: Column(
				mainAxisSize: MainAxisSize.min,
				children: <Widget>[
					Semantics(
						label: asset,
						child: const Icon(
							Icons.auto_awesome_outlined,
							size: AppSpacing.xxl,
							color: AppColors.textHint,
						),
					),
					const SizedBox(height: AppSpacing.sm),
					Text(
						title,
						style: AppTypography.bodyMedium.copyWith(
							color: AppColors.textSecondary,
						),
						textAlign: TextAlign.center,
					),
					const SizedBox(height: AppSpacing.md),
					AppButton(
						label: ctaLabel,
						onPressed: onTap,
						isFullWidth: true,
					),
				],
			),
		);
	}
}

class _LoadingBody extends StatelessWidget {
	const _LoadingBody();

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: const EdgeInsets.all(AppSpacing.md),
			child: GridView.builder(
				itemCount: 4,
				shrinkWrap: true,
				physics: const NeverScrollableScrollPhysics(),
				gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
					crossAxisCount: 2,
					crossAxisSpacing: AppSpacing.sm,
					mainAxisSpacing: AppSpacing.sm,
					childAspectRatio: 1.82,
				),
				itemBuilder: (BuildContext context, int index) {
					return const ShimmerAdCard();
				},
			),
		);
	}
}
