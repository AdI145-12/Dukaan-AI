import 'package:dukaan_ai/core/constants/firestore_constants.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String shopName,
    String? ownerName,
    String? phone,
    String? city,
    String? category,
    @Default('free') String tier,
    @Default(3) int creditsRemaining,
    @Default('hinglish') String language,
  }) = _UserProfile;

  static UserProfile fromFirestore(Map<String, dynamic> row) => UserProfile(
        id: row['id'] as String? ?? '',
        shopName: row[FirestoreFields.shopName] as String? ?? '',
        ownerName: row[FirestoreFields.ownerName] as String?,
        phone: row[FirestoreFields.phone] as String?,
        city: row[FirestoreFields.city] as String?,
        category: row[FirestoreFields.category] as String?,
        tier: row[FirestoreFields.tier] as String? ?? 'free',
        creditsRemaining: row[FirestoreFields.creditsRemaining] as int? ?? 3,
        language: row[FirestoreFields.language] as String? ?? 'hinglish',
      );

  static UserProfile fromRow(Map<String, dynamic> row) =>
      UserProfile.fromFirestore(row);
}
