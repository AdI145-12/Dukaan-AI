import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dukaan_ai/core/constants/app_routes.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/router/order_slip_params.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_shadows.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/catalogue/domain/models/catalogue_product.dart';
import 'package:dukaan_ai/features/catalogue/domain/stock_status.dart';
import 'package:dukaan_ai/features/catalogue/presentation/widgets/stock_quick_update_sheet.dart';
import 'package:dukaan_ai/features/order_slip/application/order_slip_provider.dart';
import 'package:dukaan_ai/features/order_slip/application/order_slip_state.dart';
import 'package:dukaan_ai/features/order_slip/domain/order_line_item.dart';
import 'package:dukaan_ai/features/order_slip/domain/order_slip.dart';
import 'package:dukaan_ai/features/order_slip/presentation/widgets/order_slip_card_widget.dart';
import 'package:dukaan_ai/features/order_slip/presentation/widgets/product_line_item_row.dart';
import 'package:dukaan_ai/shared/providers/catalogue_products_provider.dart';
import 'package:dukaan_ai/shared/providers/catalogue_stock_actions_provider.dart';
import 'package:dukaan_ai/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';

final NumberFormat _rupeeFormatter = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);

class CreateOrderSlipScreen extends ConsumerStatefulWidget {
  const CreateOrderSlipScreen({super.key});

  @override
  ConsumerState<CreateOrderSlipScreen> createState() =>
      _CreateOrderSlipScreenState();
}

class _CreateOrderSlipScreenState extends ConsumerState<CreateOrderSlipScreen> {
  final GlobalKey _screenshotKey = GlobalKey();
  final ScreenshotController _screenshotController = ScreenshotController();

  final TextEditingController _customerNameCtrl = TextEditingController();
  final TextEditingController _customerPhoneCtrl = TextEditingController();
  final TextEditingController _discountCtrl = TextEditingController(text: '0');
  final TextEditingController _deliveryCtrl = TextEditingController(text: '0');
  final TextEditingController _deliveryNoteCtrl = TextEditingController();

  bool _didApplyNavigationPrefill = false;
  bool _isApplyingPrefill = false;

