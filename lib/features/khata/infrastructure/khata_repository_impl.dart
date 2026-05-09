import 'package:dukaan_ai/core/constants/firestore_constants.dart';
import 'package:dukaan_ai/core/errors/app_exception.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/features/khata/domain/khata_entry.dart';
import 'package:dukaan_ai/features/khata/domain/repositories/khata_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'khata_repository_impl.g.dart';

class KhataRepositoryImpl implements KhataRepository {
  const KhataRepositoryImpl();

  @override
  Stream<List<KhataEntry>> watchEntries({required String userId}) {
    if (userId.trim().isEmpty || FirebaseService.currentUserId == null) {
      return Stream<List<KhataEntry>>.value(const <KhataEntry>[]);
    }

    final dynamic query = FirebaseService.db
        .collection(FirestoreCollections.khataEntries)
        .where(FirestoreFields.userId, isEqualTo: userId)
        .where(FirestoreFields.isSettled, isEqualTo: false)
        .orderBy(FirestoreFields.createdAt, descending: true);

    return (query.snapshots() as Stream<dynamic>).map((dynamic snapshot) {
      final List<dynamic> docs = snapshot.docs as List<dynamic>? ?? <dynamic>[];
      return docs.map(KhataEntry.fromDoc).toList(growable: false);
    });
  }

  @override
  Future<void> addEntry({
    required String userId,
    required String customerName,
    String? customerPhone,
    required double amount,
    String type = 'credit',
    String? note,
  }) async {
    if (userId.trim().isEmpty || FirebaseService.currentUserId == null) {
      return;
    }

    try {
      await FirebaseService.db.collection(FirestoreCollections.khataEntries).add(<
          String,
          dynamic
        >{
        FirestoreFields.userId: userId,
        FirestoreFields.customerName: customerName.trim(),
        if (customerPhone != null && customerPhone.trim().isNotEmpty)
          FirestoreFields.customerPhone: customerPhone.trim(),
        FirestoreFields.amount: amount,
        FirestoreFields.type: type,
        if (note != null && note.trim().isNotEmpty)
          FirestoreFields.note: note.trim(),
        FirestoreFields.isSettled: false,
        FirestoreFields.createdAt: FirebaseService.serverTimestamp(),
      });
    } on Exception catch (error) {
      throw AppException.firebase(_extractMessage(error, 'Khata save nahi hua'));
    }
  }

  @override
  Future<void> updateAmount({required String id, required double newAmount}) async {
    try {
      await FirebaseService.db
          .collection(FirestoreCollections.khataEntries)
          .doc(id)
          .update(<String, dynamic>{FirestoreFields.amount: newAmount});
    } on Exception catch (error) {
      throw AppException.firebase(_extractMessage(error, 'Update nahi hua'));
    }
  }

  @override
  Future<void> markPaid({required String id}) async {
    try {
      await FirebaseService.db
          .collection(FirestoreCollections.khataEntries)
          .doc(id)
          .update(<String, dynamic>{FirestoreFields.isSettled: true});
    } on Exception catch (error) {
      throw AppException.firebase(_extractMessage(error, 'Paid mark nahi hua'));
    }
  }

  @override
  Future<void> deleteEntry({required String id}) async {
    try {
      await FirebaseService.db
          .collection(FirestoreCollections.khataEntries)
          .doc(id)
          .delete();
    } on Exception catch (error) {
      throw AppException.firebase(_extractMessage(error, 'Delete nahi hua'));
    }
  }

  @override
  Future<void> trackEvent({
    required String userId,
    required String eventType,
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
        FirestoreFields.creditsUsed: 0,
        if (metadata != null) FirestoreFields.metadata: metadata,
        FirestoreFields.createdAt: FirebaseService.serverTimestamp(),
      });
    } on Exception catch (error) {
      debugPrint('trackEvent failed: ${_extractMessage(error, 'unknown')}');
    }
  }

  String _extractMessage(Object error, String fallback) {
    try {
      final dynamic message = (error as dynamic).message;
      if (message is String && message.isNotEmpty) {
        return message;
      }
    } catch (_) {
      // Fall through to fallback.
    }
    return fallback;
  }
}

@riverpod
KhataRepository khataRepository(Ref ref) {
  return const KhataRepositoryImpl();
}
