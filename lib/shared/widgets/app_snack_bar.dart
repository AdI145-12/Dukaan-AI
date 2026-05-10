import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Standard app snack-bar helpers.
class AppSnackBar {
	const AppSnackBar._();

	/// Shows an error snack-bar with a consistent Dukaan AI style.
	static void showError(BuildContext context, String message) {
		ScaffoldMessenger.of(context)
			..hideCurrentSnackBar()
			..showSnackBar(
				SnackBar(
					content: Text(message),
					backgroundColor: AppColors.error,
					behavior: SnackBarBehavior.floating,
				),
			);
	}
}