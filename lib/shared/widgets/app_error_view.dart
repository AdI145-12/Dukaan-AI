import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';

class AppErrorView extends StatelessWidget {
	const AppErrorView({
		super.key,
		required this.message,
		required this.onRetry,
	});

	final String message;
	final VoidCallback onRetry;

	@override
	Widget build(BuildContext context) {
		return Center(
			child: Padding(
				padding: const EdgeInsets.all(AppSpacing.md),
				child: Column(
					mainAxisSize: MainAxisSize.min,
					children: <Widget>[
						const Icon(
							Icons.error_outline_rounded,
							color: AppColors.error,
							size: AppSpacing.xl,
						),
						const SizedBox(height: AppSpacing.sm),
						Text(
							message,
							style: AppTypography.bodyMedium.copyWith(
								color: AppColors.textSecondary,
							),
							textAlign: TextAlign.center,
						),
						const SizedBox(height: AppSpacing.md),
						AppButton(
							label: AppStrings.retry,
							onPressed: onRetry,
							isFullWidth: false,
						),
					],
				),
			),
		);
	}
}