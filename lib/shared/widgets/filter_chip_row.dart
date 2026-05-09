import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Horizontally scrollable chip selector built with custom containers.
class FilterChipRow extends StatelessWidget {
  /// Creates a new filter chip row.
  const FilterChipRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int index = 0; index < options.length; index++) ...<Widget>[
            _buildChip(options[index]),
            if (index != options.length - 1)
              const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(String option) {
    final bool isSelected = option == selected;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onSelected(option),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: isSelected
              ? null
              : Border.all(color: AppColors.primary, width: 1),
        ),
        child: Text(
          option,
          style: AppTypography.labelLarge.copyWith(
            color: isSelected ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
