import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dukaan_ai/core/constants/firestore_constants.dart';
import 'package:dukaan_ai/core/providers/firebase_providers.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry_repository.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inquiry_repository_impl.g.dart';

@riverpod
InquiryRepository inquiryRepository(Ref ref) {
  final FirebaseFirestore firestore = ref.watch(firestoreProvider);
  return InquiryRepositoryImpl(firestore);
}

class InquiryRepositoryImpl implements InquiryRepository {
  InquiryRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col {
    return _firestore.collection(FirestoreCollections.inquiriesCollection);
  }

  @override
  Stream<List<Inquiry>> watchInquiries(String userId) {
    return _col
        .where(InquiryFields.userId, isEqualTo: userId)
        .orderBy(InquiryFields.updatedAt, descending: true)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
              .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
            return Inquiry.fromFirestore(doc);
          }).toList(growable: false),
        );
  }

  @override
  Stream<int> watchFollowUpDueCount(String userId) {
    return watchInquiries(userId).map(
      (List<Inquiry> list) => list.where((Inquiry i) => i.isFollowUpDue).length,
    );
  }

  @override
  Future<Inquiry> createInquiry(Inquiry inquiry) async {
    final DocumentReference<Map<String, dynamic>> docRef = _col.doc();
    final Inquiry withId = inquiry.copyWith(id: docRef.id);
    await docRef.set(withId.toFirestore());
    return withId;
  }

  @override
  Future<void> updateInquiry(Inquiry inquiry) {
    return _col.doc(inquiry.id).update(inquiry.toFirestore());
  }

  @override
  Future<void> updateStatus(String inquiryId, InquiryStatus newStatus) {
    return _col.doc(inquiryId).update(<String, Object>{
      InquiryFields.status: newStatus.value,
      InquiryFields.updatedAt: FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteInquiry(String inquiryId) {
    return _col.doc(inquiryId).delete();
  }
}
