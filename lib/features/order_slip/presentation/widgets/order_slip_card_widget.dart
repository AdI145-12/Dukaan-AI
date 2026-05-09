import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/order_slip/domain/order_line_item.dart';
import 'package:dukaan_ai/features/order_slip/domain/order_slip.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderSlipCardWidget extends StatelessWidget {
  const OrderSlipCardWidget({
    super.key,
    required this.slip,
    required this.shopName,
    this.city,
    this.shopPhone,
  });

  final OrderSlip slip;
  final String shopName;
  final String? city;
  final String? shopPhone;

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('dd MMM yyyy');

    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE0B2)),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _Header(
            shopName: shopName,
            city: city,
            slipNumber: slip.slipNumber,
            createdAt: formatter.format(slip.createdAt),
          ),
          const SizedBox(height: AppSpacing.md),
          _CustomerSection(
            name: slip.customerName,
            phone: slip.customerPhone,
          ),
          const SizedBox(height: AppSpacing.md),
          _LineItemsTable(items: slip.lineItems),
          const SizedBox(height: AppSpacing.md),
          _TotalsSection(slip: slip),
          const SizedBox(height: AppSpacing.sm),
          _PaymentSection(slip: slip),
          if (slip.gstEnabled) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'GST: Calculated separately',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Text(
              'Powered by Dukaan AI 🚀',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          if ((shopPhone ?? '').trim().isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  shopPhone!,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.shopName,
    required this.city,
    required this.slipNumber,
    required this.createdAt,
  });

  final String shopName;
  final String? city;
  final String slipNumber;
  final String createdAt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    shopName,
                    style: AppTypography.headlineLarge.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if ((city ?? '').trim().isNotEmpty)
                    Text(
                      city!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  slipNumber,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  createdAt,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        const Divider(height: 1, color: AppColors.divider),
      ],
    );
  }
}

class _CustomerSection extends StatelessWidget {
  const _CustomerSection({required this.name, required this.phone});

  final String name;
  final String? phone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Garahak: $name',
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        if ((phone ?? '').trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              phone!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}

class _LineItemsTable extends StatelessWidget {
  const _LineItemsTable({required this.items});

  final List<OrderLineItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF4F4F4),
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: const Row(
              children: <Widget>[
                Expanded(flex: 6, child: Text('Product Name')),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Qty',
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Amount',
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          ...items.map((OrderLineItem item) => _LineItemRow(item: item)),
        ],
      ),
    );
  }
}

class _LineItemRow extends StatelessWidget {
  const _LineItemRow({required this.item});

  final OrderLineItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 6,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if ((item.productImageUrl ?? '').trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        item.productImageUrl!,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return const SizedBox(
                            width: 32,
                            height: 32,
                            child: Icon(Icons.image_not_supported_outlined, size: 16),
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
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if ((item.variantLabel ?? '').trim().isNotEmpty)
                        Text(
                          item.variantLabel!,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '₹${item.subtotal.toStringAsFixed(0)}',
              textAlign: TextAlign.end,
              style: AppTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalsSection extends StatelessWidget {
  const _TotalsSection({required this.slip});

  final OrderSlip slip;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _amountRow('Subtotal', '₹${slip.subtotal.toStringAsFixed(0)}'),
        if (slip.discountAmount > 0)
          _amountRow('Discount', '-₹${slip.discountAmount.toStringAsFixed(0)}'),
        if (slip.deliveryCharge > 0)
          _amountRow('Delivery', '₹${slip.deliveryCharge.toStringAsFixed(0)}'),
        const Divider(height: AppSpacing.md, color: AppColors.divider),
        _amountRow(
          'Total',
          '₹${slip.total.toStringAsFixed(0)}',
          emphasize: true,
        ),
      ],
    );
  }

  Widget _amountRow(String label, String value, {bool emphasize = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            '$label: ',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyLarge.copyWith(
              color: emphasize ? AppColors.primary : AppColors.textPrimary,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentSection extends StatelessWidget {
  const _PaymentSection({required this.slip});

  final OrderSlip slip;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Payment: ${OrderSlip.paymentModeLabel(slip.paymentMode)}',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (slip.paymentMode == PaymentMode.upi &&
            (slip.upiId ?? '').trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              'UPI ID: ${slip.upiId!}',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}
