import 'dart:typed_data';

import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/errors/app_exception.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/core/network/cloudflare_client.dart';
import 'package:dukaan_ai/features/studio/domain/ad_creation_request.dart';
import 'package:dukaan_ai/features/studio/domain/generated_ad.dart';
import 'package:dukaan_ai/features/studio/domain/studio_repository.dart';
import 'package:dukaan_ai/features/studio/application/studio_provider.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
// ignore: depend_on_referenced_packages
import 'package:uuid/uuid.dart';

part 'ad_generation_service.g.dart';

typedef UploadBinaryHandler = Future<void> Function(
  String path,
  Uint8List bytes,
);

class AdGenerationService {
  AdGenerationService({
    required this.cloudflareClient,
    required this.studioRepository,
    http.Client? httpClient,
    UploadBinaryHandler? uploadBinary,
  })  : _httpClient = httpClient ?? http.Client(),
        _uploadBinary = uploadBinary;

  final CloudflareClient cloudflareClient;
  final StudioRepository studioRepository;

  final http.Client _httpClient;
  final UploadBinaryHandler? _uploadBinary;

  /// Generates a background, uploads result, stores metadata and returns ad.
  Future<GeneratedAd> generateAd(AdCreationRequest request) async {
    final Map<String, dynamic> data = await cloudflareClient.post(
      endpoint: '/api/generate-background',
      body: <String, dynamic>{
        'productBase64': request.processedImageBase64,
        'style': request.backgroundStyleId,
        if (request.customPrompt != null && request.customPrompt!.isNotEmpty)
          'customPrompt': request.customPrompt!,
      },
      userId: request.userId,
    );

    final String resultUrl = data['resultUrl'] as String? ?? '';
    if (resultUrl.isEmpty) {
      throw const AppException.workerError(AppStrings.errorGeneric);
    }

    final Uint8List imageBytes = await _downloadImage(resultUrl);
    final String storagePath = '${request.userId}/${const Uuid().v4()}.jpg';
    final String imageUrl = await _uploadToStorage(storagePath, imageBytes);

    return studioRepository.saveGeneratedAd(
      userId: request.userId,
      storagePath: imageUrl,
      backgroundStyle: request.backgroundStyleId,
    );
  }

  Future<Uint8List> _downloadImage(String url) async {
    try {
      final http.Response response =
          await _httpClient.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) {
        throw const AppException.network(AppStrings.errorImageDownload);
      }
      return response.bodyBytes;
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException.network(AppStrings.errorNetwork);
    }
  }

  Future<String> _uploadToStorage(String path, Uint8List bytes) async {
    if (_uploadBinary != null) {
      await _uploadBinary(path, bytes);
      return path;
    }

    try {
      final dynamic ref = FirebaseService.store.ref().child('ad-images/$path');
      await ref.putData(
        bytes,
        <String, Object>{'contentType': 'image/jpeg'},
      );
      final dynamic downloadUrl = await ref.getDownloadURL();
      if (downloadUrl is String && downloadUrl.isNotEmpty) {
        return downloadUrl;
      }
      return path;
    } on Exception catch (error) {
      String fallback = AppStrings.errorUploadFailed;
      try {
        final dynamic message = (error as dynamic).message;
        if (message is String && message.isNotEmpty) {
          fallback = message;
        }
      } catch (_) {
        // Keep fallback.
      }
      throw AppException.firebase(fallback);
    }
  }
}

@riverpod
AdGenerationService adGenerationService(Ref ref) {
  final CloudflareClient client = ref.watch(cloudflareClientProvider);
  final StudioRepository repo = ref.watch(studioRepositoryProvider);
  return AdGenerationService(
    cloudflareClient: client,
    studioRepository: repo,
  );
}
