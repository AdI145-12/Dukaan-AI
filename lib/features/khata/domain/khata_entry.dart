import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/core/constants/firestore_constants.dart';

class KhataEntry {
  const KhataEntry({
    required this.id,
    required this.userId,
    required this.customerName,
    this.customerPhone,
    required this.amount,
    this.type = 'credit',
    this.note,
    this.isSettled = false,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String customerName;
  final String? customerPhone;
  final double amount;
  final String type;
  final String? note;
  final bool isSettled;
  final DateTime createdAt;

  /// Maps a Firestore-style row to [KhataEntry].
  factory KhataEntry.fromRow(Map<String, dynamic> row) {
    return KhataEntry(
      id: row['id'] as String,
      userId: row[FirestoreFields.userId] as String,
      customerName: row[FirestoreFields.customerName] as String,
      customerPhone: row[FirestoreFields.customerPhone] as String?,
      amount: (row[FirestoreFields.amount] as num).toDouble(),
      type: row[FirestoreFields.type] as String? ?? 'credit',
      note: row[FirestoreFields.note] as String?,
      isSettled: (row[FirestoreFields.isSettled] as bool?) ?? false,
      createdAt: DateTime.parse(row[FirestoreFields.createdAt] as String),
    );
  }

  /// Maps a Firestore-style document to [KhataEntry].
  ///
  /// ASSUMPTION: [doc] exposes `.id` and `.data()` like Firestore snapshots.
  factory KhataEntry.fromDoc(dynamic doc) {
    final dynamic rawData = doc.data();
    final Map<String, dynamic> data =
        rawData is Map<String, dynamic> ? rawData : <String, dynamic>{};
    final dynamic rawCreatedAt = data['createdAt'];
    DateTime createdAt = DateTime.now();
    if (rawCreatedAt is DateTime) {
      createdAt = rawCreatedAt;
    } else if (rawCreatedAt is String) {
      createdAt = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    } else {
      try {
        final dynamic maybeDate = rawCreatedAt?.toDate();
        if (maybeDate is DateTime) {
          createdAt = maybeDate;
        }
      } catch (_) {
        createdAt = DateTime.now();
      }
    }

    return KhataEntry(
      id: doc.id as String? ?? '',
      userId: data['userId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      customerPhone: data['customerPhone'] as String?,
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      type: data['type'] as String? ?? 'credit',
      note: data['note'] as String?,
      isSettled: data['isSettled'] as bool? ?? false,
      createdAt: createdAt,
    );
  }

  /// Converts this entry to Firestore write map.
  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'userId': userId,
      'customerName': customerName,
      if (customerPhone != null) 'customerPhone': customerPhone,
      'amount': amount,
      'type': type,
      if (note != null) 'note': note,
      'isSettled': isSettled,
      'createdAt': FirebaseService.serverTimestamp(),
    };
  }

  /// Returns a new [KhataEntry] with selected values replaced.
  KhataEntry copyWith({
    String? id,
    String? userId,
    String? customerName,
    String? customerPhone,
    double? amount,
    String? type,
    String? note,
    bool? isSettled,
    DateTime? createdAt,
  }) {
    return KhataEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      note: note ?? this.note,
      isSettled: isSettled ?? this.isSettled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is KhataEntry &&
            id == other.id &&
            userId == other.userId &&
            customerName == other.customerName &&
            customerPhone == other.customerPhone &&
            amount == other.amount &&
            type == other.type &&
            note == other.note &&
            isSettled == other.isSettled &&
            createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      customerName,
      customerPhone,
      amount,
      type,
      note,
      isSettled,
      createdAt,
    );
  }
}