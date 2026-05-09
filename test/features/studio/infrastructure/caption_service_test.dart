import 'package:dukaan_ai/core/errors/app_exception.dart';
import 'package:dukaan_ai/core/network/cloudflare_client.dart';
import 'package:dukaan_ai/features/studio/domain/generated_caption.dart';
import 'package:dukaan_ai/features/studio/infrastructure/caption_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCloudflareClient extends Mock implements CloudflareClient {}

void main() {
  late MockCloudflareClient mockClient;
  late CaptionService service;

  setUp(() {
    mockClient = MockCloudflareClient();
    service = CaptionService(cloudflareClient: mockClient);
  });

  group('CaptionService.generateCaption', () {
    test('returns GeneratedCaption with caption and hashtags on success', () async {
      // Arrange
      when(
        () => mockClient.post(
          endpoint: any(named: 'endpoint'),
          body: any(named: 'body'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer(
        (_) async => <String, dynamic>{
          'caption': 'Diwali sale amazing hai! 🪔',
          'hashtags': <String>['diwali', 'offer', 'sale', 'shopping', 'india'],
          'language': 'hinglish',
        },
      );

      // Act
      final GeneratedCaption result = await service.generateCaption(userId: 'u1');

      // Assert
      expect(result.caption, 'Diwali sale amazing hai! 🪔');
      expect(result.hashtags.length, 5);
      expect(result.language, 'hinglish');
    });

    test('fullText getter includes hashtags with # prefix', () {
      // Arrange
      const GeneratedCaption caption = GeneratedCaption(
        caption: 'Amazing!',
        hashtags: <String>['sale', 'diwali'],
        language: 'hinglish',
      );

      // Assert
      expect(caption.fullText, contains('#sale'));
      expect(caption.fullText, contains('#diwali'));
    });

    test('passes productName and category in request body', () async {
      // Arrange
      when(
        () => mockClient.post(
          endpoint: any(named: 'endpoint'),
          body: any(named: 'body'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer(
        (_) async => <String, dynamic>{
          'caption': 'Great caption',
          'hashtags': <String>['a', 'b', 'c', 'd', 'e'],
          'language': 'hinglish',
        },
      );

      // Act
      await service.generateCaption(
        userId: 'u1',
        productName: 'Silk Saree',
        category: 'saree',
      );

      // Assert
      final VerificationResult verification = verify(
        () => mockClient.post(
          endpoint: any(named: 'endpoint'),
          body: captureAny(named: 'body'),
          userId: any(named: 'userId'),
        ),
      );
      verification.called(1);

      final Map<String, dynamic> body =
          verification.captured.single as Map<String, dynamic>;
      expect(body['productName'], 'Silk Saree');
      expect(body['category'], 'saree');
    });

    test('omits offer from body when offer is null', () async {
      // Arrange
      when(
        () => mockClient.post(
          endpoint: any(named: 'endpoint'),
          body: any(named: 'body'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer(
        (_) async => <String, dynamic>{
          'caption': 'Great caption',
          'hashtags': <String>[],
          'language': 'hinglish',
        },
      );

      // Act
      await service.generateCaption(userId: 'u1', offer: null);

      // Assert
      final VerificationResult verification = verify(
        () => mockClient.post(
          endpoint: any(named: 'endpoint'),
          body: captureAny(named: 'body'),
          userId: any(named: 'userId'),
        ),
      );
      verification.called(1);

      final Map<String, dynamic> body =
          verification.captured.single as Map<String, dynamic>;
      expect(body.containsKey('offer'), false);
    });

    test('includes offer in body when provided', () async {
      // Arrange
      when(
        () => mockClient.post(
          endpoint: any(named: 'endpoint'),
          body: any(named: 'body'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer(
        (_) async => <String, dynamic>{
          'caption': 'Great caption',
          'hashtags': <String>[],
          'language': 'hinglish',
        },
      );

      // Act
      await service.generateCaption(userId: 'u1', offer: 'FLAT 50% OFF');

      // Assert
      final VerificationResult verification = verify(
        () => mockClient.post(
          endpoint: any(named: 'endpoint'),
          body: captureAny(named: 'body'),
          userId: any(named: 'userId'),
        ),
      );
      verification.called(1);

      final Map<String, dynamic> body =
          verification.captured.single as Map<String, dynamic>;
      expect(body['offer'], 'FLAT 50% OFF');
    });

    test('propagates AppException from cloudflareClient', () async {
      // Arrange
      when(
        () => mockClient.post(
          endpoint: any(named: 'endpoint'),
          body: any(named: 'body'),
          userId: any(named: 'userId'),
        ),
      ).thenThrow(const AppException.network('No internet'));

      // Act + Assert
      expect(
        () => service.generateCaption(userId: 'u1'),
        throwsA(isA<NetworkAppException>()),
      );
    });

    test('defaults language to hinglish in request body when not specified', () async {
      // Arrange
      when(
        () => mockClient.post(
          endpoint: any(named: 'endpoint'),
          body: any(named: 'body'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer(
        (_) async => <String, dynamic>{
          'caption': 'Great caption',
          'hashtags': <String>[],
          'language': 'hinglish',
        },
      );

      // Act
      await service.generateCaption(userId: 'u1');

      // Assert
      final VerificationResult verification = verify(
        () => mockClient.post(
          endpoint: any(named: 'endpoint'),
          body: captureAny(named: 'body'),
          userId: any(named: 'userId'),
        ),
      );
      verification.called(1);

      final Map<String, dynamic> body =
          verification.captured.single as Map<String, dynamic>;
      expect(body['language'], 'hinglish');
    });

    test('returns empty caption and hashtags when server returns empty values', () async {
      // Arrange
      when(
        () => mockClient.post(
          endpoint: any(named: 'endpoint'),
          body: any(named: 'body'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer(
        (_) async => <String, dynamic>{
          'caption': '',
          'hashtags': <String>[],
          'language': 'hinglish',
        },
      );

      // Act
      final GeneratedCaption result = await service.generateCaption(userId: 'u1');

      // Assert
      expect(result.caption, '');
      expect(result.hashtags.isEmpty, true);
    });
  });
}
