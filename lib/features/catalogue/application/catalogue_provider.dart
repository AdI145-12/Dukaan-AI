import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/errors/app_exception.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/core/services/image_pipeline.dart';
import 'package:dukaan_ai/features/catalogue/application/catalogue_state.dart';
import 'package:dukaan_ai/features/catalogue/domain/models/catalogue_product.dart';
import 'package:dukaan_ai/features/catalogue/domain/stock_status.dart';
import 'package:dukaan_ai/features/catalogue/infrastructure/repositories/catalogue_repository_impl.dart';
import 'package:dukaan_ai/features/catalogue/infrastructure/services/catalogue_metadata_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'catalogue_provider.g.dart';

@riverpod
class Catalogue extends _$Catalogue {
  StreamSubscription<List<CatalogueProduct>>? _subscription;

  @override
  Future<List<CatalogueProduct>> build() async {
    final String? userId = FirebaseService.currentUserId;
    if (userId == null || userId.trim().isEmpty) {
      return const <CatalogueProduct>[];
    }

    final repository = ref.watch(catalogueRepositoryProvider);
    final Stream<List<CatalogueProduct>> stream =
        repository.watchProducts(userId: userId);

    final Completer<List<CatalogueProduct>> firstValue =
        Completer<List<CatalogueProduct>>();

    unawaited(_subscription?.cancel());
    _subscription = stream.listen(
      (List<CatalogueProduct> products) {
        if (!firstValue.isCompleted) {
          firstValue.complete(products);
        }
        state = AsyncData(products);
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!firstValue.isCompleted) {
          firstValue.completeError(error, stackTrace);
        }
        state = AsyncError(error, stackTrace);
      },
    );

    ref.onDispose(() {
      unawaited(_subscription?.cancel());
      _subscription = null;
    });

