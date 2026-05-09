import 'package:cached_network_image/cached_network_image.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/features/studio/domain/generated_ad.dart';
import 'package:dukaan_ai/features/studio/presentation/screens/whatsapp_broadcast_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpBroadcastScreen(
    WidgetTester tester, {
    required GeneratedAd ad,
    bool withBackStack = false,
  }) async {
    final Widget app = withBackStack
        ? MaterialApp(
            home: Navigator(
              onGenerateInitialRoutes: (
                NavigatorState navigator,
                String initialRoute,
              ) {
                return <Route<void>>[
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const SizedBox.shrink(),
                  ),
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return ProviderScope(
                        child: WhatsAppBroadcastScreen(ad: ad),
                      );
                    },
                  ),
                ];
              },
            ),
          )
        : MaterialApp(
            home: ProviderScope(
              child: WhatsAppBroadcastScreen(ad: ad),
            ),
          );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
  }

  testWidgets('renders ad thumbnail and caption preview', (
    WidgetTester tester,
  ) async {
    // Arrange
    final GeneratedAd ad = _testAd(captionHindi: 'Test caption');

    // Act
    await pumpBroadcastScreen(tester, ad: ad);

    // Assert
    expect(
      find.byWidgetPredicate((Widget widget) {
        return widget is CachedNetworkImage && widget.imageUrl == ad.imageUrl;
      }),
      findsOneWidget,
    );
    expect(find.text('Test caption'), findsAtLeastNWidgets(1));
  });

  testWidgets('CaptionLanguageSelector switches caption text', (
    WidgetTester tester,
  ) async {
    // Arrange
    final GeneratedAd ad = _testAd(
      captionHindi: 'Hindi caption',
      captionEnglish: 'English caption',
    );
    await pumpBroadcastScreen(tester, ad: ad);

    // Act
    await tester.tap(find.text(AppStrings.langEnglish));
    await tester.pump();

    // Assert
    final EditableText editable = tester.widget<EditableText>(
      find.byType(EditableText),
    );
    expect(editable.controller.text, 'English caption');
  });

  testWidgets('manual caption edit shows restore button', (
    WidgetTester tester,
  ) async {
    // Arrange
    await pumpBroadcastScreen(tester, ad: _testAd());

    // Act
    await tester.enterText(
      find.byKey(const Key('broadcast_caption_field')),
      'Custom caption by user',
    );
    await tester.pump();

    // Assert
    expect(
      find.byKey(const Key('broadcast_restore_caption_button')),
      findsOneWidget,
    );
  });

  testWidgets('copy button shows snackbar', (WidgetTester tester) async {
    // Arrange
    await pumpBroadcastScreen(tester, ad: _testAd());

    // Act
    await tester.tap(find.text(AppStrings.captionCopyBtn));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Assert
    expect(find.text(AppStrings.captionCopied), findsOneWidget);
  });

  testWidgets('back navigation shows confirmation when caption edited', (
    WidgetTester tester,
  ) async {
    // Arrange
    await pumpBroadcastScreen(tester, ad: _testAd(), withBackStack: true);
    await tester.enterText(
      find.byKey(const Key('broadcast_caption_field')),
      'Edited caption',
    );
    await tester.pump();

    // Act
    final NavigatorState navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    await navigator.maybePop();
    await tester.pumpAndSettle();

    // Assert
    expect(find.text(AppStrings.captionBackConfirmTitle), findsOneWidget);
  });

  testWidgets('all share destination cards render', (WidgetTester tester) async {
    // Arrange
    await pumpBroadcastScreen(tester, ad: _testAd());

    // Assert
    expect(find.text(AppStrings.broadcastListTitle), findsOneWidget);
    expect(find.text(AppStrings.whatsappStatusTitle), findsOneWidget);
    expect(find.text(AppStrings.groupShareTitle), findsOneWidget);
    expect(find.text(AppStrings.singleContactTitle), findsOneWidget);
  });
}

GeneratedAd _testAd({
  String? captionHindi = 'Hindi caption',
  String? captionEnglish = 'English caption',
}) {
  return GeneratedAd(
    id: 'test-ad',
    userId: 'user-1',
    imageUrl: 'https://example.com/test.jpg',
    captionHindi: captionHindi,
    captionEnglish: captionEnglish,
    createdAt: DateTime(2026, 4, 5),
  );
}