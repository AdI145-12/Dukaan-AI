import 'package:dukaan_ai/core/constants/firestore_constants.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated_ad.freezed.dart';

@freezed
abstract class GeneratedAd with _$GeneratedAd {
  const factory GeneratedAd({
    required String id,
    required String userId,
    required String imageUrl,
    String? thumbnailUrl,
    String? backgroundStyle,
    String? captionHindi,
    String? captionEnglish,
    @Default(0) int shareCount,
    @Default(0) int downloadCount,
    String? festivalTag,
    required DateTime createdAt,
  }) = _GeneratedAd;

  static GeneratedAd fromRow(Map<String, dynamic> row) => GeneratedAd(
      id: row['id'] as String,
      userId: row[FirestoreFields.userId] as String,
      imageUrl: row[FirestoreFields.imageUrl] as String,
      thumbnailUrl: row[FirestoreFields.thumbnailUrl] as String?,
      backgroundStyle: row[FirestoreFields.backgroundStyle] as String?,
      captionHindi: row[FirestoreFields.captionHindi] as String?,
      captionEnglish: row[FirestoreFields.captionEnglish] as String?,
      shareCount: row[FirestoreFields.shareCount] as int? ?? 0,
      downloadCount: row[FirestoreFields.downloadCount] as int? ?? 0,
      festivalTag: row[FirestoreFields.festivalTag] as String?,
      createdAt: DateTime.parse(row[FirestoreFields.createdAt] as String),
      );
}
