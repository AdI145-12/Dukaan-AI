import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

// Three-segment language toggle. StatelessWidget - state in parent.
class CaptionLanguageSelector extends StatelessWidget {
  const CaptionLanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.onChanged,
  });

  final String selectedLanguage;
  final ValueChanged<String> onChanged;

  static const List<(String, String)> _options = <(String, String)>[
    ('hinglish', AppStrings.langHinglish),
    ('hindi', AppStrings.langHindi),
    ('english', AppStrings.langEnglish),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.chip),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Row(
          children: List<Widget>.generate(_options.length, (int index) {
            final (String id, String label) = _options[index];
            final bool isSelected = selectedLanguage == id;
            final bool isLast = index == _options.length - 1;

            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(id),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    border: isLast
                        ? null
                        : const Border(
                            right: BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: AppTypography.labelLarge.copyWith(
                      fontSize: 14,
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
