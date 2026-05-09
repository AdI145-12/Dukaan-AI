import 'package:dukaan_ai/core/constants/firestore_constants.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Subscription dashboard snapshot for the current signed-in user.
class SubscriptionData {
  const SubscriptionData({
    required this.tier,
    required this.creditsRemaining,
    required this.transactions,
  });

  final String tier;
  final int creditsRemaining;
  final List<SubscriptionTransaction> transactions;

  /// Returns a safe fallback snapshot for signed-out users.
  factory SubscriptionData.fallback() {
    return const SubscriptionData(
      tier: 'free',
      creditsRemaining: 0,
      transactions: <SubscriptionTransaction>[],
    );
  }
}

/// One payment transaction row displayed in subscription history.
class SubscriptionTransaction {
  const SubscriptionTransaction({
    required this.id,
    required this.planId,
    required this.amountPaise,
    required this.createdAt,
  });

  final String id;
  final String planId;
  final int? amountPaise;
  final DateTime createdAt;
}

/// Loads subscription profile and successful transaction history from Firestore.
final FutureProvider<SubscriptionData> subscriptionProvider =
    FutureProvider<SubscriptionData>((Ref ref) async {
  final String? userId = FirebaseService.currentUserId;
  if (userId == null || userId.trim().isEmpty) {
    return SubscriptionData.fallback();
  }

  final dynamic userDoc = await FirebaseService.db
      .collection(FirestoreCollections.users)
      .doc(userId)
      .get();

  final Map<String, dynamic> profileData = _toMap(userDoc.data());
  final String tier = profileData[FirestoreFields.tier] as String? ?? 'free';
  final int credits =
      (profileData[FirestoreFields.creditsRemaining] as num?)?.toInt() ?? 0;

  final List<SubscriptionTransaction> transactions =
      await _loadSuccessfulTransactions(userId);

  return SubscriptionData(
    tier: tier,
    creditsRemaining: credits,
    transactions: transactions,
  );
});

Future<List<SubscriptionTransaction>> _loadSuccessfulTransactions(
  String userId,
) async {
  try {
    final dynamic snapshot = await FirebaseService.db
        .collection(FirestoreCollections.transactions)
        .where(FirestoreFields.userId, isEqualTo: userId)
        .where(FirestoreFields.status, isEqualTo: 'success')
        .limit(50)
        .get();

    final List<dynamic> docs = snapshot.docs as List<dynamic>? ?? <dynamic>[];
    final List<SubscriptionTransaction> transactions = docs
        .map((dynamic doc) => _transactionFromDoc(doc))
        .toList(growable: false);

    final List<SubscriptionTransaction> sorted =
        List<SubscriptionTransaction>.from(transactions);
    sorted.sort(
      (SubscriptionTransaction a, SubscriptionTransaction b) =>
          b.createdAt.compareTo(a.createdAt),
    );
    return sorted;
  } catch (_) {
    return const <SubscriptionTransaction>[];
  }
}

SubscriptionTransaction _transactionFromDoc(dynamic doc) {
  final Map<String, dynamic> data = _toMap(doc.data());

  return SubscriptionTransaction(
    id: _readId(doc),
    planId: data[FirestoreFields.planId] as String? ?? 'unknown',
    amountPaise: (data[FirestoreFields.amountPaise] as num?)?.toInt(),
    createdAt: _parseDate(
      data[FirestoreFields.verifiedAt] ?? data[FirestoreFields.createdAt],
    ),
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

String _readId(dynamic doc) {
  final dynamic id = doc.id;
  if (id is String) {
    return id;
  }
  return '';
}

DateTime _parseDate(Object? raw) {
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
    // Fall through to now.
  }

  return DateTime.now();
}
