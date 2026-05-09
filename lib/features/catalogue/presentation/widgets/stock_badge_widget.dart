import 'package:dukaan_ai/core/constants/app_constants.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/catalogue/domain/stock_status.dart';
import 'package:flutter/material.dart';

class StockBadgeWidget extends StatelessWidget {
  const StockBadgeWidget({
    super.key,
    required this.stockStatus,
    this.quantity,
    this.showQuantityLabel = true,
  });

  final StockStatus stockStatus;
  final int? quantity;
  final bool showQuantityLabel;

  @override
  Widget build(BuildContext context) {
    final bool canShowQuantity = showQuantityLabel && quantity != null;

    return RepaintBoundary(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (canShowQuantity) ...<Widget>[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(170),
                borderRadius: BorderRadius.circular(AppRadius.chip),
              ),
              child: Text(
                _quantityText(quantity!),
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _statusColor(stockStatus),
              border: Border.all(
                color: Colors.white,
                width: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _quantityText(int rawQuantity) {
    final int safeQuantity = rawQuantity < 0 ? 0 : rawQuantity;
    final String base = safeQuantity > 99 ? '99+' : safeQuantity.toString();

    if (stockStatus == StockStatus.inStock &&
        safeQuantity > 0 &&
        safeQuantity <= AppConstants.lowStockThreshold) {
      return '$base!';
    }

    return base;
  }

  Color _statusColor(StockStatus status) {
    final String key = StockStatusHelper.stockStatusColor(status);
    switch (key) {
      case 'success':
        return AppColors.success;
      case 'warning':
        return AppColors.warning;
      case 'error':
        return AppColors.error;
      default:
        return AppColors.success;
    }
  }
}
