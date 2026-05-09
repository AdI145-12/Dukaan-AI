import 'package:dukaan_ai/core/network/cloudflare_client.dart';
import 'package:dukaan_ai/features/catalogue/domain/models/catalogue_metadata.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'catalogue_metadata_service.g.dart';

class CatalogueMetadataService {
  const CatalogueMetadataService({required this.cloudflareClient});

  final CloudflareClient cloudflareClient;

  /// Calls Worker metadata endpoint and returns description/tags/captions.
  Future<CatalogueMetadata> generate({
    required String userId,
    required String productName,
    required String category,
    required String imageBase64,
  }) async {
    final Map<String, dynamic> data = await cloudflareClient.post(
      endpoint: '/api/generate-product-metadata',
      body: <String, dynamic>{
        'productName': productName,
        'category': category,
        'imageBase64': imageBase64,
      },
      userId: userId,
    );

    return CatalogueMetadata.fromMap(data);
  }
}

@riverpod
CatalogueMetadataService catalogueMetadataService(Ref ref) {
  final CloudflareClient client = ref.watch(cloudflareClientProvider);
  return CatalogueMetadataService(cloudflareClient: client);
}
