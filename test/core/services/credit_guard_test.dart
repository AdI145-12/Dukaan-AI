import 'dart:math';

import 'package:dukaan_ai/core/services/credit_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<BuildContext> pumpContext(WidgetTester tester) async {
    late BuildContext context;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext value) {
            context = value;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    return context;
  }

  testWidgets('canGenerate should not decrement credits for utsav tier', (
    WidgetTester tester,
  ) async {
    // Arrange
    final BuildContext context = await pumpContext(tester);
    int decrementCount = 0;

    final CreditGuard guard = CreditGuard(
      readUserId: () async => 'user-1',
      readUserDoc: (String _) async => <String, dynamic>{
        'tier': 'utsav',
        'creditsRemaining': 0,
      },
      decrementCredits: (String _) async {
        decrementCount += 1;
      },
      showUpgradeSheet: (BuildContext _) {
        fail('upgrade sheet should not be shown for utsav tier');
      },
      showLastCreditWarning: (BuildContext _) {
        fail('warning should not be shown for utsav tier');
      },
    );

    // Act
    final bool canGenerate = await guard.canGenerate(context);

    // Assert
    expect(canGenerate, isTrue);
    expect(decrementCount, 0);
  });

  testWidgets('canGenerate should deny and show upgrade when credits are zero', (
    WidgetTester tester,
  ) async {
    // Arrange
    final BuildContext context = await pumpContext(tester);
    int upgradeSheetCount = 0;
    int decrementCount = 0;

    final CreditGuard guard = CreditGuard(
      readUserId: () async => 'user-1',
      readUserDoc: (String _) async => <String, dynamic>{
        'tier': 'free',
        'creditsRemaining': 0,
      },
      decrementCredits: (String _) async {
        decrementCount += 1;
      },
      showUpgradeSheet: (BuildContext _) {
        upgradeSheetCount += 1;
      },
      showLastCreditWarning: (BuildContext _) {},
    );

    // Act
    final bool canGenerate = await guard.canGenerate(context);

    // Assert
    expect(canGenerate, isFalse);
    expect(upgradeSheetCount, 1);
    expect(decrementCount, 0);
  });

  testWidgets('canGenerate should warn and decrement when one credit remains', (
    WidgetTester tester,
  ) async {
    // Arrange
    final BuildContext context = await pumpContext(tester);
    int warningCount = 0;
    int decrementCount = 0;

    final CreditGuard guard = CreditGuard(
      readUserId: () async => 'user-1',
      readUserDoc: (String _) async => <String, dynamic>{
        'tier': 'free',
        'creditsRemaining': 1,
      },
      decrementCredits: (String _) async {
        decrementCount += 1;
      },
      showUpgradeSheet: (BuildContext _) {},
      showLastCreditWarning: (BuildContext _) {
        warningCount += 1;
      },
    );

    // Act
    final bool canGenerate = await guard.canGenerate(context);

    // Assert
    expect(canGenerate, isTrue);
    expect(warningCount, 1);
    expect(decrementCount, 1);
  });

  testWidgets('canGenerate should avoid double decrement for concurrent requests', (
    WidgetTester tester,
  ) async {
    // Arrange
    final BuildContext context = await pumpContext(tester);
    int creditsRemaining = 1;
    int decrementCount = 0;
    int upgradeSheetCount = 0;

    final CreditGuard guard = CreditGuard(
      readUserId: () async => 'user-1',
      readUserDoc: (String _) async => <String, dynamic>{
        'tier': 'free',
        'creditsRemaining': creditsRemaining,
      },
      decrementCredits: (String _) async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        decrementCount += 1;
        creditsRemaining = max(0, creditsRemaining - 1);
      },
      showUpgradeSheet: (BuildContext _) {
        upgradeSheetCount += 1;
      },
      showLastCreditWarning: (BuildContext _) {},
    );

    // Act
    final List<bool> result = await Future.wait(<Future<bool>>[
      guard.canGenerate(context),
      guard.canGenerate(context),
    ]);

    // Assert
    expect(result.where((bool value) => value).length, 1);
    expect(decrementCount, 1);
    expect(upgradeSheetCount, 1);
    expect(creditsRemaining, 0);
  });
}
