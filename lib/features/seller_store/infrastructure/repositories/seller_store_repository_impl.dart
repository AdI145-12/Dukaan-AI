import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/constants/firestore_constants.dart';
import 'package:dukaan_ai/core/errors/app_exception.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/features/seller_store/domain/models/seller_store_settings.dart';
import 'package:dukaan_ai/features/seller_store/domain/repositories/seller_store_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SellerStoreRepositoryImpl implements SellerStoreRepository {
  SellerStoreRepositoryImpl();

  static const String _profilesCollection = 'profiles';

  static final RegExp _slugPattern = RegExp(
    r'^[a-z0-9][a-z0-9\-]{1,28}[a-z0-9]$',
  );

  @override
  Future<SellerStoreSettings> fetchSettings({required String userId}) async {
    final _FallbackProfile fallback = await _readFallbackProfile(userId);

    try {
      final dynamic doc = await FirebaseService.db
          .collection(_profilesCollection)
          .doc(userId)
          .get();

      final bool exists = doc.exists as bool? ?? false;
      if (!exists) {
        return SellerStoreSettings.empty(
          userId: userId,
          shopName: fallback.shopName,
          phone: fallback.phone,
        );
      }

      final Map<String, dynamic>? data = _toMap(doc.data());
      if (data == null) {
        return SellerStoreSettings.empty(
          userId: userId,
          shopName: fallback.shopName,
          phone: fallback.phone,
        );
      }

      final String slug =
          (data[FirestoreFields.storeSlug] as String? ?? '').trim();
      if (slug.isEmpty) {
        return SellerStoreSettings.empty(
          userId: userId,
          shopName: fallback.shopName,
          phone: fallback.phone,
        );
      }

      return SellerStoreSettings.fromFirestore(
        data,
        userId,
        fallbackShopName: fallback.shopName,
        fallbackPhone: fallback.phone,
      );
    } on AppException {
      rethrow;
    } on Exception catch (_) {
      throw const AppException.firebase(AppStrings.sellerStoreLoadFailed);
    } catch (_) {
      return SellerStoreSettings.empty(
        userId: userId,
        shopName: fallback.shopName,
        phone: fallback.phone,
      );
    }
  }

  @override
  Future<SellerStoreSettings> saveSettings({
    required SellerStoreSettings settings,
  }) async {
    final String normalizedSlug =
        SellerStoreSettings.suggestSlug(settings.normalizedSlug);

    if (!_isValidSlug(normalizedSlug)) {
      throw const AppException.firebase(AppStrings.sellerStoreSlugInvalid);
    }

    final bool slugAvailable = await isSlugAvailable(
      userId: settings.userId,
      slug: normalizedSlug,
    );
    if (!slugAvailable) {
      throw const AppException.firebase(AppStrings.sellerStoreSlugTaken);
    }

    final Map<String, dynamic> payload = <String, dynamic>{
      FirestoreFields.storeSlug: normalizedSlug,
      FirestoreFields.storeDescription: settings.description.trim(),
      FirestoreFields.storeIsPublished: settings.isPublished,
      FirestoreFields.shopName: settings.shopName.trim(),
      FirestoreFields.phone: settings.phone.trim(),
    };

    final String bannerUrl = settings.bannerUrl.trim();
    if (bannerUrl.isNotEmpty) {
      payload[FirestoreFields.storeBannerUrl] = bannerUrl;
    }

    try {
      await FirebaseService.db
          .collection(_profilesCollection)
          .doc(settings.userId)
          .set(payload, SetOptions(merge: true));

      final SellerStoreSettings loaded = await fetchSettings(
        userId: settings.userId,
      );

      return loaded.copyWith(
        slug: normalizedSlug,
        description: settings.description.trim(),
        bannerUrl: bannerUrl,
        phone: settings.phone.trim(),
        shopName: settings.shopName.trim(),
      );
    } on Exception catch (_) {
      throw const AppException.firebase(AppStrings.sellerStoreSaveFailed);
    } catch (_) {
      throw const AppException.firebase(AppStrings.sellerStoreSaveFailed);
    }
  }

  @override
  Future<bool> isSlugAvailable({
    required String userId,
    required String slug,
  }) async {
    final String normalizedSlug = slug.trim().toLowerCase();
    if (!_isValidSlug(normalizedSlug)) {
      return false;
    }

    try {
      final dynamic query = await FirebaseService.db
          .collection(_profilesCollection)
          .where(FirestoreFields.storeSlug, isEqualTo: normalizedSlug)
          .limit(1)
          .get();

      final List<dynamic> docs = query.docs as List<dynamic>? ?? <dynamic>[];
      if (docs.isEmpty) {
        return true;
      }

      final dynamic firstDoc = docs.first;
      final String existingId = (firstDoc.id as String? ?? '').trim();
      return existingId == userId;
    } on Exception catch (_) {
      throw const AppException.firebase(AppStrings.sellerStoreSlugCheckFailed);
    } catch (_) {
      throw const AppException.firebase(AppStrings.sellerStoreSlugCheckFailed);
    }
  }

  bool _isValidSlug(String slug) {
    return _slugPattern.hasMatch(slug);
  }

  Future<_FallbackProfile> _readFallbackProfile(String userId) async {
    final String defaultPhone = FirebaseService.currentUserPhone?.trim() ?? '';

    try {
      final dynamic doc = await FirebaseService.db
          .collection(FirestoreCollections.users)
          .doc(userId)
          .get();

      final bool exists = doc.exists as bool? ?? false;
      if (!exists) {
        return _FallbackProfile(shopName: '', phone: defaultPhone);
      }

      final Object? raw = doc.data();
      if (raw is! Map<String, dynamic>) {
        return _FallbackProfile(shopName: '', phone: defaultPhone);
      }

      return _FallbackProfile(
        shopName: (raw[FirestoreFields.shopName] as String? ?? '').trim(),
        phone: (raw[FirestoreFields.phone] as String? ?? defaultPhone).trim(),
      );
    } catch (_) {
      return _FallbackProfile(shopName: '', phone: defaultPhone);
    }
  }

  Map<String, dynamic>? _toMap(Object? raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map<Object?, Object?>) {
      return raw.map<String, dynamic>(
        (Object? key, Object? value) => MapEntry(key.toString(), value),
      );
    }
    return null;
  }
}

class _FallbackProfile {
  const _FallbackProfile({required this.shopName, required this.phone});

  final String shopName;
  final String phone;
}

final Provider<SellerStoreRepository> sellerStoreRepositoryProvider =
    Provider<SellerStoreRepository>((Ref ref) {
  return SellerStoreRepositoryImpl();
});
