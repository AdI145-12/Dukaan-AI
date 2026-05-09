import 'dart:convert';
import 'dart:typed_data';

import 'package:dukaan_ai/core/constants/app_routes.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/studio/application/background_select_provider.dart';
import 'package:dukaan_ai/features/studio/application/background_select_state.dart';
import 'package:dukaan_ai/features/studio/domain/ad_preview_args.dart';
import 'package:dukaan_ai/features/studio/domain/background_style.dart';
import 'package:dukaan_ai/features/studio/presentation/widgets/background_style_card.dart';
import 'package:dukaan_ai/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BackgroundSelectScreen extends ConsumerStatefulWidget {
	const BackgroundSelectScreen({super.key});

	@override
	ConsumerState<BackgroundSelectScreen> createState() =>
			_BackgroundSelectScreenState();
}

class _BackgroundSelectScreenState extends ConsumerState<BackgroundSelectScreen> {
	late final TextEditingController _promptController;
	late String _processedBase64;
	late Uint8List _previewBytes;
	bool _didReadExtra = false;

	@override
	void initState() {
		super.initState();
		_promptController = TextEditingController();
		_processedBase64 = '';
		_previewBytes = Uint8List(0);
	}

	@override
	void didChangeDependencies() {
		super.didChangeDependencies();
		if (_didReadExtra) {
			return;
		}

		final Object? extra = GoRouterState.of(context).extra;
		if (extra is String) {
			_processedBase64 = extra;
			_previewBytes = _decodeBase64Sync(extra);
		}

		_didReadExtra = true;
	}

	@override
	void dispose() {
		_promptController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		final BackgroundSelectState state = ref.watch(backgroundSelectProvider);

		ref.listen<BackgroundSelectState>(backgroundSelectProvider, (
			BackgroundSelectState? previous,
			BackgroundSelectState next,
		) {
			if (next.error != null && next.error != previous?.error) {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(
						content: Text(next.error!),
						backgroundColor: AppColors.error,
					),
				);
			}

			if (next.generatedAd != null && previous?.generatedAd == null) {
				if (context.mounted) {
					context.push(
						AppRoutes.adPreview,
						extra: AdPreviewArgs(
							generatedAd: next.generatedAd!,
							processedBase64: _processedBase64,
							backgroundStyleId:
									BackgroundStyle.all[next.selectedStyleIndex!].id,
							customPrompt: next.customPrompt.isEmpty ? null : next.customPrompt,
						),
					);
				}
			}
		});

		return Scaffold(
			backgroundColor: AppColors.background,
			appBar: AppBar(
				backgroundColor: AppColors.surface,
				elevation: 0,
				title: const Text(
					AppStrings.selectBackgroundTitle,
					style: AppTypography.headlineMedium,
				),
				leading: IconButton(
					icon: const Icon(Icons.arrow_back),
					onPressed: () => context.pop(),
				),
			),
			body: CustomScrollView(
				slivers: <Widget>[
					SliverToBoxAdapter(
						child: Padding(
							padding: const EdgeInsets.all(AppSpacing.md),
							child: ClipRRect(
								borderRadius: BorderRadius.circular(AppRadius.card),
								child: _previewBytes.isNotEmpty
										? Image.memory(
												_previewBytes,
												height: 180,
												width: double.infinity,
												fit: BoxFit.contain,
											)
										: const SizedBox(height: 180),
							),
						),
					),
					const SliverPadding(
						padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
						sliver: SliverToBoxAdapter(
							child: Text(
								AppStrings.chooseBackgroundLabel,
								style: AppTypography.headlineLarge,
							),
						),
					),
					const SliverToBoxAdapter(
						child: SizedBox(height: AppSpacing.sm),
					),
					SliverPadding(
						padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
						sliver: SliverGrid(
							delegate: SliverChildBuilderDelegate(
								(BuildContext context, int index) {
									return BackgroundStyleCard(
										style: BackgroundStyle.all[index],
										isSelected: state.selectedStyleIndex == index,
										onTap: () => ref
												.read(backgroundSelectProvider.notifier)
												.selectStyle(index),
									);
								},
								childCount: BackgroundStyle.all.length,
							),
							gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
								crossAxisCount: 2,
								mainAxisSpacing: AppSpacing.sm,
								crossAxisSpacing: AppSpacing.sm,
								childAspectRatio: 1.2,
							),
						),
					),
					SliverPadding(
						padding: const EdgeInsets.all(AppSpacing.md),
						sliver: SliverToBoxAdapter(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: <Widget>[
									const Text(
										AppStrings.customPromptLabel,
										style: AppTypography.labelLarge,
									),
									const SizedBox(height: AppSpacing.sm),
									TextField(
										controller: _promptController,
										onChanged: ref.read(backgroundSelectProvider.notifier).updatePrompt,
										maxLines: 2,
										maxLength: 100,
										style: AppTypography.bodyMedium,
										decoration: InputDecoration(
											hintText: AppStrings.customPromptHint,
											hintStyle: AppTypography.bodyMedium.copyWith(
												color: AppColors.textHint,
											),
											border: OutlineInputBorder(
												borderRadius: BorderRadius.circular(AppRadius.button),
												borderSide: const BorderSide(color: AppColors.divider),
											),
											focusedBorder: OutlineInputBorder(
												borderRadius: BorderRadius.circular(AppRadius.button),
												borderSide: const BorderSide(
													color: AppColors.primary,
													width: 2,
												),
											),
											filled: true,
											fillColor: AppColors.surface,
											contentPadding: const EdgeInsets.all(AppSpacing.md),
										),
									),
								],
							),
						),
					),
					const SliverToBoxAdapter(
						child: SizedBox(height: 96),
					),
				],
			),
			bottomNavigationBar: SafeArea(
				child: Padding(
					padding: const EdgeInsets.all(AppSpacing.md),
					child: AppButton(
						label: AppStrings.generateAdButton,
						isLoading: state.isGenerating,
						onPressed: state.selectedStyleIndex == null
								? null
								: () => ref
										.read(backgroundSelectProvider.notifier)
										.generateAd(processedBase64: _processedBase64),
					),
				),
			),
		);
	}
}

Uint8List _decodeBase64Sync(String base64Str) {
	try {
		return base64Decode(base64Str);
	} catch (_) {
		return Uint8List(0);
	}
}