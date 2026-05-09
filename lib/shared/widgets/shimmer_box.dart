import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Animated shimmer skeleton for loading states.
/// ALWAYS use this instead of empty white space during loading.
class ShimmerBox extends StatelessWidget {
	const ShimmerBox({
		super.key,
		required this.width,
		required this.height,
		this.borderRadius = AppRadius.button,
	});

	final double width;
	final double height;
	final double borderRadius;

	@override
	Widget build(BuildContext context) {
		final bool disableAnimations =
				MediaQuery.maybeOf(context)?.disableAnimations ?? false;

		final Widget staticBox = Container(
			key: const Key('shimmer_box_container'),
			width: width,
			height: height,
			decoration: BoxDecoration(
				color: AppColors.divider,
				borderRadius: BorderRadius.circular(borderRadius),
			),
		);

		if (disableAnimations) {
			return staticBox;
		}

		return RepaintBoundary(
			child: Shimmer.fromColors(
				baseColor: AppColors.divider,
				highlightColor: AppColors.surface,
				child: staticBox,
			),
		);
	}
}