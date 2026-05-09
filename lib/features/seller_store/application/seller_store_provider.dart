import 'package:dukaan_ai/core/config/app_config.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/errors/app_exception.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/features/seller_store/domain/models/seller_store_settings.dart';
import 'package:dukaan_ai/features/seller_store/domain/repositories/seller_store_repository.dart';
import 'package:dukaan_ai/features/seller_store/infrastructure/repositories/seller_store_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final AsyncNotifierProvider<SellerStoreController, SellerStoreSettings>
    sellerStoreProvider =
    AsyncNotifierProvider<SellerStoreController, SellerStoreSettings>(
  SellerStoreController.new,
);

final Provider<bool> storeIsPublishedProvider = Provider<bool>((Ref ref) {
  return ref.watch(sellerStoreProvider).maybeWhen(
        data: (SellerStoreSettings settings) => settings.isPublished,
        orElse: () => false,
      );
});

final Provider<String?> sellerStoreUrlProvider = Provider<String?>((Ref ref) {
  final SellerStoreSettings? settings =
      ref.watch(sellerStoreProvider).asData?.value;
  if (settings == null || settings.normalizedSlug.isEmpty) {
    return null;
  }
  return '${AppConfig.workerBaseUrl}/api/get-seller-store/${settings.normalizedSlug}';
});

class SellerStoreController extends AsyncNotifier<SellerStoreSettings> {
  @override
  Future<SellerStoreSettings> build() async {
    final String? userId = FirebaseService.currentUserId;
    if (userId == null || userId.trim().isEmpty) {
      throw const AppException.firebase(AppStrings.errorAuth);
    }

    final SellerStoreRepository repository =
        ref.watch(sellerStoreRepositoryProvider);
    return repository.fetchSettings(userId: userId);
  }

  Future<void> refresh() async {
    final String? userId = FirebaseService.currentUserId;
    if (userId == null || userId.trim().isEmpty) {
      state = const AsyncError(
        AppException.firebase(AppStrings.errorAuth),
        StackTrace.empty,
      );
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () =>
          ref.read(sellerStoreRepositoryProvider).fetchSettings(userId: userId),
    );
  }

  Future<void> saveSettings({
    required String slug,
    required String description,
    required String bannerUrl,
    required String phone,
    required bool isPublished,
  }) async {
    final SellerStoreSettings current = state.asData?.value ?? await future;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref.read(sellerStoreRepositoryProvider).saveSettings(
            settings: current.copyWith(
              slug: slug,
              description: description,
              bannerUrl: bannerUrl,
              phone: phone,
              isPublished: isPublished,
            ),
          );
    });
  }
}
