import 'package:cached_network_image/cached_network_image.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/errors/app_exception.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_shadows.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/catalogue/application/catalogue_provider.dart';
import 'package:dukaan_ai/features/catalogue/domain/models/catalogue_product.dart';
import 'package:dukaan_ai/features/catalogue/domain/stock_status.dart';
import 'package:dukaan_ai/features/catalogue/presentation/widgets/add_product_sheet.dart';
import 'package:dukaan_ai/features/catalogue/presentation/widgets/stock_badge_widget.dart';
import 'package:dukaan_ai/features/catalogue/presentation/widgets/stock_quick_update_sheet.dart';
import 'package:dukaan_ai/features/inquiry/presentation/widgets/add_inquiry_sheet.dart';
import 'package:dukaan_ai/shared/widgets/app_bottom_sheet.dart';
import 'package:dukaan_ai/shared/widgets/app_button.dart';
import 'package:dukaan_ai/shared/widgets/app_error_view.dart';
import 'package:dukaan_ai/shared/widgets/app_snackbar.dart';
import 'package:dukaan_ai/shared/widgets/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const List<double> _grayscaleMatrix = <double>[
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
];

class CreateCatalogueScreen extends ConsumerWidget {
  const CreateCatalogueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CatalogueProduct>> productsState =
        ref.watch(catalogueProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          AppStrings.catalogueTitle,
          style: AppTypography.headlineLarge,
        ),
      ),
      body: productsState.when(
        loading: () => const _CatalogueLoadingView(),
        error: (Object error, StackTrace stackTrace) {
          return AppErrorView(
            message: AppStrings.catalogueLoadFailed,
            onRetry: () => ref.invalidate(catalogueProvider),
          );
        },
        data: (List<CatalogueProduct> products) {
          if (products.isEmpty) {
            return _CatalogueEmptyView(
              onAddProduct: () => _openAddProductSheet(context, ref),
            );
          }
          return _CatalogueList(products: products);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddProductSheet(context, ref),
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text(AppStrings.catalogueAddProduct),
      ),
    );
  }

  Future<void> _openAddProductSheet(BuildContext context, WidgetRef ref) async {
    ref.read(catalogueComposerProvider.notifier).clearComposer();
    await AppBottomSheet.show<void>(
      context: context,
      title: AppStrings.addProduct,
      child: const AddProductSheet(),
    );
  }
}

class _CatalogueLoadingView extends StatelessWidget {
  const _CatalogueLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 4,
      itemBuilder: (BuildContext context, int index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: ShimmerBox(width: double.infinity, height: 164),
        );
      },
    );
  }
}

class _CatalogueEmptyView extends StatelessWidget {
  const _CatalogueEmptyView({required this.onAddProduct});

  final VoidCallback onAddProduct;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.inventory_2_outlined,
              size: AppSpacing.xxl,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              AppStrings.catalogueEmptyTitle,
              style: AppTypography.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              AppStrings.catalogueEmptySubtitle,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: AppStrings.catalogueAddProduct,
              onPressed: onAddProduct,
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogueList extends StatelessWidget {
  const _CatalogueList({required this.products});

  final List<CatalogueProduct> products;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: products.length,
      itemBuilder: (BuildContext context, int index) {
        final CatalogueProduct product = products[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: RepaintBoundary(
            key: ValueKey<String>('card_${product.id}'),
            child: _ProductCard(product: product),
          ),
        );
      },
    );
  }
}

class _ProductCard extends ConsumerWidget {
  const _ProductCard({required this.product});