  @override
  void initState() {
    super.initState();

    _customerNameCtrl.addListener(() {
      if (_isApplyingPrefill) {
        return;
      }
      ref.read(orderSlipProvider.notifier).updateDraftCustomerName(
            _customerNameCtrl.text,
          );
    });

    _customerPhoneCtrl.addListener(() {
      if (_isApplyingPrefill) {
        return;
      }
      ref.read(orderSlipProvider.notifier).updateDraftCustomerPhone(
            _customerPhoneCtrl.text,
          );
    });

    _discountCtrl.addListener(() {
      if (_isApplyingPrefill) {
        return;
      }
      final double value = double.tryParse(_discountCtrl.text.trim()) ?? 0;
      ref.read(orderSlipProvider.notifier).updateDraftDiscount(value);
    });

    _deliveryCtrl.addListener(() {
      if (_isApplyingPrefill) {
        return;
      }
      final double value = double.tryParse(_deliveryCtrl.text.trim()) ?? 0;
      ref.read(orderSlipProvider.notifier).updateDraftDeliveryCharge(value);
    });

    _deliveryNoteCtrl.addListener(() {
      if (_isApplyingPrefill) {
        return;
      }
      ref.read(orderSlipProvider.notifier).updateDraftDeliveryNote(
            _deliveryNoteCtrl.text,
          );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didApplyNavigationPrefill) {
      return;
    }

    _didApplyNavigationPrefill = true;
    final Object? extra = GoRouterState.of(context).extra;

    if (extra is OrderSlipParams) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _isApplyingPrefill = true;
        _customerNameCtrl.text = extra.customerName;
        _customerPhoneCtrl.text = extra.customerPhone ?? '';
        _isApplyingPrefill = false;

        unawaited(
          ref.read(orderSlipProvider.notifier).prefillFromParams(
                inquiryId: extra.inquiryId,
                customerName: extra.customerName,
                customerPhone: extra.customerPhone,
                linkedProductId: extra.linkedProductId,
              ),
        );
      });
      return;
    }

    if (extra is OrderSlip) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _isApplyingPrefill = true;
        _customerNameCtrl.text = extra.customerName;
        _customerPhoneCtrl.text = extra.customerPhone ?? '';
        _discountCtrl.text = extra.discountAmount.toStringAsFixed(0);
        _deliveryCtrl.text = extra.deliveryCharge.toStringAsFixed(0);
        _deliveryNoteCtrl.text = extra.deliveryNote ?? '';
        _isApplyingPrefill = false;

        ref.read(orderSlipProvider.notifier).prefillFromSlip(extra);
      });
    }
  }

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    _customerPhoneCtrl.dispose();
    _discountCtrl.dispose();
    _deliveryCtrl.dispose();
    _deliveryNoteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<OrderSlipState>>(orderSlipProvider, (
      AsyncValue<OrderSlipState>? previous,
      AsyncValue<OrderSlipState> next,
    ) {
      final OrderSlipState? prevState = previous?.asData?.value;
      final OrderSlipState? nextState = next.asData?.value;
      if (nextState == null) {
        return;
      }

      if ((nextState.errorMessage ?? '').isNotEmpty &&
          nextState.errorMessage != prevState?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(nextState.errorMessage!)),
        );
        ref.read(orderSlipProvider.notifier).clearErrorMessage();
      }

      final OrderSlip? createdSlip = nextState.latestCreatedSlip;
      if (createdSlip != null && createdSlip != prevState?.latestCreatedSlip) {
        context.push(
          AppRoutes.orderSlipDetail.replaceFirst(':slipId', createdSlip.id),
          extra: createdSlip,
        );
        ref.read(orderSlipProvider.notifier).consumeLatestCreatedSlip();
      }

      if (nextState.stockNudgeProductId != null &&
          nextState.stockNudgeProductId != prevState?.stockNudgeProductId) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppStrings.orderSlipStockNudge} ${nextState.stockNudgeProductName ?? ''} ordered kiya gaya.',
            ),
            action: SnackBarAction(
              label: AppStrings.orderSlipStockNudgeAction,
              onPressed: () {
                final String? productId = nextState.stockNudgeProductId;
                if (productId == null || productId.trim().isEmpty) {
                  return;
                }
                unawaited(_openStockUpdateFromNudge(productId));
              },
            ),
          ),
        );
        ref.read(orderSlipProvider.notifier).clearStockNudge();
      }
    });

    final AsyncValue<OrderSlipState> asyncState = ref.watch(orderSlipProvider);
    final AsyncValue<OrderSlipSellerProfile> profileAsync =
        ref.watch(orderSlipSellerProfileProvider);
    final OrderSlipSellerProfile profile = profileAsync.maybeWhen(
      data: (OrderSlipSellerProfile value) => value,
      orElse: () => const OrderSlipSellerProfile(
        shopName: AppStrings.shopNameFallback,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          AppStrings.newOrder,
          style: AppTypography.headlineLarge,
        ),
        backgroundColor: AppColors.cardSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: AppColors.cardSurface,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              }
            },
            child: DefaultTextStyle(
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              child: const Text(AppStrings.draftSaveKaro),
            ),
          ),
        ],
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text(AppStrings.errorGeneric)),
        data: (OrderSlipState value) {
          final bool canCreate =
              value.draftLineItems.isNotEmpty &&
              value.draftCustomerName.trim().isNotEmpty;
          final double subtotal = value.draftLineItems.fold<double>(
            0,
            (double running, OrderLineItem item) => running + item.subtotal,
          );
          final double total = subtotal - value.draftDiscount + value.draftDeliveryCharge;
          final OrderSlip previewSlip = _previewSlip(value, profile);

          return Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.xxl * 2 + AppSpacing.xs,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const _SectionLabel(label: AppStrings.customerInfo),
                    _SectionCard(
                      child: Column(
                        children: <Widget>[
                          TextField(
                            controller: _customerNameCtrl,
                            decoration: const InputDecoration(
                              labelText: AppStrings.orderSlipCustomerLabel,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextField(
                            controller: _customerPhoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: AppStrings.orderSlipPhoneLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const _SectionLabel(label: AppStrings.products),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          if (value.draftLineItems.isEmpty)
                            GestureDetector(
                              onTap: _openProductPicker,
                              child: Container(
                                height: AppSpacing.xxl + AppSpacing.xl,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.divider,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(AppRadius.card),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    const Icon(
                                      Icons.add_circle_outline,
                                      color: AppColors.textHint,
                                      size: AppSpacing.xl - AppSpacing.xs,
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    DefaultTextStyle(
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.textHint,
                                      ),
                                      child: const Text(AppStrings.addProduct),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...<Widget>[
                              for (int index = 0;
                                  index < value.draftLineItems.length;
                                  index++)
                                ProductLineItemRow(
                                  item: value.draftLineItems[index],
                                  onQuantityChanged: (int qty) {
                                    ref
                                        .read(orderSlipProvider.notifier)
                                        .updateLineItemQuantity(index, qty);
                                  },
                                  onRemove: () {
                                    ref.read(orderSlipProvider.notifier).removeLineItem(index);
                                  },
                                  onPriceChanged: (double newPrice) {
                                    ref
                                        .read(orderSlipProvider.notifier)
                                        .updateLineItemPrice(index, newPrice);
                                  },
                                ),
                              const Divider(color: AppColors.divider),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  const DefaultTextStyle(
                                    style: AppTypography.bodyMedium,
                                    child: Text(AppStrings.subtotal),
                                  ),
                                  Text(
                                    _formatRupees(subtotal),
                                    style: AppTypography.labelLarge.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          const SizedBox(height: AppSpacing.sm),
                          TextButton(
                            onPressed: _openProductPicker,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Icon(
                                  Icons.add,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                DefaultTextStyle(
                                  style: AppTypography.labelLarge.copyWith(
                                    color: AppColors.primary,
                                  ),
                                  child: const Text(AppStrings.addProductCta),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const _SectionLabel(label: AppStrings.chargesDiscount),
                    _SectionCard(
                      child: Column(
                        children: <Widget>[
                          TextField(
                            controller: _deliveryCtrl,
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: AppStrings.orderSlipDeliveryLabel,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextField(
                            controller: _discountCtrl,
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: AppStrings.orderSlipDiscountLabel,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          DropdownButtonFormField<PaymentMode>(
                            initialValue: value.draftPaymentMode,
                            decoration: const InputDecoration(
                              labelText: AppStrings.paymentMode,
                            ),
                            items: PaymentMode.values
                                .map(
                                  (PaymentMode mode) => DropdownMenuItem<PaymentMode>(
                                    value: mode,
                                    child: Text(OrderSlip.paymentModeLabel(mode)),
                                  ),
                                )
                                .toList(growable: false),
                            onChanged: (PaymentMode? mode) {
                              if (mode == null) {
                                return;
                              }
                              ref
                                  .read(orderSlipProvider.notifier)
                                  .updateDraftPaymentMode(mode);
                            },
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: value.draftGstEnabled,
                            onChanged: (bool enabled) {
                              ref
                                  .read(orderSlipProvider.notifier)
                                  .updateDraftGstEnabled(enabled);
                            },
                            title: const Text(AppStrings.orderSlipGstToggle),
                            subtitle: const Text(AppStrings.orderSlipGstV1Note),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextField(
                            controller: _deliveryNoteCtrl,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: AppStrings.orderSlipDeliveryNote,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.card),
                      ),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              const DefaultTextStyle(
                                style: AppTypography.bodyMedium,
                                child: Text(AppStrings.subtotal),
                              ),
                              Text(
                                _formatRupees(subtotal),
                                style: AppTypography.bodyMedium,
                              ),
                            ],
                          ),
                          if (value.draftDeliveryCharge > 0) ...<Widget>[
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const DefaultTextStyle(
                                  style: AppTypography.bodyMedium,
                                  child: Text(AppStrings.deliveryCharges),
                                ),
                                Text(
                                  _formatRupees(value.draftDeliveryCharge),
                                  style: AppTypography.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                          if (value.draftDiscount > 0) ...<Widget>[
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                DefaultTextStyle(
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.error,
                                  ),
                                  child: const Text(AppStrings.discount),
                                ),
                                Text(
                                  '-${_formatRupees(value.draftDiscount)}',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: AppSpacing.sm),
                          const Divider(color: AppColors.divider),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              DefaultTextStyle(
                                style: AppTypography.headlineMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                                child: const Text(AppStrings.total),
                              ),
                              Text(
                                _formatRupees(total),
                                style: AppTypography.headlineMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: -5000,
                top: 0,
                child: Screenshot(
                  controller: _screenshotController,
                  child: RepaintBoundary(
                    key: _screenshotKey,
                    child: OrderSlipCardWidget(
                      slip: previewSlip,
                      shopName: profile.shopName,
                      city: profile.city,
                      shopPhone: profile.phone,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.cardSurface,
                      border: Border(
                        top: BorderSide(color: AppColors.divider),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.button),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                            ),
                            child: DefaultTextStyle(
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.primary,
                              ),
                              child: const Text(AppStrings.draftSaveKaro),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: AppButton(
                            label: AppStrings.slipBanao + AppStrings.forwardArrow,
                            onPressed: !canCreate || value.isGeneratingImage
                                ? null
                                : () {
                                    ref
                                        .read(orderSlipProvider.notifier)
                                        .createAndShareSlip(
                                          _screenshotKey,
                                          screenshotController:
                                              _screenshotController,
                                        );
                                  },
                            isLoading: value.isGeneratingImage,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openProductPicker() async {
    final List<CatalogueProduct> products =
        await ref.read(catalogueProductsProvider.future);
    if (!mounted) {
      return;
    }

    final List<CatalogueProduct> inStock = products
        .where(
          (CatalogueProduct product) =>
              product.stockStatus != StockStatus.outOfStock &&
              (product.quantity == null || product.quantity! > 0),
        )
        .toList(growable: false);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        String query = '';
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setModalState) {
            final List<CatalogueProduct> filtered = inStock.where((CatalogueProduct p) {
              if (query.trim().isEmpty) {
                return true;
              }
              return p.name.toLowerCase().contains(query.toLowerCase());
            }).toList(growable: false);

            return SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                margin: const EdgeInsets.all(AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      onChanged: (String value) {
                        setModalState(() {
                          query = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: AppStrings.searchProducts,
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (BuildContext context, int index) {
                          final CatalogueProduct product = filtered[index];
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(AppSpacing.sm),
                              child: CachedNetworkImage(
                                imageUrl: product.imageUrl,
                                width: AppSpacing.lg + AppSpacing.sm + AppSpacing.xs,
                                height: AppSpacing.lg + AppSpacing.sm + AppSpacing.xs,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(product.name),
                            subtitle: Text(_formatRupees(product.price)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(AppRadius.chip),
                              ),
                              child: DefaultTextStyle(
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primaryDark,
                                ),
                                child: product.quantity == null
                                    ? Text(_stockStatusLabel(product.stockStatus))
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          const Text(AppStrings.qty),
                                          const SizedBox(width: AppSpacing.xs),
                                          Text(product.quantity.toString()),
                                        ],
                                      ),
                              ),
                            ),
                            onTap: () {
                              ref.read(orderSlipProvider.notifier).addProductFromCatalog(product.id);
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        unawaited(_openManualAddDialog());
                      },
                      child: const Text(AppStrings.orderSlipAddManual),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openManualAddDialog() async {
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController priceCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(AppStrings.orderSlipAddManual),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: AppStrings.catalogueNameLabel,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: AppStrings.cataloguePriceLabel,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AppStrings.cancel),
            ),
            FilledButton(
              onPressed: () {
                final String name = nameCtrl.text.trim();
                final double? price = double.tryParse(priceCtrl.text.trim());
                if (name.isEmpty || price == null) {
                  return;
                }
                ref.read(orderSlipProvider.notifier).addManualLineItem(name, price);
                Navigator.of(context).pop();
              },
              child: const Text(AppStrings.addProductCta),
            ),
          ],
        );
      },
    );

    nameCtrl.dispose();
    priceCtrl.dispose();
  }

  Future<void> _openStockUpdateFromNudge(String productId) async {
    final List<CatalogueProduct> products =
        await ref.read(catalogueProductsProvider.future);

    CatalogueProduct? selected;
    for (final CatalogueProduct product in products) {
      if (product.id == productId) {
        selected = product;
        break;
      }
    }

    if (!mounted || selected == null) {
      return;
    }

    final bool? updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StockQuickUpdateSheet(
          product: selected!,
          onUpdate: (StockStatus status, int? quantity) async {
            await ref
                .read(catalogueStockActionsProvider)
                .quickUpdateStock(productId, status, quantity);
          },
        );
      },
    );

    if (!mounted || updated != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.stockUpdated)),
    );
  }

  OrderSlip _previewSlip(OrderSlipState state, OrderSlipSellerProfile profile) {
    final DateTime now = DateTime.now();
    final double subtotal = state.draftLineItems.fold<double>(
      0,
      (double running, OrderLineItem item) => running + item.subtotal,
    );
    final double total = subtotal - state.draftDiscount + state.draftDeliveryCharge;

    return OrderSlip(
      id: 'preview',
      userId: 'preview-user',
      inquiryId: state.prefillInquiryId,
      slipNumber: '${AppStrings.slipNumberPrefix}-${now.year}-1',
      customerName: state.draftCustomerName.isEmpty
          ? AppStrings.orderSlipCustomerLabel
          : state.draftCustomerName,
      customerPhone: state.draftCustomerPhone,
      lineItems: state.draftLineItems,
      subtotal: subtotal,
      discountAmount: state.draftDiscount,
      deliveryCharge: state.draftDeliveryCharge,
      total: total,
      paymentMode: state.draftPaymentMode,
      upiId: profile.upiId,
      deliveryNote: state.draftDeliveryNote,
      gstEnabled: state.draftGstEnabled,
      createdAt: now,
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.sectionLabel.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }
}

String _formatRupees(double value) {
  return _rupeeFormatter.format(value);
}

String _stockStatusLabel(StockStatus status) {
  switch (status) {
    case StockStatus.inStock:
      return AppStrings.stockInStock;
    case StockStatus.lowStock:
      return AppStrings.stockLowStock;
    case StockStatus.outOfStock:
      return AppStrings.stockOutOfStock;
  }
}
