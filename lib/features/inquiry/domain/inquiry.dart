import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dukaan_ai/core/constants/firestore_constants.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'inquiry_source.dart';
import 'inquiry_status.dart';

part 'inquiry.freezed.dart';

@freezed
abstract class Inquiry with _$Inquiry {
  const factory Inquiry({
    required String id,
    required String userId,
    required String customerName,
    String? customerPhone,
    String? productId,
    required String productAsked,
    required InquirySource source,
    required InquiryStatus status,
    String? notes,
    DateTime? lastFollowUp,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Inquiry;

  const Inquiry._();

  /// True when this inquiry is due for follow-up.
  bool get isFollowUpDue {
    if (status == InquiryStatus.followUpNeeded) {
      return true;
    }

    if (status == InquiryStatus.interested) {
      final DateTime twoDaysAgo = DateTime.now().subtract(
        const Duration(days: 2),
      );
      return updatedAt.isBefore(twoDaysAgo);
    }

    return false;
  }

  /// Builds an [Inquiry] from a Firestore document snapshot.
  factory Inquiry.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};

    return Inquiry(
      id: doc.id,
      userId: data[InquiryFields.userId] as String? ?? '',
      customerName: data[InquiryFields.customerName] as String? ?? '',
      customerPhone: data[InquiryFields.customerPhone] as String?,
      productId: data[InquiryFields.productId] as String?,
      productAsked: data[InquiryFields.productAsked] as String? ?? '',
      source: InquirySource.fromValue(
        data[InquiryFields.source] as String? ?? InquirySource.other.value,
      ),
      status: InquiryStatus.fromValue(
        data[InquiryFields.status] as String? ?? InquiryStatus.newInquiry.value,
      ),
      notes: data[InquiryFields.notes] as String?,
      lastFollowUp: (data[InquiryFields.lastFollowUp] as Timestamp?)?.toDate(),
      createdAt: _toDateTime(data[InquiryFields.createdAt]),
      updatedAt: _toDateTime(data[InquiryFields.updatedAt]),
    );
  }

  /// Serializes this inquiry into a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      InquiryFields.id: id,
      InquiryFields.userId: userId,
      InquiryFields.customerName: customerName,
      InquiryFields.customerPhone: customerPhone,
      InquiryFields.productId: productId,
      InquiryFields.productAsked: productAsked,
      InquiryFields.source: source.value,
      InquiryFields.status: status.value,
      InquiryFields.notes: notes,
      InquiryFields.lastFollowUp:
          lastFollowUp != null ? Timestamp.fromDate(lastFollowUp!) : null,
      InquiryFields.createdAt: Timestamp.fromDate(createdAt),
      InquiryFields.updatedAt: FieldValue.serverTimestamp(),
    };
  }
}

DateTime _toDateTime(Object? value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }
  return DateTime.now();
}
