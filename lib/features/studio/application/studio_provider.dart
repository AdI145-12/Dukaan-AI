import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/features/studio/application/studio_state.dart';
import 'package:dukaan_ai/features/studio/domain/generated_ad.dart';
import 'package:dukaan_ai/features/studio/domain/studio_repository.dart';
import 'package:dukaan_ai/features/studio/infrastructure/studio_repository_impl.dart';
import 'package:dukaan_ai/shared/domain/user_profile.dart';
import 'package:dukaan_ai/shared/utils/festival_calendar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'studio_provider.g.dart';

@riverpod
StudioRepository studioRepository(Ref ref) {
  return const StudioRepositoryImpl();
}

@riverpod
class Studio extends _$Studio {
  @override
  Future<StudioState> build() async {
    // ASSUMPTION: Firebase auth is the source of truth for current user identity.
    final String? userId = FirebaseService.currentUserId;

    if (userId == null) {
      return const StudioState();
    }

    final StudioRepository repo = ref.watch(studioRepositoryProvider);

    final List<Object> results = await Future.wait<Object>(<Future<Object>>[
      repo.getRecentAds(userId: userId, limit: 3),
      repo.getProfile(userId: userId),
    ]);

    return StudioState(
      recentAds: results[0] as List<GeneratedAd>,
      profile: results[1] as UserProfile,
      todayFestival: FestivalCalendar.getTodayFestival(),
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}