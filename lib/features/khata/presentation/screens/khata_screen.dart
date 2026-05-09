import 'dart:async';

import 'package:dukaan_ai/core/constants/app_assets.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/errors/error_handler.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_shadows.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/khata/application/khata_provider.dart';
import 'package:dukaan_ai/features/khata/domain/khata_entry.dart';
import 'package:dukaan_ai/features/khata/presentation/widgets/add_khata_sheet.dart';
import 'package:dukaan_ai/features/khata/presentation/widgets/khata_entry_card.dart';
import 'package:dukaan_ai/shared/widgets/app_bottom_sheet.dart';
import 'package:dukaan_ai/shared/widgets/app_button.dart';
import 'package:dukaan_ai/shared/widgets/app_error_view.dart';
import 'package:dukaan_ai/shared/widgets/app_snackbar.dart';
import 'package:dukaan_ai/shared/widgets/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Khata screen with the refreshed summary hero and customer list layout.
class KhataScreen extends ConsumerStatefulWidget {
  /// Creates a new Khata screen.
  const KhataScreen({super.key});

  @override
  ConsumerState<KhataScreen> createState() => _KhataScreenState();
}

class _KhataScreenState extends ConsumerState<KhataScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<void> _openAddSheet() {
    return AppBottomSheet.show<void>(
      context: context,
      title: AppStrings.addKhataTitle,
      child: const AddKhataSheet(),
    );
  }

  Future<void> _sendWhatsAppReminder(KhataEntry entry) async {
    if (entry.customerPhone == null || entry.customerPhone!.trim().isEmpty) {
      AppSnackBar.show(
        context,
        message: AppStrings.noPhoneNumber,
        type: AppSnackBarType.warning,
      );
      return;
    }

    final String rawPhone =
        entry.customerPhone!.replaceAll(RegExp(r'[^0-9]'), '');
    if (rawPhone.isEmpty) {
      AppSnackBar.show(
        context,
        message: AppStrings.noPhoneNumber,
        type: AppSnackBarType.warning,
      );
      return;
    }

    final String phone = rawPhone.startsWith('91') && rawPhone.length == 12
        ? rawPhone
        : '91$rawPhone';
    final String message = Uri.encodeComponent(
      AppStrings.whatsappReminderMessage(
        customerName: entry.customerName,
        shopName: AppStrings.shopNameFallback,
        amount: entry.amount.toStringAsFixed(0),
      ),
    );
    final Uri uri = Uri.parse('https://wa.me/$phone?text=$message');

    if (!await canLaunchUrl(uri)) {
      if (!mounted) {
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
    if (!launched || !mounted) {
      return;
    }

    final String userId = FirebaseService.currentUserId ?? '';
    if (userId.isNotEmpty) {
      unawaited(
        ref.read(khataProvider.notifier).sendReminderTracked(
              userId: userId,
              entryId: entry.id,
            ),
      );
    }
  }

  Future<void> _showEditAmountDialog(KhataEntry entry) async {
    final TextEditingController amountCtrl =
        TextEditingController(text: entry.amount.toStringAsFixed(0));

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(AppStrings.editAmountTitle),
          content: TextField(
            controller: amountCtrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(prefixText: '₹ '),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(AppStrings.cancelButton),
            ),
            TextButton(
              onPressed: () async {
                final double? newAmount =
                    double.tryParse(amountCtrl.text.trim());
                if (newAmount == null || newAmount <= 0) {
                  return;
                }
                Navigator.of(dialogContext).pop();
                await ref.read(khataProvider.notifier).updateAmount(
                      id: entry.id,
                      newAmount: newAmount,
                    );
                if (!mounted || _showMutationErrorIfAny()) {
                  return;
                }
                AppSnackBar.show(
                  context,
                  message: AppStrings.amountUpdatedMessage,
                  type: AppSnackBarType.success,
                );
              },
              child: Text(
                AppStrings.saveButton,
                style:
                    AppTypography.labelLarge.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );

    amountCtrl.dispose();
  }

  Future<void> _markPaid(KhataEntry entry) async {
    await ref.read(khataProvider.notifier).markPaid(id: entry.id);
    if (!mounted || _showMutationErrorIfAny()) {
      return;
    }
    AppSnackBar.show(
      context,
      message: AppStrings.markPaidMessage(
        customerName: entry.customerName,
        amount: entry.amount.toStringAsFixed(0),
      ),
      type: AppSnackBarType.success,
    );
  }

  Future<void> _showDeleteDialog(KhataEntry entry) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(AppStrings.deleteConfirmTitle),
          content:
              Text(AppStrings.deleteEntryConfirmMessage(entry.customerName)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(AppStrings.cancelButton),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _deleteEntry(entry);
              },
              child: Text(
                AppStrings.deleteEntryAction,
                style:
                    AppTypography.labelLarge.copyWith(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteEntry(KhataEntry entry) async {
    await ref.read(khataProvider.notifier).deleteEntry(id: entry.id);
    if (!mounted || _showMutationErrorIfAny()) {
      return;
    }
    AppSnackBar.show(
      context,
      message: AppStrings.entryDeletedMessage,
      type: AppSnackBarType.success,
    );
  }

  bool _showMutationErrorIfAny() {
    final AsyncValue<void> operationState = ref.read(khataProvider);
    if (!operationState.hasError || !mounted) {
      return false;
    }
    AppSnackBar.show(
      context,
      message: ErrorHandler.toUserMessage(operationState.error!),
      type: AppSnackBarType.error,
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final AsyncValue<List<KhataEntry>> entriesAsync =
        ref.watch(khataEntriesProvider);
    final List<KhataEntry> currentEntries =
        entriesAsync.asData?.value ?? const <KhataEntry>[];
    final double totalOutstanding = currentEntries.fold<double>(
      0,
      (double running, KhataEntry entry) => running + entry.amount,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          AppStrings.khataTitle,
          style: AppTypography.headlineLarge,
        ),
        backgroundColor: AppColors.cardSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: AppColors.cardSurface,
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('khata_add_fab'),
        heroTag: 'khata_add_fab',
        onPressed: _openAddSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        icon: const Icon(Icons.add),
        label: Text(
          AppStrings.addNew,
          style: AppTypography.labelLarge.copyWith(color: AppColors.surface),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SizedBox(
              height: AppSpacing.xxl * 3,
              child: KhataSummaryCard(
                totalOutstanding: totalOutstanding,
                customerCount: currentEntries.length,
              ),
            ),
          ),
          Expanded(
            child: entriesAsync.when(
              loading: () => const _KhataLoadingState(),
              error: (Object error, StackTrace _) {
                return AppErrorView(
                  message: ErrorHandler.toUserMessage(error),
                  onRetry: () => ref.invalidate(khataEntriesProvider),
                );
              },
              data: (List<KhataEntry> entries) {
                if (entries.isEmpty) {
                  return AppEmptyState(
                    asset: AppAssets.emptyKhata,
                    title: AppStrings.noUdhaar,
                    ctaLabel: AppStrings.addFirstCustomer,
                    onTap: _openAddSheet,
                  );
                }

                return _KhataContent(
                  entries: entries,
                  onSendReminder: _sendWhatsAppReminder,
                  onMarkPaid: _markPaid,
                  onDeleteRequested: _showDeleteDialog,
                  onDeleteConfirmed: _deleteEntry,
                  onEditAmount: _showEditAmountDialog,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _KhataContent extends StatelessWidget {
  const _KhataContent({
    required this.entries,
    required this.onSendReminder,
    required this.onMarkPaid,
    required this.onDeleteRequested,
    required this.onDeleteConfirmed,
    required this.onEditAmount,
  });

  final List<KhataEntry> entries;
  final Future<void> Function(KhataEntry entry) onSendReminder;
  final Future<void> Function(KhataEntry entry) onMarkPaid;
  final Future<void> Function(KhataEntry entry) onDeleteRequested;
  final Future<void> Function(KhataEntry entry) onDeleteConfirmed;
  final Future<void> Function(KhataEntry entry) onEditAmount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(
        top: AppSpacing.xs,
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.xxl,
      ),
      itemCount: entries.length,
      itemBuilder: (BuildContext context, int index) {
        final KhataEntry entry = entries[index];
        return Dismissible(
          key: ValueKey<String>(entry.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: const Icon(
              Icons.delete_outline,
              color: AppColors.surface,
              size: AppSpacing.lg - AppSpacing.xs / 2,
            ),
          ),
          confirmDismiss: (_) => _showDeleteConfirmDialog(context, entry),
          onDismissed: (_) => unawaited(onDeleteConfirmed(entry)),
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: KhataEntryCard(
              entry: entry,
              onSendReminder: () => unawaited(onSendReminder(entry)),
              onMarkPaid: () => unawaited(onMarkPaid(entry)),
              onDelete: () => unawaited(onDeleteRequested(entry)),
              onEditAmount: () => unawaited(onEditAmount(entry)),
            ),
          ),
        );
      },
    );
  }
}

Future<bool> _showDeleteConfirmDialog(BuildContext context, KhataEntry entry) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text(AppStrings.deleteConfirmTitle),
        content: Text(AppStrings.deleteEntryConfirmMessage(entry.customerName)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              AppStrings.deleteEntryAction,
              style: AppTypography.labelLarge.copyWith(color: AppColors.error),
            ),
          ),
        ],
      );
    },
  ).then((bool? value) => value ?? false);
}

class _KhataLoadingState extends StatelessWidget {
  const _KhataLoadingState();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: <Widget>[
          for (int index = 0; index < 4; index++)
            const Padding(
              padding: EdgeInsets.only(
                bottom: AppSpacing.sm,
                left: AppSpacing.md,
                right: AppSpacing.md,
              ),
              child: ShimmerBox(
                width: double.infinity,
                height: AppSpacing.xl * 2 + AppSpacing.md / 2,
                borderRadius: AppRadius.card,
              ),
            ),
        ],
      ),
    );
  }
}

