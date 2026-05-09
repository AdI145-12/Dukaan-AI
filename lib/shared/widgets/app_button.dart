import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, ghost }

/// The standard primary button for all Dukaan AI actions.
/// Use this instead of raw ElevatedButton everywhere.
class AppButton extends StatelessWidget {
	const AppButton({
		super.key,
		required this.label,
		required this.onPressed,
		this.isLoading = false,
		this.isFullWidth = true,
		this.variant = AppButtonVariant.primary,
	});

	final String label;
	final VoidCallback? onPressed;
	final bool isLoading;
	final bool isFullWidth;
	final AppButtonVariant variant;

	@override
	Widget build(BuildContext context) {
		final bool isEnabled = onPressed != null && !isLoading;
		final _ButtonColors colors = _resolveColors(isEnabled);

		final Widget button = SizedBox(
			height: AppSpacing.xxl,
			child: Material(
				color: Colors.transparent,
				child: InkWell(
					onTap: isEnabled ? onPressed : null,
					borderRadius: BorderRadius.circular(AppRadius.button),
					child: DecoratedBox(
						key: const Key('app_button_container'),
						decoration: BoxDecoration(
							color: colors.background,
							borderRadius: BorderRadius.circular(AppRadius.button),
							border: colors.border,
						),
						child: Padding(
							padding: const EdgeInsets.symmetric(
								horizontal: AppSpacing.lg,
								vertical: AppSpacing.sm,
							),
							child: Center(
								child: isLoading
										? SizedBox(
												width: AppSpacing.md,
												height: AppSpacing.md,
												child: CircularProgressIndicator(
													strokeWidth: AppSpacing.xs / 2,
													valueColor: AlwaysStoppedAnimation<Color>(
														colors.progress,
													),
												),
											)
										: Text(
												label,
												style: AppTypography.labelLarge.copyWith(
													color: colors.foreground,
												),
											),
							),
						),
					),
				),
			),
		);

		return SizedBox(
			key: const Key('app_button_width_box'),
			width: isFullWidth ? double.infinity : null,
			child: button,
		);
	}

	_ButtonColors _resolveColors(bool isEnabled) {
		final Color disabledOverlay = Colors.white.withValues(alpha: 0.5);

		switch (variant) {
			case AppButtonVariant.primary:
				return _ButtonColors(
					background: isEnabled
							? AppColors.primary
							: Color.alphaBlend(disabledOverlay, AppColors.primary),
					foreground: AppColors.surface,
					progress: AppColors.surface,
					border: null,
				);
			case AppButtonVariant.secondary:
				return _ButtonColors(
					background: Colors.transparent,
					foreground: isEnabled
							? AppColors.primary
							: AppColors.primary.withValues(alpha: 0.5),
					progress: isEnabled
							? AppColors.primary
							: AppColors.primary.withValues(alpha: 0.5),
					border: Border.all(
						color: isEnabled
								? AppColors.primary
								: AppColors.primary.withValues(alpha: 0.5),
					),
				);
			case AppButtonVariant.ghost:
				return _ButtonColors(
					background: Colors.transparent,
					foreground: isEnabled
							? AppColors.primary
							: AppColors.primary.withValues(alpha: 0.5),
					progress: isEnabled
							? AppColors.primary
							: AppColors.primary.withValues(alpha: 0.5),
					border: null,
				);
		}
	}
}

class _ButtonColors {
	const _ButtonColors({
		required this.background,
		required this.foreground,
		required this.progress,
		required this.border,
	});

	final Color background;
	final Color foreground;
	final Color progress;
	final BoxBorder? border;
}