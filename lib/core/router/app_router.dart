import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../firebase/firebase_service.dart';
import '../../features/account/presentation/screens/account_screen.dart';
import '../../features/account/presentation/screens/edit_profile_screen.dart';
import '../../features/account/presentation/screens/upi_settings_screen.dart';
import '../../features/catalogue/presentation/screens/create_catalogue_screen.dart';
import '../../features/inquiry/presentation/screens/add_inquiry_screen.dart';
import '../../features/inquiry/presentation/screens/inquiry_detail_screen.dart';
import '../../features/inquiry/presentation/screens/inquiry_list_screen.dart';
import '../../features/khata/presentation/screens/khata_screen.dart';
import '../../features/my_ads/presentation/screens/my_ads_screen.dart';
import '../../features/onboarding/presentation/screens/phone_auth_screen.dart';
import '../../features/onboarding/presentation/screens/shop_setup_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import '../../features/order_slip/domain/order_slip.dart';
import '../../features/order_slip/presentation/screens/create_order_slip_screen.dart';
import '../../features/order_slip/presentation/screens/order_slip_detail_screen.dart';
import '../../features/order_slip/presentation/screens/orders_list_screen.dart';
import '../../features/seller_store/presentation/screens/seller_store_screen.dart';
import '../../features/subscription/presentation/screens/subscription_screen.dart';
import '../../features/studio/domain/generated_ad.dart';
import '../../features/studio/presentation/screens/ad_preview_screen.dart';
import '../../features/studio/presentation/screens/background_select_screen.dart';
import '../../features/studio/presentation/screens/camera_capture_screen.dart';
import '../../features/studio/presentation/screens/studio_screen.dart';
import '../../features/studio/presentation/screens/whatsapp_broadcast_screen.dart';
import '../../shared/widgets/app_shell_scaffold.dart';
import '../constants/app_routes.dart';

part 'app_router.g.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _studioNavKey =
    GlobalKey<NavigatorState>(debugLabel: 'studio');
final GlobalKey<NavigatorState> _khataNavKey =
    GlobalKey<NavigatorState>(debugLabel: 'khata');
final GlobalKey<NavigatorState> _myAdsNavKey =
    GlobalKey<NavigatorState>(debugLabel: 'myads');
final GlobalKey<NavigatorState> _subscriptionNavKey =
    GlobalKey<NavigatorState>(debugLabel: 'subscription');
final GlobalKey<NavigatorState> _inquiryNavKey =
    GlobalKey<NavigatorState>(debugLabel: 'inquiry');
final GlobalKey<NavigatorState> _accountNavKey =
    GlobalKey<NavigatorState>(debugLabel: 'account');

