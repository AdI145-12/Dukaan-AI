import 'dart:async';

import 'package:dukaan_ai/core/constants/app_routes.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/shared/widgets/app_bottom_sheet.dart';
import 'package:dukaan_ai/shared/widgets/app_button.dart';
import 'package:dukaan_ai/shared/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

typedef ReadUserId = Future<String?> Function();
typedef ReadUserDoc = Future<Map<String, dynamic>?> Function(String userId);
typedef DecrementCredits = Future<void> Function(String userId);
typedef UiCallback = void Function(BuildContext context);

class CreditGuard {
  CreditGuard({
    AsyncMutex? mutex,
    ReadUserId? readUserId,
    ReadUserDoc? readUserDoc,
    DecrementCredits? decrementCredits,
    UiCallback? showUpgradeSheet,
    UiCallback? showLastCreditWarning,
  })  : _mutex = mutex ?? AsyncMutex(),
        _readUserId = readUserId ?? _defaultReadUserId,
        _readUserDoc = readUserDoc ?? _defaultReadUserDoc,
        _decrementCredits = decrementCredits ?? _defaultDecrementCredits,
        _showUpgradeSheet = showUpgradeSheet ?? _defaultShowUpgradeSheet,
        _showLastCreditWarning =
            showLastCreditWarning ?? _defaultShowLastCreditWarning;

  final AsyncMutex _mutex;
  final ReadUserId _readUserId;
  final ReadUserDoc _readUserDoc;
  final DecrementCredits _decrementCredits;
  final UiCallback _showUpgradeSheet;
  final UiCallback _showLastCreditWarning;

  /// Checks and consumes one generation credit when available.
  Future<bool> canGenerate(BuildContext context) {
    return _mutex.protect(() async {
      final String? userId = await _readUserId();
      if (userId == null || userId.isEmpty) {
        return false;
      }

      final Map<String, dynamic>? data = await _readUserDoc(userId);
      if (data == null) {
        return false;
      }

      final String tier = data['tier'] as String? ?? 'free';
      final int credits = (data['creditsRemaining'] as num?)?.toInt() ?? 0;

      if (tier == 'utsav' || tier == 'utsav_monthly') {
        return true;
      }

      if (credits <= 0) {
        if (context.mounted) {
          _showUpgradeSheet(context);
        }
        return false;
      }

      if (credits == 1 && context.mounted) {
        _showLastCreditWarning(context);
      }

      await _decrementCredits(userId);
      return true;
    });
  }

  static Future<String?> _defaultReadUserId() async {
    return FirebaseService.currentUserId;
  }

  static Future<Map<String, dynamic>?> _defaultReadUserDoc(
      String userId) async {
    final dynamic doc =
        await FirebaseService.db.collection('users').doc(userId).get();
    final bool exists = doc.exists as bool? ?? false;
    if (!exists) {
      return null;
    }

    final dynamic raw = doc.data();
    if (raw is Map<String, dynamic>) {
      return raw;
    }

    if (raw is Map<Object?, Object?>) {
      return raw.map<String, dynamic>(
        (Object? key, Object? value) => MapEntry(key.toString(), value),
      );
    }

    return null;
  }

  static Future<void> _defaultDecrementCredits(String userId) async {
    final Map<String, dynamic>? latest = await _defaultReadUserDoc(userId);
    final int current = (latest?['creditsRemaining'] as num?)?.toInt() ?? 0;
    final int next = current > 0 ? current - 1 : 0;

    await FirebaseService.db
        .collection('users')
        .doc(userId)
        .update(<String, dynamic>{
      'creditsRemaining': next,
    });
  }

  static void _defaultShowLastCreditWarning(BuildContext context) {
    AppSnackBar.show(
      context,
      message: AppStrings.creditsLastOne,
      type: AppSnackBarType.warning,
    );
  }

  static void _defaultShowUpgradeSheet(BuildContext context) {
    AppBottomSheet.show<void>(
      context: context,
      title: AppStrings.creditsExhausted,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.lock_outline,
            size: AppSpacing.xxl,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            AppStrings.creditsExhaustedBody,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: AppStrings.creditsBuyPack,
            onPressed: () {
              Navigator.of(context).pop();
              context.push(AppRoutes.subscription);
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: AppStrings.creditsGetPlan,
            variant: AppButtonVariant.secondary,
            onPressed: () {
              Navigator.of(context).pop();
              context.push(AppRoutes.subscription);
            },
          ),
        ],
      ),
    );
  }
}

final Provider<CreditGuard> creditGuardProvider = Provider<CreditGuard>(
  (Ref ref) {
    return CreditGuard();
  },
);

class AsyncMutex {
  Future<void> _pending = Future<void>.value();

  Future<T> protect<T>(Future<T> Function() action) {
    final Completer<T> completer = Completer<T>();

    _pending = _pending.then((_) async {
      try {
        final T value = await action();
        completer.complete(value);
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });

    return completer.future;
  }
}
