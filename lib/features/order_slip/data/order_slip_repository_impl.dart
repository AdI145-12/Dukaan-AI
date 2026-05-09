import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dukaan_ai/core/constants/firestore_constants.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/features/order_slip/data/order_slip_repository.dart';
import 'package:dukaan_ai/features/order_slip/domain/order_slip.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'order_slip_repository_impl.g.dart';

class OrderSlipRepositoryImpl implements OrderSlipRepository {
  const OrderSlipRepositoryImpl();

  dynamic get _collection {
    return FirebaseService.db.collection(FirestoreCollections.orderSlipsCollection);
  }

  @override
  Future<List<OrderSlip>> getSlips(String userId) async {
    final dynamic query = _collection
        .where(FirestoreFields.orderSlipUserId, isEqualTo: userId)
        .orderBy(FirestoreFields.orderSlipCreatedAt, descending: true);

    final dynamic snapshot = await query.get();
    final List<dynamic> docs = snapshot.docs as List<dynamic>? ?? <dynamic>[];

    return docs
        .map(
          (dynamic doc) => OrderSlip.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<OrderSlip> createSlip(OrderSlip slip) async {
    final dynamic ref = await _collection.add(slip.toFirestore());
    final String id = ref.id as String? ?? '';
    return slip.copyWith(id: id);
  }

  @override
  Future<void> updateSlipImageUrl(String slipId, String imageUrl) async {
    await _collection.doc(slipId).update(<String, Object>{
      FirestoreFields.orderSlipSlipImageUrl: imageUrl,
    });
  }

  @override
  Future<void> deleteSlip(String slipId) async {
    await _collection.doc(slipId).delete();
  }

  @override
  Future<int> getSlipCount(String userId) async {
    final dynamic query = _collection.where(
      FirestoreFields.orderSlipUserId,
      isEqualTo: userId,
    );

    try {
      final dynamic aggregate = await query.count().get();
      final dynamic count = aggregate.count;
      if (count is int) {
        return count;
      }
      if (count is num) {
        return count.toInt();
      }
    } catch (_) {
      // Fallback to full query when aggregate count isn't available.
    }

    final dynamic snapshot = await query.get();
    final List<dynamic> docs = snapshot.docs as List<dynamic>? ?? <dynamic>[];
    return docs.length;
  }
}

@riverpod
OrderSlipRepository orderSlipRepository(Ref ref) {
  return const OrderSlipRepositoryImpl();
}
