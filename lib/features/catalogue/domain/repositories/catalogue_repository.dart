import 'dart:typed_data';

import 'package:dukaan_ai/features/catalogue/domain/models/catalogue_product.dart';

abstract class CatalogueRepository {
  /// Watches products for one signed-in user in reverse created time order.
  Stream<List<CatalogueProduct>> watchProducts({required String userId});

  /// Creates one product after uploading [imageBytes] to storage.
  Future<CatalogueProduct> createProduct({
    required CatalogueProduct product,
    required Uint8List imageBytes,
  });

  /// Creates one product using an already-hosted image URL.
  ///
  /// This is used by Studio -> Catalogue bridge mode, where the generated image
  /// is already uploaded in storage and should not be uploaded again.
  Future<CatalogueProduct> createProductWithImageUrl({
    required CatalogueProduct product,
  });

  /// Updates an existing product document.
  ///
  /// Re-uploads image only when [newImagePath] is provided.
  Future<void> updateProduct(
    CatalogueProduct product, {
    String? newImagePath,
  });

  /// Deletes an existing product document.
  Future<void> deleteProduct(String productId);

  /// Uploads product image bytes and returns a public image URL.
  Future<String> uploadProductImage({
    required String userId,
    required Uint8List imageBytes,
  });
}
