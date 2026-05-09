import 'package:dukaan_ai/features/studio/domain/generated_ad.dart';
import 'package:dukaan_ai/shared/domain/user_profile.dart';

abstract interface class StudioRepository {
  /// Returns the most recently generated ads for a user.
  Future<List<GeneratedAd>> getRecentAds({
    required String userId,
    int limit = 3,
  });

  /// Returns the authenticated user's profile.
  Future<UserProfile> getProfile({required String userId});

  /// Inserts generated ad metadata and returns a GeneratedAd with signed URL.
  Future<GeneratedAd> saveGeneratedAd({
    required String userId,
    required String storagePath,
    required String backgroundStyle,
  });

  /// Inserts a row into usageevents. Non-fatal failures are swallowed.
  Future<void> trackUsageEvent({
    required String userId,
    required String eventType,
    int creditsUsed = 0,
    Map<String, dynamic>? metadata,
  });

  /// Increments sharecount by 1. Non-fatal.
  Future<void> incrementShareCount(String adId);

  /// Increments downloadcount by 1. Non-fatal.
  Future<void> incrementDownloadCount(String adId);

  /// Backfills caption columns in generatedads row.
  /// Only updates fields that are non-null.
  /// Non-fatal failures are swallowed.
  Future<void> updateCaption({
    required String adId,
    String? captionHindi,
    String? captionEnglish,
  });
}
