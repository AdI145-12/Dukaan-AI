import 'package:dukaan_ai/core/constants/supabase_constants.dart';
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
        id: row[SupabaseColumns.id] as String,
        userId: row[SupabaseColumns.userId] as String,
        imageUrl: row[SupabaseColumns.imageUrl] as String,
        thumbnailUrl: row[SupabaseColumns.thumbnailUrl] as String?,
        backgroundStyle: row[SupabaseColumns.backgroundStyle] as String?,
        captionHindi: row[SupabaseColumns.captionHindi] as String?,
        captionEnglish: row[SupabaseColumns.captionEnglish] as String?,
        shareCount: row['sharecount'] as int? ?? 0,
        downloadCount: row['downloadcount'] as int? ?? 0,
        festivalTag: row['festivaltag'] as String?,
        createdAt: DateTime.parse(row[SupabaseColumns.createdAt] as String),
      );
}
