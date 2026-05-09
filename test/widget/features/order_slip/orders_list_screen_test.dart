import 'package:dukaan_ai/core/constants/app_routes.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/features/order_slip/data/order_slip_repository.dart';
import 'package:dukaan_ai/features/order_slip/data/order_slip_repository_impl.dart';
import 'package:dukaan_ai/features/order_slip/domain/order_line_item.dart';
import 'package:dukaan_ai/features/order_slip/domain/order_slip.dart';
import 'package:dukaan_ai/features/order_slip/presentation/screens/orders_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderSlipRepository extends Mock implements OrderSlipRepository {}

class _FakeUser {
  const _FakeUser(this.uid);

  final String uid;
}

class _FakeAuth {
  const _FakeAuth({this.currentUser});

  final _FakeUser? currentUser;
}

void main() {
  late MockOrderSlipRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(
      OrderSlip(
        id: 'fallback',
        userId: 'test-user-id',
        slipNumber: 'ORD-2026-1',
        customerName: 'Fallback',
        lineItems: const <OrderLineItem>[
          OrderLineItem(productName: 'Fallback', unitPrice: 100),
        ],
        subtotal: 100,
        total: 100,
        createdAt: DateTime(2026, 4, 12),
      ),
    );
  });

  setUp(() {
    mockRepository = MockOrderSlipRepository();

    FirebaseService.clearOverrides();
    FirebaseService.setAuthOverride(
      const _FakeAuth(currentUser: _FakeUser('test-user-id')),
    );

    when(() => mockRepository.getSlipCount(any())).thenAnswer((_) async => 0);
    when(() => mockRepository.createSlip(any())).thenThrow(Exception('not used'));
    when(() => mockRepository.updateSlipImageUrl(any(), any()))
        .thenAnswer((_) async {});
    when(() => mockRepository.deleteSlip(any())).thenAnswer((_) async {});
  });

  tearDown(FirebaseService.clearOverrides);

  OrderSlip buildSlip({
    String id = 'slip-1',
    String customerName = 'Rina Sharma',
  }) {
    return OrderSlip(
      id: id,
      userId: 'test-user-id',
      slipNumber: 'ORD-2026-1',
      customerName: customerName,
      lineItems: const <OrderLineItem>[
        OrderLineItem(productName: 'Kurti', unitPrice: 500, quantity: 1),
      ],
      subtotal: 500,
      total: 500,
      createdAt: DateTime(2026, 4, 12),
    );
  }

  Future<void> pumpWithRouter(
    WidgetTester tester, {
    required List<OrderSlip> slips,
  }) async {
    when(() => mockRepository.getSlips(any())).thenAnswer((_) async => slips);

    final GoRouter router = GoRouter(
      initialLocation: AppRoutes.ordersHistory,
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.ordersHistory,
          builder: (BuildContext context, GoRouterState state) {
            return const OrdersListScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.orderSlipDetail,
          builder: (BuildContext context, GoRouterState state) {
            return const Scaffold(body: Text('Order detail route'));
          },
        ),
      ],
    );

    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          orderSlipRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('shows empty state message when there are no slips',
      (WidgetTester tester) async {
    await pumpWithRouter(tester, slips: const <OrderSlip>[]);

    expect(find.text('Abhi koi order nahi hai. Pehla order banao! 📦'), findsOneWidget);
  });

  testWidgets('renders order cards when slips exist', (WidgetTester tester) async {
    await pumpWithRouter(
      tester,
      slips: <OrderSlip>[
        buildSlip(id: 'slip-1', customerName: 'Rina Sharma'),
        buildSlip(id: 'slip-2', customerName: 'Vikram Singh'),
      ],
    );

    expect(find.text('Rina Sharma'), findsOneWidget);
    expect(find.text('Vikram Singh'), findsOneWidget);
  });

  testWidgets('tapping order card navigates to detail route',
      (WidgetTester tester) async {
    await pumpWithRouter(
      tester,
      slips: <OrderSlip>[buildSlip(id: 'slip-1', customerName: 'Tap Target')],
    );

    await tester.tap(find.text('Tap Target'));
    await tester.pumpAndSettle();

    expect(find.text('Order detail route'), findsOneWidget);
  });
}
