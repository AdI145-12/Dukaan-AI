import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_shadows.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Standard bottom sheet wrapper. Use showModalBottomSheet
/// with this widget as content for ALL bottom sheets in the app.
class AppBottomSheet extends StatelessWidget {
	const AppBottomSheet({
		super.key,
		required this.title,
		required this.child,
		this.showDragHandle = true,
	});

	final String title;
	final Widget child;
	final bool showDragHandle;

	static Future<T?> show<T>({
		required BuildContext context,
		required String title,
		required Widget child,
		bool isDismissible = true,
	}) {
		return showModalBottomSheet<T>(
			context: context,
			isScrollControlled: true,
			isDismissible: isDismissible,
			backgroundColor: Colors.transparent,
			builder: (_) => AppBottomSheet(title: title, child: child),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Container(
			decoration: const BoxDecoration(
				color: AppColors.surface,
				borderRadius: BorderRadius.only(
					topLeft: Radius.circular(AppRadius.sheet),
					topRight: Radius.circular(AppRadius.sheet),
				),
				boxShadow: AppShadows.elevated,
			),
			child: Column(
				mainAxisSize: MainAxisSize.min,
				children: <Widget>[
					if (showDragHandle)
						Container(
							margin: const EdgeInsets.only(top: AppSpacing.sm),
							width: AppSpacing.xl + AppSpacing.sm,
							height: AppSpacing.xs,
							decoration: BoxDecoration(
								color: AppColors.divider,
								borderRadius: BorderRadius.circular(AppSpacing.xs / 2),
							),
						),
					Padding(
						padding: const EdgeInsets.symmetric(
							horizontal: AppSpacing.md,
							vertical: AppSpacing.sm,
						),
						child: Text(
							title,
							style: AppTypography.headlineMedium,
						),
					),
					const Divider(color: AppColors.divider, height: 1),
					Padding(
						padding: const EdgeInsets.all(AppSpacing.md),
						child: child,
					),
					SizedBox(height: MediaQuery.of(context).padding.bottom),
				],
			),
		);
	}
}