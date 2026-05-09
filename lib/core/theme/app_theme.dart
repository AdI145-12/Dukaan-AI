import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
	const AppTheme._();

	static ThemeData light() {
		return ThemeData(
			colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
			scaffoldBackgroundColor: AppColors.background,
			appBarTheme: const AppBarTheme(
				backgroundColor: AppColors.surface,
				elevation: 0,
				titleTextStyle: AppTypography.headlineLarge,
				foregroundColor: AppColors.textPrimary,
			),
			bottomNavigationBarTheme: const BottomNavigationBarThemeData(
				backgroundColor: AppColors.surface,
				selectedItemColor: AppColors.primary,
				unselectedItemColor: AppColors.textSecondary,
				selectedLabelStyle: AppTypography.labelSmall,
				unselectedLabelStyle: AppTypography.labelSmall,
				type: BottomNavigationBarType.fixed,
			),
			elevatedButtonTheme: ElevatedButtonThemeData(
				style: ElevatedButton.styleFrom(
					backgroundColor: AppColors.primary,
					foregroundColor: AppColors.surface,
					textStyle: AppTypography.labelLarge,
					minimumSize: const Size.fromHeight(AppSpacing.xxl),
					shape: RoundedRectangleBorder(
						borderRadius: BorderRadius.circular(AppRadius.button),
					),
				),
			),
			inputDecorationTheme: InputDecorationTheme(
				border: OutlineInputBorder(
					borderRadius: BorderRadius.circular(AppRadius.button),
				),
				enabledBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(AppRadius.button),
					borderSide: const BorderSide(color: AppColors.divider),
				),
				focusedBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(AppRadius.button),
					borderSide: const BorderSide(color: AppColors.primary),
				),
				filled: true,
				fillColor: AppColors.surface,
			),
			cardTheme: CardThemeData(
				color: AppColors.surface,
				elevation: 0,
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(AppRadius.card),
				),
			),
			useMaterial3: true,
			fontFamily: 'NotoSans',
		);
	}
}