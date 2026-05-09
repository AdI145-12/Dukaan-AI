import 'dart:async';
import 'dart:typed_data';

import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/features/catalogue/domain/models/catalogue_product.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry.dart';
import 'package:dukaan_ai/features/order_slip/application/order_slip_provider.dart';
import 'package:dukaan_ai/features/order_slip/application/order_slip_state.dart';
import 'package:dukaan_ai/features/order_slip/data/order_slip_repository.dart';
import 'package:dukaan_ai/features/order_slip/data/order_slip_repository_impl.dart';
import 'package:dukaan_ai/features/order_slip/domain/order_line_item.dart';
import 'package:dukaan_ai/features/order_slip/domain/order_slip.dart';
import 'package:dukaan_ai/shared/providers/catalogue_products_provider.dart';
import 'package:dukaan_ai/shared/providers/order_slip_actions_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:screenshot/screenshot.dart';

import '../../../helpers/test_data.dart';

class MockOrderSlipRepository extends Mock implements OrderSlipRepository {}

class MockInquiryOrderActions extends Mock implements InquiryOrderActions {}

class MockKhataOrderActions extends Mock implements KhataOrderActions {}

class MockScreenshotController extends Mock implements ScreenshotController {}

class _FakeUser {
  const _FakeUser(this.uid);

  final String uid;
}

class _FakeAuth {
  const _FakeAuth({this.currentUser});

  final _FakeUser? currentUser;
}

class _FakeStorage {
  _FakeStorageRef ref() => _FakeStorageRef('');
}

class _FakeStorageRef {
  _FakeStorageRef(this.path);

  final String path;

  _FakeStorageRef child(String nextPath) {
    final String merged = path.isEmpty ? nextPath : '$path/$nextPath';
    return _FakeStorageRef(merged);
  }

  Future<void> putData(
    Uint8List bytes,
    Map<String, Object> metadata,
  ) async {}

