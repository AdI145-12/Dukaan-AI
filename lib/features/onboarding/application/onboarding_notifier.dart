import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const Object _stateUnset = Object();

final NotifierProvider<OnboardingNotifier, OnboardingState>
    onboardingNotifierProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  /// Updates the shop name captured during onboarding.
  void updateShopName(String value) {
    state = state.copyWith(shopName: value, error: null);
  }

  /// Updates the selected business category captured during onboarding.
  void updateCategory(String value) {
    state = state.copyWith(category: value, error: null);
  }

  /// Updates the city captured during onboarding.
  void updateCity(String value) {
    state = state.copyWith(city: value, error: null);
  }

  /// Sends OTP to the provided Indian phone number.
  Future<void> sendOtp(String phoneNumber) async {
    final String normalized = _normalizePhone(phoneNumber);
    if (normalized.length != 10) {
      state = state.copyWith(
        isLoading: false,
        error: AppStrings.authInvalidPhone,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      otpVerified: false,
      autoVerified: false,
    );

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91$normalized',
        timeout: const Duration(seconds: 60),
        forceResendingToken: state.resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            state = state.copyWith(
              isLoading: false,
              otpSent: true,
              otpVerified: true,
              autoVerified: true,
              error: null,
            );
          } on FirebaseAuthException catch (error) {
            state = state.copyWith(
              isLoading: false,
              error: _mapAuthError(error.code),
            );
          }
        },
        verificationFailed: (FirebaseAuthException error) {
          state = state.copyWith(
            isLoading: false,
            error: _mapAuthError(error.code),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          state = state.copyWith(
            isLoading: false,
            otpSent: true,
            verificationId: verificationId,
            resendToken: resendToken,
            error: null,
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          state = state.copyWith(verificationId: verificationId);
        },
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: AppStrings.errorGeneric,
      );
    }
  }

  /// Verifies user-entered OTP and signs the user in.
  Future<void> verifyOtp(String otp) async {
    final String? verificationId = state.verificationId;
    if (verificationId == null || verificationId.isEmpty) {
      state = state.copyWith(error: AppStrings.authSessionExpired);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      state = state.copyWith(
        isLoading: false,
        otpVerified: true,
        error: null,
      );
    } on FirebaseAuthException catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: _mapAuthError(error.code),
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: AppStrings.errorGeneric,
      );
    }
  }

  /// Saves the merchant profile in Firestore after successful authentication.
  Future<void> saveShopProfile({
    required String shopName,
    required String category,
    required String city,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      final String? uid = user?.uid;
      if (uid == null || uid.isEmpty) {
        throw Exception('User not authenticated');
      }

      await FirebaseService.db.collection('users').doc(uid).set(<String, dynamic>{
        'shopName': shopName,
        'category': category,
        'city': city,
        'whatsappNumber': user?.phoneNumber ?? '',
        'tier': 'free',
        'creditsRemaining': 5,
        'createdAt': FirebaseService.serverTimestamp(),
        'updatedAt': FirebaseService.serverTimestamp(),
      });

      state = state.copyWith(
        isLoading: false,
        profileSaved: true,
        error: null,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: AppStrings.profileSaveFailed,
      );
    }
  }

  /// Triggers OTP resend flow for the same number.
  Future<void> resendOtp(String phoneNumber) {
    return sendOtp(phoneNumber);
  }

  /// Clears the visible onboarding error.
  void clearError() {
    state = state.copyWith(error: null);
  }

  String _normalizePhone(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return AppStrings.authInvalidPhone;
      case 'invalid-verification-code':
        return AppStrings.authInvalidOtp;
      case 'session-expired':
        return AppStrings.authSessionExpired;
      case 'too-many-requests':
        return AppStrings.authTooManyRequests;
      default:
        return AppStrings.errorGeneric;
    }
  }
}

class OnboardingState {
  const OnboardingState({
    this.isLoading = false,
    this.otpSent = false,
    this.otpVerified = false,
    this.autoVerified = false,
    this.profileSaved = false,
    this.verificationId,
    this.resendToken,
    this.error,
    this.shopName = '',
    this.category = '',
    this.city = '',
  });

  final bool isLoading;
  final bool otpSent;
  final bool otpVerified;
  final bool autoVerified;
  final bool profileSaved;
  final String? verificationId;
  final int? resendToken;
  final String? error;
  final String shopName;
  final String category;
  final String city;

  /// Whether setup form has the mandatory fields.
  bool get isFormValid => shopName.trim().isNotEmpty && category.isNotEmpty;

  /// Returns a new state with selected fields replaced.
  OnboardingState copyWith({
    bool? isLoading,
    bool? otpSent,
    bool? otpVerified,
    bool? autoVerified,
    bool? profileSaved,
    Object? verificationId = _stateUnset,
    Object? resendToken = _stateUnset,
    Object? error = _stateUnset,
    String? shopName,
    String? category,
    String? city,
  }) {
    return OnboardingState(
      isLoading: isLoading ?? this.isLoading,
      otpSent: otpSent ?? this.otpSent,
      otpVerified: otpVerified ?? this.otpVerified,
      autoVerified: autoVerified ?? this.autoVerified,
      profileSaved: profileSaved ?? this.profileSaved,
      verificationId: verificationId == _stateUnset
          ? this.verificationId
          : verificationId as String?,
      resendToken: resendToken == _stateUnset
          ? this.resendToken
          : resendToken as int?,
      error: error == _stateUnset ? this.error : error as String?,
      shopName: shopName ?? this.shopName,
      category: category ?? this.category,
      city: city ?? this.city,
    );
  }
}
