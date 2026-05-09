import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_shadows.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/core/utils/upi_utils.dart';
import 'package:dukaan_ai/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AppIndexes {
  const AppIndexes._();

  static const int first = 0;
  static const int second = 1;
}

class UpiPosterScreen extends StatefulWidget {
  const UpiPosterScreen({super.key});

  @override
  State<UpiPosterScreen> createState() => _UpiPosterScreenState();
}

class _UpiPosterScreenState extends State<UpiPosterScreen> {
  final GlobalKey _posterKey = GlobalKey();
  late final TextEditingController _upiIdController;
  late final TextEditingController _shopNameController;
  int _selectedStyle = AppIndexes.first;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _upiIdController = TextEditingController();
    _shopNameController = TextEditingController();
  }

  @override
  void dispose() {
    _upiIdController.dispose();
    _shopNameController.dispose();
    super.dispose();
  }

  void _downloadPoster() {}

  void _sharePoster() {
    if (_isGenerating) {
      return;
    }
    setState(() => _isGenerating = true);
    setState(() => _isGenerating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          AppStrings.upiPosterTitle,
          style: AppTypography.headlineLarge,
        ),
        backgroundColor: AppColors.cardSurface,
        elevation: AppSpacing.none,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const _StepLabel(
                    step: AppStrings.stepOne,
                    label: AppStrings.upiInfoStep,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      boxShadow: AppShadows.card,
                    ),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: <Widget>[
                        AppTextField(
                          label: AppStrings.upiId,
                          controller: _upiIdController,
                          hint: AppStrings.upiIdHint,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppTextField(
                          label: AppStrings.shopName,
                          controller: _shopNameController,
                          hint: AppStrings.shopNameHint,
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _StepLabel(
                    step: AppStrings.stepTwo,
                    label: AppStrings.choosePosterStyle,
                  ),
                  PosterStyleSelector(
                    selectedStyle: _selectedStyle,
                    onChanged: (int value) {
                      setState(() => _selectedStyle = value);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _StepLabel(
                    step: AppStrings.stepThree,
                    label: AppStrings.posterPreview,
                  ),
                  RepaintBoundary(
                    key: _posterKey,
                    child: PosterPreview(
                      shopName: _shopNameController.text,
                      upiId: _upiIdController.text,
                      selectedStyle: _selectedStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.cardSurface,
              border: Border(
                top: BorderSide(color: AppColors.divider),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _downloadPoster,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(
                          Icons.download_outlined,
                          color: AppColors.primary,
                          size: AppSpacing.iconSm,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          AppStrings.downloadPoster,
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    label: AppStrings.sharePoster,
                    onPressed: _sharePoster,
                    isLoading: _isGenerating,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepLabel extends StatelessWidget {
  const _StepLabel({
    required this.step,
    required this.label,
  });

  final String step;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: AppSpacing.step,
            height: AppSpacing.step,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              step,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class PosterStyleSelector extends StatelessWidget {
  const PosterStyleSelector({
    super.key,
    required this.selectedStyle,
    required this.onChanged,
  });

  final int selectedStyle;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _StyleOption(
            index: AppIndexes.first,
            selectedStyle: selectedStyle,
            label: AppStrings.subscriptionPlanDukaan,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StyleOption(
            index: AppIndexes.second,
            selectedStyle: selectedStyle,
            label: AppStrings.subscriptionPlanUtsav,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _StyleOption extends StatelessWidget {
  const _StyleOption({
    required this.index,
    required this.selectedStyle,
    required this.label,
    required this.onChanged,
  });

  final int index;
  final int selectedStyle;
  final String label;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedStyle == index;
    return InkWell(
      onTap: () => onChanged(index),
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppShadows.card,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class PosterPreview extends StatelessWidget {
  const PosterPreview({
    super.key,
    required this.shopName,
    required this.upiId,
    required this.selectedStyle,
  });

  final String shopName;
  final String upiId;
  final int selectedStyle;

  @override
  Widget build(BuildContext context) {
    final String resolvedShopName =
        shopName.trim().isEmpty ? AppStrings.shopNameFallback : shopName.trim();
    final String resolvedUpiId =
        upiId.trim().isEmpty ? AppStrings.upiIdHint : upiId.trim();
    final String qrData = buildUpiPaymentUrl(
      upiId: resolvedUpiId,
      payeeName: resolvedShopName,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: selectedStyle == AppIndexes.first
            ? AppColors.cardSurface
            : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: <Widget>[
          Text(
            resolvedShopName,
            style: AppTypography.headlineLarge.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          QrImageView(
            data: qrData,
            size: AppSpacing.animationSuccess,
            backgroundColor: AppColors.surface,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            resolvedUpiId,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
        ),
      ],
    );
  }
}
