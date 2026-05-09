import 'package:dukaan_ai/features/seller_store/domain/models/seller_store_settings.dart';

abstract class SellerStoreRepository {
  /// Loads current seller store settings for one user.
  Future<SellerStoreSettings> fetchSettings({required String userId});

  /// Saves seller store settings and returns latest saved state.
  Future<SellerStoreSettings> saveSettings({
    required SellerStoreSettings settings,
  });

  /// Returns true when [slug] is not used by any other profile.
  Future<bool> isSlugAvailable({
    required String userId,
    required String slug,
  });
}