    return firstValue.future;
  }

  Future<void> updateProduct(
    CatalogueProduct product, {
    String? newImagePath,
  }) async {
    final List<CatalogueProduct> currentProducts =
        state.asData?.value ?? <CatalogueProduct>[];
    final List<CatalogueProduct> optimisticList = currentProducts
        .map(
          (CatalogueProduct existing) =>
              existing.id == product.id ? product : existing,
        )
        .toList(growable: false);
    state = AsyncData(optimisticList);

    final AsyncValue<void> result = await AsyncValue.guard(() async {
      await ref.read(catalogueRepositoryProvider).updateProduct(
            product,
            newImagePath: newImagePath,
          );
    });

    if (result.hasError) {
      state = AsyncError(result.error!, result.stackTrace!);
    }
  }

  Future<void> quickUpdateStock(
    String productId,
    StockStatus newStatus,
    int? newQuantity,
  ) async {
    final List<CatalogueProduct> products = state.asData?.value ?? <CatalogueProduct>[];

    CatalogueProduct? selected;
    for (final CatalogueProduct product in products) {
      if (product.id == productId) {
        selected = product;
        break;
      }
    }

    if (selected == null) {
      log(
        'quickUpdateStock skipped; product not found: $productId',
        name: 'CatalogueNotifier',
      );
      return;
    }

    await updateProduct(
      selected.copyWith(
        stockStatus: newStatus,
        quantity: newStatus == StockStatus.outOfStock ? null : newQuantity,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }

  Future<void> deleteProduct(String productId) async {
    final List<CatalogueProduct> currentProducts =
        state.asData?.value ?? <CatalogueProduct>[];
    final List<CatalogueProduct> optimisticList = currentProducts
        .where((CatalogueProduct product) => product.id != productId)
        .toList(growable: false);
    state = AsyncData(optimisticList);

    final AsyncValue<void> result = await AsyncValue.guard(() async {
      await ref.read(catalogueRepositoryProvider).deleteProduct(productId);
    });

    if (result.hasError) {
      state = AsyncError(result.error!, result.stackTrace!);
    }
  }
}

@riverpod
class CatalogueComposer extends _$CatalogueComposer {
  @override
  CatalogueState build() {
    return const CatalogueState();
  }

  /// Clears draft metadata after closing add-product sheet.
  void clearComposer() {
    state = const CatalogueState();
  }

  /// Writes user-edited metadata back to state so save uses latest values.
  void applyManualMetadata({
    required String description,
    required List<String> tags,
    required List<String> suggestedCaptions,
  }) {
    state = state.copyWith(
      description: description.trim(),
      tags: _normalizeList(tags),
      suggestedCaptions: _normalizeList(suggestedCaptions),
    );
  }

  /// Generates metadata for one product draft. Can be auto or manual.
  Future<void> generateMetadata({
    required XFile imageFile,
    required String name,
    required String category,
    bool force = false,
  }) async {
    final String? userId = FirebaseService.currentUserId;
    if (userId == null || userId.trim().isEmpty) {
      state = state.copyWith(errorMessage: AppStrings.errorAuth);
      return;
    }

    final String normalizedName = name.trim();
    final String normalizedCategory = category.trim();
    if (normalizedName.isEmpty || normalizedCategory.isEmpty) {
      return;
    }

    final String requestKey =
        '${imageFile.path}|$normalizedName|$normalizedCategory';
    if (!force && state.lastGeneratedKey == requestKey) {
      return;
    }

    state = state.copyWith(isGeneratingMetadata: true, errorMessage: null);

    try {
      final Uint8List processed =
          await ImagePipeline.prepareForUpload(imageFile);
      final String imageBase64 = await ImagePipeline.toBase64(processed);

      final metadata =
          await ref.read(catalogueMetadataServiceProvider).generate(
                userId: userId,
                productName: normalizedName,
                category: normalizedCategory,
                imageBase64: imageBase64,
              );

      state = state.copyWith(
        isGeneratingMetadata: false,
        description: metadata.description,
        tags: metadata.tags,
        suggestedCaptions: metadata.suggestedCaptions,
        lastGeneratedKey: requestKey,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        isGeneratingMetadata: false,
        errorMessage: _toErrorMessage(error),
      );
    }
  }

  /// Creates one product document and uploads image bytes.
  Future<bool> createProduct({
    required XFile imageFile,
    required String name,
    required String category,
    required double price,
    List<CatalogueVariantGroup> variants = const <CatalogueVariantGroup>[],
    StockStatus stockStatus = StockStatus.inStock,
    int? quantity,
    String? description,
    List<String>? tags,
    List<String>? suggestedCaptions,
  }) async {
    final String? userId = FirebaseService.currentUserId;
    if (userId == null || userId.trim().isEmpty) {
      state = state.copyWith(errorMessage: AppStrings.errorAuth);
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final Uint8List processed =
          await ImagePipeline.prepareForUpload(imageFile);
      final CatalogueProduct draft = _buildDraft(
        userId: userId,
        name: name,
        category: category,
        price: price,
        variants: variants,
        stockStatus: stockStatus,
        quantity: quantity,
        description: description,
        tags: tags,
        suggestedCaptions: suggestedCaptions,
      );

      await ref.read(catalogueRepositoryProvider).createProduct(
            product: draft,
            imageBytes: processed,
          );

      state = state.copyWith(isSubmitting: false, errorMessage: null);
      return true;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _toErrorMessage(error),
      );
      return false;
    }
  }

  /// Creates one product document using a pre-uploaded network image URL.
  Future<bool> createProductWithImageUrl({
    required String imageUrl,
    required String name,
    required String category,
    required double price,
    List<CatalogueVariantGroup> variants = const <CatalogueVariantGroup>[],
    StockStatus stockStatus = StockStatus.inStock,
    int? quantity,
    String? description,
    List<String>? tags,
    List<String>? suggestedCaptions,
  }) async {
    final String? userId = FirebaseService.currentUserId;
    if (userId == null || userId.trim().isEmpty) {
      state = state.copyWith(errorMessage: AppStrings.errorAuth);
      return false;
    }

    final String normalizedImageUrl = imageUrl.trim();
    if (normalizedImageUrl.isEmpty) {
      state = state.copyWith(errorMessage: AppStrings.catalogueImageRequired);
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final CatalogueProduct draft = _buildDraft(
        userId: userId,
        name: name,
        category: category,
        price: price,
        variants: variants,
        stockStatus: stockStatus,
        quantity: quantity,
        description: description,
        tags: tags,
        suggestedCaptions: suggestedCaptions,
        imageUrl: normalizedImageUrl,
      );

      await ref.read(catalogueRepositoryProvider).createProductWithImageUrl(
            product: draft,
          );

      state = state.copyWith(isSubmitting: false, errorMessage: null);
      return true;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _toErrorMessage(error),
      );
      return false;
    }
  }

  CatalogueProduct _buildDraft({
    required String userId,
    required String name,
    required String category,
    required double price,
    required List<CatalogueVariantGroup> variants,
    required StockStatus stockStatus,
    required int? quantity,
    required String? description,
    required List<String>? tags,
    required List<String>? suggestedCaptions,
    String imageUrl = '',
  }) {
    final DateTime now = DateTime.now().toUtc();

    return CatalogueProduct(
      id: '',
      userId: userId,
      name: name.trim(),
      price: price,
      category: category.trim(),
      variants: variants,
      stockStatus: stockStatus,
      quantity: quantity,
      imageUrl: imageUrl,
      description: (description ?? state.description).trim(),
      tags: _normalizeList(tags ?? state.tags),
      suggestedCaptions:
          _normalizeList(suggestedCaptions ?? state.suggestedCaptions),
      createdAt: now,
      updatedAt: now,
    );
  }

  String _toErrorMessage(Object error) {
    if (error is AppException) {
      return error.userMessage;
    }
    return AppStrings.errorGeneric;
  }

  List<String> _normalizeList(List<String> input) {
    final List<String> values = <String>[];
    for (final String raw in input) {
      final String cleaned = raw.trim();
      if (cleaned.isEmpty || values.contains(cleaned)) {
        continue;
      }
      values.add(cleaned);
    }
    return values;
  }
}
