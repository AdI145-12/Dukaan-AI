import 'package:dukaan_ai/core/constants/app_routes.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_shadows.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/order_slip/application/order_slip_provider.dart';
import 'package:dukaan_ai/features/order_slip/domain/order_slip.dart';
import 'package:dukaan_ai/features/order_slip/presentation/widgets/order_slip_card_widget.dart';
import 'package:dukaan_ai/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class OrderSlipDetailScreen extends ConsumerStatefulWidget {
  const OrderSlipDetailScreen({
    super.key,
    this.slip,
    this.slipId,
  });

  final OrderSlip? slip;
  final String? slipId;

  @override
  ConsumerState<OrderSlipDetailScreen> createState() =>
      _OrderSlipDetailScreenState();
}

class _OrderSlipDetailScreenState extends ConsumerState<OrderSlipDetailScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _addedToKhata = false;
  OrderSlip? _overrideSlip;

  @override
  Widget build(BuildContext context) {
    final OrderSlip? slip = _resolveSlip();
    if (slip == null) {
      return _buildMissingSlip();
    }

    final OrderSlipSellerProfile profile = _resolveProfile();
    final DateFormat formatter = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(slip),
      body: _buildBody(context, slip, profile, formatter),
    );
  }

  OrderSlip? _resolveSlip() {
    final String targetId = (widget.slipId ?? widget.slip?.id ?? '').trim();
    if (targetId.isEmpty) {
      return _overrideSlip ?? widget.slip;
    }

    final OrderSlip? fromProvider =
        ref.watch(orderSlipByIdProvider(targetId));
    return _overrideSlip ?? fromProvider ?? widget.slip;
  }

  OrderSlipSellerProfile _resolveProfile() {
    final AsyncValue<OrderSlipSellerProfile> profileAsync =
        ref.watch(orderSlipSellerProfileProvider);
    return profileAsync.maybeWhen(
      data: (OrderSlipSellerProfile value) => value,
      orElse: () => const OrderSlipSellerProfile(
        shopName: AppStrings.shopNameFallback,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(OrderSlip slip) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: Text(
        AppStrings.orderSlipTitle(slip.slipNumber),
        style: AppTypography.headlineLarge,
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: () => _shareOnWhatsApp(slip),
          tooltip: AppStrings.orderSlipShare,
        ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    OrderSlip slip,
    OrderSlipSellerProfile profile,
    DateFormat formatter,
  ) {
    final List<_ActionConfig> actions = _buildActions(context, slip);
    final bool shouldRegenerate = (slip.slipImageUrl ?? '').trim().isEmpty;

    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              <Widget>[
                _MetaCard(slip: slip, formatter: formatter),
                const SizedBox(height: AppSpacing.md),
                _PreviewCard(
                  controller: _screenshotController,
                  slip: slip,
                  profile: profile,
                ),
                const SizedBox(height: AppSpacing.md),
                _ActionGrid(actions: actions),
                if (shouldRegenerate) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: AppStrings.orderSlipRegenerate,
                    onPressed: () => _regenerateImage(slip),
                    variant: AppButtonVariant.secondary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<_ActionConfig> _buildActions(BuildContext context, OrderSlip slip) {
    return <_ActionConfig>[
      _ActionConfig(
        label: AppStrings.orderSlipShare,
        onPressed: () => _shareOnWhatsApp(slip),
        variant: AppButtonVariant.primary,
      ),
      _ActionConfig(
        label: AppStrings.orderSlipCopySummary,
        onPressed: () => _copySummary(slip),
        variant: AppButtonVariant.secondary,
      ),
      _ActionConfig(
        label: _addedToKhata
            ? AppStrings.orderSlipAddedLabel
            : AppStrings.orderSlipAddToKhata,
        onPressed: _addedToKhata ? null : () => _addToKhata(slip),
        variant: AppButtonVariant.secondary,
      ),
      _ActionConfig(
        label: AppStrings.orderSlipEdit,
        onPressed: () => context.push(
          AppRoutes.orderSlipCreate,
          extra: slip,
        ),
        variant: AppButtonVariant.ghost,
      ),
    ];
  }

  Widget _buildMissingSlip() {
    return const Scaffold(
      body: Center(child: Text(AppStrings.errorGeneric)),
    );
  }

  Future<void> _shareOnWhatsApp(OrderSlip slip) async {
    final OrderSlipNotifier notifier = ref.read(orderSlipProvider.notifier);
    await notifier.shareToWhatsApp(slip);

    final String? localPath = await notifier.getLocalImagePath(slip);
    if (localPath == null) {
      return;
    }

    await Share.shareXFiles(
      <XFile>[XFile(localPath)],
      text: AppStrings.orderSlipShareText,
    );
  }

  Future<void> _copySummary(OrderSlip slip) async {
    await Clipboard.setData(ClipboardData(text: slip.whatsAppSummary));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.orderSlipCopied)),
    );
  }

  Future<void> _addToKhata(OrderSlip slip) async {
    await ref.read(orderSlipProvider.notifier).addToKhata(slip);
    if (!mounted) {
      return;
    }

    setState(() {
      _addedToKhata = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.orderSlipAddedToKhata)),
    );
  }

  Future<void> _regenerateImage(OrderSlip slip) async {
    final OrderSlip? updated = await ref
        .read(orderSlipProvider.notifier)
        .regenerateSlipImage(
          slip,
          screenshotController: _screenshotController,
        );
    if (!mounted || updated == null) {
      return;
    }

    setState(() {
      _overrideSlip = updated;
    });
  }
}

class _MetaCard extends StatelessWidget {
  const _MetaCard({
    required this.slip,
    required this.formatter,
  });

  final OrderSlip slip;
  final DateFormat formatter;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            slip.customerName,
            style: AppTypography.headlineLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppStrings.orderSlipTitle(slip.slipNumber),
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${AppStrings.orderSlipCreatedLabel}: '
            '${formatter.format(slip.createdAt)}',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: _MetaStat(
                  label: AppStrings.total,
                  value: slip.formattedTotal,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _MetaStat(
                  label: AppStrings.products,
                  value: slip.lineItems.length.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _PaymentModeChip(
            label: OrderSlip.paymentModeLabel(slip.paymentMode),
          ),
        ],
      ),
    );
  }
}

class _MetaStat extends StatelessWidget {
  const _MetaStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.headlineMedium,
          ),
        ],
      ),
    );
  }
}

class _PaymentModeChip extends StatelessWidget {
  const _PaymentModeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          AppStrings.paymentMode,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppRadius.chip),
          ),
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.primaryDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.controller,
    required this.slip,
    required this.profile,
  });

  final ScreenshotController controller;
  final OrderSlip slip;
  final OrderSlipSellerProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.modal,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Center(
        child: Screenshot(
          controller: controller,
          child: RepaintBoundary(
            child: OrderSlipCardWidget(
              slip: slip,
              shopName: profile.shopName,
              city: profile.city,
              shopPhone: profile.phone,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.actions});

  final List<_ActionConfig> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width =
            (constraints.maxWidth - AppSpacing.sm) / 2;
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: actions
              .map(
                (_ActionConfig action) => SizedBox(
                  width: width,
                  child: AppButton(
                    label: action.label,
                    onPressed: action.onPressed,
                    isFullWidth: true,
                    variant: action.variant,
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _ActionConfig {
  const _ActionConfig({
    required this.label,
    required this.onPressed,
    required this.variant,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
}
