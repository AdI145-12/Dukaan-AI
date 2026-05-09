class SupabaseTables {
  const SupabaseTables._();

  static const String profiles = 'profiles';
  static const String shops = 'profiles';
  static const String generatedAds = 'generated_ads';
  static const String khataEntries = 'khata_entries';
  static const String transactions = 'transactions';
  static const String usageEvents = 'usage_events';
  static const String catalogues = 'catalogues';
  static const String catalogueProducts = 'catalogue_products';
}

class SupabaseColumns {
  const SupabaseColumns._();

  static const String id = 'id';
  static const String userId = 'user_id';
  static const String shopName = 'shop_name';
  static const String ownerName = 'owner_name';
  static const String category = 'category';
  static const String city = 'city';
  static const String phone = 'phone';
  static const String tier = 'tier';
  static const String creditsRemaining = 'credits_remaining';
  static const String fcmToken = 'fcm_token';
  static const String language = 'language';
  static const String imageUrl = 'image_url';
  static const String thumbnailUrl = 'thumbnail_url';
  static const String backgroundStyle = 'background_style';
  static const String captionHindi = 'caption_hindi';
  static const String captionEnglish = 'caption_english';
  static const String createdAt = 'created_at';
  static const String isSettled = 'is_settled';
  static const String amount = 'amount';
  static const String type = 'type';
  static const String status = 'status';
  static const String planId = 'plan_id';
  static const String amountPaise = 'amount_paise';
  static const String creditsGranted = 'credits_granted';
}
