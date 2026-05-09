import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  testWidgets(
    'primary variant renders with correct background color AppColors.primary',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppButton(
            label: 'Test',
            onPressed: () {},
          ),
        ),
      );

      final DecoratedBox decoratedBox = tester.widget(
        find.byKey(const Key('app_button_container')),
      );
      final BoxDecoration boxDecoration =
          decoratedBox.decoration as BoxDecoration;

      expect(boxDecoration.color, AppColors.primary);
    },
  );

  testWidgets(
    'isLoading=true shows CircularProgressIndicator not label text',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppButton(
            label: 'Test',
            onPressed: () {},
            isLoading: true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Test'), findsNothing);
    },
  );

  testWidgets(
    'onPressed=null disables the button with no tap callback',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppButton(
            label: 'Disabled',
            onPressed: null,
          ),
        ),
      );

      final InkWell inkWell = tester.widget(find.byType(InkWell));
      expect(inkWell.onTap, isNull);

      await tester.tap(find.byType(AppButton));
      await tester.pump();
    },
  );

  testWidgets(
    'secondary variant renders with border and no fill',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppButton(
            label: 'Secondary',
            onPressed: () {},
            variant: AppButtonVariant.secondary,
          ),
        ),
      );

      final DecoratedBox decoratedBox = tester.widget(
        find.byKey(const Key('app_button_container')),
      );
      final BoxDecoration boxDecoration =
          decoratedBox.decoration as BoxDecoration;

      expect(boxDecoration.border, isNotNull);
      expect(boxDecoration.color, Colors.transparent);
    },
  );

  testWidgets(
    'isFullWidth=true wraps in full-width SizedBox',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppButton(
            label: 'Full Width',
            onPressed: () {},
            isFullWidth: true,
          ),
        ),
      );

      final SizedBox sizedBox = tester.widget(
        find.byKey(const Key('app_button_width_box')),
      );

      expect(sizedBox.width, double.infinity);
    },
  );
}
