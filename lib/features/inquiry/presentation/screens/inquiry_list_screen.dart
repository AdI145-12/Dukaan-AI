import 'dart:async';

import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/errors/error_handler.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/inquiry/application/inquiry_provider.dart';
import 'package:dukaan_ai/features/inquiry/application/inquiry_state.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry_status.dart';
import 'package:dukaan_ai/features/inquiry/presentation/widgets/add_inquiry_sheet.dart';
import 'package:dukaan_ai/features/inquiry/presentation/widgets/follow_up_due_section.dart';
import 'package:dukaan_ai/features/inquiry/presentation/widgets/inquiry_card.dart';
import 'package:dukaan_ai/features/inquiry/presentation/widgets/inquiry_status_chip.dart';
import 'package:dukaan_ai/shared/widgets/app_bottom_sheet.dart';
import 'package:dukaan_ai/shared/widgets/app_button.dart';
import 'package:dukaan_ai/shared/widgets/app_error_view.dart';
import 'package:dukaan_ai/shared/widgets/app_snackbar.dart';
import 'package:dukaan_ai/shared/widgets/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class InquiryListScreen extends ConsumerWidget {
  const InquiryListScreen({super.key});

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
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openAddSheet(context),
            tooltip: AppStrings.addInquiry,
          ),
        ],
      ),
      body: state.when(
        loading: () => const _InquiryListSkeleton(),
        error: (Object error, StackTrace stackTrace) {
          return AppErrorView(
            message: ErrorHandler.toUserMessage(error),
            onRetry: () => ref.invalidate(inquiryProvider),
          );
        },
        data: (InquiryState value) => _InquiryListBody(state: value),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddSheet(context),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addInquiry),
      ),
    );
  }

  Future<void> _openAddSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddInquirySheet(),
    );
  }
}

class _InquiryListBody extends ConsumerWidget {
  const _InquiryListBody({required this.state});

  final InquiryState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Inquiry> due = state.followUpDue;
    final List<Inquiry> filtered = state.filtered;

    if (state.inquiries.isEmpty) {
      return _EmptyInquiryState(
        onAdd: () => _openAddSheet(context),
      );
    }

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: FollowUpDueSection(
            dueInquiries: due,
            onWhatsApp: (Inquiry inquiry) {
              unawaited(_launchWhatsApp(ref, inquiry, context));
            },
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _StatusFilterDelegate(
            selected: state.activeFilter,
            onFilter: (InquiryStatus? status) {
              ref.read(inquiryProvider.notifier).setFilter(status);
            },
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              final Inquiry inquiry = filtered[index];
              return InquiryCard(
                inquiry: inquiry,
                onWhatsApp: () {
                  unawaited(_launchWhatsApp(ref, inquiry, context));
                },
                onAdvance: () {
                  unawaited(
                    ref.read(inquiryProvider.notifier).advanceStatus(inquiry),
                  );
                },
                onMarkFollowUp: () {
                  unawaited(
                    ref
                        .read(inquiryProvider.notifier)
                        .markFollowUpNeeded(inquiry),
                  );
                },
                onEdit: () => _openEditSheet(context, inquiry),
                onDelete: () => _confirmDelete(context, ref, inquiry),
              );
            },
            childCount: filtered.length,
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Future<void> _openAddSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddInquirySheet(),
    );
  }

  Future<void> _openEditSheet(BuildContext context, Inquiry inquiry) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddInquirySheet(initialInquiry: inquiry),
    );
  }

  Future<void> _launchWhatsApp(
    WidgetRef ref,
    Inquiry inquiry,
    BuildContext context,
  ) async {
    final String rawPhone = (inquiry.customerPhone ?? '').trim();
    if (rawPhone.isEmpty) {
      AppSnackBar.show(
        context,
        message: AppStrings.noPhoneNumber,
        type: AppSnackBarType.warning,
      );
      return;
    }

    final String digits = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 10) {
      AppSnackBar.show(
        context,
        message: AppStrings.noPhoneNumber,
        type: AppSnackBarType.warning,
      );
      return;
    }

    final String e164 = digits.startsWith('91') && digits.length == 12
        ? digits
        : '91${digits.substring(digits.length - 10)}';
    final String encoded = Uri.encodeComponent(
      AppStrings.inquiryWhatsAppMessage(
        customerName: inquiry.customerName,
        productAsked: inquiry.productAsked,
      ),
    );

    final Uri uri = Uri.parse('https://wa.me/$e164?text=$encoded');
    if (!await canLaunchUrl(uri)) {
      if (!context.mounted) {
        return;
      }
      AppSnackBar.show(
        context,
        message: AppStrings.whatsappNotInstalled,
        type: AppSnackBarType.error,
      );
      return;
    }

    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      return;
    }

    unawaited(
      ref.read(inquiryProvider.notifier).updateInquiry(
            inquiry.copyWith(
              lastFollowUp: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Inquiry inquiry,
  ) {
    return AppBottomSheet.show<void>(
      context: context,
      title: AppStrings.deleteInquiry,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            AppStrings.deleteInquiryConfirm,
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: AppStrings.deleteInquiryConfirmCta,
            onPressed: () {
              Navigator.of(context).pop();
              unawaited(
                ref.read(inquiryProvider.notifier).deleteInquiry(inquiry.id),
              );
              AppSnackBar.show(
                context,
                message: AppStrings.inquiryDeleted,
                type: AppSnackBarType.success,
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: AppStrings.cancel,
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _InquiryListSkeleton extends StatelessWidget {
  const _InquiryListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (BuildContext context, int index) {
        return const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: ShimmerBox(
            width: double.infinity,
            height: 120,
          ),
        );
      },
    );
  }
}

class _EmptyInquiryState extends StatelessWidget {
  const _EmptyInquiryState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.record_voice_over_outlined,
              size: 64,
              color: AppColors.divider,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              AppStrings.noInquiriesYet,
              style: AppTypography.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppStrings.inquiryEmptySubtitle,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: AppStrings.addFirstInquiry,
              isFullWidth: false,
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusFilterDelegate extends SliverPersistentHeaderDelegate {
  _StatusFilterDelegate({
    required this.selected,
    required this.onFilter,
  });

  final InquiryStatus? selected;
  final void Function(InquiryStatus? status) onFilter;

  @override
  double get minExtent => 62;

  @override
  double get maxExtent => 62;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: ChoiceChip(
              label: const Text(AppStrings.inquiryFilterAll),
              selected: selected == null,
              onSelected: (_) => onFilter(null),
            ),
          ),
          ...InquiryStatus.values.map(
            (InquiryStatus status) {
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: ChoiceChip(
                  label: InquiryStatusChip(status: status, isSmall: true),
                  selected: selected == status,
                  onSelected: (_) => onFilter(status),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StatusFilterDelegate oldDelegate) {
    return oldDelegate.selected != selected;
  }
}