/// Summary hero shown above the customer list.
class KhataSummaryCard extends StatelessWidget {
  /// Creates a new Khata summary card.
  const KhataSummaryCard({
    super.key,
    required this.totalOutstanding,
    required this.customerCount,
  });

  final double totalOutstanding;
  final int customerCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.primary,
          width: AppSpacing.xs / 4,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _KhataMetric(
              value: '₹${totalOutstanding.toStringAsFixed(0)}',
              label: AppStrings.totalPendingLabel,
            ),
          ),
          Container(
            width: AppSpacing.xs / 4,
            height: AppSpacing.xl * 2,
            color: AppColors.primaryDark,
          ),
          Expanded(
            child: _KhataMetric(
              value: customerCount.toString(),
              label: AppStrings.customersLabel,
              valueColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _KhataMetric extends StatelessWidget {
  const _KhataMetric({
    required this.value,
    required this.label,
    this.valueColor = AppColors.textPrimary,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            value,
            style: AppTypography.displayMedium.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Khata empty state used when there are no customers yet.
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
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Semantics(
              label: asset,
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                size: AppSpacing.xl * 2 + AppSpacing.md / 2,
                color: AppColors.divider,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppStrings.khataEmptySubtitle,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: ctaLabel,
              isFullWidth: true,
              onPressed: () => unawaited(onTap()),
            ),
          ],
        ),
      ),
    );
  }
}
