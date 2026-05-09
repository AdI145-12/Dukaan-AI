import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/features/daily_plan/application/daily_plan_provider.dart';
import 'package:dukaan_ai/features/daily_plan/domain/models/daily_content_plan.dart';
import 'package:dukaan_ai/features/studio/application/studio_provider.dart';
import 'package:dukaan_ai/features/studio/application/studio_state.dart';
import 'package:dukaan_ai/features/studio/presentation/screens/studio_screen.dart';
import 'package:dukaan_ai/shared/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeStudio extends Studio {
  FakeStudio(this.value);

  final StudioState value;

  @override
  Future<StudioState> build() async {
    return value;
  }
}

void main() {
  const StudioState studioState = StudioState(
    profile: UserProfile(
      id: 'test-user-id',
      shopName: 'Test Dukaan',
      tier: 'free',
      creditsRemaining: 3,
      language: 'hinglish',
    ),
    todayFestival: 'Holi',
  );

  final DailyContentPlan testPlan = DailyContentPlan(
    title: 'Aaj cotton kurta post karo',
    reason: 'Festival traffic high hai.',
    captionIdea: 'Kurta offer + WhatsApp CTA add karo.',
    callToAction: 'Abhi post banao',
    date: DateTime(2026, 8, 21),
  );

  Widget buildSubject({required DailyContentPlan? plan}) {
    return ProviderScope(
      overrides: [
        studioProvider.overrideWith(() => FakeStudio(studioState)),
        dailyPlanProvider.overrideWith((Ref ref) async => plan),
      ],
      child: const MaterialApp(home: StudioScreen()),
    );
  }

  testWidgets('StudioScreen shows daily plan card above quick create section',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject(plan: testPlan));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.dailyPlanTitle), findsOneWidget);
    expect(find.text(AppStrings.sectionQuickCreate), findsOneWidget);

    final double dailyPlanY =
        tester.getTopLeft(find.text(AppStrings.dailyPlanTitle)).dy;
    final double quickCreateY =
        tester.getTopLeft(find.text(AppStrings.sectionQuickCreate)).dy;

    expect(dailyPlanY < quickCreateY, isTrue);
  });

  testWidgets('StudioScreen hides daily plan card when plan is null',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject(plan: null));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.dailyPlanTitle), findsNothing);
    expect(find.text(AppStrings.sectionQuickCreate), findsOneWidget);
  });
}
