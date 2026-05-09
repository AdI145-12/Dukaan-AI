import 'package:dukaan_ai/core/constants/firestore_constants.dart';
import 'package:dukaan_ai/core/errors/app_exception.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/features/studio/domain/generated_ad.dart';
import 'package:dukaan_ai/features/studio/domain/studio_repository.dart';
import 'package:dukaan_ai/shared/domain/user_profile.dart';
import 'package:flutter/foundation.dart';

class StudioRepositoryImpl implements StudioRepository {
  const StudioRepositoryImpl([Object? legacyClient]);

  @override
  Future<List<GeneratedAd>> getRecentAds({
    required String userId,
    int limit = 3,
  }) async {
    if (userId.trim().isEmpty || FirebaseService.currentUserId == null) {
      return const <GeneratedAd>[];
    }

    try {
      final dynamic snapshot = await FirebaseService.db
          .collection(FirestoreCollections.generatedAds)
          .where(FirestoreFields.userId, isEqualTo: userId)
          .orderBy(FirestoreFields.createdAt, descending: true)
          .limit(limit)
          .get();

      final List<dynamic> docs = snapshot.docs as List<dynamic>? ?? <dynamic>[];
      return docs.map((dynamic doc) {
        final Map<String, dynamic> data = _docData(doc);
        return GeneratedAd(
          id: _docId(doc),
          userId: data[FirestoreFields.userId] as String? ?? userId,
          imageUrl: data[FirestoreFields.imageUrl] as String? ?? '',
          thumbnailUrl: data[FirestoreFields.thumbnailUrl] as String?,
          backgroundStyle: data[FirestoreFields.backgroundStyle] as String?,
          captionHindi: data[FirestoreFields.captionHindi] as String?,
          captionEnglish: data[FirestoreFields.captionEnglish] as String?,
          shareCount: (data[FirestoreFields.shareCount] as num?)?.toInt() ?? 0,
          downloadCount:
              (data[FirestoreFields.downloadCount] as num?)?.toInt() ?? 0,
          festivalTag: data[FirestoreFields.festivalTag] as String?,
          createdAt: _toDateTime(data[FirestoreFields.createdAt]),
        );
      }).toList(growable: false);
    } on Exception catch (error) {
      throw AppException.firebase(_extractMessage(error, 'Ads load nahi hue'));
    } catch (error) {
      throw AppException.unknown(error.toString());
    }
  }

  @override
  Future<UserProfile> getProfile({required String userId}) async {
    if (userId.trim().isEmpty || FirebaseService.currentUserId == null) {
      return const UserProfile(
        id: '',
        shopName: '',
      );
    }

    try {
      final dynamic doc = await FirebaseService.db
          .collection(FirestoreCollections.users)
          .doc(userId)
          .get();

      final bool exists = doc.exists as bool? ?? false;
      if (!exists) {
        throw const AppException.firebase('Profile nahi mila');
      }

      final Map<String, dynamic> data = _docData(doc);
      return UserProfile(
        id: _docId(doc),
        shopName: data[FirestoreFields.shopName] as String? ?? '',
        ownerName: data[FirestoreFields.ownerName] as String?,
        phone: data[FirestoreFields.phone] as String?,
        city: data[FirestoreFields.city] as String?,
        category: data[FirestoreFields.category] as String?,
        tier: data[FirestoreFields.tier] as String? ?? 'free',
        creditsRemaining:
            (data[FirestoreFields.creditsRemaining] as num?)?.toInt() ?? 3,
        language: data[FirestoreFields.language] as String? ?? 'hinglish',
      );
    } on Exception catch (error) {
      throw AppException.firebase(_extractMessage(error, 'Profile load nahi hua'));
    } catch (error) {
      throw AppException.unknown(error.toString());
    }
  }

