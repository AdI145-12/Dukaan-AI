import 'dart:async';

import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/errors/app_exception.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/core/network/cloudflare_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

sealed class PaymentResult {
  const PaymentResult();

  const factory PaymentResult.success({required String transactionId}) =
      PaymentSuccess;
  const factory PaymentResult.failure({required String message}) =
      PaymentFailure;
  const factory PaymentResult.cancelled() = PaymentCancelled;
}

final class PaymentSuccess extends PaymentResult {
  const PaymentSuccess({required this.transactionId});

  final String transactionId;
}

final class PaymentFailure extends PaymentResult {
  const PaymentFailure({required this.message});

  final String message;
}

final class PaymentCancelled extends PaymentResult {
  const PaymentCancelled();
}

class PaymentService {
  PaymentService({required CloudflareClient cloudflareClient})
      : _cloudflareClient = cloudflareClient;

  final CloudflareClient _cloudflareClient;

  /// Starts payment flow for a plan/pack and returns final payment status.
  Future<PaymentResult> initiatePayment({
    required String planId,
    required int amountPaise,
    required String userId,
  }) async {
    if (userId.trim().isEmpty) {
      return const PaymentResult.failure(
        message: AppStrings.errorAuth,
      );
    }

    if (amountPaise == 0) {
      try {
        await _updateTierInFirestore(
          userId: userId,
          planId: planId,
          creditsAdded: 5,
        );
        return const PaymentResult.success(transactionId: 'free');
      } on AppException catch (error) {
        return PaymentResult.failure(message: error.userMessage);
      } catch (_) {
        return const PaymentResult.failure(
          message: AppStrings.errorGeneric,
        );
      }
    }

    try {
      final Map<String, dynamic> orderResponse = await _cloudflareClient.post(
        endpoint: '/api/create-order',
        body: <String, dynamic>{
          'planId': planId,
          'amountPaise': amountPaise,
          'userId': userId,
        },
        userId: userId,
      );

      final String orderId = orderResponse['orderId'] as String? ?? '';
      if (orderId.isEmpty) {
        return const PaymentResult.failure(
          message: AppStrings.paymentOrderCreateFailed,
        );
      }

      return _openCheckout(
        amountPaise: amountPaise,
        orderId: orderId,
        planId: planId,
        userId: userId,
      );
    } on AppException catch (error) {
      return PaymentResult.failure(message: error.userMessage);
    } catch (_) {
      return const PaymentResult.failure(
        message: AppStrings.paymentSupportMessage,
      );
    }
  }

  Future<PaymentResult> _openCheckout({
    required int amountPaise,
    required String orderId,
    required String planId,
    required String userId,
  }) {
    final Razorpay razorpay = Razorpay();
    final Completer<PaymentResult> completer = Completer<PaymentResult>();

    void complete(PaymentResult result) {
      if (!completer.isCompleted) {
        completer.complete(result);
      }
      razorpay.clear();
    }

    razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      (Object? payload) async {
        final PaymentSuccessResponse response =
            payload as PaymentSuccessResponse;

        try {
          final Map<String, dynamic> verifyResponse = await _cloudflareClient.post(
            endpoint: '/api/verify-payment',
            body: <String, dynamic>{
              'razorpayPaymentId': response.paymentId,
              'razorpayOrderId': response.orderId,
              'razorpaySignature': response.signature,
              'userId': userId,
              'planId': planId,
            },
            userId: userId,
          );

          final bool isSuccess = verifyResponse['success'] as bool? ?? false;
          if (!isSuccess) {
            complete(
              const PaymentResult.failure(
                message: AppStrings.paymentVerifyFailed,
              ),
            );
            return;
          }

          complete(
            PaymentResult.success(
              transactionId: response.paymentId ?? '',
            ),
          );
        } catch (_) {
          complete(
            const PaymentResult.failure(
              message: AppStrings.paymentSupportMessage,
            ),
          );
        }
      },
    );

    razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      (Object? payload) {
        final PaymentFailureResponse response = payload as PaymentFailureResponse;
        complete(
          PaymentResult.failure(
            message: _razorpayErrorMessage(response.code),
          ),
        );
      },
    );

    razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      (Object? _) {
        complete(const PaymentResult.cancelled());
      },
    );

    try {
      razorpay.open(<String, Object>{
        'key': const String.fromEnvironment('RAZORPAY_KEY_ID'),
        'amount': amountPaise,
        'order_id': orderId,
        'name': AppStrings.appName,
        'description': planId,
        'prefill': <String, String>{
          'contact': FirebaseService.currentUserPhone ?? '',
          'email': '',
          'name': '',
        },
        'theme': <String, String>{'color': '#FF6F00'},
        'method': <String, bool>{
          'upi': true,
          'card': true,
          'netbanking': true,
          'wallet': true,
        },
      });
    } catch (_) {
      complete(
        const PaymentResult.failure(
          message: AppStrings.paymentSetupIssue,
        ),
      );
    }

    return completer.future;
  }

  /// Maps Razorpay error codes to user-friendly Hinglish copy.
  String _razorpayErrorMessage(int? code) {
    return switch (code) {
      Razorpay.NETWORK_ERROR => AppStrings.errorNetwork,
      Razorpay.INVALID_OPTIONS => AppStrings.paymentSetupIssue,
      Razorpay.PAYMENT_CANCELLED => AppStrings.paymentCancelled,
      _ => AppStrings.paymentRetryFailed,
    };
  }

  Future<void> _updateTierInFirestore({
    required String userId,
    required String planId,
    required int creditsAdded,
  }) async {
    try {
      await FirebaseService.db.collection('users').doc(userId).set(
        <String, dynamic>{
          'tier': planId,
          'creditsRemaining': creditsAdded,
        },
        <String, dynamic>{'merge': true},
      );
    } catch (_) {
      throw const AppException.firebase('Tier update nahi hua. Dobara try karein.');
    }
  }
}

final Provider<PaymentService> paymentServiceProvider = Provider<PaymentService>(
  (Ref ref) {
    return PaymentService(
      cloudflareClient: ref.watch(cloudflareClientProvider),
    );
  },
);
