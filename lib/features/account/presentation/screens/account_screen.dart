import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dukaan_ai/core/constants/app_routes.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/constants/firestore_constants.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_shadows.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/shared/widgets/app_bottom_sheet.dart';
import 'package:dukaan_ai/shared/widgets/app_button.dart';
import 'package:dukaan_ai/shared/widgets/app_error_view.dart';
import 'package:dukaan_ai/shared/widgets/app_snackbar.dart';
import 'package:dukaan_ai/shared/widgets/shimmer_box.dart';
import 'package:dukaan_ai/shared/widgets/stat_tile.dart';
import 'package:dukaan_ai/features/order_slip/application/order_slip_provider.dart';
import 'package:dukaan_ai/features/seller_store/application/seller_store_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

const String _helpSupportUrl = 'https://wa.me/91XXXXXXXXXX';
const String _playStoreUrl =
    'https://play.google.com/store/apps/details?id=prachar.web.app';
const String _privacyPolicyUrl = 'https://dukaanai.app/privacy-policy';

final FutureProvider<AccountProfile> accountProfileProvider =
    FutureProvider<AccountProfile>((Ref ref) async {
  final String? userId = FirebaseService.currentUserId;
  if (userId == null || userId.trim().isEmpty) {
    return const AccountProfile.empty();
  }

  final FirebaseFirestore db = FirebaseService.db as FirebaseFirestore;
  final DocumentSnapshot<Map<String, dynamic>> snapshot = await db
      .collection(FirestoreCollections.users)
      .doc(userId)
      .get();

  if (!snapshot.exists) {
    return const AccountProfile.empty();
  }

  final Map<String, dynamic> data = _toMap(snapshot.data());

  return AccountProfile(
    shopName: data[FirestoreFields.shopName] as String? ??
        AppStrings.shopNameFallback,
    category: data[FirestoreFields.category] as String?,
    city: data[FirestoreFields.city] as String?,
    phone: data[FirestoreFields.phone] as String?,
    tier: data[FirestoreFields.tier] as String? ?? 'free',
    creditsRemaining:
        (data[FirestoreFields.creditsRemaining] as num?)?.toInt() ?? 0,
  );
});

final FutureProvider<int> accountAdsCountProvider =
    FutureProvider<int>((Ref ref) async {
  final String? userId = FirebaseService.currentUserId;
  if (userId == null || userId.trim().isEmpty) {
    return 0;
  }

  try {
    final FirebaseFirestore db = FirebaseService.db as FirebaseFirestore;
    final QuerySnapshot<Map<String, dynamic>> query = await db
        .collection(FirestoreCollections.generatedAds)
        .where(FirestoreFields.userId, isEqualTo: userId)
        .get();
    return query.docs.length;
  } catch (_) {
    return 0;
  }
});

Map<String, dynamic> _toMap(Object? rawData) {
  if (rawData is Map<String, dynamic>) {
    return rawData;
  }
  if (rawData is Map<Object?, Object?>) {
    return rawData.map<String, dynamic>(
      (Object? key, Object? value) => MapEntry(key.toString(), value),
    );
  }
  return <String, dynamic>{};
}

class AccountProfile {
  const AccountProfile({
    required this.shopName,
    required this.category,
    required this.city,
    required this.phone,
    required this.tier,
    required this.creditsRemaining,
  });

  const AccountProfile.empty()
      : shopName = AppStrings.shopNameFallback,
        category = null,
        city = null,
        phone = null,
        tier = 'free',
        creditsRemaining = 0;

