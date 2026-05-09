import 'dart:convert';
import 'dart:io';

import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/errors/app_exception.dart';
import 'package:dukaan_ai/core/network/cloudflare_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://fallback.local'));
  });

  group('CloudflareClient.post', () {
    late MockHttpClient mockHttpClient;
    late CloudflareClient cloudflareClient;

    setUp(() {
      mockHttpClient = MockHttpClient();
      cloudflareClient = CloudflareClient(
        baseUrl: 'https://worker.example',
        client: mockHttpClient,
      );
    });

    test('post returns data map on 200 response', () async {
      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          jsonEncode(<String, dynamic>{
            'success': true,
            'data': <String, dynamic>{'resultBase64': 'abc'},
          }),
          200,
        ),
      );

      final Map<String, dynamic> data = await cloudflareClient.post(
        endpoint: '/api/remove-bg',
        body: <String, dynamic>{'imageBase64': 'raw'},
        userId: 'user-1',
      );

      expect(data['resultBase64'], 'abc');
    });

    test('post throws AppException.workerRateLimit on 429', () async {
      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          jsonEncode(<String, dynamic>{
            'success': false,
            'error': AppStrings.errorRateLimit,
          }),
          429,
        ),
      );

      expect(
        () => cloudflareClient.post(
          endpoint: '/api/remove-bg',
          body: <String, dynamic>{'imageBase64': 'raw'},
          userId: 'user-1',
        ),
        throwsA(isA<WorkerRateLimitAppException>()),
      );
    });

    test('post throws AppException.workerError on 500', () async {
      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          jsonEncode(<String, dynamic>{
            'success': false,
            'error': AppStrings.errorGeneric,
          }),
          500,
        ),
      );

      expect(
        () => cloudflareClient.post(
          endpoint: '/api/remove-bg',
          body: <String, dynamic>{'imageBase64': 'raw'},
          userId: 'user-1',
        ),
        throwsA(isA<WorkerErrorAppException>()),
      );
    });

    test('post throws AppException.network on network failure', () async {
      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenThrow(const SocketException('No network'));

      expect(
        () => cloudflareClient.post(
          endpoint: '/api/remove-bg',
          body: <String, dynamic>{'imageBase64': 'raw'},
          userId: 'user-1',
        ),
        throwsA(isA<NetworkAppException>()),
      );
    });

    test('post no longer sends x-user-id header', () async {
      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          jsonEncode(<String, dynamic>{
            'success': true,
            'data': <String, dynamic>{},
          }),
          200,
        ),
      );

      await cloudflareClient.post(
        endpoint: '/api/remove-bg',
        body: <String, dynamic>{'imageBase64': 'raw'},
        userId: 'user-123',
      );

      final VerificationResult verification = verify(
        () => mockHttpClient.post(
          any(),
          headers: captureAny(named: 'headers'),
          body: any(named: 'body'),
        ),
      );
      verification.called(1);

      final Map<String, String> headers =
          verification.captured.single as Map<String, String>;
      expect(headers['x-user-id'], isNull);
    });
  });
}
