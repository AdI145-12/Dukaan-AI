import 'dart:async';

import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/network/cloudflare_client.dart';
import 'package:dukaan_ai/features/account/application/payment_service.dart';
import 'package:dukaan_ai/features/account/application/profile_provider.dart';
import 'package:dukaan_ai/features/account/domain/pricing_plans.dart';
import 'package:dukaan_ai/features/account/presentation/screens/pricing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePaymentService extends PaymentService {
  _FakePaymentService({required this.handler})
      : super(cloudflareClient: CloudflareClient(baseUrl: 'https://example.com'));

  final Future<PaymentResult> Function({
    required String planId,
    required int amountPaise,
    required String userId,
  }) handler;

  @override
  Future<PaymentResult> initiatePayment({
    required String planId,
    required int amountPaise,
    required String userId,
  }) {
    return handler(
      planId: planId,
      amountPaise: amountPaise,
      userId: userId,
    );
  }
}

void main() {
  Future<void> pumpPricingScreen(
    WidgetTester tester, {
    required PlanTier currentTier,
    PaymentService? paymentService,
  }) async {
    final PaymentService resolvedPaymentService = paymentService ??
        _FakePaymentService(
          handler: ({
            required String planId,
            required int amountPaise,
            required String userId,
          }) async {
            return const PaymentResult.cancelled();
          },
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountTierProvider.overrideWith(
            (Ref ref) async {
              return currentTier;
            },
          ),
          paymentServiceProvider.overrideWithValue(resolvedPaymentService),
        ],
        child: const MaterialApp(home: PricingScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders all 4 plan cards in Monthly Plans view', (
    WidgetTester tester,
  ) async {
    // Arrange
    await pumpPricingScreen(tester, currentTier: PlanTier.free);

    // Assert
    expect(find.text('Free'), findsOneWidget);
    expect(find.text('Dukaan'), findsOneWidget);
    expect(find.text('Vyapaar'), findsOneWidget);
    expect(find.text('Utsav'), findsOneWidget);
  });

  testWidgets('Vyapaar card shows Most Popular badge', (
    WidgetTester tester,
  ) async {
    // Arrange
    await pumpPricingScreen(tester, currentTier: PlanTier.free);

    // Assert
    expect(find.text(AppStrings.mostPopularBadge), findsOneWidget);
  });

  testWidgets('current plan shows Current Plan label and hides buy button', (
    WidgetTester tester,
  ) async {
    // Arrange
    await pumpPricingScreen(tester, currentTier: PlanTier.dukaan);

    // Assert
    expect(find.text(AppStrings.currentPlanLabel), findsOneWidget);
    expect(find.text('Yeh plan lo — ₹99/mo'), findsNothing);
  });

  testWidgets('toggle switches to Ad Packs view', (WidgetTester tester) async {
    // Arrange
    await pumpPricingScreen(tester, currentTier: PlanTier.free);

    // Act
    await tester.tap(find.text(AppStrings.adPacksTab));
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Starter Pack'), findsOneWidget);
    expect(find.text('Value Pack'), findsOneWidget);
    expect(find.text('Festival Pack'), findsOneWidget);
  });

  testWidgets('tapping buy plan shows loading overlay', (WidgetTester tester) async {
    // Arrange
    final Completer<PaymentResult> neverCompletes = Completer<PaymentResult>();
    final PaymentService pendingService = _FakePaymentService(
      handler: ({
        required String planId,
        required int amountPaise,
        required String userId,
      }) {
        return neverCompletes.future;
      },
    );

    await pumpPricingScreen(
      tester,
      currentTier: PlanTier.free,
      paymentService: pendingService,
    );

    // Act
    await tester.ensureVisible(find.text('Yeh plan lo — ₹249/mo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yeh plan lo — ₹249/mo'));
    await tester.pump();

    // Assert
    expect(find.text(AppStrings.paymentInProgress), findsOneWidget);
  });

  testWidgets('successful payment shows success bottom sheet', (
    WidgetTester tester,
  ) async {
    // Arrange
    final PaymentService successService = _FakePaymentService(
      handler: ({
        required String planId,
        required int amountPaise,
        required String userId,
      }) async {
        return const PaymentResult.success(transactionId: 'pay_test123');
      },
    );

    await pumpPricingScreen(
      tester,
      currentTier: PlanTier.free,
      paymentService: successService,
    );

    // Act
    await tester.ensureVisible(find.text('Yeh plan lo — ₹249/mo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yeh plan lo — ₹249/mo'));
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Vyapaar plan active ho gaya! 🎉'), findsOneWidget);
    expect(find.text('Transaction ID: pay_test123'), findsOneWidget);
  });
}
