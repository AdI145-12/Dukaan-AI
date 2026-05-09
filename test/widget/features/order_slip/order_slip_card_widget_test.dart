import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/features/order_slip/domain/order_line_item.dart';
import 'package:dukaan_ai/features/order_slip/domain/order_slip.dart';
import 'package:dukaan_ai/features/order_slip/presentation/widgets/order_slip_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  OrderSlip buildSlip({
    double discount = 0,
    double delivery = 0,
    PaymentMode paymentMode = PaymentMode.pending,
    String? upiId,
    bool gstEnabled = false,
  }) {
    return OrderSlip(
      id: 'slip-1',
      userId: 'user-1',
      slipNumber: 'ORD-2026-1',
      customerName: 'Rina Sharma',
      customerPhone: '9876543210',
      lineItems: const <OrderLineItem>[
        OrderLineItem(productName: 'Blue Kurti', unitPrice: 500, quantity: 2),
        OrderLineItem(productName: 'Cotton Dupatta', unitPrice: 300, quantity: 1),
      ],
      subtotal: 1300,
      discountAmount: discount,
      deliveryCharge: delivery,
      total: 1300 - discount + delivery,
      paymentMode: paymentMode,
      upiId: upiId,
      gstEnabled: gstEnabled,
      createdAt: DateTime(2026, 4, 12),
    );
  }

  Future<void> pumpCard(WidgetTester tester, OrderSlip slip) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: OrderSlipCardWidget(
              slip: slip,
              shopName: 'Test Dukaan',
              city: 'Lucknow',
              shopPhone: '9999999999',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders customer name correctly', (WidgetTester tester) async {
    await pumpCard(tester, buildSlip());

    expect(find.textContaining('Rina Sharma'), findsOneWidget);
  });

  testWidgets('renders all line items with name qty and subtotal',
      (WidgetTester tester) async {
    await pumpCard(tester, buildSlip());

    expect(find.text('Blue Kurti'), findsOneWidget);
    expect(find.text('Cotton Dupatta'), findsOneWidget);
    expect(find.text('2'), findsWidgets);
    expect(find.text('₹1000'), findsOneWidget);
    expect(find.text('₹300'), findsWidgets);
  });

  testWidgets('renders discount row only when discount is greater than 0',
      (WidgetTester tester) async {
    await pumpCard(tester, buildSlip(discount: 100));
    expect(find.textContaining('Discount'), findsOneWidget);

    await pumpCard(tester, buildSlip(discount: 0));
    expect(find.textContaining('Discount'), findsNothing);
  });

  testWidgets('renders delivery row only when delivery charge is greater than 0',
      (WidgetTester tester) async {
    await pumpCard(tester, buildSlip(delivery: 50));
    expect(find.textContaining('Delivery'), findsOneWidget);

    await pumpCard(tester, buildSlip(delivery: 0));
    expect(find.textContaining('Delivery'), findsNothing);
  });

  testWidgets('shows correct payment mode label in Hinglish',
      (WidgetTester tester) async {
    await pumpCard(tester, buildSlip(paymentMode: PaymentMode.cash));

    expect(find.textContaining(AppStrings.paymentModeCash), findsOneWidget);
  });

  testWidgets('shows UPI ID only when paymentMode is upi and upiId exists',
      (WidgetTester tester) async {
    await pumpCard(
      tester,
      buildSlip(paymentMode: PaymentMode.upi, upiId: 'seller@upi'),
    );
    expect(find.textContaining('UPI ID'), findsOneWidget);

    await pumpCard(
      tester,
      buildSlip(paymentMode: PaymentMode.cash, upiId: 'seller@upi'),
    );
    expect(find.textContaining('UPI ID'), findsNothing);
  });

  testWidgets('shows GST placeholder row only when gstEnabled true',
      (WidgetTester tester) async {
    await pumpCard(tester, buildSlip(gstEnabled: true));

    expect(find.textContaining('GST: Calculated separately'), findsOneWidget);
  });

  testWidgets('does not show GST row when gstEnabled false',
      (WidgetTester tester) async {
    await pumpCard(tester, buildSlip(gstEnabled: false));

    expect(find.textContaining('GST: Calculated separately'), findsNothing);
  });

  testWidgets('formattedTotal is displayed on card', (WidgetTester tester) async {
    final OrderSlip slip = buildSlip(discount: 100, delivery: 50);
    await pumpCard(tester, slip);

    expect(find.text(slip.formattedTotal), findsOneWidget);
  });
}
