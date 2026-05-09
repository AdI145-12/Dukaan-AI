import 'package:dukaan_ai/core/constants/app_routes.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _FakeUser {
  const _FakeUser(this.uid);

  final String uid;
}

class _FakeAuth {
  const _FakeAuth({this.currentUser});

  final _FakeUser? currentUser;
}

class _FakeDb {
  const _FakeDb({required this.shopName});

  final String? shopName;

  _FakeCollection collection(String name) {
    return _FakeCollection(shopName: shopName);
  }
}

class _FakeCollection {
  const _FakeCollection({required this.shopName});

  final String? shopName;

  _FakeDocRef doc(String userId) {
    return _FakeDocRef(shopName: shopName);
  }
}

class _FakeDocRef {
  const _FakeDocRef({required this.shopName});

  final String? shopName;

  Future<_FakeDocSnapshot> get() async {
    return _FakeDocSnapshot(shopName: shopName);
  }
}

class _FakeDocSnapshot {
  const _FakeDocSnapshot({required this.shopName});

  final String? shopName;

  bool get exists => shopName != null;

  Map<String, dynamic>? data() {
    if (shopName == null) {
      return null;
    }
    return <String, dynamic>{'shopName': shopName};
  }
}

void main() {
  setUp(FirebaseService.clearOverrides);
  tearDown(FirebaseService.clearOverrides);

  Future<GoRouter> pumpRouter(WidgetTester tester) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final GoRouter router = container.read(appRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    return router;
  }

  String locationOf(GoRouter router) {
    return router.routeInformationProvider.value.uri.path;
  }

  testWidgets('Unauthenticated redirect', (WidgetTester tester) async {
    FirebaseService.setAuthOverride(const _FakeAuth(currentUser: null));
    FirebaseService.setDbOverride(const _FakeDb(shopName: null));

    final GoRouter router = await pumpRouter(tester);

    expect(locationOf(router), AppRoutes.onboarding);
  });

  testWidgets('Authenticated without profile redirects to setup',
      (WidgetTester tester) async {
    FirebaseService.setAuthOverride(const _FakeAuth(currentUser: _FakeUser('u-1')));
    FirebaseService.setDbOverride(const _FakeDb(shopName: null));

    final GoRouter router = await pumpRouter(tester);

    expect(locationOf(router), AppRoutes.onboardingSetup);
  });

  testWidgets('Authenticated with profile accessing onboarding redirects to studio',
      (WidgetTester tester) async {
    FirebaseService.setAuthOverride(const _FakeAuth(currentUser: _FakeUser('u-1')));
    FirebaseService.setDbOverride(const _FakeDb(shopName: 'Test Dukaan'));

    final GoRouter router = await pumpRouter(tester);

    expect(locationOf(router), AppRoutes.studio);

    router.go(AppRoutes.onboarding);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(locationOf(router), AppRoutes.studio);
  });
}