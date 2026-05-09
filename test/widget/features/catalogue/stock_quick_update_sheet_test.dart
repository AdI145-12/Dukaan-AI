import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/features/catalogue/domain/models/catalogue_product.dart';
import 'package:dukaan_ai/features/catalogue/domain/stock_status.dart';
import 'package:dukaan_ai/features/catalogue/presentation/widgets/stock_quick_update_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_data.dart';

void main() {
  Widget buildSubject({
    required CatalogueProduct product,
    required Future<void> Function(StockStatus, int?) onUpdate,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            return Center(
              child: FilledButton(
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (BuildContext context) {
                      return StockQuickUpdateSheet(
                        product: product,
                        onUpdate: onUpdate,
                      );
                    },
                  );
                },
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> openSheet(WidgetTester tester) async {
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  CatalogueProduct baseProduct({
    StockStatus stockStatus = StockStatus.inStock,
    int? quantity = 10,
  }) {
    return testCatalogueProduct(
      id: 'p1',
      name: 'Fancy Kurta',
      stockStatus: stockStatus,
      quantity: quantity,
    );
  }

  testWidgets('shows passed product name', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildSubject(
        product: baseProduct(),
        onUpdate: (_, __) async {},
      ),
    );
    await openSheet(tester);

    expect(find.text('Fancy Kurta'), findsOneWidget);
  });

  testWidgets('renders all three stock chips', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildSubject(product: baseProduct(), onUpdate: (_, __) async {}),
    );
    await openSheet(tester);

    expect(find.text(AppStrings.stockInStock), findsOneWidget);
    expect(find.text(AppStrings.stockLowStock), findsOneWidget);
    expect(find.text(AppStrings.stockOutOfStock), findsOneWidget);
  });

  testWidgets('active status chip is selected on open',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildSubject(
        product: baseProduct(stockStatus: StockStatus.lowStock),
        onUpdate: (_, __) async {},
      ),
    );
    await openSheet(tester);

    final ChoiceChip chip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, AppStrings.stockLowStock),
    );
    expect(chip.selected, isTrue);
  });

  testWidgets('quantity field visible for inStock', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildSubject(
        product: baseProduct(stockStatus: StockStatus.inStock),
        onUpdate: (_, __) async {},
      ),
    );
    await openSheet(tester);

    expect(find.text(AppStrings.stockQuantityLabel), findsOneWidget);
  });

  testWidgets('quantity field visible for lowStock', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildSubject(
        product: baseProduct(stockStatus: StockStatus.lowStock),
        onUpdate: (_, __) async {},
      ),
    );
    await openSheet(tester);

    expect(find.text(AppStrings.stockQuantityLabel), findsOneWidget);
  });

  testWidgets('quantity field hidden for outOfStock',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildSubject(product: baseProduct(), onUpdate: (_, __) async {}),
    );
    await openSheet(tester);

    await tester.tap(find.text(AppStrings.stockOutOfStock));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(AppStrings.stockQuantityLabel), findsNothing);
  });

  testWidgets('update button disabled when no changes made',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildSubject(product: baseProduct(), onUpdate: (_, __) async {}),
    );
    await openSheet(tester);

    final FilledButton button = tester.widget(
      find.widgetWithText(FilledButton, AppStrings.stockUpdateButton),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('update button enabled after status change',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildSubject(product: baseProduct(), onUpdate: (_, __) async {}),
    );
    await openSheet(tester);

    await tester.tap(find.text(AppStrings.stockLowStock));
    await tester.pump(const Duration(milliseconds: 300));

    final FilledButton button = tester.widget(
      find.widgetWithText(FilledButton, AppStrings.stockUpdateButton),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('calls onUpdate with selected status and quantity',
      (WidgetTester tester) async {
    StockStatus? calledStatus;
    int? calledQuantity;

    await tester.pumpWidget(
      buildSubject(
        product: baseProduct(),
        onUpdate: (StockStatus status, int? quantity) async {
          calledStatus = status;
          calledQuantity = quantity;
        },
      ),
    );
    await openSheet(tester);

    await tester.tap(find.text(AppStrings.stockLowStock));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.byType(TextFormField), '2');
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.widgetWithText(FilledButton, AppStrings.stockUpdateButton));
    await tester.pump(const Duration(milliseconds: 300));

    expect(calledStatus, StockStatus.lowStock);
    expect(calledQuantity, 2);
  });

  testWidgets('shows low stock warning when quantity <= threshold',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildSubject(product: baseProduct(quantity: 5), onUpdate: (_, __) async {}),
    );
    await openSheet(tester);

    await tester.enterText(find.byType(TextFormField), '3');
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(AppStrings.stockLowWarning), findsOneWidget);
  });
}
