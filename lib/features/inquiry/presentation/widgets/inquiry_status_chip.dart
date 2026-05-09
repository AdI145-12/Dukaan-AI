import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry_status.dart';
import 'package:flutter/material.dart';

class InquiryStatusChip extends StatelessWidget {
  const InquiryStatusChip({
    super.key,
    required this.status,
    this.isSmall = false,
  });

  final InquiryStatus status;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    final (Color color, Color bg, String emoji) = switch (status) {
      InquiryStatus.newInquiry => (
          AppColors.primary,
          AppColors.primaryLight,
          '🆕',
        ),
      InquiryStatus.interested => (
          AppColors.warning,
          AppColors.warning.withValues(alpha: 0.12),
          '🔥',
        ),
      InquiryStatus.paymentPending => (
          AppColors.warning,
          AppColors.warning.withValues(alpha: 0.16),
          '💰',
        ),
      InquiryStatus.ordered => (
          AppColors.success,
          AppColors.success.withValues(alpha: 0.12),
          '✅',
        ),
      InquiryStatus.delivered => (
          AppColors.success,
          AppColors.success.withValues(alpha: 0.18),
          '📦',
        ),
      InquiryStatus.followUpNeeded => (
          AppColors.error,
          AppColors.error.withValues(alpha: 0.12),
          '🔁',
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? AppSpacing.xs : AppSpacing.sm,
        vertical: isSmall ? 2 : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            emoji,
            style: TextStyle(fontSize: isSmall ? 10 : 12),
          ),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: isSmall ? 10 : null,
            ),
          ),
        ],
      ),
    );
  }
}