  Future<String> getDownloadURL() async {
    return 'https://example.com/$path';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockOrderSlipRepository mockRepository;
  late MockInquiryOrderActions mockInquiryActions;
  late MockKhataOrderActions mockKhataActions;

  setUpAll(() {
    registerFallbackValue(
      OrderSlip(
        id: 'fallback',
        userId: 'test-user-id',
        slipNumber: 'ORD-2026-1',
        customerName: 'Fallback Customer',
        lineItems: const <OrderLineItem>[
          OrderLineItem(productName: 'Fallback Item', unitPrice: 100),
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
      final OrderSlip input = inv.positionalArguments.first as OrderSlip;
      return input.copyWith(id: 'slip-1');
    });
    when(
      () => mockRepository.updateSlipImageUrl(any(), any()),
    ).thenAnswer((_) async {});
    when(() => mockRepository.deleteSlip(any())).thenAnswer((_) async {});

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

  ProviderContainer createContainer({
    List<CatalogueProduct> products = const <CatalogueProduct>[],
  }) {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        orderSlipRepositoryProvider.overrideWithValue(mockRepository),
        orderSlipSellerProfileProvider.overrideWith(
          (Ref ref) async => const OrderSlipSellerProfile(
            shopName: 'Test Dukaan',
            city: 'Lucknow',
            phone: '9876543210',
            upiId: 'seller@upi',
          ),
        ),
        catalogueProductsProvider.overrideWith((Ref ref) async => products),
        inquiryOrderActionsProvider.overrideWith((Ref ref) => mockInquiryActions),
        khataOrderActionsProvider.overrideWith((Ref ref) => mockKhataActions),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<void> seedDraft(
    ProviderContainer container, {
    String customerName = 'Rina Sharma',
  }) async {
    final OrderSlipNotifier notifier = container.read(orderSlipProvider.notifier);
    notifier.updateDraftCustomerName(customerName);
    notifier.addManualLineItem('Cotton Kurti', 499);
  }

  group('orderSlipProvider build', () {
    test('build loads existing slips into state.slips', () async {
      final OrderSlip existing = OrderSlip(
        id: 'slip-x',
        userId: 'test-user-id',
        slipNumber: 'ORD-2026-99',
        customerName: 'Asha',
        lineItems: const <OrderLineItem>[
          OrderLineItem(productName: 'Kurta', unitPrice: 300),
        ],
        subtotal: 300,
        total: 300,
        createdAt: DateTime(2026, 4, 1),
      );

      when(() => mockRepository.getSlips('test-user-id')).thenAnswer(
        (_) async => <OrderSlip>[existing],
      );

      final ProviderContainer container = createContainer();
      final OrderSlipState state = await container.read(orderSlipProvider.future);

      expect(state.slips.length, 1);
      expect(state.slips.first.id, 'slip-x');
    });
  });

  group('draft item operations', () {
    test('addProductFromCatalog appends draft line item from catalogue product',
        () async {
      final CatalogueProduct product = testCatalogueProduct(
        id: 'prod-1',
        name: 'Blue Shirt',
        price: 799,
      );
      final ProviderContainer container = createContainer(products: <CatalogueProduct>[product]);
      await container.read(orderSlipProvider.future);

      await container.read(orderSlipProvider.notifier).addProductFromCatalog('prod-1');

      final OrderSlipState state = container.read(orderSlipProvider).requireValue;
      expect(state.draftLineItems.length, 1);
      expect(state.draftLineItems.first.productName, 'Blue Shirt');
      expect(state.draftLineItems.first.unitPrice, 799);
    });

    test('addProductFromCatalog twice increments quantity instead of duplicate',
        () async {
      final CatalogueProduct product = testCatalogueProduct(
        id: 'prod-1',
        name: 'Blue Shirt',
        price: 799,
      );
      final ProviderContainer container = createContainer(products: <CatalogueProduct>[product]);
      await container.read(orderSlipProvider.future);

      final OrderSlipNotifier notifier = container.read(orderSlipProvider.notifier);
      await notifier.addProductFromCatalog('prod-1');
      await notifier.addProductFromCatalog('prod-1');

      final OrderSlipState state = container.read(orderSlipProvider).requireValue;
      expect(state.draftLineItems.length, 1);
      expect(state.draftLineItems.first.quantity, 2);
    });

    test('addManualLineItem appends line item with null productId', () async {
      final ProviderContainer container = createContainer();
      await container.read(orderSlipProvider.future);

      container.read(orderSlipProvider.notifier).addManualLineItem('Manual Item', 250);

      final OrderSlipState state = container.read(orderSlipProvider).requireValue;
      expect(state.draftLineItems.length, 1);
      expect(state.draftLineItems.first.productId, isNull);
    });

    test('removeLineItem removes item at requested index', () async {
      final ProviderContainer container = createContainer();
      await container.read(orderSlipProvider.future);

      final OrderSlipNotifier notifier = container.read(orderSlipProvider.notifier);
      notifier.addManualLineItem('Item A', 100);
      notifier.addManualLineItem('Item B', 200);
      notifier.removeLineItem(0);

      final OrderSlipState state = container.read(orderSlipProvider).requireValue;
      expect(state.draftLineItems.length, 1);
      expect(state.draftLineItems.first.productName, 'Item B');
    });

    test('updateLineItemQuantity with 0 removes item', () async {
      final ProviderContainer container = createContainer();
      await container.read(orderSlipProvider.future);

      final OrderSlipNotifier notifier = container.read(orderSlipProvider.notifier);
      notifier.addManualLineItem('Item A', 100);
      notifier.updateLineItemQuantity(0, 0);

      final OrderSlipState state = container.read(orderSlipProvider).requireValue;
      expect(state.draftLineItems, isEmpty);
    });

    test('updateLineItemQuantity with positive value updates quantity', () async {
      final ProviderContainer container = createContainer();
      await container.read(orderSlipProvider.future);

      final OrderSlipNotifier notifier = container.read(orderSlipProvider.notifier);
      notifier.addManualLineItem('Item A', 100);
      notifier.updateLineItemQuantity(0, 5);

      final OrderSlipState state = container.read(orderSlipProvider).requireValue;
      expect(state.draftLineItems.first.quantity, 5);
    });

    test('computedTotal equals subtotal minus discount plus delivery', () async {
      final ProviderContainer container = createContainer();
      await container.read(orderSlipProvider.future);

      final OrderSlipNotifier notifier = container.read(orderSlipProvider.notifier);
      notifier.addManualLineItem('Item A', 100);
      notifier.addManualLineItem('Item B', 50);
      notifier.updateDraftDiscount(20);
      notifier.updateDraftDeliveryCharge(30);

      expect(notifier.computedSubtotal, 150);
      expect(notifier.computedTotal, 160);
    });
  });

  group('createAndShareSlip', () {
    test('fails validation when line items are empty', () async {
      final ProviderContainer container = createContainer();
      await container.read(orderSlipProvider.future);
      container.read(orderSlipProvider.notifier).updateDraftCustomerName('Rina');

      final MockScreenshotController screenshot = MockScreenshotController();
      when(() => screenshot.capture(pixelRatio: any(named: 'pixelRatio')))
          .thenAnswer((_) async => null);

      await container.read(orderSlipProvider.notifier).createAndShareSlip(
            GlobalKey(),
            screenshotController: screenshot,
          );

      final OrderSlipState state = container.read(orderSlipProvider).requireValue;
      expect(state.errorMessage, isNotNull);
      verifyNever(() => mockRepository.createSlip(any()));
    });

    test('fails validation when customer name is empty', () async {
      final ProviderContainer container = createContainer();
      await container.read(orderSlipProvider.future);
      container.read(orderSlipProvider.notifier).addManualLineItem('Item', 200);

      final MockScreenshotController screenshot = MockScreenshotController();
      when(() => screenshot.capture(pixelRatio: any(named: 'pixelRatio')))
          .thenAnswer((_) async => null);

      await container.read(orderSlipProvider.notifier).createAndShareSlip(
            GlobalKey(),
            screenshotController: screenshot,
          );

      verifyNever(() => mockRepository.createSlip(any()));
    });

    test('success calls createSlip and sets generating flag during capture',
        () async {
      final ProviderContainer container = createContainer();
      final Completer<OrderSlipState> generatingState = Completer<OrderSlipState>();
      final ProviderSubscription<AsyncValue<OrderSlipState>> subscription =
          container.listen(orderSlipProvider, (_, AsyncValue<OrderSlipState> next) {
        final OrderSlipState? value = next.asData?.value;
        if (value != null && value.isGeneratingImage && !generatingState.isCompleted) {
          generatingState.complete(value);
        }
      });
      addTearDown(subscription.close);

      await container.read(orderSlipProvider.future);
      await seedDraft(container);

      final Completer<Uint8List?> captureCompleter = Completer<Uint8List?>();
      final MockScreenshotController screenshot = MockScreenshotController();
      when(() => screenshot.capture(pixelRatio: any(named: 'pixelRatio')))
          .thenAnswer((_) => captureCompleter.future);

      final Future<void> pending =
          container.read(orderSlipProvider.notifier).createAndShareSlip(
                GlobalKey(),
                screenshotController: screenshot,
              );

      await untilCalled(() => mockRepository.createSlip(any()));
      final OrderSlipState mid = await generatingState.future;
      expect(mid.slips.length, 1);
      expect(mid.isGeneratingImage, isTrue);
      verify(() => mockRepository.createSlip(any())).called(1);

      captureCompleter.complete(null);
      await pending;
    });

    test('after image upload updates slipImageUrl and resets generating flag',
        () async {
      FirebaseService.setStoreOverride(_FakeStorage());
      final ProviderContainer container = createContainer();
      await container.read(orderSlipProvider.future);
      await seedDraft(container);

      final MockScreenshotController screenshot = MockScreenshotController();
      when(() => screenshot.capture(pixelRatio: any(named: 'pixelRatio')))
          .thenAnswer((_) async => Uint8List.fromList(<int>[1, 2, 3]));

      await container.read(orderSlipProvider.notifier).createAndShareSlip(
            GlobalKey(),
            screenshotController: screenshot,
          );

      verify(() => mockRepository.updateSlipImageUrl('slip-1', any())).called(1);
      final OrderSlipState state = container.read(orderSlipProvider).requireValue;
      expect(state.isGeneratingImage, isFalse);
      expect(state.slips.first.slipImageUrl, isNotNull);
    });
  });

  group('cross-feature bridges', () {
    test('prefillFromInquiry sets customer fields and prefillInquiryId',
        () async {
      final CatalogueProduct product = testCatalogueProduct(
        id: 'linked-1',
        name: 'Linked Product',
        price: 120,
      );
      final ProviderContainer container = createContainer(products: <CatalogueProduct>[product]);
      await container.read(orderSlipProvider.future);

      final Inquiry inquiry = testInquiry(
        id: 'inq-1',
        customerName: 'Vikram',
        customerPhone: '9999999999',
        productId: 'linked-1',
      );

      await container.read(orderSlipProvider.notifier).prefillFromInquiry(inquiry);
      final OrderSlipState state = container.read(orderSlipProvider).requireValue;

      expect(state.prefillInquiryId, 'inq-1');
      expect(state.draftCustomerName, 'Vikram');
      expect(state.draftCustomerPhone, '9999999999');
      expect(state.draftLineItems.length, 1);
    });

    test('createAndShareSlip with prefillInquiryId marks inquiry ordered',
        () async {
      FirebaseService.setStoreOverride(_FakeStorage());
      final ProviderContainer container = createContainer();
      await container.read(orderSlipProvider.future);
      await seedDraft(container);
      await container.read(orderSlipProvider.notifier).prefillFromParams(
            inquiryId: 'inq-42',
            customerName: 'Rina Sharma',
          );

      final MockScreenshotController screenshot = MockScreenshotController();
      when(() => screenshot.capture(pixelRatio: any(named: 'pixelRatio')))
          .thenAnswer((_) async => Uint8List.fromList(<int>[1, 2, 3]));

      await container.read(orderSlipProvider.notifier).createAndShareSlip(
            GlobalKey(),
            screenshotController: screenshot,
          );

      verify(() => mockInquiryActions.markInquiryOrdered('inq-42')).called(1);
    });

    test('addToKhata sends debit entry with order note and total', () async {
      final ProviderContainer container = createContainer();
      await container.read(orderSlipProvider.future);

      final OrderSlip slip = OrderSlip(
        id: 'slip-2',
        userId: 'test-user-id',
        slipNumber: 'ORD-2026-2',
        customerName: 'Nisha',
        customerPhone: '9888777666',
        lineItems: const <OrderLineItem>[
          OrderLineItem(productName: 'Saree', unitPrice: 500, quantity: 2),
        ],
        subtotal: 1000,
        total: 980,
        discountAmount: 20,
        createdAt: DateTime(2026, 4, 12),
      );

      await container.read(orderSlipProvider.notifier).addToKhata(slip);

      verify(
        () => mockKhataActions.addOrderDebitEntry(
          customerName: 'Nisha',
          customerPhone: '9888777666',
          amount: 980,
          note: 'Order ORD-2026-2',
        ),
      ).called(1);
    });
  });
}
