import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/core/router/order_slip_params.dart';
import 'package:dukaan_ai/features/catalogue/domain/models/catalogue_product.dart';
import 'package:dukaan_ai/features/order_slip/application/order_slip_provider.dart';
import 'package:dukaan_ai/features/order_slip/data/order_slip_repository.dart';
import 'package:dukaan_ai/features/order_slip/data/order_slip_repository_impl.dart';
import 'package:dukaan_ai/features/order_slip/domain/order_line_item.dart';
import 'package:dukaan_ai/features/order_slip/domain/order_slip.dart';
import 'package:dukaan_ai/features/order_slip/presentation/screens/create_order_slip_screen.dart';
import 'package:dukaan_ai/shared/providers/catalogue_products_provider.dart';
import 'package:dukaan_ai/shared/providers/order_slip_actions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_data.dart';

class MockOrderSlipRepository extends Mock implements OrderSlipRepository {}

class MockInquiryOrderActions extends Mock implements InquiryOrderActions {}

class MockKhataOrderActions extends Mock implements KhataOrderActions {}

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
  late MockInquiryOrderActions mockInquiryActions;
  late MockKhataOrderActions mockKhataActions;

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
    mockInquiryActions = MockInquiryOrderActions();
    mockKhataActions = MockKhataOrderActions();

    FirebaseService.clearOverrides();
    FirebaseService.setAuthOverride(
      const _FakeAuth(currentUser: _FakeUser('test-user-id')),
    );

    when(() => mockRepository.getSlips(any())).thenAnswer(
      (_) async => const <OrderSlip>[],
    );
    when(() => mockRepository.getSlipCount(any())).thenAnswer((_) async => 0);
    when(() => mockRepository.createSlip(any())).thenAnswer((Invocation inv) async {
      final OrderSlip slip = inv.positionalArguments.first as OrderSlip;
      return slip.copyWith(id: 'created-1');
    });
    when(() => mockRepository.updateSlipImageUrl(any(), any()))
        .thenAnswer((_) async {});

    when(() => mockInquiryActions.markInquiryOrdered(any())).thenAnswer((_) async {});
    when(
      () => mockKhataActions.addOrderDebitEntry(
        customerName: any(named: 'customerName'),
        customerPhone: any(named: 'customerPhone'),
        amount: any(named: 'amount'),
        note: any(named: 'note'),
      ),
    ).thenAnswer((_) async {});
  });

  tearDown(FirebaseService.clearOverrides);

  Future<ProviderContainer> pumpScreen(
    WidgetTester tester, {
    List<CatalogueProduct> products = const <CatalogueProduct>[],
    Object? extra,
  }) async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        orderSlipRepositoryProvider.overrideWithValue(mockRepository),
        orderSlipSellerProfileProvider.overrideWith(
          (Ref ref) async => const OrderSlipSellerProfile(
            shopName: 'Test Dukaan',
            city: 'Lucknow',
            phone: '9999999999',
            upiId: 'seller@upi',
          ),
        ),
        catalogueProductsProvider.overrideWith((Ref ref) async => products),
        inquiryOrderActionsProvider.overrideWith((Ref ref) => mockInquiryActions),
        khataOrderActionsProvider.overrideWith((Ref ref) => mockKhataActions),
      ],
    );
    addTearDown(container.dispose);

    final GoRouter router = GoRouter(
      initialLocation: '/create',
      initialExtra: extra,
      routes: <RouteBase>[
        GoRoute(
          path: '/create',
          builder: (BuildContext context, GoRouterState state) {
            return const CreateOrderSlipScreen();
          },
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    return container;
  }

  testWidgets('Order button is disabled on empty form',
      (WidgetTester tester) async {
    await pumpScreen(tester);

    final FilledButton button = tester.widget(
      find.widgetWithText(FilledButton, AppStrings.orderSlipCreateButton),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('Order button is disabled when customer is empty but product exists',
      (WidgetTester tester) async {
    final ProviderContainer container = await pumpScreen(tester);

    container.read(orderSlipProvider.notifier).addManualLineItem('Item', 500);
    await tester.pumpAndSettle();

    final FilledButton button = tester.widget(
      find.widgetWithText(FilledButton, AppStrings.orderSlipCreateButton),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('Order button is enabled when customer and line item exist',
      (WidgetTester tester) async {
    final ProviderContainer container = await pumpScreen(tester);

    final OrderSlipNotifier notifier = container.read(orderSlipProvider.notifier);
    notifier.updateDraftCustomerName('Rina Sharma');
    notifier.addManualLineItem('Item', 500);
    await tester.pumpAndSettle();

    final FilledButton button = tester.widget(
      find.widgetWithText(FilledButton, AppStrings.orderSlipCreateButton),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('Product picker bottom sheet opens on catalog add tap',
      (WidgetTester tester) async {
    await pumpScreen(
      tester,
      products: <CatalogueProduct>[testCatalogueProduct(id: 'p1')],
    );

    await tester.tap(find.text(AppStrings.orderSlipAddFromCatalog));
    await tester.pumpAndSettle();

    expect(find.text('Search products'), findsOneWidget);
  });

  testWidgets('Line item appears after adding a catalog product',
      (WidgetTester tester) async {
    final CatalogueProduct product =
        testCatalogueProduct(id: 'p1', name: 'Fancy Kurta', price: 799);
    final ProviderContainer container =
        await pumpScreen(tester, products: <CatalogueProduct>[product]);

    await container.read(orderSlipProvider.notifier).addProductFromCatalog('p1');
    await tester.pumpAndSettle();

    expect(find.text('Fancy Kurta'), findsWidgets);
  });

  testWidgets('Quantity stepper increments and decrements correctly',
      (WidgetTester tester) async {
    final ProviderContainer container = await pumpScreen(tester);
    final OrderSlipNotifier notifier = container.read(orderSlipProvider.notifier);
    notifier.addManualLineItem('Stepper Item', 100);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_circle_outline).first);
    await tester.pumpAndSettle();
    expect(find.text('2'), findsWidgets);

    await tester.tap(find.byIcon(Icons.remove_circle_outline).first);
    await tester.pumpAndSettle();
    expect(find.text('1'), findsWidgets);
  });

  testWidgets('Removing line item via X removes it', (WidgetTester tester) async {
    final ProviderContainer container = await pumpScreen(tester);
    final OrderSlipNotifier notifier = container.read(orderSlipProvider.notifier);
    notifier.addManualLineItem('Remove Me', 100);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Remove Me'), findsNothing);
  });

  testWidgets('Form pre-fills customer name and phone from inquiry params',
      (WidgetTester tester) async {
    await pumpScreen(
      tester,
      extra: const OrderSlipParams(
        inquiryId: 'inq-1',
        customerName: 'Prefilled Customer',
        customerPhone: '9999999999',
      ),
    );

    final List<TextField> fields =
        tester.widgetList<TextField>(find.byType(TextField)).toList(growable: false);

    expect(fields.first.controller?.text, 'Prefilled Customer');
    expect(fields[1].controller?.text, '9999999999');
  });

  testWidgets('Total auto-updates when discount field changes',
      (WidgetTester tester) async {
    final ProviderContainer container = await pumpScreen(tester);
    final OrderSlipNotifier notifier = container.read(orderSlipProvider.notifier);
    notifier.updateDraftCustomerName('Total Test');
    notifier.addManualLineItem('Price Item', 500);
    await tester.pumpAndSettle();

    expect(notifier.computedTotal, 500);

    final Finder discountField = find.byWidgetPredicate(
      (Widget widget) =>
          widget is TextField &&
          widget.decoration?.labelText == AppStrings.orderSlipDiscountLabel,
    );

    await tester.enterText(discountField, '100');
    await tester.pumpAndSettle();

    expect(notifier.computedTotal, 400);
  });
}
