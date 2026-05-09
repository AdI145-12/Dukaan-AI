import 'dart:typed_data';
import 'dart:io';

import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/constants/firestore_constants.dart';
import 'package:dukaan_ai/core/errors/app_exception.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/features/catalogue/domain/models/catalogue_product.dart';
import 'package:dukaan_ai/features/catalogue/domain/repositories/catalogue_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'catalogue_repository_impl.g.dart';

class CatalogueRepositoryImpl implements CatalogueRepository {
  const CatalogueRepositoryImpl();

  @override
  Stream<List<CatalogueProduct>> watchProducts({required String userId}) {
    if (userId.trim().isEmpty || FirebaseService.currentUserId == null) {
      return Stream<List<CatalogueProduct>>.value(
        const <CatalogueProduct>[],
      );
    }

    final dynamic query = FirebaseService.db
        .collection(FirestoreCollections.products)
        .where(FirestoreFields.userId, isEqualTo: userId)
        .orderBy(FirestoreFields.createdAt, descending: true);

    return (query.snapshots() as Stream<dynamic>).map((dynamic snapshot) {
      final List<dynamic> docs = snapshot.docs as List<dynamic>? ?? <dynamic>[];
      return docs
          .map(
            (dynamic doc) => CatalogueProduct.fromDoc(
              doc,
              fallbackUserId: userId,
            ),
          )
          .toList(growable: false);
    });
  }

  @override
  Future<CatalogueProduct> createProduct({
    required CatalogueProduct product,
    required Uint8List imageBytes,
  }) async {
    try {
      final dynamic ref =
          FirebaseService.db.collection(FirestoreCollections.products).doc();
      final String productId = ref.id as String? ?? '';
      final String imageUrl = await _uploadImageBytes(
        product.userId,
        productId,
        imageBytes,
      );

      final Map<String, dynamic> payload =
          product.copyWith(id: productId, imageUrl: imageUrl).toFirestore();
      payload[FirestoreFields.createdAt] = FirebaseService.serverTimestamp();
      payload[FirestoreFields.updatedAt] = FirebaseService.serverTimestamp();

      await ref.set(payload);
      final dynamic snapshot = await ref.get();

      return CatalogueProduct.fromDoc(
        snapshot,
        fallbackUserId: product.userId,
      );
    } on AppException {
      rethrow;
    } on Exception catch (error) {
      throw AppException.firebase(
        _extractMessage(error, AppStrings.catalogueSaveFailed),
      );
    } catch (error) {
      throw AppException.unknown(error.toString());
    }
  }

  @override
  Future<CatalogueProduct> createProductWithImageUrl({
    required CatalogueProduct product,
  }) async {
    if (product.imageUrl.trim().isEmpty) {
      throw const AppException.firebase(AppStrings.catalogueImageRequired);
    }

    try {
      final dynamic ref =
          FirebaseService.db.collection(FirestoreCollections.products).doc();
      final String productId = ref.id as String? ?? '';

      final Map<String, dynamic> payload = product
          .copyWith(id: productId, imageUrl: product.imageUrl.trim())
          .toFirestore();
      payload[FirestoreFields.createdAt] = FirebaseService.serverTimestamp();
      payload[FirestoreFields.updatedAt] = FirebaseService.serverTimestamp();

      await ref.set(payload);
      final dynamic snapshot = await ref.get();

      return CatalogueProduct.fromDoc(
        snapshot,
        fallbackUserId: product.userId,
      );
    } on AppException {
      rethrow;
    } on Exception catch (error) {
      throw AppException.firebase(
        _extractMessage(error, AppStrings.catalogueSaveFailed),
      );
    } catch (error) {
      throw AppException.unknown(error.toString());
    }
  }

  @override
  Future<void> updateProduct(
    CatalogueProduct product, {
    String? newImagePath,
  }) async {
    try {
      String imageUrl = product.imageUrl;
      if (newImagePath != null && newImagePath.trim().isNotEmpty) {
        imageUrl = await _uploadImage(
          product.userId,
          product.id,
          newImagePath,
        );
      }

      final CatalogueProduct updatedProduct =
          product.copyWith(imageUrl: imageUrl);
      final Map<String, dynamic> updates = updatedProduct.toFirestore();
      updates.remove(FirestoreFields.createdAt);
      updates[FirestoreFields.updatedAt] = FirebaseService.serverTimestamp();

      final dynamic ref = FirebaseService.db
          .collection(FirestoreCollections.products)
          .doc(product.id);

      await ref.update(updates);
    } on Exception catch (error) {
      throw AppException.firebase(
        _extractMessage(error, AppStrings.catalogueSaveFailed),
      );
    } catch (error) {
      throw AppException.unknown(error.toString());
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await FirebaseService.db
          .collection(FirestoreCollections.products)
          .doc(productId)
          .delete();
    } on Exception catch (error) {
      throw AppException.firebase(
        _extractMessage(error, AppStrings.catalogueSaveFailed),
      );
    } catch (error) {
      throw AppException.unknown(error.toString());
    }
  }

  @override
  Future<String> uploadProductImage({
    required String userId,
    required Uint8List imageBytes,
  }) async {
    try {
      final int ts = DateTime.now().millisecondsSinceEpoch;
      return _uploadImageBytes(userId, 'tmp-$ts', imageBytes);
    } on Exception catch (error) {
      throw AppException.firebase(
        _extractMessage(error, AppStrings.errorUploadFailed),
      );
    } catch (error) {
      throw AppException.unknown(error.toString());
    }
  }

  Future<String> _uploadImage(
    String userId,
    String productId,
    String newImagePath,
  ) async {
    final Uint8List bytes = await File(newImagePath).readAsBytes();
    return _uploadImageBytes(userId, productId, bytes);
  }

  Future<String> _uploadImageBytes(
    String userId,
    String productId,
    Uint8List bytes,
  ) async {
    final String cleanUserId = userId.trim();
    final String cleanProductId = productId.trim();
    final String path = 'products/$cleanUserId/$cleanProductId.jpg';
    final dynamic ref = FirebaseService.store.ref().child(path);

    await ref.putData(
      bytes,
      <String, Object>{'contentType': 'image/jpeg'},
    );

    final dynamic downloadUrl = await ref.getDownloadURL();
    if (downloadUrl is String && downloadUrl.trim().isNotEmpty) {
      return downloadUrl;
    }

    return path;
  }

  String _extractMessage(Object error, String fallback) {
    try {
      final dynamic message = (error as dynamic).message;
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    } catch (_) {
      // Fall through.
    }
    return fallback;
  }
}

@riverpod
CatalogueRepository catalogueRepository(Ref ref) {
  return const CatalogueRepositoryImpl();
}
