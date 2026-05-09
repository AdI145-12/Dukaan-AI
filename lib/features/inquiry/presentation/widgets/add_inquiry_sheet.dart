import 'package:cached_network_image/cached_network_image.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/providers/firebase_providers.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/catalogue/application/catalogue_provider.dart';
import 'package:dukaan_ai/features/catalogue/domain/models/catalogue_product.dart';
import 'package:dukaan_ai/features/inquiry/application/inquiry_provider.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry_source.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry_status.dart';
import 'package:dukaan_ai/features/inquiry/presentation/widgets/inquiry_status_chip.dart';
import 'package:dukaan_ai/shared/widgets/app_button.dart';
import 'package:dukaan_ai/shared/widgets/app_snackbar.dart';
import 'package:dukaan_ai/shared/widgets/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddInquirySheet extends ConsumerStatefulWidget {
  const AddInquirySheet({
    super.key,
    this.initialInquiry,
    this.prefillProduct,
  });

  final Inquiry? initialInquiry;
  final CatalogueProduct? prefillProduct;

  @override
  ConsumerState<AddInquirySheet> createState() => _AddInquirySheetState();
}

class _AddInquirySheetState extends ConsumerState<AddInquirySheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _productCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  InquirySource _source = InquirySource.whatsapp;
  InquiryStatus _status = InquiryStatus.newInquiry;
  String? _linkedProductId;
  bool _isSaving = false;

  bool get _isEditMode => widget.initialInquiry != null;

  bool get _canSave {
    return _nameCtrl.text.trim().isNotEmpty &&
        _productCtrl.text.trim().isNotEmpty &&
        !_isSaving;
  }

  @override
  void initState() {
    super.initState();

    if (widget.prefillProduct != null && widget.initialInquiry == null) {
      _productCtrl.text = widget.prefillProduct!.name;
      _linkedProductId = widget.prefillProduct!.id;
    }

    final Inquiry? inquiry = widget.initialInquiry;
    if (inquiry != null) {
      _nameCtrl.text = inquiry.customerName;
      _phoneCtrl.text = inquiry.customerPhone ?? '';
      _productCtrl.text = inquiry.productAsked;
      _notesCtrl.text = inquiry.notes ?? '';
      _source = inquiry.source;
      _status = inquiry.status;
      _linkedProductId = inquiry.productId;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _productCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.sheet),
            topRight: Radius.circular(AppRadius.sheet),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: AppSpacing.xl + AppSpacing.sm,
                      height: AppSpacing.xs,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(AppSpacing.xs / 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _isEditMode
                        ? AppStrings.editInquiry
                        : AppStrings.addInquiry,
                    style: AppTypography.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: AppStrings.customerNameLabel,
                      hintText: AppStrings.customerNameHint,
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (String? value) {
                      if ((value ?? '').trim().isEmpty) {
                        return AppStrings.fieldRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: AppStrings.customerPhoneLabel,
                      hintText: AppStrings.customerPhoneHint,
                      prefixText: '+91 ',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _productCtrl,
                    decoration: InputDecoration(
                      labelText: AppStrings.productAskedLabel,
                      hintText: AppStrings.productAskedHint,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.inventory_2_outlined, size: 18),
                        onPressed: _openCataloguePicker,
                        tooltip: AppStrings.inquiryCataloguePick,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (String? value) {
                      if ((value ?? '').trim().isEmpty) {
                        return AppStrings.fieldRequired;
                      }
                      return null;
                    },
                  ),
                  if (_linkedProductId != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        '✓ ${AppStrings.inquiryLinkedProduct}',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    AppStrings.sourceLabel,
                    style: AppTypography.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: InquirySource.values.map((InquirySource source) {
                      return ChoiceChip(
                        label: Text(source.label),
                        selected: _source == source,
                        onSelected: (_) => setState(() => _source = source),
                      );
                    }).toList(growable: false),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    AppStrings.inquiryStatusLabel,
                    style: AppTypography.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: InquiryStatus.values.map((InquiryStatus status) {
                      return ChoiceChip(
                        label: InquiryStatusChip(status: status, isSmall: true),
                        selected: _status == status,
                        onSelected: (_) => setState(() => _status = status),
                      );
                    }).toList(growable: false),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: AppStrings.notesLabel,
                      hintText: AppStrings.notesHint,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: _isEditMode
                        ? AppStrings.editInquiry
                        : AppStrings.addInquiry,
                    isLoading: _isSaving,
                    onPressed: _canSave ? _save : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openCataloguePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _CataloguePickerSheet(
          onSelect: (CatalogueProduct product) {
            setState(() {
              _linkedProductId = product.id;
              _productCtrl.text = product.name;
            });
          },
        );
      },
    );
  }

  Future<void> _save() async {
    if (!_canSave) {
      return;
    }

    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final String userId = ref.read(currentUserIdProvider).trim();
    if (userId.isEmpty) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: AppStrings.errorAuth,
          type: AppSnackBarType.error,
        );
      }
      setState(() => _isSaving = false);
      return;
    }

    final DateTime now = DateTime.now();

    final Inquiry inquiry = _isEditMode
        ? widget.initialInquiry!.copyWith(
            customerName: _nameCtrl.text.trim(),
            customerPhone: _normalizePhoneOrNull(_phoneCtrl.text),
            productAsked: _productCtrl.text.trim(),
            productId: _linkedProductId,
            source: _source,
            status: _status,
            notes: _normalizeTextOrNull(_notesCtrl.text),
            updatedAt: now,
          )
        : Inquiry(
            id: '',
            userId: userId,
            customerName: _nameCtrl.text.trim(),
            customerPhone: _normalizePhoneOrNull(_phoneCtrl.text),
            productAsked: _productCtrl.text.trim(),
            productId: _linkedProductId,
            source: _source,
            status: _status,
            notes: _normalizeTextOrNull(_notesCtrl.text),
            createdAt: now,
            updatedAt: now,
          );

    if (_isEditMode) {
      await ref.read(inquiryProvider.notifier).updateInquiry(inquiry);
    } else {
      await ref.read(inquiryProvider.notifier).addInquiry(inquiry);
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
    AppSnackBar.show(
      context,
      message:
          _isEditMode ? AppStrings.inquiryUpdated : AppStrings.inquirySaved,
      type: AppSnackBarType.success,
    );

    setState(() => _isSaving = false);
  }

  String? _normalizeTextOrNull(String value) {
    final String normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  String? _normalizePhoneOrNull(String value) {
    final String normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}

class _CataloguePickerSheet extends ConsumerWidget {
  const _CataloguePickerSheet({required this.onSelect});

  final void Function(CatalogueProduct product) onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CatalogueProduct>> catalogueState =
        ref.watch(catalogueProvider);

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.6,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.sheet),
          topRight: Radius.circular(AppRadius.sheet),
        ),
      ),
      child: Column(
        children: <Widget>[
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: AppSpacing.xl + AppSpacing.sm,
            height: AppSpacing.xs,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(AppSpacing.xs / 2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Text(
              AppStrings.inquiryCataloguePickerTitle,
              style: AppTypography.headlineMedium,
            ),
          ),
          Expanded(
            child: catalogueState.when(
              loading: () => ListView.builder(
                itemCount: 5,
                itemBuilder: (BuildContext context, int index) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    child: ShimmerBox(width: double.infinity, height: 56),
                  );
                },
              ),
              error: (Object error, StackTrace stackTrace) {
                return const Center(
                  child: Text(
                    AppStrings.catalogueLoadFailed,
                    style: AppTypography.bodyMedium,
                  ),
                );
              },
              data: (List<CatalogueProduct> products) {
                if (products.isEmpty) {
                  return const Center(
                    child: Text(
                      AppStrings.catalogueEmptyTitle,
                      style: AppTypography.bodyMedium,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (BuildContext context, int index) {
                    final CatalogueProduct product = products[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.button),
                        child: CachedNetworkImage(
                          imageUrl: product.imageUrl,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          placeholder: (
                            BuildContext context,
                            String value,
                          ) {
                            return const ShimmerBox(width: 44, height: 44);
                          },
                          errorWidget: (
                            BuildContext context,
                            String value,
                            Object error,
                          ) {
                            return Container(
                              width: 44,
                              height: 44,
                              color: AppColors.primaryLight,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                size: 18,
                              ),
                            );
                          },
                        ),
                      ),
                      title: Text(product.name),
                      subtitle: Text('₹${product.price.toStringAsFixed(0)}'),
                      trailing: const Icon(Icons.add_circle_outline),
                      onTap: () {
                        Navigator.of(context).pop();
                        onSelect(product);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
