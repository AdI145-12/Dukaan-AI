import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/features/studio/presentation/widgets/caption_language_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CaptionLanguageSelector', () {
    testWidgets('renders all 3 language options', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CaptionLanguageSelector(
              selectedLanguage: 'hinglish',
              onChanged: _noop,
            ),
          ),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.text(AppStrings.langHinglish), findsOneWidget);
      expect(find.text(AppStrings.langHindi), findsOneWidget);
      expect(find.text(AppStrings.langEnglish), findsOneWidget);
    });

    testWidgets('selected segment has primary background color', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CaptionLanguageSelector(
              selectedLanguage: 'hindi',
              onChanged: _noop,
            ),
          ),
        ),
      );
      await tester.pump();

      // Assert
      final Text hindiText = tester.widget<Text>(find.text(AppStrings.langHindi));
      expect(hindiText.style?.color, Colors.white);

      final Text hinglishText =
          tester.widget<Text>(find.text(AppStrings.langHinglish));
      expect(hinglishText.style?.color, AppColors.primary);
    });

    testWidgets('tapping a segment calls onChanged with correct language id', (
      WidgetTester tester,
    ) async {
      // Arrange
      String? tappedLanguage;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CaptionLanguageSelector(
              selectedLanguage: 'hinglish',
              onChanged: (String lang) => tappedLanguage = lang,
            ),
          ),
        ),
      );
      await tester.pump();

      // Act
      await tester.tap(find.text(AppStrings.langEnglish));
      await tester.pump();

      // Assert
      expect(tappedLanguage, 'english');
    });

    testWidgets('tapping already-selected segment still calls onChanged', (
      WidgetTester tester,
    ) async {
      // Arrange
      int callCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CaptionLanguageSelector(
              selectedLanguage: 'hinglish',
              onChanged: (_) => callCount++,
            ),
          ),
        ),
      );
      await tester.pump();

      // Act
      await tester.tap(find.text(AppStrings.langHinglish));
      await tester.pump();

      // Assert
      expect(callCount, 1);
    });

    testWidgets('widget height is 40dp', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: CaptionLanguageSelector(
                selectedLanguage: 'hinglish',
                onChanged: _noop,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Assert
      final Size size = tester.getSize(find.byType(CaptionLanguageSelector));
      expect(size.height, 40.0);
    });
  });
}

void _noop(String _) {}
