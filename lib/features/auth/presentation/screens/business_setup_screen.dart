import 'package:dukaan_ai/core/constants/app_routes.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/auth/application/auth_provider.dart';
import 'package:dukaan_ai/shared/widgets/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Simple business setup screen for new Google users.
class BusinessSetupScreen extends ConsumerStatefulWidget {
	const BusinessSetupScreen({super.key});

	@override
	ConsumerState<BusinessSetupScreen> createState() => _BusinessSetupScreenState();
}

class _BusinessSetupScreenState extends ConsumerState<BusinessSetupScreen> {
	late final TextEditingController _shopNameController;
	late final TextEditingController _categoryController;
	late final TextEditingController _cityController;
	bool _isSaving = false;

	@override
	void initState() {
		super.initState();
		_shopNameController = TextEditingController();
		_categoryController = TextEditingController();
		_cityController = TextEditingController();
	}

	@override
	void dispose() {
		_shopNameController.dispose();
		_categoryController.dispose();
		_cityController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: AppColors.surface,
			appBar: AppBar(
				title: const Text(AppStrings.shopSetupTitle),
				backgroundColor: AppColors.surface,
				elevation: 0,
				leading: IconButton(
					onPressed: () => context.pop(),
					icon: const Icon(Icons.arrow_back_rounded),
				),
			),
			body: SingleChildScrollView(
				padding: const EdgeInsets.all(AppSpacing.lg),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: <Widget>[
						TextField(
							controller: _shopNameController,
							decoration: const InputDecoration(
								labelText: AppStrings.shopNameLabel,
								hintText: AppStrings.shopNameHint,
							),
						),
						const SizedBox(height: AppSpacing.md),
						TextField(
							controller: _categoryController,
							decoration: const InputDecoration(
								labelText: AppStrings.categoryLabel,
								hintText: AppStrings.categoryHint,
							),
						),
						const SizedBox(height: AppSpacing.md),
						TextField(
							controller: _cityController,
							decoration: const InputDecoration(
								labelText: AppStrings.cityLabel,
								hintText: AppStrings.cityHint,
							),
						),
						const SizedBox(height: AppSpacing.lg),
						SizedBox(
							width: double.infinity,
							height: 52,
							child: ElevatedButton(
								onPressed: _isSaving ? null : _saveProfile,
								style: ElevatedButton.styleFrom(
									backgroundColor: AppColors.primary,
									foregroundColor: AppColors.surface,
									shape: const StadiumBorder(),
								),
								child: _isSaving
									? const SizedBox(
										width: 20,
										height: 20,
										child: CircularProgressIndicator(
											strokeWidth: 2,
											color: AppColors.surface,
										),
									)
									: Text(
										AppStrings.nextButton,
										style: AppTypography.labelLarge.copyWith(color: AppColors.surface),
									),
							),
						),
					],
				),
			),
		);
	}

	Future<void> _saveProfile() async {
		final String userId = FirebaseService.currentUserId ?? '';
		if (userId.isEmpty) {
			AppSnackBar.showError(context, AppStrings.errorAuth);
			return;
		}

		setState(() => _isSaving = true);
		try {
			await FirebaseService.db.collection('profiles').doc(userId).set(
				<String, dynamic>{
					'email': FirebaseService.auth.currentUser?.email,
					'displayName': FirebaseService.auth.currentUser?.displayName,
					'photoUrl': FirebaseService.auth.currentUser?.photoURL,
					'shopName': _shopNameController.text.trim(),
					'category': _categoryController.text.trim(),
					'city': _cityController.text.trim(),
					'onboardingComplete': true,
				},
				SetOptions(merge: true),
			);
			ref.invalidate(googleAuthProvider);
			if (mounted) {
				context.go(AppRoutes.studio);
			}
		} catch (error) {
			if (mounted) {
				AppSnackBar.showError(context, error.toString());
			}
		} finally {
			if (mounted) {
				setState(() => _isSaving = false);
			}
		}
	}
}// Screen 2: shop name + category input