  final CatalogueProduct product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String caption = product.suggestedCaptions.isNotEmpty
        ? product.suggestedCaptions.first
        : AppStrings.catalogueNoCaption;
    final bool isOutOfStock = product.stockStatus == StockStatus.outOfStock;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.card),
            ),
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  isOutOfStock
                      ? ColorFiltered(
                          colorFilter: const ColorFilter.matrix(_grayscaleMatrix),
                          child: _buildProductImage(product),
                        )
                      : _buildProductImage(product),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: StockBadgeWidget(
                      stockStatus: product.stockStatus,
                      quantity: product.quantity,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        product.name,
                        style: AppTypography.headlineMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (String action) {
                        if (action == 'stock') {
                          _openStockUpdateSheet(context, ref);
                          return;
                        }
                        if (action == 'edit') {
                          _openEditSheet(context, ref);
                          return;
                        }
                        if (action == 'track_inquiry') {
                          _openTrackInquirySheet(context);
                          return;
                        }
                        if (action == 'delete') {
                          _confirmDelete(context, ref);
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'stock',
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.inventory_2_outlined, size: 16),
                              SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  AppStrings.updateStock,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Text(AppStrings.editProduct),
                        ),
                        const PopupMenuItem<String>(
                          value: 'track_inquiry',
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.people_outline, size: 16),
                              SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  AppStrings.trackInquiry,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text(
                            AppStrings.deleteProduct,
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '₹${product.price.toStringAsFixed(0)}',
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  product.quantity == null
                      ? product.category
                      : '${product.category} · Qty ${product.quantity}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (product.variants.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _variantText(product),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (product.tags.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: product.tags
                        .take(4)
                        .map(
                          (String tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(
                                AppRadius.chip,
                              ),
                            ),
                            child: Text(
                              '#$tag',
                              style: AppTypography.labelSmall,
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Text(
                  caption,
                  style: AppTypography.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(CatalogueProduct product) {
    return CachedNetworkImage(
      imageUrl: product.imageUrl,
      height: 140,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (BuildContext context, String value) {
        return const ShimmerBox(width: double.infinity, height: 140);
      },
      errorWidget: (
        BuildContext context,
        String value,
        Object error,
      ) {
        return Container(
          height: 140,
          color: AppColors.primaryLight,
          alignment: Alignment.center,
          child: const Icon(Icons.image_not_supported_outlined),
        );
      },
    );
  }

  Future<void> _openEditSheet(BuildContext context, WidgetRef ref) async {
    ref.read(catalogueComposerProvider.notifier).clearComposer();
    await AppBottomSheet.show<void>(
      context: context,
      title: AppStrings.editProduct,
      child: AddProductSheet(initialProduct: product),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    await AppBottomSheet.show<void>(
      context: context,
      title: AppStrings.deleteProduct,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            AppStrings.deleteProductConfirm,
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: AppStrings.deleteProduct,
            onPressed: () async {
              Navigator.of(context).pop();
              await ref
                  .read(catalogueProvider.notifier)
                  .deleteProduct(product.id);
              if (!context.mounted) {
                return;
              }

              final AsyncValue<List<CatalogueProduct>> current =
                  ref.read(catalogueProvider);
              if (current.hasError && current.error != null) {
                AppSnackBar.show(
                  context,
                  message: _toErrorMessage(current.error!),
                  type: AppSnackBarType.error,
                );
                return;
              }

              AppSnackBar.show(
                context,
                message: AppStrings.productDeleted,
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

  Future<void> _openTrackInquirySheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddInquirySheet(prefillProduct: product),
    );
  }

  Future<void> _openStockUpdateSheet(BuildContext context, WidgetRef ref) async {
    final bool? updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StockQuickUpdateSheet(
          product: product,
          onUpdate: (StockStatus status, int? quantity) async {
            await ref
                .read(catalogueProvider.notifier)
                .quickUpdateStock(product.id, status, quantity);
          },
        );
      },
    );

    if (!context.mounted || updated != true) {
      return;
    }

    AppSnackBar.show(
      context,
      message: AppStrings.stockUpdated,
      type: AppSnackBarType.success,
    );
  }

  String _toErrorMessage(Object error) {
    if (error is AppException) {
      return error.userMessage;
    }
    return AppStrings.errorGeneric;
  }

  String _variantText(CatalogueProduct product) {
    return product.variants.map((CatalogueVariantGroup group) {
      final String values = group.options.join('/');
      return '${group.name}: $values';
    }).join(' • ');
  }
}
