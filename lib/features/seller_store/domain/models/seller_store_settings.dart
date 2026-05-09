import 'package:dukaan_ai/core/constants/firestore_constants.dart';

class SellerStoreSettings {
  const SellerStoreSettings({
    required this.userId,
    required this.shopName,
    required this.phone,
    required this.slug,
    required this.description,
    required this.bannerUrl,
    required this.isPublished,
    required this.viewsCount,
    required this.whatsappClicks,
  });

  factory SellerStoreSettings.empty({
    required String userId,
    String shopName = '',
    String phone = '',
  }) {
    return SellerStoreSettings(
      userId: userId,
      shopName: shopName,
      phone: phone,
      slug: suggestSlug(shopName),
      description: '',
      bannerUrl: '',
      isPublished: false,
      viewsCount: 0,
      whatsappClicks: 0,
    );
  }

  factory SellerStoreSettings.fromFirestore(
    Map<String, dynamic> data,
    String userId, {
    String fallbackShopName = '',
    String fallbackPhone = '',
  }) {
    final String shopName =
        (data[FirestoreFields.shopName] as String? ?? fallbackShopName).trim();
    final String slugRaw =
        (data[FirestoreFields.storeSlug] as String? ?? '').trim().toLowerCase();

    return SellerStoreSettings(
      userId: userId,
      shopName: shopName,
      phone: (data[FirestoreFields.phone] as String? ?? fallbackPhone).trim(),
      slug: slugRaw.isEmpty ? suggestSlug(shopName) : slugRaw,
      description:
          (data[FirestoreFields.storeDescription] as String? ?? '').trim(),
      bannerUrl: (data[FirestoreFields.storeBannerUrl] as String? ?? '').trim(),
      isPublished: data[FirestoreFields.storeIsPublished] as bool? ?? false,
      viewsCount: (data[FirestoreFields.storeViewsCount] as num?)?.toInt() ?? 0,
      whatsappClicks:
          (data[FirestoreFields.storeWhatsappClicks] as num?)?.toInt() ?? 0,
    );
  }

  final String userId;
  final String shopName;
  final String phone;
  final String slug;
  final String description;
  final String bannerUrl;
  final bool isPublished;
  final int viewsCount;
  final int whatsappClicks;

  String get normalizedSlug => slug.trim().toLowerCase();

  SellerStoreSettings copyWith({
    String? userId,
    String? shopName,
    String? phone,
    String? slug,
    String? description,
    String? bannerUrl,
    bool? isPublished,
    int? viewsCount,
    int? whatsappClicks,
  }) {
    return SellerStoreSettings(
      userId: userId ?? this.userId,
      shopName: shopName ?? this.shopName,
      phone: phone ?? this.phone,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      isPublished: isPublished ?? this.isPublished,
      viewsCount: viewsCount ?? this.viewsCount,
      whatsappClicks: whatsappClicks ?? this.whatsappClicks,
    );
  }

  static String suggestSlug(String raw) {
    final String lower = raw.trim().toLowerCase();
    if (lower.isEmpty) {
      return '';
    }

    final String normalized = lower
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');

    if (normalized.length <= 40) {
      return normalized;
    }

    return normalized.substring(0, 40).replaceAll(RegExp(r'-+$'), '');
  }
}
