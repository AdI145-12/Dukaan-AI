import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dukaan_ai/core/network/cloudflare_client.dart';

part 'background_removal_service.g.dart';

class BackgroundRemovalService {
  const BackgroundRemovalService({required this.client});

  final CloudflareClient client;

  /// Sends [base64Image] to the background removal API.
  /// Returns the processed image as a base64 string.
  Future<String> removeBackground({
    required String base64Image,
    required String userId,
  }) async {
    final Map<String, dynamic> data = await client.post(
      endpoint: '/api/remove-bg',
      body: <String, dynamic>{'imageBase64': base64Image},
      userId: userId,
    );

    return data['resultBase64'] as String;
  }
}

@riverpod
BackgroundRemovalService backgroundRemovalService(Ref ref) {
  final CloudflareClient client = ref.watch(cloudflareClientProvider);
  return BackgroundRemovalService(client: client);
}