Future<bool> _hasShopProfile(String userId) async {
  try {
    final dynamic snapshot = await FirebaseService.db
        .collection('users')
        .doc(userId)
        .get()
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw Exception('Firestore timeout'),
        );
    final bool exists = snapshot.exists as bool? ?? false;
    if (!exists) return false;

    final dynamic raw = snapshot.data();
    Map<String, dynamic> data = <String, dynamic>{};
    if (raw is Map<String, dynamic>) {
      data = raw;
    } else if (raw is Map<Object?, Object?>) {
      data = raw.map<String, dynamic>(
        (Object? key, Object? value) => MapEntry(key.toString(), value),
      );
    }

    final String shopName = data['shopName'] as String? ?? '';
    return shopName.trim().isNotEmpty;
  } catch (_) {
    // On any error (network, timeout, auth) — treat as no profile
    // so the user lands on onboarding rather than being stuck forever.
    return false;
  }
}

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.studio,
    redirect: (BuildContext context, GoRouterState state) async {
      if (const bool.fromEnvironment('SKIP_AUTH', defaultValue: false)) {
        return null;
      }

      final bool isOnboarding =
          state.matchedLocation.startsWith(AppRoutes.onboarding);
      final String? userId = FirebaseService.currentUserId;

      if (userId == null || userId.isEmpty) {
        if (!isOnboarding) {
          return AppRoutes.onboarding;
        }
        return null;
      }

      bool hasProfile = false;
      try {
        hasProfile = await _hasShopProfile(userId);
      } catch (_) {
        hasProfile = false;
      }

      if (!hasProfile && !isOnboarding) {
        return AppRoutes.onboardingSetup;
      }

      if (isOnboarding && hasProfile) {
        return AppRoutes.studio;
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.nameOnboarding,
        builder: (BuildContext context, GoRouterState state) {
          return const WelcomeScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.onboardingSetup,
        name: AppRoutes.nameOnboardingSetup,
        builder: (BuildContext context, GoRouterState state) {
          return const ShopSetupScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.onboardingPhone,
        name: AppRoutes.nameOnboardingPhone,
        builder: (BuildContext context, GoRouterState state) {
          return const PhoneAuthScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.ordersHistory,
        name: AppRoutes.nameOrdersHistory,
        builder: (BuildContext context, GoRouterState state) {
          return const OrdersListScreen();
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'create',
            name: AppRoutes.nameOrderSlipCreate,
            builder: (BuildContext context, GoRouterState state) {
              return const CreateOrderSlipScreen();
            },
          ),
          GoRoute(
            path: ':slipId',
            name: AppRoutes.nameOrderSlipDetail,
            builder: (BuildContext context, GoRouterState state) {
              final Object? extra = state.extra;
              final OrderSlip? slip = extra is OrderSlip ? extra : null;

              return OrderSlipDetailScreen(
                slip: slip,
                slipId: state.pathParameters['slipId'] ?? '',
              );
            },
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) {
          return AppShellScaffold(
            navigationShell: navigationShell,
            child: navigationShell,
          );
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            navigatorKey: _studioNavKey,
            initialLocation: AppRoutes.studio,
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.studio,
                name: AppRoutes.nameStudio,
                builder: (BuildContext context, GoRouterState state) {
                  return const StudioScreen();
                },
                routes: <RouteBase>[
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    path: 'capture',
                    name: AppRoutes.nameCameraCapture,
                    builder: (BuildContext context, GoRouterState state) {
                      return const CameraCaptureScreen();
                    },
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    path: 'background-select',
                    builder: (BuildContext context, GoRouterState state) {
                      return const BackgroundSelectScreen();
                    },
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    path: 'ad-preview',
                    name: AppRoutes.nameAdPreview,
                    builder: (BuildContext context, GoRouterState state) {
                      return const AdPreviewScreen();
                    },
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    path: 'broadcast',
                    name: AppRoutes.nameWhatsappBroadcast,
                    builder: (BuildContext context, GoRouterState state) {
                      final GeneratedAd ad = state.extra! as GeneratedAd;
                      return WhatsAppBroadcastScreen(ad: ad);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _khataNavKey,
            initialLocation: AppRoutes.khata,
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.khata,
                name: AppRoutes.nameKhata,
                builder: (BuildContext context, GoRouterState state) {
                  return const KhataScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _myAdsNavKey,
            initialLocation: AppRoutes.myAds,
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.myAds,
                name: AppRoutes.nameMyAds,
                builder: (BuildContext context, GoRouterState state) {
                  return const MyAdsScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _subscriptionNavKey,
            initialLocation: AppRoutes.subscription,
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.subscription,
                name: AppRoutes.nameSubscription,
                builder: (BuildContext context, GoRouterState state) {
                  return const SubscriptionScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _inquiryNavKey,
            initialLocation: AppRoutes.inquiries,
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.inquiries,
                name: AppRoutes.nameInquiries,
                builder: (BuildContext context, GoRouterState state) {
                  return const InquiryListScreen();
                },
                routes: <RouteBase>[
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    path: 'add',
                    name: AppRoutes.nameAddInquiry,
                    builder: (BuildContext context, GoRouterState state) {
                      return const AddInquiryScreen();
                    },
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    path: ':inquiryId',
                    name: AppRoutes.nameInquiryDetail,
                    builder: (BuildContext context, GoRouterState state) {
                      return InquiryDetailScreen(
                        inquiryId: state.pathParameters['inquiryId'] ?? '',
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _accountNavKey,
            initialLocation: AppRoutes.account,
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.account,
                name: AppRoutes.nameAccount,
                builder: (BuildContext context, GoRouterState state) {
                  return const AccountScreen();
                },
                routes: <RouteBase>[
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    path: 'edit-profile',
                    name: AppRoutes.nameEditProfile,
                    builder: (BuildContext context, GoRouterState state) {
                      return const EditProfileScreen();
                    },
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    path: 'upi-settings',
                    name: AppRoutes.nameUpiSettings,
                    builder: (BuildContext context, GoRouterState state) {
                      return const UpiSettingsScreen();
                    },
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    path: 'catalogue',
                    name: AppRoutes.nameCatalogue,
                    builder: (BuildContext context, GoRouterState state) {
                      return const CreateCatalogueScreen();
                    },
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    path: 'seller-store',
                    name: AppRoutes.nameSellerStore,
                    builder: (BuildContext context, GoRouterState state) {
                      return const SellerStoreScreen();
                    },
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    path: 'pricing',
                    name: AppRoutes.namePricing,
                    builder: (BuildContext context, GoRouterState state) {
                      return const SubscriptionScreen();
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