  final String shopName;
  final String? category;
  final String? city;
  final String? phone;
  final String tier;
  final int creditsRemaining;
}

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final AsyncValue<AccountProfile> profileState =
        ref.watch(accountProfileProvider);
    final AsyncValue<int> adsCountState = ref.watch(accountAdsCountProvider);
    final bool storeIsPublished = ref.watch(storeIsPublishedProvider);
    final bool storeStatusLoading = ref.watch(sellerStoreProvider).isLoading;
    final int currentMonthOrders = ref.watch(currentMonthOrderCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(AppStrings.accountTitle),
        titleTextStyle: AppTypography.headlineLarge,
      ),
      body: profileState.when(
        loading: _buildLoadingState,
        error: (_, __) {
          return AppErrorView(
            message: AppStrings.accountProfileLoadError,
            onRetry: () {
              ref.invalidate(accountProfileProvider);
              ref.invalidate(accountAdsCountProvider);
            },
          );
        },
        data: (AccountProfile profile) => _buildDataContent(
          context: context,
          profile: profile,
          adsCountState: adsCountState,
          storeIsPublished: storeIsPublished,
          storeStatusLoading: storeStatusLoading,
          currentMonthOrders: currentMonthOrders,
        ),
      ),
    );
  }

  Widget _buildDataContent({
    required BuildContext context,
    required AccountProfile profile,
    required AsyncValue<int> adsCountState,
    required bool storeIsPublished,
    required bool storeStatusLoading,
    required int currentMonthOrders,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          RepaintBoundary(
            child: _ProfileHeaderCard(
              profile: profile,
              onEdit: () => context.push(AppRoutes.editProfile),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          RepaintBoundary(
            child: adsCountState.when(
              loading: () => const _StatsRowShimmer(),
              error: (_, __) {
                return _StatsRow(
                  adsCount: 0,
                  tier: profile.tier,
                  creditsRemaining: profile.creditsRemaining,
                );
              },
              data: (int adsCount) {
                return _StatsRow(
                  adsCount: adsCount,
                  tier: profile.tier,
                  creditsRemaining: profile.creditsRemaining,
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _AccountSection(
            title: AppStrings.accountShopSettings,
            tiles: <_AccountTile>[
              _AccountTile(
                icon: Icons.store_outlined,
                label: AppStrings.accountShopNameEdit,
                onTap: () => context.push(AppRoutes.editProfile),
              ),
              _AccountTile(
                icon: Icons.category_outlined,
                label: AppStrings.accountCategoryCity,
                onTap: () => context.push(AppRoutes.editProfile),
              ),
              _AccountTile(
                icon: Icons.qr_code_outlined,
                label: AppStrings.accountUpiQr,
                onTap: () => context.push(AppRoutes.upiSettings),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _AccountSection(
            title: AppStrings.accountTools,
            tiles: <_AccountTile>[
              _AccountTile(
                icon: Icons.auto_awesome_outlined,
                label: AppStrings.accountStudioShortcut,
                onTap: () => context.go(AppRoutes.studio),
              ),
              _AccountTile(
                icon: Icons.account_balance_wallet_outlined,
                label: AppStrings.accountKhataShortcut,
                onTap: () => context.go(AppRoutes.khata),
              ),
              _AccountTile(
                icon: Icons.inventory_2_outlined,
                label: AppStrings.accountCatalogueShortcut,
                onTap: () => context.push(AppRoutes.catalogue),
              ),
              _AccountTile(
                icon: Icons.receipt_long_rounded,
                label: AppStrings.ordersTitle,
                subtitle: currentMonthOrders > 0
                    ? '$currentMonthOrders orders this month'
                    : AppStrings.ordersSubtitle,
                onTap: () => context.push(AppRoutes.ordersHistory),
              ),
              _AccountTile(
                icon: Icons.storefront_outlined,
                label: AppStrings.accountSellerStoreShortcut,
                trailing: _StoreStatusTrailing(
                  isPublished: storeIsPublished,
                  isLoading: storeStatusLoading,
                ),
                onTap: () => context.push(AppRoutes.sellerStore),
              ),
              _AccountTile(
                icon: Icons.record_voice_over_outlined,
                label: AppStrings.accountInquiryShortcut,
                onTap: () => context.go(AppRoutes.inquiries),
              ),
              _AccountTile(
                icon: Icons.message_outlined,
                label: AppStrings.accountQuickReplies,
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _AccountSection(
            title: AppStrings.accountSupport,
            tiles: <_AccountTile>[
              _AccountTile(
                icon: Icons.help_outline,
                label: AppStrings.accountHelpSupport,
                onTap: () => _launchUrl(context, _helpSupportUrl),
              ),
              _AccountTile(
                icon: Icons.star_rate_outlined,
                label: AppStrings.accountRateApp,
                onTap: () => _launchUrl(context, _playStoreUrl),
              ),
              _AccountTile(
                icon: Icons.share_outlined,
                label: AppStrings.accountReferFriends,
                onTap: _shareReferral,
              ),
              _AccountTile(
                icon: Icons.privacy_tip_outlined,
                label: AppStrings.accountPrivacyPolicy,
                onTap: () => _launchUrl(context, _privacyPolicyUrl),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _AccountSection(
            title: AppStrings.accountDangerZone,
            tiles: <_AccountTile>[
              _AccountTile(
                icon: Icons.logout,
                label: AppStrings.accountLogout,
                onTap: () => _showLogoutSheet(context),
                leadingColor: AppColors.error,
                titleStyle: AppTypography.bodyLarge,
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textHint,
                ),
              ),
              _AccountTile(
                icon: Icons.delete_forever_outlined,
                label: AppStrings.accountDeleteAccount,
                onTap: () => _showDeleteSheet(context),
                leadingColor: AppColors.error,
                titleStyle: AppTypography.bodyLarge,
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: const <Widget>[
        ShimmerBox(width: double.infinity, height: 170),
        SizedBox(height: AppSpacing.md),
        _StatsRowShimmer(),
        SizedBox(height: AppSpacing.lg),
        ShimmerBox(width: double.infinity, height: 200),
        SizedBox(height: AppSpacing.md),
        ShimmerBox(width: double.infinity, height: 170),
      ],
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) {
      if (!context.mounted) {
        return;
      }
      AppSnackBar.show(
        context,
        message: AppStrings.errorGeneric,
        type: AppSnackBarType.error,
      );
      return;
    }

    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      AppSnackBar.show(
        context,
        message: AppStrings.errorGeneric,
        type: AppSnackBarType.error,
      );
    }
  }

  Future<void> _shareReferral() async {
    await Share.share(AppStrings.accountReferText);
  }

  void _showComingSoon(BuildContext context) {
    AppSnackBar.show(
      context,
      message: AppStrings.accountComingSoon,
      type: AppSnackBarType.info,
    );
  }

  Future<void> _showLogoutSheet(BuildContext context) async {
    await AppBottomSheet.show<void>(
      context: context,
      title: AppStrings.accountLogoutConfirm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            AppStrings.accountLogoutSafe,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await _logout(context);
              },
              child: const Text(AppStrings.accountLogoutCta),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: AppStrings.accountLogoutCancel,
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseService.auth.signOut();
      if (!context.mounted) {
        return;
      }
      context.go(AppRoutes.login);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      AppSnackBar.show(
        context,
        message: AppStrings.errorGeneric,
        type: AppSnackBarType.error,
      );
    }
  }

  Future<void> _showDeleteSheet(BuildContext context) async {
    await AppBottomSheet.show<void>(
      context: context,
      title: AppStrings.accountDeleteAccount,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            AppStrings.accountDeleteWarning,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: AppStrings.accountDeleteSupport,
            onPressed: () {
              Navigator.of(context).pop();
              _launchUrl(context, _helpSupportUrl);
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: AppStrings.accountLogoutCancel,
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.profile,
    required this.onEdit,
  });

  final AccountProfile profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final String location = <String?>[profile.category, profile.city]
        .where((String? value) => value != null && value.trim().isNotEmpty)
        .cast<String>()
        .join(' · ');
    final String categoryLine = location.isEmpty
        ? AppStrings.addCategoryCity
        : location;
    final String phoneLine = profile.phone?.trim().isNotEmpty == true
        ? profile.phone!
        : AppStrings.addPhoneNumber;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary,
            child: Text(
              _initials(profile.shopName),
              style: AppTypography.headlineLarge.copyWith(
                color: AppColors.surface,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  profile.shopName,
                  style: AppTypography.headlineLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  categoryLine,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  phoneLine,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onEdit,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              visualDensity: VisualDensity.compact,
            ),
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text(AppStrings.editProfile),
          ),
        ],
      ),
    );
  }

  String _initials(String shopName) {
    final List<String> parts = shopName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList(growable: false);

    if (parts.isEmpty) {
      return 'DA';
    }

    if (parts.length == 1) {
      final String first = parts.first;
      return first.substring(0, first.length >= 2 ? 2 : 1).toUpperCase();
    }

    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.adsCount,
    required this.tier,
    required this.creditsRemaining,
  });

  final int adsCount;
  final String tier;
  final int creditsRemaining;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: StatTile(
            value: '$adsCount',
            label: AppStrings.ads,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: StatTile(
            value: tier.toUpperCase(),
            label: AppStrings.tierBadge,
            valueColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: StatTile(
            value: '$creditsRemaining',
            label: AppStrings.credits,
          ),
        ),
      ],
    );
  }
}

class _StatsRowShimmer extends StatelessWidget {
  const _StatsRowShimmer();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: <Widget>[
        Expanded(child: _StatTileShimmer()),
        SizedBox(width: AppSpacing.sm),
        Expanded(child: _StatTileShimmer()),
        SizedBox(width: AppSpacing.sm),
        Expanded(child: _StatTileShimmer()),
      ],
    );
  }
}

class _StatTileShimmer extends StatelessWidget {
  const _StatTileShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ShimmerBox(width: 56, height: 18),
          SizedBox(height: AppSpacing.xs),
          ShimmerBox(width: 64, height: 12),
        ],
      ),
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({
    required this.title,
    required this.tiles,
  });

  final String title;
  final List<_AccountTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          title.toUpperCase(),
          textAlign: TextAlign.center,
          style: AppTypography.sectionLabel.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            children: List<Widget>.generate(tiles.length * 2 - 1, (int index) {
              if (index.isOdd) {
                return const Divider(
                  height: 1,
                  color: AppColors.divider,
                );
              }
              return tiles[index ~/ 2];
            }),
          ),
        ),
      ],
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.leadingColor = AppColors.primary,
    this.titleStyle = AppTypography.bodyLarge,
    this.trailing,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color leadingColor;
  final TextStyle titleStyle;
  final Widget? trailing;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: leadingColor),
      title: Text(label, style: titleStyle),
      subtitle: (subtitle ?? '').trim().isEmpty
          ? null
          : Text(
              subtitle!,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
      trailing: trailing ??
          const Icon(Icons.chevron_right, color: AppColors.textHint),
    );
  }
}

class _StoreStatusTrailing extends StatelessWidget {
  const _StoreStatusTrailing({
    required this.isPublished,
    required this.isLoading,
  });

  final bool isPublished;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 52,
        child: Center(
          child: SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isPublished
                ? AppColors.success.withValues(alpha: 0.14)
                : AppColors.warning.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppRadius.chip),
          ),
          child: Text(
            isPublished
                ? AppStrings.accountStoreLive
                : AppStrings.accountStoreDraft,
            style: AppTypography.labelSmall.copyWith(
              color: isPublished ? AppColors.success : AppColors.warning,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        const Icon(Icons.chevron_right, color: AppColors.textHint),
      ],
    );
  }
}
