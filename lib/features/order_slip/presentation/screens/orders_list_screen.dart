import 'package:dukaan_ai/core/constants/app_assets.dart';
import 'package:dukaan_ai/core/constants/app_routes.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_shadows.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/order_slip/application/order_slip_provider.dart';
import 'package:dukaan_ai/features/order_slip/application/order_slip_state.dart';
import 'package:dukaan_ai/features/order_slip/domain/order_slip.dart';
import 'package:dukaan_ai/features/order_slip/presentation/widgets/order_slip_card_widget.dart';
import 'package:dukaan_ai/shared/widgets/app_button.dart';
import 'package:dukaan_ai/shared/widgets/app_error_view.dart';
import 'package:dukaan_ai/shared/widgets/shimmer_box.dart';
import 'package:dukaan_ai/shared/widgets/stat_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

final NumberFormat _rupeeFormatter = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);

class OrdersListScreen extends ConsumerWidget {
  const OrdersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<OrderSlipState> state = ref.watch(orderSlipProvider);
    final AsyncValue<OrderSlipSellerProfile> sellerProfileState =
        ref.watch(orderSlipSellerProfileProvider);
    final OrderSlipSellerProfile sellerProfile = sellerProfileState.maybeWhen(
      data: (OrderSlipSellerProfile value) => value,
      orElse: () => const OrderSlipSellerProfile(
        shopName: AppStrings.shopNameFallback,
      ),
    );
    final OrderSlipState dataState = state.asData?.value ?? const OrderSlipState();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: AppColors.cardSurface,
        title: const Text(
          AppStrings.ordersTitle,
          style: AppTypography.headlineLarge,
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => context.push(AppRoutes.orderSlipCreate),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => context.push(AppRoutes.orderSlipCreate),
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppStrings.ordersSectionLabel.toUpperCase(),
                  style: AppTypography.sectionLabel.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: StatTile(
                        value: '${dataState.slips.length}',
                        label: AppStrings.total,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: StatTile(
                        value: _formatRupees(_totalValue(dataState.slips)),
                        label: AppStrings.totalValue,
                        valueColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: StatTile(
                        value: '${_thisWeekCount(dataState.slips)}',
                        label: AppStrings.thisWeek,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: state.when(
              loading: () => const _LoadingOrdersList(),
              error: (Object error, StackTrace _) {
                return AppErrorView(
                  message: _errorMessage(error),
                  onRetry: () => ref.invalidate(orderSlipProvider),
                );
              },
              data: (OrderSlipState value) {
                if (value.slips.isEmpty) {
                  return Center(
                    child: AppEmptyState(
                      asset: AppAssets.emptyOrders,
                      title: AppStrings.noOrders,
                      ctaLabel: AppStrings.createFirstOrder,
                      onTap: () => context.push(AppRoutes.orderSlipCreate),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.xxl,
                  ),
                  itemCount: value.slips.length,
                  itemBuilder: (BuildContext context, int index) {
                    final OrderSlip slip = value.slips[index];
                    return _OrderSlipListCard(
                      slip: slip,
                      sellerProfile: sellerProfile,
                      onTap: () {
                        context.push(
                          AppRoutes.orderSlipDetail.replaceFirst(
                            ':slipId',
                            slip.id,
                          ),
                          extra: slip,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _OrderSlipListCard extends StatelessWidget {
  const _OrderSlipListCard({
    required this.slip,
    required this.sellerProfile,
    required this.onTap,
  });

  final OrderSlip slip;
  final OrderSlipSellerProfile sellerProfile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: onTap,
          child: OrderSlipCardWidget(
            slip: slip,
            shopName: sellerProfile.shopName,
            city: sellerProfile.city,
            shopPhone: sellerProfile.phone,
          ),
        ),
      ),
    );
  }
}

class _LoadingOrdersList extends StatelessWidget {
  const _LoadingOrdersList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(4, (int index) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            index == 3 ? 0 : AppSpacing.sm,
          ),
          child: const ShimmerBox(width: double.infinity, height: 96),
        );
      }),
    );
  }
}

class AppEmptyState extends StatelessWidget {
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
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Semantics(
            label: asset,
            child: const Icon(
              Icons.receipt_long_outlined,
              size: AppSpacing.xxl * 2,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: AppTypography.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: ctaLabel,
            onPressed: onTap,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}

double _totalValue(List<OrderSlip> slips) {
  return slips.fold<double>(
    0,
    (double running, OrderSlip slip) => running + slip.total,
  );
}

int _thisWeekCount(List<OrderSlip> slips) {
  final DateTime cutoff = DateTime.now().subtract(const Duration(days: 7));
  return slips.where((OrderSlip slip) => !slip.createdAt.isBefore(cutoff)).length;
}

String _formatRupees(double value) {
  return _rupeeFormatter.format(value);
}

String _errorMessage(Object error) {
  final String message = error.toString().trim();
  if (message.isEmpty || message == 'null') {
    return AppStrings.errorGeneric;
  }
  return message;
}
