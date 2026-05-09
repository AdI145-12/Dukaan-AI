import 'dart:typed_data';

import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/errors/app_exception.dart';
import 'package:dukaan_ai/core/network/cloudflare_client.dart';
import 'package:dukaan_ai/features/studio/domain/ad_creation_request.dart';
import 'package:dukaan_ai/features/studio/domain/generated_ad.dart';
import 'package:dukaan_ai/features/studio/domain/studio_repository.dart';
import 'package:dukaan_ai/features/studio/infrastructure/ad_generation_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockCloudflareClient extends Mock implements CloudflareClient {}

class MockStudioRepository extends Mock implements StudioRepository {}

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockCloudflareClient mockCloudflareClient;
  late MockStudioRepository mockStudioRepository;
  late MockHttpClient mockHttpClient;
  late AdGenerationService service;

  final GeneratedAd testAd = GeneratedAd(
    id: 'ad-001',
    userId: 'user-1',
    imageUrl: 'https://supabase.example/signed-url.jpg',
    backgroundStyle: 'diwali',
    shareCount: 0,
    downloadCount: 0,
    createdAt: DateTime(2026, 4, 5),
  );

  const AdCreationRequest testRequest = AdCreationRequest(
    processedImageBase64: 'base64-image',
    backgroundStyleId: 'diwali',
    userId: 'user-1',
    customPrompt: 'blue marble',
  );

  setUpAll(() {
    registerFallbackValue(
      const AdCreationRequest(
        processedImageBase64: 'base64',
        backgroundStyleId: 'white',
        userId: 'user-1',
      ),
    );
    registerFallbackValue(Uri.parse('https://fallback.example/image.jpg'));
  });

  setUp(() {
    mockCloudflareClient = MockCloudflareClient();
    mockStudioRepository = MockStudioRepository();
    mockHttpClient = MockHttpClient();

    service = AdGenerationService(
      cloudflareClient: mockCloudflareClient,
      studioRepository: mockStudioRepository,
      httpClient: mockHttpClient,
      uploadBinary: (_, __) async {},
    );
  });

  group('AdGenerationService', () {
    test('generateAd calls POST /api/generate-background with style body', () async {
      when(
        () => mockCloudflareClient.post(
          endpoint: any(named: 'endpoint'),
          body: any(named: 'body'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer(
        (_) async => <String, dynamic>{
          'resultUrl': 'https://replicate.delivery/img.jpg',
        },
      );
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response.bytes(Uint8List.fromList(<int>[1, 2, 3]), 200),
      );
      when(
        () => mockStudioRepository.saveGeneratedAd(
          userId: any(named: 'userId'),
          storagePath: any(named: 'storagePath'),
          backgroundStyle: any(named: 'backgroundStyle'),
        ),
      ).thenAnswer((_) async => testAd);

      await service.generateAd(testRequest);

      final VerificationResult verification = verify(
        () => mockCloudflareClient.post(
          endpoint: captureAny(named: 'endpoint'),
          body: captureAny(named: 'body'),
          userId: captureAny(named: 'userId'),
        ),
      );
      verification.called(1);

      expect(verification.captured[0], '/api/generate-background');
      final Map<String, dynamic> body =
          verification.captured[1] as Map<String, dynamic>;
      expect(body.containsKey('style'), isTrue);
    });

    test('generateAd returns GeneratedAd on success', () async {
      when(
        () => mockCloudflareClient.post(
          endpoint: any(named: 'endpoint'),
          body: any(named: 'body'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer(
        (_) async => <String, dynamic>{
          'resultUrl': 'https://replicate.delivery/img.jpg',
        },
      );
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response.bytes(Uint8List.fromList(<int>[4, 5]), 200),
      );
      when(
        () => mockStudioRepository.saveGeneratedAd(
          userId: any(named: 'userId'),
          storagePath: any(named: 'storagePath'),
          backgroundStyle: any(named: 'backgroundStyle'),
        ),
      ).thenAnswer((_) async => testAd);

      final GeneratedAd result = await service.generateAd(testRequest);

      expect(result.id, testAd.id);
      expect(result.imageUrl, testAd.imageUrl);
    });

    test('generateAd propagates workerRateLimit from cloudflareClient', () async {
      when(
        () => mockCloudflareClient.post(
          endpoint: any(named: 'endpoint'),
          body: any(named: 'body'),
          userId: any(named: 'userId'),
        ),
      ).thenThrow(const AppException.workerRateLimit('rate limit'));

      expect(
        () => service.generateAd(testRequest),
        throwsA(isA<WorkerRateLimitAppException>()),
      );

      verifyNever(
        () => mockStudioRepository.saveGeneratedAd(
          userId: any(named: 'userId'),
          storagePath: any(named: 'storagePath'),
          backgroundStyle: any(named: 'backgroundStyle'),
        ),
      );
    });

    test('generateAd throws network error when download response is non-200', () async {
      when(
        () => mockCloudflareClient.post(
          endpoint: any(named: 'endpoint'),
          body: any(named: 'body'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer(
        (_) async => <String, dynamic>{
          'resultUrl': 'https://replicate.delivery/img.jpg',
        },
      );
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('error', 500),
      );

      expect(
        () => service.generateAd(testRequest),
        throwsA(isA<NetworkAppException>()),
      );

      verifyNever(
        () => mockStudioRepository.saveGeneratedAd(
          userId: any(named: 'userId'),
          storagePath: any(named: 'storagePath'),
          backgroundStyle: any(named: 'backgroundStyle'),
        ),
      );
    });

    test('generateAd passes customPrompt when provided', () async {
      when(
        () => mockCloudflareClient.post(
          endpoint: any(named: 'endpoint'),
          body: any(named: 'body'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer(
        (_) async => <String, dynamic>{
          'resultUrl': 'https://replicate.delivery/img.jpg',
        },
      );
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response.bytes(Uint8List.fromList(<int>[1, 2, 3]), 200),
      );
      when(
        () => mockStudioRepository.saveGeneratedAd(
          userId: any(named: 'userId'),
          storagePath: any(named: 'storagePath'),
          backgroundStyle: any(named: 'backgroundStyle'),
        ),
      ).thenAnswer((_) async => testAd);

      await service.generateAd(testRequest);

      final VerificationResult verification = verify(
        () => mockCloudflareClient.post(
          endpoint: any(named: 'endpoint'),
          body: captureAny(named: 'body'),
          userId: any(named: 'userId'),
        ),
      );
      verification.called(1);

      final Map<String, dynamic> body =
          verification.captured.first as Map<String, dynamic>;
      expect(body['customPrompt'], 'blue marble');
    });

    test('generateAd omits customPrompt when null', () async {
      const AdCreationRequest requestWithoutPrompt = AdCreationRequest(
        processedImageBase64: 'base64-image',
        backgroundStyleId: 'diwali',
        userId: 'user-1',
      );

      when(
        () => mockCloudflareClient.post(
          endpoint: any(named: 'endpoint'),
          body: any(named: 'body'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer(
        (_) async => <String, dynamic>{
          'resultUrl': 'https://replicate.delivery/img.jpg',
        },
      );
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response.bytes(Uint8List.fromList(<int>[1]), 200),
      );
      when(
        () => mockStudioRepository.saveGeneratedAd(
          userId: any(named: 'userId'),
          storagePath: any(named: 'storagePath'),
          backgroundStyle: any(named: 'backgroundStyle'),
        ),
      ).thenAnswer((_) async => testAd);

      await service.generateAd(requestWithoutPrompt);

      final VerificationResult verification = verify(
        () => mockCloudflareClient.post(
          endpoint: any(named: 'endpoint'),
          body: captureAny(named: 'body'),
          userId: any(named: 'userId'),
        ),
      );
      verification.called(1);

      final Map<String, dynamic> body =
          verification.captured.first as Map<String, dynamic>;
      expect(body.containsKey('customPrompt'), isFalse);
    });

    test('generateAd passes storagePath with user prefix and jpg suffix', () async {
      when(
        () => mockCloudflareClient.post(
          endpoint: any(named: 'endpoint'),
          body: any(named: 'body'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer(
        (_) async => <String, dynamic>{
          'resultUrl': 'https://replicate.delivery/img.jpg',
        },
      );
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response.bytes(Uint8List.fromList(<int>[7, 8]), 200),
      );
      when(
        () => mockStudioRepository.saveGeneratedAd(
          userId: any(named: 'userId'),
          storagePath: any(named: 'storagePath'),
          backgroundStyle: any(named: 'backgroundStyle'),
        ),
      ).thenAnswer((_) async => testAd);

      await service.generateAd(testRequest);

      final VerificationResult verification = verify(
        () => mockStudioRepository.saveGeneratedAd(
          userId: captureAny(named: 'userId'),
          storagePath: captureAny(named: 'storagePath'),
          backgroundStyle: captureAny(named: 'backgroundStyle'),
        ),
      );
      verification.called(1);

      final String capturedUser = verification.captured[0] as String;
      final String storagePath = verification.captured[1] as String;
      expect(storagePath.startsWith('$capturedUser/'), isTrue);
      expect(storagePath.endsWith('.jpg'), isTrue);
    });
  });

  test('errorImageDownload string remains available for network failure messaging', () {
    expect(AppStrings.errorImageDownload, isNotEmpty);
  });
}
