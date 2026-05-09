import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

enum AppSnackBarType { success, error, warning, info }

class AppSnackBar {
	const AppSnackBar._();

	static void show(
		BuildContext context, {
		required String message,
		AppSnackBarType type = AppSnackBarType.info,
	}) {
		final Color backgroundColor = switch (type) {
			AppSnackBarType.success => AppColors.success,
			AppSnackBarType.error => AppColors.error,
			AppSnackBarType.warning => AppColors.warning,
			AppSnackBarType.info => AppColors.textPrimary,
		};

		final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
		messenger.hideCurrentSnackBar();
		messenger.showSnackBar(
			SnackBar(
				content: Text(
					message,
					style: AppTypography.bodyMedium.copyWith(color: AppColors.surface),
				),
				backgroundColor: backgroundColor,
				behavior: SnackBarBehavior.floating,
			),
		);
	}
}