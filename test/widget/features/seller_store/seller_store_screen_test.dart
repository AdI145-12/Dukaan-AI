import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/features/seller_store/domain/models/seller_store_settings.dart';
import 'package:dukaan_ai/features/seller_store/domain/repositories/seller_store_repository.dart';
import 'package:dukaan_ai/features/seller_store/infrastructure/repositories/seller_store_repository_impl.dart';
import 'package:dukaan_ai/features/seller_store/presentation/screens/seller_store_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSellerStoreRepository extends Mock implements SellerStoreRepository {}

class _FakeUser {
  const _FakeUser(this.uid);

  final String uid;
}

class _FakeAuth {
  const _FakeAuth({this.currentUser});

  final _FakeUser? currentUser;
}

void main() {
  late MockSellerStoreRepository mockRepository;

  const SellerStoreSettings settings = SellerStoreSettings(
    userId: 'test-user-id',
    shopName: 'Ramu Store',
    phone: '9876543210',
    slug: 'ramu-store',
    description: 'Fresh daily products',
    bannerUrl: '',
    isPublished: false,
    viewsCount: 4,
    whatsappClicks: 2,
  );

  setUpAll(() {
    registerFallbackValue(settings);
  });

  setUp(() {
    mockRepository = MockSellerStoreRepository();

    FirebaseService.clearOverrides();
    FirebaseService.setAuthOverride(
      const _FakeAuth(currentUser: _FakeUser('test-user-id')),
    );

    when(
      () => mockRepository.fetchSettings(userId: any(named: 'userId')),
    ).thenAnswer((_) async => settings);

    when(
      () => mockRepository.isSlugAvailable(
        userId: any(named: 'userId'),
        slug: any(named: 'slug'),
      ),
    ).thenAnswer((_) async => true);

    when(
      () => mockRepository.saveSettings(settings: any(named: 'settings')),
    ).thenAnswer((Invocation invocation) async {
      final SellerStoreSettings input =
          invocation.namedArguments[#settings] as SellerStoreSettings;
      return input;
    });
  });

  tearDown(FirebaseService.clearOverrides);

  Widget buildSubject() {
    return ProviderScope(
      overrides: [
        sellerStoreRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: const MaterialApp(home: SellerStoreScreen()),
    );
  }

  testWidgets('renders seller store details from repository',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump(const Duration(milliseconds: 40));

    expect(find.text(AppStrings.sellerStoreTitle), findsOneWidget);
    expect(find.text('Ramu Store'), findsOneWidget);
    expect(find.textContaining('/api/get-seller-store/ramu-store'),
        findsOneWidget);
    verify(() => mockRepository.fetchSettings(userId: 'test-user-id'))
        .called(1);
  });

  testWidgets('save button persists edited store settings',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump(const Duration(milliseconds: 40));

    await tester.enterText(find.byType(TextFormField).at(0), 'ramu-live');
    await tester.enterText(find.byType(TextFormField).at(1), '9876543210');
    await tester.ensureVisible(find.byType(TextFormField).at(3));
    await tester.enterText(
        find.byType(TextFormField).at(3), 'Best kirana dukaan');

    await tester.ensureVisible(find.text(AppStrings.sellerStoreSaveButton));
    await tester.tap(find.text(AppStrings.sellerStoreSaveButton));
    await tester.pump();

    verify(
      () => mockRepository.saveSettings(settings: any(named: 'settings')),
    ).called(1);
  });
}
