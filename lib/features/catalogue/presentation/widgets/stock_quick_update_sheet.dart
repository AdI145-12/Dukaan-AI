import 'package:cached_network_image/cached_network_image.dart';
import 'package:dukaan_ai/core/constants/app_constants.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/catalogue/domain/models/catalogue_product.dart';
import 'package:dukaan_ai/features/catalogue/domain/stock_status.dart';
import 'package:dukaan_ai/shared/widgets/shimmer_box.dart';
import 'package:flutter/material.dart';

typedef StockQuickUpdateCallback = Future<void> Function(
  StockStatus status,
  int? quantity,
);

class StockQuickUpdateSheet extends StatefulWidget {
  const StockQuickUpdateSheet({
    super.key,
    required this.product,
    required this.onUpdate,
  });

  final CatalogueProduct product;
  final StockQuickUpdateCallback onUpdate;

  @override
  State<StockQuickUpdateSheet> createState() => _StockQuickUpdateSheetState();
}

class _StockQuickUpdateSheetState extends State<StockQuickUpdateSheet> {
  late final TextEditingController _quantityCtrl;
  late final StockStatus _initialStatus;
  late final int? _initialQuantity;

  late StockStatus _selectedStatus;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.product.stockStatus;
    _initialStatus = widget.product.stockStatus;
    _initialQuantity = widget.product.quantity;
    _quantityCtrl = TextEditingController(
      text: widget.product.quantity?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _quantityCtrl.dispose();
    super.dispose();
  }

  int? get _parsedQuantity {
    if (_selectedStatus == StockStatus.outOfStock) {
      return null;
    }

    final String raw = _quantityCtrl.text.trim();
    if (raw.isEmpty) {
      return null;
    }

    return int.tryParse(raw);
  }

  bool get _showQuantityField => _selectedStatus != StockStatus.outOfStock;

  bool get _showLowWarning {
    final int? qty = _parsedQuantity;
    return qty != null && qty > 0 && qty <= AppConstants.lowStockThreshold;
  }

  bool get _hasChanges {
    if (_selectedStatus != _initialStatus) {
      return true;
    }
    return _parsedQuantity != _initialQuantity;
  }

  Future<void> _onUpdatePressed() async {
    if (!_hasChanges || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onUpdate(_selectedStatus, _parsedQuantity);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                AppStrings.stockUpdateTitle,
                style: AppTypography.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: widget.product.imageUrl,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      placeholder: (BuildContext context, String _) {
                        return const ShimmerBox(width: 36, height: 36);
                      },
                      errorWidget: (
                        BuildContext context,
                        String _,
                        Object error,
                      ) {
                        return Container(
                          width: 36,
                          height: 36,
                          color: AppColors.primaryLight,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported_outlined, size: 18),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.product.name,
                          style: AppTypography.labelLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${widget.product.price.toStringAsFixed(0)}',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: StockStatus.values
                    .map(
                      (StockStatus status) => ChoiceChip(
                        label: Text(StockStatusHelper.stockStatusLabel(status)),
                        selected: _selectedStatus == status,
                        selectedColor: _chipColor(status),
                        onSelected: (bool selected) {
                          if (!selected) {
                            return;
                          }
                          setState(() {
                            _selectedStatus = status;
                          });
                        },
                      ),
                    )
                    .toList(growable: false),
              ),
              if (_showQuantityField) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _quantityCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: AppStrings.stockQuantityLabel,
                    hintText: AppStrings.stockQuantityHint,
                  ),
                  onChanged: (_) {
                    setState(() {});
                  },
                ),
                if (_showLowWarning) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    AppStrings.stockLowWarning,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ],
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: !_hasChanges || _isSaving ? null : _onUpdatePressed,
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(AppStrings.stockUpdateButton),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Center(
                child: TextButton(
                  onPressed: _isSaving
                      ? null
                      : () {
                          Navigator.of(context).pop(false);
                        },
                  child: const Text(AppStrings.stockDismiss),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _chipColor(StockStatus status) {
    switch (status) {
      case StockStatus.inStock:
        return AppColors.success.withAlpha(36);
      case StockStatus.lowStock:
        return AppColors.warning.withAlpha(46);
      case StockStatus.outOfStock:
        return AppColors.error.withAlpha(36);
    }
  }
}
