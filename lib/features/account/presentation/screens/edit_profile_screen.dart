import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_shadows.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _shopNameController;
  late final TextEditingController _ownerNameController;
  late final TextEditingController _cityController;
  late final TextEditingController _phoneController;
  String? _category;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _shopNameController = TextEditingController();
    _ownerNameController = TextEditingController();
    _cityController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _ownerNameController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_isSaving) {
      return;
    }
    setState(() => _isSaving = true);
    Navigator.of(context).maybePop();
  }

  void _pickShopPhoto() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          AppStrings.editProfile,
          style: AppTypography.headlineLarge,
        ),
        backgroundColor: AppColors.cardSurface,
        elevation: AppSpacing.none,
        actions: <Widget>[
          TextButton(
            onPressed: _saveProfile,
            child: Text(
              AppStrings.saveKaro,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Stack(
                children: <Widget>[
                  AvatarCircle(
                    name: _shopNameController.text,
                    imageUrl: null,
                    radius: AppSpacing.xxl,
                  ),
                  Positioned(
                    bottom: AppSpacing.none,
                    right: AppSpacing.none,
                    child: GestureDetector(
                      onTap: _pickShopPhoto,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.cardSurface,
                            width: AppSpacing.border,
                          ),
                        ),
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        child: const Icon(
                          Icons.camera_alt,
                          color: AppColors.surface,
                          size: AppSpacing.iconSm,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppStrings.shopInfo.toUpperCase(),
              style: AppTypography.sectionLabel.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                boxShadow: AppShadows.card,
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AppTextField(
                    label: AppStrings.shopName,
                    controller: _shopNameController,
                    hint: AppStrings.shopNameHint,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    label: AppStrings.ownerName,
                    controller: _ownerNameController,
                    hint: AppStrings.ownerNameHint,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: _inputDecoration(AppStrings.categoryHint),
                    hint: const Text(AppStrings.categoryHint),
                    items: AppStrings.onboardingCategories
                        .map(
                          (String category) => DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                    onChanged: (String? value) {
                      setState(() => _category = value);
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    label: AppStrings.city,
                    controller: _cityController,
                    hint: AppStrings.cityHint,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    label: AppStrings.whatsappNumber,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    hint: AppStrings.phoneHint,
                    prefix: Container(
                      width: AppSpacing.xxl,
                      height: AppSpacing.xxl,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(AppRadius.input),
                          bottomLeft: Radius.circular(AppRadius.input),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        AppStrings.phoneCountryCode,
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.surface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: AppStrings.saveKaro,
              onPressed: _saveProfile,
              isLoading: _isSaving,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
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
    );
  }
}

class AvatarCircle extends StatelessWidget {
  const AvatarCircle({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.radius,
  });

  final String name;
  final String? imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryLight,
      foregroundColor: AppColors.primary,
      backgroundImage: imageUrl == null ? null : NetworkImage(imageUrl!),
      child: imageUrl == null
          ? Text(
              name.trim().isEmpty ? AppStrings.shopNameFallback : name.trim(),
              style: AppTypography.headlineLarge.copyWith(
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            )
          : null,
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
    this.prefix,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final Widget? prefix;

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
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            prefixIcon: prefix,
            prefixIconConstraints: const BoxConstraints(
              minWidth: AppSpacing.xxl,
              minHeight: AppSpacing.xxl,
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
