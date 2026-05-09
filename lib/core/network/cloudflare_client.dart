import 'dart:async';
import 'dart:convert';

import 'package:dukaan_ai/core/config/app_config.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/errors/app_exception.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cloudflare_client.g.dart';

class CloudflareClient {
  CloudflareClient({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  /// GET from [endpoint], optionally authenticated using Firebase ID token.
  /// Returns the `data` field from Worker success response.
  /// Throws [AppException] for Worker and network failures.
  Future<Map<String, dynamic>> get({
    required String endpoint,
    bool withAuth = true,
  }) async {
    try {
      final String? idToken =
          withAuth ? await FirebaseService.currentIdToken() : null;

      final http.Response response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
      ).timeout(const Duration(seconds: 30));

      final Map<String, dynamic> json = _decodeJsonObject(response.body);

      if (response.statusCode == 429) {
        throw AppException.workerRateLimit(
          json['error'] as String? ?? AppStrings.errorRateLimit,
        );
      }

      if (response.statusCode >= 500) {
        throw AppException.workerError(
          json['error'] as String? ?? AppStrings.errorGeneric,
        );
      }

      if (response.statusCode >= 400) {
        throw AppException.workerError(
          json['error'] as String? ?? AppStrings.errorGeneric,
        );
      }

      return json['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException.network(AppStrings.errorNetwork);
    }
  }

  /// POST to [endpoint] with [body], authenticated using Firebase ID token.
  /// Returns the `data` field from Worker success response.
  /// Throws [AppException] for Worker and network failures.
  Future<Map<String, dynamic>> post({
    required String endpoint,
    required Map<String, dynamic> body,
    required String userId,
  }) async {
    try {
      final String? idToken = await FirebaseService.currentIdToken();

      final http.Response response = await _client
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: <String, String>{
              'Content-Type': 'application/json',
              if (idToken != null) 'Authorization': 'Bearer $idToken',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      final Map<String, dynamic> json = _decodeJsonObject(response.body);

      if (response.statusCode == 429) {
        throw AppException.workerRateLimit(
          json['error'] as String? ?? AppStrings.errorRateLimit,
        );
      }

      if (response.statusCode >= 500) {
        throw AppException.workerError(
          json['error'] as String? ?? AppStrings.errorGeneric,
        );
      }

      if (response.statusCode >= 400) {
        throw AppException.workerError(
          json['error'] as String? ?? AppStrings.errorGeneric,
        );
      }

      return json['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException.network(AppStrings.errorNetwork);
    }
  }

  Map<String, dynamic> _decodeJsonObject(String responseBody) {
    if (responseBody.isEmpty) {
      return <String, dynamic>{};
    }

    final Object? decoded = jsonDecode(responseBody);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{};
  }
}

@riverpod
CloudflareClient cloudflareClient(Ref ref) {
  return CloudflareClient(baseUrl: AppConfig.workerBaseUrl);
}
