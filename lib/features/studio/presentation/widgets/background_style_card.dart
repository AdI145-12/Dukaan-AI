import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_shadows.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/studio/domain/background_style.dart';
import 'package:flutter/material.dart';

class BackgroundStyleCard extends StatelessWidget {
  const BackgroundStyleCard({
    super.key,
    required this.style,
    required this.isSelected,
    required this.onTap,
  });

  final BackgroundStyle style;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: style.previewColor,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: isSelected
                ? Border.all(
                    color: AppColors.primary,
                    width: 3,
                  )
                : Border.all(
                    color: AppColors.divider,
                    width: 1,
                  ),
            boxShadow: isSelected ? AppShadows.card : null,
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(AppRadius.card),
                      bottomRight: Radius.circular(AppRadius.card),
                    ),
                  ),
                  child: Text(
                    style.displayName,
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  top: AppSpacing.xs,
                  right: AppSpacing.xs,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
