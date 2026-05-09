import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/shared/widgets/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  Widget buildTestWidget({
    required bool disableAnimations,
    required Widget child,
  }) {
    return MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: MaterialApp(
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }

  testWidgets(
    'renders Shimmer widget when disableAnimations=false',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          disableAnimations: false,
          child: const ShimmerBox(width: 100, height: 40),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
    },
  );

  testWidgets(
    'renders static Container when disableAnimations=true',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          disableAnimations: true,
          child: const ShimmerBox(width: 100, height: 40),
        ),
      );

      expect(find.byType(Shimmer), findsNothing);
      expect(find.byKey(const Key('shimmer_box_container')), findsOneWidget);
    },
  );

  testWidgets(
    'applies correct borderRadius to child Container',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          disableAnimations: true,
          child: const ShimmerBox(
            width: 100,
            height: 40,
            borderRadius: AppRadius.card,
          ),
        ),
      );

      final Container container = tester.widget(
        find.byKey(const Key('shimmer_box_container')),
      );
      final BoxDecoration boxDecoration =
          container.decoration as BoxDecoration;

      expect(
        boxDecoration.borderRadius,
        BorderRadius.circular(AppRadius.card),
      );
    },
  );
}
