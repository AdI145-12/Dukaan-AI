import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_shadows.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry_status.dart';
import 'package:dukaan_ai/features/inquiry/presentation/widgets/inquiry_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InquiryCard extends ConsumerWidget {
  const InquiryCard({
    super.key,
    required this.inquiry,
    required this.onWhatsApp,
    required this.onAdvance,
    required this.onMarkFollowUp,
    required this.onEdit,
    required this.onDelete,
  });

  final Inquiry inquiry;
  final VoidCallback onWhatsApp;
  final VoidCallback onAdvance;
  final VoidCallback onMarkFollowUp;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String customerName = inquiry.customerName.trim();
    final String initial =
        customerName.isEmpty ? '?' : customerName.substring(0, 1).toUpperCase();
    final String? phone = inquiry.customerPhone?.trim();
    final bool hasPhone = (phone ?? '').isNotEmpty;

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: inquiry.isFollowUpDue
              ? AppColors.error.withValues(alpha: 0.06)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: inquiry.isFollowUpDue
                ? AppColors.error.withValues(alpha: 0.25)
                : AppColors.divider,
          ),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.xs,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      initial,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          customerName.isEmpty ? '-' : customerName,
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (hasPhone)
                          Text(
                            phone!,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      InquiryStatusChip(status: inquiry.status),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 18),
                        onSelected: (String value) {
                          switch (value) {
                            case 'edit':
                              onEdit();
                            case 'advance':
                              onAdvance();
                            case 'followup':
                              onMarkFollowUp();
                            case 'delete':
                              onDelete();
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          final List<PopupMenuEntry<String>> entries =
                              <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Text(AppStrings.editInquiry),
                            ),
                          ];

                          if (inquiry.status.next != null) {
                            entries.add(
                              PopupMenuItem<String>(
                                value: 'advance',
                                child: Text(
                                  '${AppStrings.inquiryAdvancePrefix} ${inquiry.status.next!.label}',
                                ),
                              ),
                            );
                          }

                          if (inquiry.status != InquiryStatus.followUpNeeded) {
                            entries.add(
                              const PopupMenuItem<String>(
                                value: 'followup',
                                child: Text(AppStrings.inquiryMarkFollowUp),
                              ),
                            );
                          }

                          entries.add(
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Text(
                                AppStrings.deleteInquiry,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          );

                          return entries;
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 14,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      inquiry.productAsked,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if ((inquiry.notes ?? '').trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: Text(
                  inquiry.notes!,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textHint,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.sm,
                AppSpacing.sm,
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                    child: Text(
                      inquiry.source.label,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _timeAgo(inquiry.updatedAt),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                  if (hasPhone) ...<Widget>[
                    const SizedBox(width: AppSpacing.sm),
                    GestureDetector(
                      onTap: onWhatsApp,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.button),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Icon(
                              Icons.phone_outlined,
                              size: 14,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppStrings.whatsappLabel,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final Duration diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) {
      return AppStrings.myAdsDaysAgo(diff.inDays);
    }
    if (diff.inHours > 0) {
      return AppStrings.myAdsHoursAgo(diff.inHours);
    }
    return AppStrings.myAdsTimeNow;
  }
}
