import 'package:dukaan_ai/core/constants/app_routes.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/onboarding/application/onboarding_notifier.dart';
import 'package:dukaan_ai/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ShopSetupScreen extends ConsumerStatefulWidget {
  const ShopSetupScreen({super.key});

  @override
  ConsumerState<ShopSetupScreen> createState() => _ShopSetupScreenState();
}

class _ShopSetupScreenState extends ConsumerState<ShopSetupScreen> {
  late final TextEditingController _shopNameController;
  late final TextEditingController _cityController;

  @override
  void initState() {
    super.initState();
    final OnboardingState state = ref.read(onboardingNotifierProvider);
    _shopNameController = TextEditingController(text: state.shopName);
    _cityController = TextEditingController(text: state.city);
    _shopNameController.addListener(_onShopNameChanged);
    _cityController.addListener(_onCityChanged);
  }

  @override
  void dispose() {
    _shopNameController.removeListener(_onShopNameChanged);
    _cityController.removeListener(_onCityChanged);
    _shopNameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _onShopNameChanged() {
    ref.read(onboardingNotifierProvider.notifier).updateShopName(
          _shopNameController.text,
        );
  }

  void _onCityChanged() {
    ref.read(onboardingNotifierProvider.notifier).updateCity(_cityController.text);
  }

  @override
  Widget build(BuildContext context) {
    final OnboardingState state = ref.watch(onboardingNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          AppStrings.shopSetupTitle,
          style: AppTypography.headlineMedium,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: AppSpacing.md),
            const _OnboardingDots(currentIndex: 1, total: 3),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              AppStrings.shopNameLabel,
              style: AppTypography.labelLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _shopNameController,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                hintText: AppStrings.shopNameHint,
              ),
            ),
            const SizedBox(height: AppSpacing.md + AppSpacing.xs),
            const Text(
              AppStrings.categoryLabel,
              style: AppTypography.labelLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: state.category.isEmpty ? null : state.category,
              decoration: _inputDecoration(hintText: AppStrings.categoryHint),
              hint: const Text(AppStrings.categoryHint),
              items: AppStrings.onboardingCategories
                  .map(
                    (String category) => DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (String? value) {
                ref
                    .read(onboardingNotifierProvider.notifier)
                    .updateCategory(value ?? '');
              },
            ),
            const SizedBox(height: AppSpacing.md + AppSpacing.xs),
            const Text(
              AppStrings.cityLabel,
              style: AppTypography.labelLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _cityController,
              textInputAction: TextInputAction.done,
              decoration: _inputDecoration(
                hintText: AppStrings.cityHint,
              ),
            ),
            if (state.error != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(
                state.error!,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: AppStrings.nextButton,
              onPressed: state.isFormValid
                  ? () => context.push(AppRoutes.onboardingPhone)
                  : null,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.button),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.button),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}

class _OnboardingDots extends StatelessWidget {
  const _OnboardingDots({
    required this.currentIndex,
    required this.total,
  });

  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(total, (int index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          width: index == currentIndex ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == currentIndex ? AppColors.primary : AppColors.divider,
            borderRadius: BorderRadius.circular(AppSpacing.xs),
          ),
        );
      }),
    );
  }
}
