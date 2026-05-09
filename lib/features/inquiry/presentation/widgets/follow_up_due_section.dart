import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry.dart';
import 'package:flutter/material.dart';

class FollowUpDueSection extends StatelessWidget {
  const FollowUpDueSection({
    super.key,
    required this.dueInquiries,
    required this.onWhatsApp,
  });

  final List<Inquiry> dueInquiries;
  final void Function(Inquiry inquiry) onWhatsApp;

  @override
  Widget build(BuildContext context) {
    if (dueInquiries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Row(
            children: <Widget>[
              const Text('🔁', style: TextStyle(fontSize: 16)),
              const SizedBox(width: AppSpacing.xs),
              Text(
                AppStrings.followUpDueTitle,
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Text(
                  '${dueInquiries.length}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 96,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: dueInquiries.length,
            itemBuilder: (BuildContext context, int index) {
              final Inquiry inquiry = dueInquiries[index];
              return GestureDetector(
                onTap: () => onWhatsApp(inquiry),
                child: Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        inquiry.customerName,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        inquiry.productAsked,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.phone_outlined,
                            size: 12,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              AppStrings.whatsappFollowUp,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.success,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Divider(),
        ),
      ],
    );
  }
}