  @override
  Future<GeneratedAd> saveGeneratedAd({
    required String userId,
    required String storagePath,
    required String backgroundStyle,
  }) async {
    if (userId.trim().isEmpty || FirebaseService.currentUserId == null) {
      return GeneratedAd(
        id: '',
        userId: '',
        imageUrl: storagePath,
        backgroundStyle: backgroundStyle,
        createdAt: DateTime.now(),
      );
    }

    try {
      final dynamic docRef = await FirebaseService.db
          .collection(FirestoreCollections.generatedAds)
          .add(<String, dynamic>{
        FirestoreFields.userId: userId,
        FirestoreFields.imageUrl: storagePath,
        FirestoreFields.backgroundStyle: backgroundStyle,
        FirestoreFields.shareCount: 0,
        FirestoreFields.downloadCount: 0,
        FirestoreFields.createdAt: FirebaseService.serverTimestamp(),
      });

      final dynamic doc = await docRef.get();
      final Map<String, dynamic> data = _docData(doc);
      return GeneratedAd(
        id: _docId(doc),
        userId: data[FirestoreFields.userId] as String? ?? userId,
        imageUrl: data[FirestoreFields.imageUrl] as String? ?? storagePath,
        thumbnailUrl: data[FirestoreFields.thumbnailUrl] as String?,
        backgroundStyle: data[FirestoreFields.backgroundStyle] as String?,
        captionHindi: data[FirestoreFields.captionHindi] as String?,
        captionEnglish: data[FirestoreFields.captionEnglish] as String?,
        shareCount: (data[FirestoreFields.shareCount] as num?)?.toInt() ?? 0,
        downloadCount:
            (data[FirestoreFields.downloadCount] as num?)?.toInt() ?? 0,
        festivalTag: data[FirestoreFields.festivalTag] as String?,
        createdAt: _toDateTime(data[FirestoreFields.createdAt]),
      );
    } on Exception catch (error) {
      throw AppException.firebase(_extractMessage(error, 'Ad save nahi hua'));
    } catch (error) {
      throw AppException.unknown(error.toString());
    }
  }

  @override
  Future<void> trackUsageEvent({
    required String userId,
    required String eventType,
    int creditsUsed = 0,
    Map<String, dynamic>? metadata,
  }) async {
    if (userId.trim().isEmpty || FirebaseService.currentUserId == null) {
      return;
    }

    try {
      await FirebaseService.db.collection(FirestoreCollections.usageEvents).add(<
          String,
          dynamic
        >{
        FirestoreFields.userId: userId,
        FirestoreFields.eventType: eventType,
        FirestoreFields.creditsUsed: creditsUsed,
        if (metadata != null) FirestoreFields.metadata: metadata,
        FirestoreFields.createdAt: FirebaseService.serverTimestamp(),
      });
    } on Exception catch (error) {
      debugPrint('trackUsageEvent failed: ${_extractMessage(error, 'unknown')}');
    }
  }

  @override
  Future<void> incrementShareCount(String adId) async {
    await _incrementCounter(
      adId: adId,
      fieldName: FirestoreFields.shareCount,
      logTag: 'incrementShareCount',
    );
  }

  @override
  Future<void> incrementDownloadCount(String adId) async {
    await _incrementCounter(
      adId: adId,
      fieldName: FirestoreFields.downloadCount,
      logTag: 'incrementDownloadCount',
    );
  }

  @override
  Future<void> updateCaption({
    required String adId,
    String? captionHindi,
    String? captionEnglish,
  }) async {
    final Map<String, dynamic> updates = <String, dynamic>{
      if (captionHindi != null) FirestoreFields.captionHindi: captionHindi,
      if (captionEnglish != null) FirestoreFields.captionEnglish: captionEnglish,
    };

    if (updates.isEmpty) {
      return;
    }

    try {
      await FirebaseService.db
          .collection(FirestoreCollections.generatedAds)
          .doc(adId)
          .update(updates);
    } on Exception catch (error) {
      debugPrint('updateCaption failed: ${_extractMessage(error, 'unknown')}');
    }
  }

  Future<void> _incrementCounter({
    required String adId,
    required String fieldName,
    required String logTag,
  }) async {
    try {
      final dynamic docRef =
          FirebaseService.db.collection(FirestoreCollections.generatedAds).doc(adId);
      final dynamic snapshot = await docRef.get();
      final Map<String, dynamic> data = _docData(snapshot);
      final int current = (data[fieldName] as num?)?.toInt() ?? 0;
      await docRef.update(<String, dynamic>{fieldName: current + 1});
    } on Exception catch (error) {
      debugPrint('$logTag failed: ${_extractMessage(error, 'unknown')}');
    }
  }

  Map<String, dynamic> _docData(dynamic doc) {
    final dynamic data = doc.data();
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map<Object?, Object?>) {
      return data.map<String, dynamic>(
        (Object? key, Object? value) => MapEntry(key.toString(), value),
      );
    }
    return <String, dynamic>{};
  }

  String _docId(dynamic doc) {
    final dynamic id = doc.id;
    return id is String ? id : '';
  }

  DateTime _toDateTime(Object? raw) {
    if (raw is DateTime) {
      return raw;
    }
    if (raw is String) {
      return DateTime.tryParse(raw) ?? DateTime.now();
    }
    try {
      final dynamic converted = (raw as dynamic)?.toDate();
      if (converted is DateTime) {
        return converted;
      }
    } catch (_) {
      // Fall through.
    }
    return DateTime.now();
  }

  String _extractMessage(Object error, String fallback) {
    try {
      final dynamic message = (error as dynamic).message;
      if (message is String && message.isNotEmpty) {
        return message;
      }
    } catch (_) {
      // Fall through.
    }
    return fallback;
  }
}
