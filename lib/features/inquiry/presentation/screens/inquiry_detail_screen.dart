import 'package:dukaan_ai/core/constants/app_routes.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/router/order_slip_params.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/inquiry/application/inquiry_provider.dart';
import 'package:dukaan_ai/features/inquiry/application/inquiry_state.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class InquiryDetailScreen extends ConsumerWidget {
  const InquiryDetailScreen({
    super.key,
    required this.inquiryId,
  });

  final String inquiryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<InquiryState> state = ref.watch(inquiryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          AppStrings.inquiriesTitle,
          style: AppTypography.headlineLarge,
        ),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text(AppStrings.errorGeneric)),
        data: (InquiryState value) {
          Inquiry? selected;
          for (final Inquiry inquiry in value.inquiries) {
            if (inquiry.id == inquiryId) {
              selected = inquiry;
              break;
            }
          }

          if (selected == null) {
            return const Center(child: Text(AppStrings.errorGeneric));
          }

          final bool canConvert = selected.status == InquiryStatus.newInquiry ||
              selected.status == InquiryStatus.interested ||
              selected.status == InquiryStatus.paymentPending;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: <Widget>[
              Text(
                selected.customerName,
                style: AppTypography.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                selected.customerPhone ?? '-',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                selected.productAsked,
                style: AppTypography.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Status: ${selected.status.label}',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (canConvert)
                FilledButton(
                  onPressed: () {
                    context.push(
                      AppRoutes.orderSlipCreate,
                      extra: OrderSlipParams(
                        inquiryId: selected!.id,
                        customerName: selected.customerName,
                        customerPhone: selected.customerPhone,
                        linkedProductId: selected.productId,
                        linkedProductName: selected.productAsked,
                      ),
                    );
                  },
                  child: const Text(AppStrings.convertToOrder),
                ),
            ],
          );
        },
      ),
    );
  }
}
