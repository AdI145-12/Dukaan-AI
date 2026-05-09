import 'package:dukaan_ai/core/errors/app_exception.dart';
import 'package:dukaan_ai/core/network/cloudflare_client.dart';
import 'package:dukaan_ai/features/studio/infrastructure/background_removal_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCloudflareClient extends Mock implements CloudflareClient {}

void main() {
  group('BackgroundRemovalService.removeBackground', () {
    late MockCloudflareClient mockCloudflareClient;
    late BackgroundRemovalService service;

    setUp(() {
      mockCloudflareClient = MockCloudflareClient();
      service = BackgroundRemovalService(client: mockCloudflareClient);
    });

    test('calls POST /api/remove-bg and returns resultBase64', () async {
      when(
        () => mockCloudflareClient.post(
          endpoint: '/api/remove-bg',
          body: <String, dynamic>{'imageBase64': 'raw-base64'},
          userId: 'user-1',
        ),
      ).thenAnswer(
        (_) async => <String, dynamic>{'resultBase64': 'processed-base64'},
      );

      final String result = await service.removeBackground(
        base64Image: 'raw-base64',
        userId: 'user-1',
      );

      expect(result, 'processed-base64');
      verify(
        () => mockCloudflareClient.post(
          endpoint: '/api/remove-bg',
          body: <String, dynamic>{'imageBase64': 'raw-base64'},
          userId: 'user-1',
        ),
      ).called(1);
    });

    test('propagates AppException.workerRateLimit from client', () async {
      when(
        () => mockCloudflareClient.post(
          endpoint: any(named: 'endpoint'),
          body: any(named: 'body'),
          userId: any(named: 'userId'),
        ),
      ).thenThrow(
        const AppException.workerRateLimit('Rate limit reached'),
      );

      expect(
        () => service.removeBackground(
          base64Image: 'raw-base64',
          userId: 'user-1',
        ),
        throwsA(isA<WorkerRateLimitAppException>()),
      );
    });

    test('propagates AppException.workerError from client', () async {
      when(
        () => mockCloudflareClient.post(
          endpoint: any(named: 'endpoint'),
          body: any(named: 'body'),
          userId: any(named: 'userId'),
        ),
      ).thenThrow(
        const AppException.workerError('Worker failed'),
      );

      expect(
        () => service.removeBackground(
          base64Image: 'raw-base64',
          userId: 'user-1',
        ),
        throwsA(isA<WorkerErrorAppException>()),
      );
    });
  });
}
