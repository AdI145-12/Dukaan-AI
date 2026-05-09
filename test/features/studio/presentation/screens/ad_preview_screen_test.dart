import 'dart:async';

import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/features/studio/application/studio_provider.dart';
import 'package:dukaan_ai/features/studio/domain/ad_creation_request.dart';
import 'package:dukaan_ai/features/studio/domain/ad_preview_args.dart';
import 'package:dukaan_ai/features/studio/domain/generated_ad.dart';
import 'package:dukaan_ai/features/studio/domain/generated_caption.dart';
import 'package:dukaan_ai/features/studio/domain/studio_repository.dart';
import 'package:dukaan_ai/features/studio/infrastructure/ad_generation_service.dart';
import 'package:dukaan_ai/features/studio/infrastructure/caption_service.dart';
import 'package:dukaan_ai/features/studio/presentation/screens/ad_preview_screen.dart';
import 'package:dukaan_ai/shared/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockAdGenerationService extends Mock implements AdGenerationService {}

class MockCaptionService extends Mock implements CaptionService {}

class _FakeUser {
  const _FakeUser(this.uid);

  final String uid;
}

class _FakeAuth {
  const _FakeAuth({this.currentUser});

  final _FakeUser? currentUser;
}

class FakeStudioRepository implements StudioRepository {
  FakeStudioRepository({required this.profile});

  final UserProfile profile;

  @override
  Future<List<GeneratedAd>> getRecentAds({
    required String userId,
    int limit = 3,
  }) async {
    return <GeneratedAd>[];
  }

  @override
  Future<UserProfile> getProfile({required String userId}) async {
    return profile;
  }

  @override
  Future<GeneratedAd> saveGeneratedAd({
    required String userId,
    required String storagePath,
    required String backgroundStyle,
  }) async {
    return GeneratedAd(
      id: 'saved-ad',
      userId: userId,
      imageUrl: storagePath,
      backgroundStyle: backgroundStyle,
      createdAt: DateTime(2026, 4, 5),
    );
  }

  @override
  Future<void> trackUsageEvent({
    required String userId,
    required String eventType,
    int creditsUsed = 0,
    Map<String, dynamic>? metadata,
  }) async {}

  @override
  Future<void> incrementShareCount(String adId) async {}

  @override
  Future<void> incrementDownloadCount(String adId) async {}

  @override
  Future<void> updateCaption({
    required String adId,
    String? captionHindi,
    String? captionEnglish,
  }) async {}
}

