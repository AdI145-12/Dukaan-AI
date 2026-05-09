import 'package:cached_network_image/cached_network_image.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_shadows.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/studio/domain/generated_ad.dart';
import 'package:dukaan_ai/shared/widgets/shimmer_box.dart';
import 'package:flutter/material.dart';

class GeneratedAdCard extends StatelessWidget {
  const GeneratedAdCard({
    super.key,
    required this.ad,
    required this.onShare,
    required this.onDownload,
  });

  final GeneratedAd ad;
  final VoidCallback onShare;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.card),
                bottomLeft: Radius.circular(AppRadius.card),
              ),
              child: CachedNetworkImage(
                imageUrl: ad.thumbnailUrl ?? ad.imageUrl,
                width: 120,
                height: 88,
                fit: BoxFit.cover,
                memCacheWidth: 240,
                placeholder: (_, __) => const ShimmerBox(
                  width: 120,
                  height: 88,
                  borderRadius: 0,
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 120,
                  height: 88,
                  color: AppColors.divider,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.textHint,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      _formatDate(ad.createdAt),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (ad.festivalTag != null)
                      Text(
                        ad.festivalTag!,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        IconButton(
                          onPressed: onShare,
                          tooltip: AppStrings.share,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          icon: const Icon(
                            Icons.share_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        IconButton(
                          onPressed: onDownload,
                          tooltip: AppStrings.download,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          icon: const Icon(
                            Icons.download_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime dateTime) {
  final Duration difference = DateTime.now().difference(dateTime);
  if (difference.inDays == 0) {
    return 'Aaj';
  }
  if (difference.inDays == 1) {
    return 'Kal';
  }
  if (difference.inDays < 7) {
    return '${difference.inDays} din pehle';
  }
  return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
}
