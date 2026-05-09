import 'package:cached_network_image/cached_network_image.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/shared/widgets/shimmer_box.dart';
import 'package:flutter/material.dart';

class SaveAsProductBanner extends StatelessWidget {
  const SaveAsProductBanner({
    super.key,
    required this.imageUrl,
    required this.onSave,
    required this.onDismiss,
  });

  final String imageUrl;
  final VoidCallback onSave;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('save_as_product_banner'),
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.button),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              placeholder: (BuildContext context, String _) {
                return const ShimmerBox(width: 44, height: 44);
              },
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  AppStrings.saveAsProductTitle,
                  style: AppTypography.labelLarge,
                ),
                Text(
                  AppStrings.saveAsProductSubtitle,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onSave,
            child: Text(
              AppStrings.saveAsProductCta,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          IconButton(
            key: const Key('save_as_product_banner_dismiss'),
            onPressed: onDismiss,
            icon: const Icon(
              Icons.close,
              size: 18,
              color: AppColors.textHint,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
          ),
        ],
      ),
    );
  }
}