void main() {
  late MockCaptionService mockCaptionService;

  setUpAll(() {
    registerFallbackValue(
      const AdCreationRequest(
        processedImageBase64: 'base64',
        backgroundStyleId: 'diwali',
        userId: 'user-1',
      ),
    );
  });

  setUp(() {
    FirebaseService.clearOverrides();
    FirebaseService.setAuthOverride(
      const _FakeAuth(currentUser: _FakeUser('user-1')),
    );

    mockCaptionService = MockCaptionService();
    when(
      () => mockCaptionService.generateCaption(
        userId: any(named: 'userId'),
        productName: any(named: 'productName'),
        category: any(named: 'category'),
        language: any(named: 'language'),
      ),
    ).thenAnswer(
      (_) async => const GeneratedCaption(
        caption: '',
        hashtags: <String>[],
        language: 'hinglish',
      ),
    );
  });

  tearDown(FirebaseService.clearOverrides);

  Future<void> pumpAdPreviewScreen(
    WidgetTester tester, {
    required UserProfile profile,
    required AdPreviewArgs args,
    MockAdGenerationService? adGenerationService,
    MockCaptionService? captionService,
  }) async {
    // Arrange
    final MockAdGenerationService mockService =
        adGenerationService ?? MockAdGenerationService();
    final MockCaptionService mockResolvedCaptionService =
        captionService ?? mockCaptionService;
    when(() => mockService.generateAd(any()))
        .thenAnswer((_) async => _testAd(id: 'regenerated-ad'));

    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (_, __) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: '/preview',
          builder: (_, __) => const AdPreviewScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studioRepositoryProvider.overrideWithValue(
            FakeStudioRepository(profile: profile),
          ),
          adGenerationServiceProvider.overrideWithValue(mockService),
          captionServiceProvider.overrideWithValue(mockResolvedCaptionService),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    // Act
    router.go('/preview', extra: args);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('AdPreviewScreen shows image with watermark on free tier', (
    WidgetTester tester,
  ) async {
    // Arrange
    final AdPreviewArgs args = AdPreviewArgs(
      generatedAd: _testAd(id: 'ad-free'),
      processedBase64: 'base64-image',
      backgroundStyleId: 'diwali',
    );

    await pumpAdPreviewScreen(
      tester,
      profile: _profileWithTier('free'),
      args: args,
    );

    // Assert
    expect(find.text('Made with Dukaan AI'), findsOneWidget);
  });

  testWidgets('AdPreviewScreen hides watermark on paid tier', (
    WidgetTester tester,
  ) async {
    // Arrange
    final AdPreviewArgs args = AdPreviewArgs(
      generatedAd: _testAd(id: 'ad-paid'),
      processedBase64: 'base64-image',
      backgroundStyleId: 'diwali',
    );

    await pumpAdPreviewScreen(
      tester,
      profile: _profileWithTier('dukaan'),
      args: args,
    );

    // Assert
    expect(find.text('Made with Dukaan AI'), findsNothing);
  });

  testWidgets('AdPreviewScreen shows 3 action buttons',
      (WidgetTester tester) async {
    // Arrange
    final AdPreviewArgs args = AdPreviewArgs(
      generatedAd: _testAd(id: 'ad-actions'),
      processedBase64: 'base64-image',
      backgroundStyleId: 'diwali',
    );

    await pumpAdPreviewScreen(
      tester,
      profile: _profileWithTier('free'),
      args: args,
    );

    // Assert
    expect(find.text(AppStrings.saveButton), findsOneWidget);
    expect(find.text(AppStrings.shareWhatsAppButton), findsOneWidget);
    expect(find.text(AppStrings.copyCaptionButton), findsOneWidget);
  });

  testWidgets('AdPreviewScreen shows Regenerate AppBar button', (
    WidgetTester tester,
  ) async {
    // Arrange
    final AdPreviewArgs args = AdPreviewArgs(
      generatedAd: _testAd(id: 'ad-regenerate-btn'),
      processedBase64: 'base64-image',
      backgroundStyleId: 'diwali',
    );

    await pumpAdPreviewScreen(
      tester,
      profile: _profileWithTier('free'),
      args: args,
    );

    // Assert
    expect(find.text(AppStrings.regenerateButton), findsOneWidget);
  });

  testWidgets('Save-as-product banner is visible and dismissible', (
    WidgetTester tester,
  ) async {
    // Arrange
    final AdPreviewArgs args = AdPreviewArgs(
      generatedAd: _testAd(id: 'ad-banner'),
      processedBase64: 'base64-image',
      backgroundStyleId: 'diwali',
    );

    await pumpAdPreviewScreen(
      tester,
      profile: _profileWithTier('free'),
      args: args,
    );

    // Assert
    expect(find.text(AppStrings.saveAsProductTitle), findsOneWidget);
    expect(find.text(AppStrings.saveAsProductCta), findsOneWidget);

    // Act
    await tester.tap(find.byKey(const Key('save_as_product_banner_dismiss')));
    await tester.pump();

    // Assert
    expect(find.text(AppStrings.saveAsProductTitle), findsNothing);
  });

  testWidgets(
    'AdPreviewScreen shows regenerating overlay when isRegenerating is true',
    (WidgetTester tester) async {
      // Arrange
      final Completer<GeneratedAd> completer = Completer<GeneratedAd>();
      final Completer<GeneratedCaption> captionCompleter =
          Completer<GeneratedCaption>();
      final MockAdGenerationService mockService = MockAdGenerationService();
      final MockCaptionService pendingCaptionService = MockCaptionService();
      when(() => mockService.generateAd(any()))
          .thenAnswer((_) => completer.future);
      when(
        () => pendingCaptionService.generateCaption(
          userId: any(named: 'userId'),
          productName: any(named: 'productName'),
          category: any(named: 'category'),
          language: any(named: 'language'),
        ),
      ).thenAnswer((_) => captionCompleter.future);

      final AdPreviewArgs args = AdPreviewArgs(
        generatedAd: _testAd(id: 'ad-regenerating'),
        processedBase64: 'base64-image',
        backgroundStyleId: 'diwali',
      );

      await pumpAdPreviewScreen(
        tester,
        profile: _profileWithTier('free'),
        args: args,
        adGenerationService: mockService,
        captionService: pendingCaptionService,
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Act
      await tester.tap(find.text(AppStrings.regenerateButton));
      await tester.pump();
      await tester.pump();

      // Assert
      verify(() => mockService.generateAd(any())).called(1);
    },
  );

  testWidgets('copyCaption shows snackbar when captionHindi is null', (
    WidgetTester tester,
  ) async {
    // Arrange
    final Completer<GeneratedCaption> captionCompleter =
        Completer<GeneratedCaption>();
    final MockCaptionService pendingCaptionService = MockCaptionService();
    when(
      () => pendingCaptionService.generateCaption(
        userId: any(named: 'userId'),
        productName: any(named: 'productName'),
        category: any(named: 'category'),
        language: any(named: 'language'),
      ),
    ).thenAnswer((_) => captionCompleter.future);

    final AdPreviewArgs args = AdPreviewArgs(
      generatedAd: _testAd(
        id: 'ad-no-caption',
        captionHindi: null,
        captionEnglish: null,
      ),
      processedBase64: 'base64-image',
      backgroundStyleId: 'diwali',
    );

    await pumpAdPreviewScreen(
      tester,
      profile: _profileWithTier('free'),
      args: args,
      captionService: pendingCaptionService,
    );

    // Act
    await tester.tap(find.text(AppStrings.copyCaptionButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Assert
    expect(find.text(AppStrings.captionNotAvailableYet), findsOneWidget);
  });
}

GeneratedAd _testAd({
  required String id,
  String? captionHindi = 'Naya offer aa gaya!',
  String? captionEnglish = 'Fresh offer is here!',
}) {
  return GeneratedAd(
    id: id,
    userId: 'user-1',
    imageUrl: 'https://example.com/ad.jpg',
    backgroundStyle: 'diwali',
    captionHindi: captionHindi,
    captionEnglish: captionEnglish,
    createdAt: DateTime(2026, 4, 5),
  );
}

UserProfile _profileWithTier(String tier) {
  return UserProfile(
    id: 'user-1',
    shopName: 'Test Dukaan',
    tier: tier,
    creditsRemaining: 3,
    language: 'hinglish',
  );
}
