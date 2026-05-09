import 'dart:async';
import 'dart:io';

import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/constants/app_routes.dart';
import 'package:dukaan_ai/core/constants/app_assets.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_shadows.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/my_ads/application/my_ads_notifier.dart';
import 'package:dukaan_ai/features/studio/domain/ad_preview_args.dart';
import 'package:dukaan_ai/features/studio/domain/generated_ad.dart';
import 'package:dukaan_ai/shared/widgets/app_bottom_sheet.dart';
import 'package:dukaan_ai/shared/widgets/app_button.dart';
import 'package:dukaan_ai/shared/widgets/app_error_view.dart';
import 'package:dukaan_ai/shared/widgets/shimmer_box.dart';
import 'package:dukaan_ai/shared/widgets/stat_tile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyAdsScreen extends ConsumerStatefulWidget {
  const MyAdsScreen({super.key});

  @override
  ConsumerState<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends ConsumerState<MyAdsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final AsyncValue<List<GeneratedAd>> adsState =
        ref.watch(myAdsNotifierProvider);
    final bool hasMore = ref.watch(myAdsHasMoreProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardSurface,
        elevation: AppSpacing.none,
        scrolledUnderElevation: AppSpacing.none,
        title: const Text(
          AppStrings.myAdsTitle,
          style: AppTypography.headlineLarge,
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              ref.read(myAdsNotifierProvider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh_outlined),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          adsState.maybeWhen(
            data: (List<GeneratedAd> ads) => _StatsBar(ads: ads),
            orElse: () => const _StatsBar(ads: <GeneratedAd>[]),
          ),
          const _AdsFilterBar(),
          Expanded(
            child: adsState.when(
              loading: () => const _ShimmerGrid(),
              error: (Object error, StackTrace stackTrace) {
                return AppErrorView(
                  message: AppStrings.myAdsLoadError,
                  onRetry: () =>
                      ref.read(myAdsNotifierProvider.notifier).refresh(),
                );
              },
              data: (List<GeneratedAd> ads) {
                if (ads.isEmpty) {
                  return const _MereAdsEmptyState();
                }

                return _AdsGrid(
                  ads: ads,
                  hasMore: hasMore,
                  onRefresh: () =>
                      ref.read(myAdsNotifierProvider.notifier).refresh(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  const _StatsBar({required this.ads});

  final List<GeneratedAd> ads;

  @override
  Widget build(BuildContext context) {
    final int sharedCount = ads.fold<int>(
      0,
      (int total, GeneratedAd ad) => total + ad.shareCount,
    );
    final int downloadCount = ads.fold<int>(
      0,
      (int total, GeneratedAd ad) => total + ad.downloadCount,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: StatTile(
              value: ads.length.toString(),
              label: AppStrings.total,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: StatTile(
              value: sharedCount.toString(),
              label: AppStrings.shared,
              valueColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: StatTile(
              value: downloadCount.toString(),
              label: AppStrings.downloaded,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdsFilterBar extends StatelessWidget {
  const _AdsFilterBar();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: SizedBox(height: AppSpacing.xs),
    );
  }
}

class _MereAdsEmptyState extends StatelessWidget {
  const _MereAdsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _AppEmptyState(
        asset: AppAssets.emptyAds,
        title: AppStrings.noAdsYet,
        ctaLabel: AppStrings.makeFirstAd,
        onTap: () => context.go(AppRoutes.studio),
      ),
    );
  }
}

class _AdsGrid extends ConsumerWidget {
  const _AdsGrid({
    required this.ads,
    required this.hasMore,
    required this.onRefresh,
  });

  final List<GeneratedAd> ads;
  final bool hasMore;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          childAspectRatio: AppSpacing.adGridAspectRatio,
        ),
        itemCount: ads.length + (hasMore ? 1 : 0),
        itemBuilder: (BuildContext context, int index) {
          if (index == ads.length) {
            return _LoadMoreButton(
              onTap: () {
                ref.read(myAdsNotifierProvider.notifier).loadMore();
              },
            );
          }

          final GeneratedAd ad = ads[index];
          return RepaintBoundary(
            child: _AdCard(
              key: ValueKey<String>(ad.id),
              ad: ad,
            ),
          );
        },
      ),
    );
  }
}

class _AdCard extends ConsumerStatefulWidget {
  const _AdCard({required super.key, required this.ad});

  final GeneratedAd ad;

  @override
  ConsumerState<_AdCard> createState() => _AdCardState();
}

class _AdCardState extends ConsumerState<_AdCard>
    with AutomaticKeepAliveClientMixin<_AdCard> {
  static final Logger _logger = Logger();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _cardContent(context);
  }

  Widget _cardContent(BuildContext context) {
    final GeneratedAd ad = widget.ad;
    final String previewText =
        ad.captionHindi ?? ad.captionEnglish ?? AppStrings.myAdsPreviewFallback;

    return InkWell(
      key: Key('my_ads_card_${ad.id}'),
      onTap: () {
        context.push(
          AppRoutes.adPreview,
          extra: AdPreviewArgs(
            generatedAd: ad,
            processedBase64: '',
            backgroundStyleId: ad.backgroundStyle ?? 'studio',
          ),
        );
      },
      onLongPress: () => _showCardActions(context),
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.card),
              ),
              child: SizedBox(
                height: AppSpacing.adImageHeight,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CachedNetworkImage(
                      imageUrl: ad.imageUrl,
                      fit: BoxFit.cover,
                      memCacheWidth: 240,
                      fadeInDuration: const Duration(milliseconds: 150),
                      placeholder: (BuildContext context, String url) {
                        return const ShimmerBox(
                          width: double.infinity,
                          height: AppSpacing.adImageHeight,
                          borderRadius: AppRadius.none,
                        );
                      },
                      errorWidget:
                          (BuildContext context, String url, Object error) {
                        return Container(
                          color: AppColors.divider,
                          child: const Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.textSecondary,
                          ),
                        );
                      },
                    ),
                    Positioned(
                      right: AppSpacing.sm,
                      bottom: AppSpacing.sm,
                      child: Material(
                        color: AppColors.textPrimary.withValues(alpha: 0.45),
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: () {
                            unawaited(_downloadAd(context, ad.imageUrl));
                          },
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(AppSpacing.sm),
                            child: Icon(
                              Icons.download_outlined,
                              size: AppSpacing.md + 2,
                              color: AppColors.surface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    previewText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm - 2),
                  Row(
                    children: <Widget>[
                      Text(
                        _formatDate(ad.createdAt),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          context.push(
                            AppRoutes.whatsappBroadcast,
                            extra: ad,
                          );
                        },
                        child: const Icon(
                          Icons.share_outlined,
                          size: AppSpacing.md + 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadAd(BuildContext context, String imageUrl) async {
    final GeneratedAd ad = widget.ad;
    final bool hasGalleryPermission = await _requestGalleryPermission();
    if (!context.mounted) return;
    if (!hasGalleryPermission) {
      _showSnackBar(
        context,
        message: AppStrings.mereAdsPermissionDenied,
        backgroundColor: AppColors.error,
      );
      return;
    }

    try {
      final http.Response response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        throw Exception(AppStrings.downloadFailed);
      }

      await Gal.putImageBytes(response.bodyBytes, album: AppStrings.appName);
      await ref.read(myAdsNotifierProvider.notifier).incrementDownloadCount(
            adId: ad.id,
            currentCount: ad.downloadCount,
          );

      if (!context.mounted) return;
      _showSnackBar(
        context,
        message: AppStrings.mereAdsDownloadSuccess,
        backgroundColor: AppColors.success,
      );
    } catch (error, stackTrace) {
      _logger.e(
        'my_ads_download_failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!context.mounted) return;
      _showSnackBar(
        context,
        message: AppStrings.mereAdsDownloadFailed,
        backgroundColor: AppColors.error,
      );
    }
  }

  Future<bool> _requestGalleryPermission() async {
    final Permission permission = await _galleryPermission();
    final PermissionStatus status = await permission.request();
    return status.isGranted || status.isLimited;
  }

  Future<Permission> _galleryPermission() async {
    if (!Platform.isAndroid) {
      return Permission.photos;
    }

    final bool isAndroid13Plus = await _isAndroid13OrAbove();
    return isAndroid13Plus ? Permission.photos : Permission.storage;
  }

  Future<bool> _isAndroid13OrAbove() async {
    try {
      final AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
      return info.version.sdkInt >= 33;
    } catch (error, stackTrace) {
      _logger.w(
        'my_ads_android_version_check_failed',
        error: error,
        stackTrace: stackTrace,
      );
      return true;
    }
  }

  void _showSnackBar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
  }) {
    if (!context.mounted) {
      return;
    }

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  void _showCardActions(BuildContext context) {
    final GeneratedAd ad = widget.ad;
    AppBottomSheet.show<void>(
      context: context,
      title: AppStrings.myAdsTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: const Text(AppStrings.myAdsShareAction),
            onTap: () {
              Navigator.of(context).pop();
              context.push(AppRoutes.whatsappBroadcast, extra: ad);
            },
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text(AppStrings.myAdsSaveAction),
            onTap: () {
              Navigator.of(context).pop();
              unawaited(_downloadAd(context, ad.imageUrl));
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppColors.error),
            title: Text(
              AppStrings.myAdsDeleteAction,
              style: AppTypography.labelLarge.copyWith(color: AppColors.error),
            ),
            onTap: () {
              Navigator.of(context).pop();
              _showDeleteConfirm(context);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    final GeneratedAd ad = widget.ad;
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(AppStrings.myAdsDeleteTitle),
          content: const Text(AppStrings.myAdsDeleteConfirm),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(AppStrings.cancelButton),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ref.read(myAdsNotifierProvider.notifier).deleteAd(ad.id);
              },
              child: Text(
                AppStrings.myAdsDeleteAction,
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime dateTime) {
    final Duration diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) {
      return AppStrings.myAdsDaysAgo(diff.inDays);
    }
    if (diff.inHours > 0) {
      return AppStrings.myAdsHoursAgo(diff.inHours);
    }
    return AppStrings.myAdsTimeNow;
  }
}

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
          ),
          child: Text(
            AppStrings.myAdsLoadMore,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerGrid extends StatelessWidget {
  const _ShimmerGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: AppSpacing.adGridAspectRatio,
      ),
      itemBuilder: (BuildContext context, int index) {
        return const ShimmerBox(
          height: double.infinity,
          width: double.infinity,
          borderRadius: AppRadius.card,
        );
      },
    );
  }
}

class _AppEmptyState extends StatelessWidget {
  const _AppEmptyState({
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
          Image.asset(
            asset,
            width: AppSpacing.xxl,
            height: AppSpacing.xxl,
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stackTrace) {
              return const Icon(
                Icons.photo_library_outlined,
                size: AppSpacing.xxl,
                color: AppColors.textHint,
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTypography.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(label: ctaLabel, onPressed: onTap),
        ],
      ),
    );
  }
}
