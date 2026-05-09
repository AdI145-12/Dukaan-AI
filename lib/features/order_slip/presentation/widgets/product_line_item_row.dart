import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/order_slip/domain/order_line_item.dart';
import 'package:flutter/material.dart';

class ProductLineItemRow extends StatelessWidget {
  const ProductLineItemRow({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
    required this.onPriceChanged,
  });

  final OrderLineItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;
  final ValueChanged<double> onPriceChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if ((item.productImageUrl ?? '').trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.productImageUrl!,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return const SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(Icons.image_not_supported_outlined),
                    );
                  },
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.productName,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if ((item.variantLabel ?? '').trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      item.variantLabel!,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  width: 96,
                  child: TextFormField(
                    initialValue: item.unitPrice.toStringAsFixed(0),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      isDense: true,
                      prefixText: '₹',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    onChanged: (String value) {
                      final double? parsed = double.tryParse(value.trim());
                      if (parsed != null && parsed >= 0) {
                        onPriceChanged(parsed);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    onPressed: () => onQuantityChanged(item.quantity - 1),
                    icon: const Icon(Icons.remove_circle_outline),
                    splashRadius: 18,
                  ),
                  Text(
                    '${item.quantity}',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    onPressed: () => onQuantityChanged(item.quantity + 1),
                    icon: const Icon(Icons.add_circle_outline),
                    splashRadius: 18,
                  ),
                ],
              ),
              Text(
                '₹${item.subtotal.toStringAsFixed(0)}',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded),
                color: AppColors.error,
                splashRadius: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
