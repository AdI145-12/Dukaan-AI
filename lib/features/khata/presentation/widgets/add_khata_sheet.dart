import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/errors/error_handler.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/features/khata/application/khata_provider.dart';
import 'package:dukaan_ai/shared/widgets/app_button.dart';
import 'package:dukaan_ai/shared/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddKhataSheet extends ConsumerStatefulWidget {
  const AddKhataSheet({super.key});

  @override
  ConsumerState<AddKhataSheet> createState() => _AddKhataSheetState();
}

class _AddKhataSheetState extends ConsumerState<AddKhataSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    await ref.read(khataProvider.notifier).addEntry(
          customerName: _nameCtrl.text.trim(),
          customerPhone: _normalizedOrNull(_phoneCtrl.text),
          amount: double.parse(_amountCtrl.text.trim()),
          note: _normalizedOrNull(_noteCtrl.text),
        );

    if (!mounted) {
      return;
    }

    final AsyncValue<void> operationState = ref.read(khataProvider);
    if (operationState.hasError) {
      setState(() => _isSubmitting = false);
      AppSnackBar.show(
        context,
        message: ErrorHandler.toUserMessage(operationState.error!),
        type: AppSnackBarType.error,
      );
      return;
    }

    Navigator.of(context).pop();
    AppSnackBar.show(
      context,
      message: AppStrings.khataAddedMessage,
      type: AppSnackBarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration(
                  labelText: AppStrings.customerNameLabel,
                  hintText: AppStrings.customerNameHint,
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: _inputDecoration(
                  labelText: AppStrings.customerPhoneLabel,
                  hintText: AppStrings.customerPhoneHint,
                  prefixText: '+91 ',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDecoration(
                  labelText: AppStrings.amountLabel,
                  hintText: AppStrings.amountHint,
                  prefixText: '₹ ',
                ),
                validator: _amountValidator,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _noteCtrl,
                maxLength: 100,
                decoration: _inputDecoration(
                  labelText: AppStrings.noteLabel,
                  hintText: AppStrings.noteHint,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: AppStrings.saveKhataButton,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    return null;
  }

  String? _amountValidator(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return AppStrings.fieldRequired;
    }

    final double? parsed = double.tryParse(value!.trim());
    if (parsed == null || parsed <= 0) {
      return AppStrings.amountInvalid;
    }

    return null;
  }

  String? _normalizedOrNull(String value) {
    final String normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  InputDecoration _inputDecoration({
    required String labelText,
    required String hintText,
    String? prefixText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixText: prefixText,
    );
  }
}
