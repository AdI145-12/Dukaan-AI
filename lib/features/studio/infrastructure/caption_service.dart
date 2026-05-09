import 'package:dukaan_ai/core/network/cloudflare_client.dart';
import 'package:dukaan_ai/features/studio/domain/generated_caption.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'caption_service.g.dart';

class CaptionService {
  const CaptionService({required this.cloudflareClient});

  final CloudflareClient cloudflareClient;

  /// Calls POST /api/generate-caption.
  /// productName is optional and language defaults to hinglish.
  Future<GeneratedCaption> generateCaption({
    required String userId,
    String productName = '',
    String category = 'general',
    String language = 'hinglish',
    String? offer,
  }) async {
    final Map<String, dynamic> data = await cloudflareClient.post(
      endpoint: '/api/generate-caption',
      body: <String, dynamic>{
        'productName': productName,
        'category': category,
        'language': language,
        if (offer != null && offer.isNotEmpty) 'offer': offer,
      },
      userId: userId,
    );

    return GeneratedCaption(
      caption: data['caption'] as String? ?? '',
      hashtags: (data['hashtags'] as List<dynamic>?)
              ?.map((dynamic e) => e.toString())
              .toList() ??
          <String>[],
      language: data['language'] as String? ?? language,
    );
  }
}

@riverpod
CaptionService captionService(Ref ref) {
  final CloudflareClient client = ref.watch(cloudflareClientProvider);
  return CaptionService(cloudflareClient: client);
}