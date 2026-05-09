import 'package:dukaan_ai/core/errors/app_exception.dart';
import 'package:dukaan_ai/core/providers/shared_providers.dart';
import 'package:dukaan_ai/features/studio/application/studio_provider.dart';
import 'package:dukaan_ai/features/studio/application/studio_state.dart';
import 'package:dukaan_ai/features/studio/domain/generated_ad.dart';
import 'package:dukaan_ai/features/studio/domain/studio_repository.dart';
import 'package:dukaan_ai/shared/domain/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockStudioRepository extends Mock implements StudioRepository {}
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  const String userId = '00000000-0000-0000-0000-000000000123';

  late MockStudioRepository mockStudioRepository;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;

  setUp(() {
    mockStudioRepository = MockStudioRepository();
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
  });

  ProviderContainer createContainer({
    required Stream<AuthState> authStateStream,
    required User? currentUser,
  }) {
    when(() => mockGoTrueClient.currentUser).thenReturn(currentUser);

    final ProviderContainer container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith((Ref ref) => authStateStream),
        supabaseClientProvider.overrideWith((Ref ref) => mockSupabaseClient),
        studioRepositoryProvider.overrideWith(
          (Ref ref) => mockStudioRepository,
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('build returns StudioState with recentAds list when user is logged in',
      () async {
    when(
      () => mockStudioRepository.getRecentAds(userId: userId, limit: 3),
    ).thenAnswer((_) async => <GeneratedAd>[testAd(id: 'ad-1')]);
    when(
      () => mockStudioRepository.getProfile(userId: userId),
    ).thenAnswer((_) async => testProfile());

    final ProviderContainer container = createContainer(
      authStateStream: Stream<AuthState>.value(
        AuthState(AuthChangeEvent.signedIn, signedInSession(userId: userId)),
      ),
      currentUser: userWithId(userId),
    );

    final StudioState state = await container.read(studioProvider.future);

    expect(state.recentAds, hasLength(1));
    expect(state.recentAds.first.id, 'ad-1');
    expect(state.profile?.id, userId);
  });

  test('build returns empty StudioState when userId is null', () async {
    final ProviderContainer container = createContainer(
      authStateStream: Stream<AuthState>.value(
        const AuthState(AuthChangeEvent.signedOut, null),
      ),
      currentUser: null,
    );

    final StudioState state = await container.read(studioProvider.future);

    expect(state.recentAds, isEmpty);
    expect(state.profile, isNull);
    verifyNever(
      () => mockStudioRepository.getRecentAds(userId: any(named: 'userId')),
    );
    verifyNever(
      () => mockStudioRepository.getProfile(userId: any(named: 'userId')),
    );
  });

  test('build propagates AppException.supabase from repo.getRecentAds',
      () async {
    when(
      () => mockStudioRepository.getRecentAds(userId: userId, limit: 3),
    ).thenThrow(const AppException.supabase('DB failed'));
    when(
      () => mockStudioRepository.getProfile(userId: userId),
    ).thenAnswer((_) async => testProfile());

    final ProviderContainer container = createContainer(
      authStateStream: Stream<AuthState>.value(
        AuthState(AuthChangeEvent.signedIn, signedInSession(userId: userId)),
      ),
      currentUser: userWithId(userId),
    );

    final ProviderSubscription<AsyncValue<StudioState>> subscription =
        container.listen(studioProvider, (_, __) {});
    addTearDown(subscription.close);

    await Future<void>.delayed(Duration.zero);

    final AsyncValue<StudioState> state = subscription.read();
    expect(state.hasError, isTrue);
    expect(state.error, isA<SupabaseAppException>());
  });

  test('build requests max 3 recent ads from repository', () async {
    when(
      () => mockStudioRepository.getRecentAds(userId: userId, limit: 3),
    ).thenAnswer(
      (_) async => <GeneratedAd>[
        testAd(id: 'ad-1'),
        testAd(id: 'ad-2'),
        testAd(id: 'ad-3'),
        testAd(id: 'ad-4'),
      ],
    );
    when(
      () => mockStudioRepository.getProfile(userId: userId),
    ).thenAnswer((_) async => testProfile());

    final ProviderContainer container = createContainer(
      authStateStream: Stream<AuthState>.value(
        AuthState(AuthChangeEvent.signedIn, signedInSession(userId: userId)),
      ),
      currentUser: userWithId(userId),
    );

    await container.read(studioProvider.future);

    verify(
      () => mockStudioRepository.getRecentAds(userId: userId, limit: 3),
    ).called(1);
  });

  test('refresh calls invalidateSelf and re-fetches data', () async {
    when(
      () => mockStudioRepository.getRecentAds(userId: userId, limit: 3),
    ).thenAnswer((_) async => <GeneratedAd>[testAd(id: 'ad-1')]);
    when(
      () => mockStudioRepository.getProfile(userId: userId),
    ).thenAnswer((_) async => testProfile());

    final ProviderContainer container = createContainer(
      authStateStream: Stream<AuthState>.value(
        AuthState(AuthChangeEvent.signedIn, signedInSession(userId: userId)),
      ),
      currentUser: userWithId(userId),
    );

    await container.read(studioProvider.future);
    await container.read(studioProvider.notifier).refresh();

    verify(
      () => mockStudioRepository.getRecentAds(userId: userId, limit: 3),
    ).called(2);
    verify(
      () => mockStudioRepository.getProfile(userId: userId),
    ).called(2);
  });
}

GeneratedAd testAd({required String id}) {
  return GeneratedAd(
    id: id,
    userId: '00000000-0000-0000-0000-000000000123',
    imageUrl: 'https://example.com/ad.jpg',
    thumbnailUrl: 'https://example.com/thumb.jpg',
    createdAt: DateTime(2026, 11, 17),
  );
}

UserProfile testProfile() {
  return const UserProfile(
    id: '00000000-0000-0000-0000-000000000123',
    shopName: 'Test Dukaan',
    tier: 'free',
    creditsRemaining: 3,
    language: 'hinglish',
  );
}

Session signedInSession({required String userId}) {
  return Session(
    accessToken: 'test-access-token',
    tokenType: 'bearer',
    user: User(
      id: userId,
      appMetadata: const <String, Object?>{},
      userMetadata: const <String, Object?>{},
      aud: 'authenticated',
      createdAt: DateTime(2026, 1, 1).toIso8601String(),
    ),
  );
}

User userWithId(String userId) {
  return User(
    id: userId,
    appMetadata: const <String, Object?>{},
    userMetadata: const <String, Object?>{},
    aud: 'authenticated',
    createdAt: DateTime(2026, 1, 1).toIso8601String(),
  );
}
