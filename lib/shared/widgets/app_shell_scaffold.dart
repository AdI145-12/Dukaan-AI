import 'dart:async';

import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/constants/app_routes.dart';
import 'package:dukaan_ai/core/services/local_notification_service.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/inquiry/application/inquiry_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppShellScaffold extends ConsumerWidget {
  const AppShellScaffold({
    super.key,
    required this.navigationShell,
    required this.child,
  });

  final StatefulNavigationShell navigationShell;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<int> followUpCount = ref.watch(followUpDueCountProvider);
    final int badgeCount = followUpCount.asData?.value ?? 0;

    ref.listen<AsyncValue<int>>(followUpDueCountProvider, (
      AsyncValue<int>? previous,
      AsyncValue<int> next,
    ) {
      next.whenData((int count) {
        unawaited(
          LocalNotificationService.instance.scheduleFollowUpReminder(count),
        );
      });
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryLight,
        selectedIndex: navigationShell.currentIndex,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        height: AppSpacing.xxl + AppSpacing.md,
        onDestinationSelected: (int index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: <NavigationDestination>[
          const NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome, color: AppColors.primary),
            label: AppStrings.tabStudio,
          ),
          const NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(
              Icons.account_balance_wallet,
              color: AppColors.primary,
            ),
            label: AppStrings.tabKhata,
          ),
          const NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view, color: AppColors.primary),
            label: AppStrings.tabMyAds,
          ),
          const NavigationDestination(
            icon: Icon(Icons.workspace_premium_outlined),
            selectedIcon:
                Icon(Icons.workspace_premium, color: AppColors.primary),
            label: AppStrings.subscriptionTab,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: badgeCount > 0,
              label: Text(badgeCount > 9 ? '9+' : '$badgeCount'),
              child: const Icon(Icons.people_outline),
            ),
            selectedIcon: Badge(
              isLabelVisible: badgeCount > 0,
              label: Text(badgeCount > 9 ? '9+' : '$badgeCount'),
              child: const Icon(Icons.people, color: AppColors.primary),
            ),
            label: AppStrings.inquiriesTitle,
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.primary),
            label: AppStrings.tabAccount,
          ),
        ],
      ),
      floatingActionButton: _buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget? _buildFab(BuildContext context) {
    if (navigationShell.currentIndex != 0) {
      return null;
    }

    return SizedBox(
      width: AppSpacing.xxl + AppSpacing.md,
      height: AppSpacing.xxl + AppSpacing.md,
      child: FloatingActionButton(
        heroTag: 'studio_camera_fab',
        onPressed: () {
          context.push(AppRoutes.cameraCapture);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        tooltip: AppStrings.fabNewAd,
        shape: const CircleBorder(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.camera_alt,
              size: AppSpacing.md + AppSpacing.xs,
            ),
            Text(
              AppStrings.fabNewAd,
              style:
                  AppTypography.labelSmall.copyWith(color: AppColors.surface),
            ),
          ],
        ),
      ),
    );
  }
}
