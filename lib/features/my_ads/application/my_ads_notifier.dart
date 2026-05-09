import 'dart:async';

import 'package:dukaan_ai/core/constants/firestore_constants.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/features/studio/domain/generated_ad.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final NotifierProvider<MyAdsHasMoreController, bool> myAdsHasMoreProvider =
    NotifierProvider<MyAdsHasMoreController, bool>(
  MyAdsHasMoreController.new,
);

final NotifierProvider<MyAdsController, AsyncValue<List<GeneratedAd>>>
    myAdsNotifierProvider =
    NotifierProvider<MyAdsController, AsyncValue<List<GeneratedAd>>>(
  MyAdsNotifier.new,
);

abstract class MyAdsController extends Notifier<AsyncValue<List<GeneratedAd>>> {
  @override
  AsyncValue<List<GeneratedAd>> build();

  /// Loads the next page of ads when available.
  Future<void> loadMore();

  /// Reloads ads from the first page.
  Future<void> refresh();

  /// Deletes one ad by id and updates local state.
  Future<void> deleteAd(String adId);

  /// Updates the download count for one ad in Firestore and local state.
  Future<void> incrementDownloadCount({
    required String adId,
    required int currentCount,
  });
}

class MyAdsHasMoreController extends Notifier<bool> {
  @override
  bool build() => true;

  /// Updates the load-more visibility state.
  void setHasMore(bool value) {
    state = value;
  }
}

class MyAdsNotifier extends MyAdsController {
  static const int _pageSize = 10;

  dynamic _lastDocument;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _isInitialized = false;

  @override
  AsyncValue<List<GeneratedAd>> build() {
    if (!_isInitialized) {
      _isInitialized = true;
      unawaited(Future<void>.microtask(refresh));
    }
    return const AsyncLoading();
  }

  @override
  Future<void> refresh() async {
    state = const AsyncLoading();
    _lastDocument = null;
    _hasMore = true;
    _updateHasMore();

    state = await AsyncValue.guard(
      () => _fetchPage(isFirstPage: true),
    );
  }

  Future<List<GeneratedAd>> _fetchPage({required bool isFirstPage}) async {
    final String? userId = FirebaseService.currentUserId;
    if (userId == null || userId.isEmpty) {
      _hasMore = false;
      _updateHasMore();
      return <GeneratedAd>[];
    }

    dynamic query = FirebaseService.db
        .collection(FirestoreCollections.generatedAds)
        .where(FirestoreFields.userId, isEqualTo: userId)
        .orderBy(FirestoreFields.createdAt, descending: true)
        .limit(_pageSize);

    if (!isFirstPage && _lastDocument != null) {
      query = query.startAfterDocument(_lastDocument);
    }

    final dynamic snapshot = await query.get();
    final List<dynamic> docs = snapshot.docs as List<dynamic>? ?? <dynamic>[];

    if (docs.isNotEmpty) {
      _lastDocument = docs.last;
    }
    _hasMore = docs.length == _pageSize;
    _updateHasMore();

    return docs
        .map((dynamic doc) => _fromFirestoreDoc(doc, userId))
        .toList(growable: false);
  }

  @override
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) {
      return;
    }

    _isLoadingMore = true;
    try {
      final List<GeneratedAd> current = state.asData?.value ?? <GeneratedAd>[];
      final List<GeneratedAd> nextPage = await _fetchPage(isFirstPage: false);

      state = AsyncData(<GeneratedAd>[...current, ...nextPage]);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    } finally {
      _isLoadingMore = false;
    }
  }

  @override
  Future<void> deleteAd(String adId) async {
    await FirebaseService.db
        .collection(FirestoreCollections.generatedAds)
        .doc(adId)
        .delete();
    final List<GeneratedAd> current = state.asData?.value ?? <GeneratedAd>[];
    state = AsyncData(
      current.where((GeneratedAd ad) => ad.id != adId).toList(growable: false),
    );
  }

  @override
  Future<void> incrementDownloadCount({
    required String adId,
    required int currentCount,
  }) async {
    await FirebaseService.db
        .collection(FirestoreCollections.generatedAds)
        .doc(adId)
        .update(<String, dynamic>{
      FirestoreFields.downloadCount: currentCount + 1,
    });

    final List<GeneratedAd> currentAds = state.asData?.value ?? <GeneratedAd>[];
    state = AsyncData(
      currentAds
          .map(
            (GeneratedAd ad) => ad.id == adId
                ? ad.copyWith(downloadCount: ad.downloadCount + 1)
                : ad,
          )
          .toList(growable: false),
    );
  }

  void _updateHasMore() {
    ref.read(myAdsHasMoreProvider.notifier).setHasMore(_hasMore);
  }

  GeneratedAd _fromFirestoreDoc(dynamic doc, String fallbackUserId) {
    final dynamic rawData = doc.data();
    final Map<String, dynamic> data = _toMap(rawData);

    return GeneratedAd(
      id: _docId(doc),
      userId: data[FirestoreFields.userId] as String? ?? fallbackUserId,
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
  }

  Map<String, dynamic> _toMap(dynamic rawData) {
    if (rawData is Map<String, dynamic>) {
      return rawData;
    }
    if (rawData is Map<Object?, Object?>) {
      return rawData.map<String, dynamic>(
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
}
