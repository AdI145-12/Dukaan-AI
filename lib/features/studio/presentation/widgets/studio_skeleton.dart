import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/shared/widgets/shimmer_box.dart';
import 'package:flutter/material.dart';

class StudioSkeleton extends StatelessWidget {
  const StudioSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const ShimmerBox(width: 200, height: 24),
            const SizedBox(height: AppSpacing.xs),
            const ShimmerBox(width: 140, height: 16),
            const SizedBox(height: AppSpacing.lg),
            const ShimmerBox(width: 100, height: 16),
            const SizedBox(height: AppSpacing.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List<Widget>.generate(4, (int index) {
                  return const Padding(
                    padding: EdgeInsets.only(right: AppSpacing.sm),
                    child: ShimmerBox(
                      width: 80,
                      height: 90,
                      borderRadius: AppRadius.card,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const ShimmerBox(width: 100, height: 16),
            const SizedBox(height: AppSpacing.sm),
            ...List<Widget>.generate(3, (int index) {
              return const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: ShimmerBox(
                  width: double.infinity,
                  height: 88,
                  borderRadius: AppRadius.card,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
