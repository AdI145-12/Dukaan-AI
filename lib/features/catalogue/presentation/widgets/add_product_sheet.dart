import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dukaan_ai/core/constants/app_routes.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/errors/app_exception.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/catalogue/application/catalogue_provider.dart';
import 'package:dukaan_ai/features/catalogue/application/catalogue_state.dart';
import 'package:dukaan_ai/features/catalogue/domain/models/catalogue_product.dart';
import 'package:dukaan_ai/features/catalogue/domain/stock_status.dart';
import 'package:dukaan_ai/shared/widgets/app_button.dart';
import 'package:dukaan_ai/shared/widgets/app_snackbar.dart';
import 'package:dukaan_ai/shared/widgets/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class AddProductSheet extends ConsumerStatefulWidget {
  const AddProductSheet({
    super.key,
    this.initialProduct,
    this.prefillImageUrl,
    this.initialImageFile,
  });

  final CatalogueProduct? initialProduct;
  final String? prefillImageUrl;
  final XFile? initialImageFile;

  @override
  ConsumerState<AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends ConsumerState<AddProductSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _quantityCtrl = TextEditingController();
  final TextEditingController _sizeCtrl = TextEditingController();
  final TextEditingController _colorCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  final TextEditingController _tagsCtrl = TextEditingController();
  final TextEditingController _captionCtrl = TextEditingController();

  StockStatus _selectedStockStatus = StockStatus.inStock;

  final ValueNotifier<XFile?> _selectedImageNotifier = ValueNotifier<XFile?>(
    null,
  );
  final ValueNotifier<String?> _selectedCategoryNotifier =
      ValueNotifier<String?>(null);
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);

  final ImagePicker _picker = ImagePicker();

  Timer? _metadataDebounce;
  bool _descriptionTouched = false;
  bool _captionTouched = false;
  String? _prefillNetworkImageUrl;

  bool get _isEditMode => widget.initialProduct != null;

  @override
  void initState() {
    super.initState();

    if (widget.prefillImageUrl != null && widget.initialProduct == null) {
      final String normalized = widget.prefillImageUrl!.trim();
      if (normalized.isNotEmpty) {
        _prefillNetworkImageUrl = normalized;
      }
    }

    if (widget.initialImageFile != null) {
      _selectedImageNotifier.value = widget.initialImageFile;
    }

    final CatalogueProduct? initial = widget.initialProduct;
    if (initial != null) {
      _nameCtrl.text = initial.name;
      _priceCtrl.text = initial.price.toStringAsFixed(0);
      _quantityCtrl.text = initial.quantity?.toString() ?? '';
      _selectedStockStatus = initial.stockStatus;
      _selectedCategoryNotifier.value = initial.category;
      _descriptionCtrl.text = initial.description;
      _tagsCtrl.text = initial.tags.join(', ');
      _captionCtrl.text = initial.suggestedCaptions.isNotEmpty
          ? initial.suggestedCaptions.first
          : '';
      _sizeCtrl.text = initial.variants
          .where((CatalogueVariantGroup group) =>
              group.name.toLowerCase() == 'size')
          .expand((CatalogueVariantGroup group) => group.options)
          .join(', ');
      _colorCtrl.text = initial.variants
          .where((CatalogueVariantGroup group) =>
              group.name.toLowerCase() == 'color')
          .expand((CatalogueVariantGroup group) => group.options)
          .join(', ');
      _prefillNetworkImageUrl = initial.imageUrl;
      _descriptionTouched = true;
      _captionTouched = true;
    }

    _nameCtrl.addListener(_scheduleAutoMetadata);
    _descriptionCtrl.addListener(_markDescriptionTouched);
    _captionCtrl.addListener(_markCaptionTouched);
  }

  @override
  void dispose() {
    _metadataDebounce?.cancel();
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _quantityCtrl.dispose();
    _sizeCtrl.dispose();
    _colorCtrl.dispose();
    _descriptionCtrl.dispose();
    _tagsCtrl.dispose();
    _captionCtrl.dispose();
    _selectedImageNotifier.dispose();
    _selectedCategoryNotifier.dispose();
    _isSavingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CatalogueState>(catalogueComposerProvider, (
      CatalogueState? previous,
      CatalogueState next,
    ) {
      _syncMetadata(next);
      final String? nextError = next.errorMessage;
      if (nextError == null || nextError == previous?.errorMessage) {
        return;
      }
      AppSnackBar.show(
        context,
        message: nextError,
        type: AppSnackBarType.error,
      );
    });

    final CatalogueState composerState = ref.watch(catalogueComposerProvider);

    return ValueListenableBuilder<bool>(
      valueListenable: _isSavingNotifier,
      builder: (BuildContext context, bool isSaving, Widget? child) {
        final bool isSubmitting = isSaving || composerState.isSubmitting;

        return AnimatedPadding(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding:
              EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    _isEditMode
                        ? AppStrings.editProduct
                        : AppStrings.addProduct,
                    style: AppTypography.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildImageSelector(),
                  if (_isEditMode) ...<Widget>[
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      AppStrings.imageChanged,
                      style: AppTypography.labelSmall,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: AppStrings.catalogueNameLabel,
                      hintText: AppStrings.catalogueNameHint,
                    ),
                    validator: _validateName,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          controller: _priceCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: AppStrings.cataloguePriceLabel,
                            hintText: AppStrings.cataloguePriceHint,
                            prefixText: '₹ ',
                          ),
                          validator: _validatePrice,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    AppStrings.stockSectionLabel,
                    style: AppTypography.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: StockStatus.values
                        .map(
                          (StockStatus status) => ChoiceChip(
                            label: Text(StockStatusHelper.stockStatusLabel(status)),
                            selected: _selectedStockStatus == status,
                            selectedColor: _statusChipColor(status),
                            onSelected: (bool selected) {
                              if (!selected) {
                                return;
                              }
                              setState(() {
                                _selectedStockStatus = status;
                                if (status == StockStatus.outOfStock) {
                                  _quantityCtrl.clear();
                                }
                              });
                            },
                          ),
                        )
                        .toList(growable: false),
                  ),
                  if (_selectedStockStatus != StockStatus.outOfStock) ...<Widget>[
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _quantityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: AppStrings.stockQuantityLabel,
                        hintText: AppStrings.stockQuantityHint,
                      ),
                      validator: _validateQuantity,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  ValueListenableBuilder<String?>(
                    valueListenable: _selectedCategoryNotifier,
                    builder: (
                      BuildContext context,
                      String? selectedCategory,
                      Widget? child,
                    ) {
                      return DropdownButtonFormField<String>(
                        key: ValueKey<String?>(selectedCategory),
                        initialValue: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: AppStrings.catalogueCategoryLabel,
                        ),
                        items: AppStrings.onboardingCategories
                            .map(
                              (String category) => DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (String? value) {
                          _selectedCategoryNotifier.value = value;
                          _scheduleAutoMetadata();
                        },
                        validator: (String? value) {
                          if ((value ?? '').trim().isEmpty) {
                            return AppStrings.catalogueCategoryRequired;
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    AppStrings.catalogueVariantTitle,
                    style: AppTypography.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _sizeCtrl,
                    decoration: const InputDecoration(
                      labelText: AppStrings.catalogueVariantSize,
                      hintText: AppStrings.catalogueVariantHint,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _colorCtrl,
                    decoration: const InputDecoration(
                      labelText: AppStrings.catalogueVariantColor,
                      hintText: AppStrings.catalogueVariantHint,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    AppStrings.catalogueMetadataTitle,
                    style: AppTypography.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    AppStrings.catalogueAutoMetadataHint,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (composerState.isGeneratingMetadata)
                    const LinearProgressIndicator(minHeight: 2),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _descriptionCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: AppStrings.catalogueDescriptionLabel,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _tagsCtrl,
                    decoration: const InputDecoration(
                      labelText: AppStrings.catalogueTagsLabel,
                      hintText: AppStrings.catalogueVariantHint,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _captionCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: AppStrings.catalogueCaptionLabel,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: AppStrings.catalogueMetadataRegenerate,
                    variant: AppButtonVariant.secondary,
                    onPressed: composerState.isGeneratingMetadata
                        ? null
                        : () => _regenerateMetadata(force: true),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: _isEditMode
                        ? AppStrings.editProduct
                        : AppStrings.catalogueSaveButton,
                    isLoading: isSubmitting,
                    onPressed: isSubmitting ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSelector() {
    return ValueListenableBuilder<XFile?>(
      valueListenable: _selectedImageNotifier,
      builder: (BuildContext context, XFile? selectedImage, Widget? child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              AppStrings.catalogueImageLabel,
              style: AppTypography.labelLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: _buildImagePreview(selectedImage),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text(AppStrings.catalogueImageCamera),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text(AppStrings.catalogueImageGallery),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildImagePreview(XFile? selectedImage) {
    if (selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: Image.file(
          File(selectedImage.path),
          fit: BoxFit.cover,
        ),
      );
    }

    if (_prefillNetworkImageUrl != null &&
        _prefillNetworkImageUrl!.trim().isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: CachedNetworkImage(
          imageUrl: _prefillNetworkImageUrl!,
          fit: BoxFit.cover,
          placeholder: (BuildContext context, String _) {
            return const ShimmerBox(width: double.infinity, height: 160);
          },
          errorWidget: (
            BuildContext context,
            String _,
            Object error,
          ) {
            return const Center(
              child: Icon(Icons.image_not_supported_outlined),
            );
          },
        ),
      );
    }

    return const Center(
      child: Icon(
        Icons.add_photo_alternate_outlined,
        size: 40,
        color: AppColors.textSecondary,
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) {
        return;
      }
      _selectedImageNotifier.value = image;
      _prefillNetworkImageUrl = null;
      _scheduleAutoMetadata(force: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppSnackBar.show(
        context,
        message: AppStrings.cataloguePickImageFailed,
        type: AppSnackBarType.error,
      );
    }
  }

  void _scheduleAutoMetadata({bool force = false}) {
    final XFile? image = _selectedImageNotifier.value;
    final String name = _nameCtrl.text.trim();
    final String category = (_selectedCategoryNotifier.value ?? '').trim();
    if (image == null || name.isEmpty || category.isEmpty) {
      return;
    }

    _metadataDebounce?.cancel();
    _metadataDebounce = Timer(const Duration(milliseconds: 450), () {
      _regenerateMetadata(force: force);
    });
  }

  Future<void> _regenerateMetadata({required bool force}) async {
    final XFile? image = _selectedImageNotifier.value;
    final String category = (_selectedCategoryNotifier.value ?? '').trim();
    if (image == null) {
      AppSnackBar.show(
        context,
        message: AppStrings.catalogueNoImageSelected,
        type: AppSnackBarType.error,
      );
      return;
    }
    if (_nameCtrl.text.trim().isEmpty || category.isEmpty) {
      return;
    }

    await ref.read(catalogueComposerProvider.notifier).generateMetadata(
          imageFile: image,
          name: _nameCtrl.text.trim(),
          category: category,
          force: force,
        );
  }

  void _syncMetadata(CatalogueState state) {
    if (!_descriptionTouched && state.description.isNotEmpty) {
      _descriptionCtrl.text = state.description;
    }

    if (_tagsCtrl.text.trim().isEmpty && state.tags.isNotEmpty) {
      _tagsCtrl.text = state.tags.join(', ');
    }

    if (!_captionTouched && state.suggestedCaptions.isNotEmpty) {
      _captionCtrl.text = state.suggestedCaptions.first;
    }
  }

  void _markDescriptionTouched() {
    if (_descriptionCtrl.text.trim().isNotEmpty) {
      _descriptionTouched = true;
    }
  }

  void _markCaptionTouched() {
    if (_captionCtrl.text.trim().isNotEmpty) {
      _captionTouched = true;
    }
  }

  Future<void> _submit() async {
    if (_isSavingNotifier.value) {
      return;
    }

    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final bool hasSelectedImage = _selectedImageNotifier.value != null;
    final bool hasPrefillImageUrl =
        (_prefillNetworkImageUrl ?? '').trim().isNotEmpty;

    if (!_isEditMode && !hasSelectedImage && !hasPrefillImageUrl) {
      AppSnackBar.show(
        context,
        message: AppStrings.catalogueImageRequired,
        type: AppSnackBarType.error,
      );
      return;
    }

    final String category = (_selectedCategoryNotifier.value ?? '').trim();
    if (category.isEmpty) {
      AppSnackBar.show(
        context,
        message: AppStrings.catalogueCategoryRequired,
        type: AppSnackBarType.error,
      );
      return;
    }

    final List<String> tags = _splitCsv(_tagsCtrl.text);
    final List<String> captions = _splitCsv(_captionCtrl.text);
    final int? parsedQuantity = _selectedStockStatus == StockStatus.outOfStock
      ? null
      : _toQuantity(_quantityCtrl.text);

    ref.read(catalogueComposerProvider.notifier).applyManualMetadata(
          description: _descriptionCtrl.text,
          tags: tags,
          suggestedCaptions: captions,
        );

    _isSavingNotifier.value = true;
    try {
      if (_isEditMode) {
        final CatalogueProduct base = widget.initialProduct!;
        final CatalogueProduct updatedProduct = base.copyWith(
          name: _nameCtrl.text.trim(),
          price: double.parse(_priceCtrl.text.trim()),
          category: category,
          variants: _buildVariantGroups(),
          stockStatus: _selectedStockStatus,
          quantity: parsedQuantity,
          description: _descriptionCtrl.text.trim(),
          tags: tags,
          suggestedCaptions: captions,
          updatedAt: DateTime.now().toUtc(),
        );

        await ref.read(catalogueProvider.notifier).updateProduct(
              updatedProduct,
              newImagePath: _selectedImageNotifier.value?.path,
            );

        if (!mounted) {
          return;
        }

        final AsyncValue<List<CatalogueProduct>> state =
            ref.read(catalogueProvider);
        if (state.hasError && state.error != null) {
          AppSnackBar.show(
            context,
            message: _toErrorMessage(state.error!),
            type: AppSnackBarType.error,
          );
          return;
        }

        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        AppSnackBar.show(
          context,
          message: AppStrings.productUpdated,
          type: AppSnackBarType.success,
        );
        return;
      }

      final int productsBeforeCreate =
          ref.read(catalogueProvider).asData?.value.length ?? 0;
      final bool shouldPromptStoreSetup = productsBeforeCreate == 0;

      final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
      final GoRouter? router = GoRouter.maybeOf(context);

      final bool success = hasSelectedImage
          ? await ref.read(catalogueComposerProvider.notifier).createProduct(
                imageFile: _selectedImageNotifier.value!,
                name: _nameCtrl.text.trim(),
                category: category,
                price: double.parse(_priceCtrl.text.trim()),
                variants: _buildVariantGroups(),
                stockStatus: _selectedStockStatus,
                quantity: parsedQuantity,
                description: _descriptionCtrl.text.trim(),
                tags: tags,
                suggestedCaptions: captions,
              )
          : await ref
              .read(catalogueComposerProvider.notifier)
              .createProductWithImageUrl(
                imageUrl: _prefillNetworkImageUrl!,
                name: _nameCtrl.text.trim(),
                category: category,
                price: double.parse(_priceCtrl.text.trim()),
                variants: _buildVariantGroups(),
                stockStatus: _selectedStockStatus,
                quantity: parsedQuantity,
                description: _descriptionCtrl.text.trim(),
                tags: tags,
                suggestedCaptions: captions,
              );

      if (!mounted) {
        return;
      }

      if (!success) {
        final String error = ref.read(catalogueComposerProvider).errorMessage ??
            AppStrings.catalogueSaveFailed;
        AppSnackBar.show(
          context,
          message: error,
          type: AppSnackBarType.error,
        );
        return;
      }

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (shouldPromptStoreSetup) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: const Text(AppStrings.catalogueStoreNudgeMessage),
            action: SnackBarAction(
              label: AppStrings.catalogueStoreNudgeAction,
              onPressed: () {
                router?.push(AppRoutes.sellerStore);
              },
            ),
          ),
        );
        return;
      }

      AppSnackBar.show(
        context,
        message: AppStrings.catalogueSaveSuccess,
        type: AppSnackBarType.success,
      );
    } finally {
      _isSavingNotifier.value = false;
    }
  }

  List<CatalogueVariantGroup> _buildVariantGroups() {
    final List<CatalogueVariantGroup> groups = <CatalogueVariantGroup>[];
    final List<String> sizes = _splitCsv(_sizeCtrl.text);
    final List<String> colors = _splitCsv(_colorCtrl.text);

    if (sizes.isNotEmpty) {
      groups.add(
        CatalogueVariantGroup(name: 'Size', options: sizes),
      );
    }
    if (colors.isNotEmpty) {
      groups.add(
        CatalogueVariantGroup(name: 'Color', options: colors),
      );
    }

    return groups;
  }

  List<String> _splitCsv(String input) {
    final List<String> result = <String>[];
    for (final String item in input.split(',')) {
      final String value = item.trim();
      if (value.isEmpty || result.contains(value)) {
        continue;
      }
      result.add(value);
    }
    return result;
  }

  int? _toQuantity(String value) {
    final String cleaned = value.trim();
    if (cleaned.isEmpty) {
      return null;
    }
    return int.tryParse(cleaned);
  }

  String? _validateName(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return AppStrings.catalogueNameRequired;
    }
    return null;
  }

  String? _validatePrice(String? value) {
    final String cleaned = (value ?? '').trim();
    final double? parsed = double.tryParse(cleaned);
    if (parsed == null || parsed <= 0) {
      return AppStrings.cataloguePriceRequired;
    }
    return null;
  }

  String? _validateQuantity(String? value) {
    final String cleaned = (value ?? '').trim();
    if (cleaned.isEmpty) {
      return null;
    }
    final int? parsed = int.tryParse(cleaned);
    if (parsed == null || parsed < 0) {
      return AppStrings.amountInvalid;
    }
    return null;
  }

  Color _statusChipColor(StockStatus status) {
    switch (status) {
      case StockStatus.inStock:
        return AppColors.success.withAlpha(36);
      case StockStatus.lowStock:
        return AppColors.warning.withAlpha(46);
      case StockStatus.outOfStock:
        return AppColors.error.withAlpha(36);
    }
  }

  String _toErrorMessage(Object error) {
    if (error is AppException) {
      return error.userMessage;
    }
    return AppStrings.catalogueSaveFailed;
  }
}
