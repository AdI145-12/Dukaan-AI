import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Section title row with an optional action on the right.
class SectionHeader extends StatelessWidget {
  /// Creates a new section header.
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = AppTypography.labelSmall.copyWith(
      color: AppColors.textSecondary,
      letterSpacing: 0.8,
    );
    final TextStyle actionStyle = AppTypography.labelLarge.copyWith(
      color: AppColors.primary,
    );

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: titleStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            child: Text(
              '$actionLabel →',
              style: actionStyle,
            ),
          ),
      ],
    );
  }
}
