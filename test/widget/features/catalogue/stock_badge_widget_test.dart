import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/features/catalogue/domain/stock_status.dart';
import 'package:dukaan_ai/features/catalogue/presentation/widgets/stock_badge_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({
    required StockStatus status,
    int? quantity,
    bool showQuantityLabel = true,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: StockBadgeWidget(
            stockStatus: status,
            quantity: quantity,
            showQuantityLabel: showQuantityLabel,
          ),
        ),
      ),
    );
  }

  Finder dotFinder() {
    return find.byWidgetPredicate(
      (Widget widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration! as BoxDecoration).shape == BoxShape.circle &&
          ((widget.decoration! as BoxDecoration).border as Border?)?.top.width ==
              1.5,
    );
  }

  Color readDotColor(WidgetTester tester) {
    final Container dot = tester.widget<Container>(dotFinder());
    final BoxDecoration decoration = dot.decoration! as BoxDecoration;
    return decoration.color!;
  }

  testWidgets('shows green dot for inStock', (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject(status: StockStatus.inStock));
    expect(dotFinder(), findsOneWidget);
    expect(readDotColor(tester), AppColors.success);
  });

  testWidgets('shows amber dot for lowStock', (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject(status: StockStatus.lowStock));
    expect(dotFinder(), findsOneWidget);
    expect(readDotColor(tester), AppColors.warning);
  });

  testWidgets('shows red dot for outOfStock', (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject(status: StockStatus.outOfStock));
    expect(dotFinder(), findsOneWidget);
    expect(readDotColor(tester), AppColors.error);
  });

  testWidgets('shows quantity label when quantity exists and enabled',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildSubject(status: StockStatus.inStock, quantity: 5),
    );

    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('hides quantity label when showQuantityLabel is false',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildSubject(
        status: StockStatus.inStock,
        quantity: 5,
        showQuantityLabel: false,
      ),
    );

    expect(find.text('5'), findsNothing);
  });

  testWidgets('shows 99+ when quantity is greater than 99',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildSubject(status: StockStatus.inStock, quantity: 120),
    );

    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets('renders without overflow at 12x12 base dot dimensions',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 40,
            height: 20,
            child: StockBadgeWidget(
              stockStatus: StockStatus.inStock,
              quantity: null,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(dotFinder(), findsOneWidget);
  });
}
