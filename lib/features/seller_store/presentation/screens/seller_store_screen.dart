import 'package:dukaan_ai/core/config/app_config.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/errors/app_exception.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_shadows.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/seller_store/application/seller_store_provider.dart';
import 'package:dukaan_ai/features/seller_store/domain/models/seller_store_settings.dart';
import 'package:dukaan_ai/shared/widgets/app_button.dart';
import 'package:dukaan_ai/shared/widgets/app_error_view.dart';
import 'package:dukaan_ai/shared/widgets/app_snackbar.dart';
import 'package:dukaan_ai/shared/widgets/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SellerStoreScreen extends ConsumerStatefulWidget {
  const SellerStoreScreen({super.key});

  @override
  ConsumerState<SellerStoreScreen> createState() => _SellerStoreScreenState();
}

class _SellerStoreScreenState extends ConsumerState<SellerStoreScreen> {
  static final RegExp _slugPattern = RegExp(
    r'^[a-z0-9](?:[a-z0-9-]{1,38}[a-z0-9])$',
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _slugCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  final TextEditingController _bannerCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();

  bool _isPublished = false;
  String _lastHydratedKey = '';

  @override
  void dispose() {
    _slugCtrl.dispose();
    _descriptionCtrl.dispose();
    _bannerCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<SellerStoreSettings> state =
        ref.watch(sellerStoreProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          AppStrings.sellerStoreTitle,
          style: AppTypography.headlineLarge,
        ),
      ),
      body: state.when(
        loading: () => const _StoreLoadingView(),
        error: (Object error, StackTrace stackTrace) {
          return AppErrorView(
            message: _toErrorMessage(error),
            onRetry: () => ref.read(sellerStoreProvider.notifier).refresh(),
          );
        },
        data: (SellerStoreSettings settings) {
          _hydrateIfNeeded(settings);
          return _buildForm(context, settings);
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, SellerStoreSettings settings) {
    final String? url = _buildUrl();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                settings.shopName.isEmpty
                    ? AppStrings.shopNameFallback
                    : settings.shopName,
                style: AppTypography.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                AppStrings.sellerStoreInfoLine,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _StatsRow(
                viewsCount: settings.viewsCount,
                whatsappClicks: settings.whatsappClicks,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: AppShadows.card,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _slugCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: AppStrings.sellerStoreSlugLabel,
                    hintText: AppStrings.sellerStoreSlugHint,
                  ),
                  onChanged: (String value) {
                    final String normalized =
                        SellerStoreSettings.suggestSlug(value);
                    if (normalized == value) {
                      return;
                    }
                    _slugCtrl.value = TextEditingValue(
                      text: normalized,
                      selection: TextSelection.collapsed(
                        offset: normalized.length,
                      ),
                    );
                  },
                  validator: _validateSlug,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppStrings.sellerStoreSlugHelp,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _phoneCtrl,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: AppStrings.sellerStorePhoneLabel,
                    hintText: AppStrings.phoneHint,
                  ),
                  validator: _validatePhone,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _bannerCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: AppStrings.sellerStoreBannerLabel,
                    hintText: AppStrings.sellerStoreBannerHint,
                  ),
                  validator: _validateBannerUrl,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _descriptionCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: AppStrings.sellerStoreDescriptionLabel,
                    hintText: AppStrings.sellerStoreDescriptionHint,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SwitchListTile.adaptive(
                  value: _isPublished,
                  onChanged: (bool value) {
                    setState(() {
                      _isPublished = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    AppStrings.sellerStorePublishLabel,
                    style: AppTypography.bodyLarge,
                  ),
                  subtitle: Text(
                    _isPublished
                        ? AppStrings.sellerStorePublishOn
                        : AppStrings.sellerStorePublishOff,
                    style: AppTypography.labelSmall.copyWith(
                      color: _isPublished
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (url != null && url.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  SelectableText(
                    url,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: AppStrings.sellerStoreSaveButton,
                  onPressed: () => _save(settings),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: AppButton(
                        label: AppStrings.sellerStorePreviewButton,
                        variant: AppButtonVariant.secondary,
                        onPressed: () => _previewStore(context),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton(
                        label: AppStrings.sellerStoreShareButton,
                        variant: AppButtonVariant.secondary,
                        onPressed: _shareStore,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _save(SellerStoreSettings current) async {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    await ref.read(sellerStoreProvider.notifier).saveSettings(
          slug: _slugCtrl.text,
          description: _descriptionCtrl.text,
          bannerUrl: _bannerCtrl.text,
          phone: _phoneCtrl.text,
          isPublished: _isPublished,
        );

    if (!mounted) {
      return;
    }

    final AsyncValue<SellerStoreSettings> latest =
        ref.read(sellerStoreProvider);
    if (latest.hasError && latest.error != null) {
      AppSnackBar.show(
        context,
        message: _toErrorMessage(latest.error!),
        type: AppSnackBarType.error,
      );
      return;
    }

    AppSnackBar.show(
      context,
      message: AppStrings.sellerStoreSaveSuccess,
      type: AppSnackBarType.success,
    );

    final SellerStoreSettings? saved = latest.asData?.value;
    if (saved != null) {
      _hydrateIfNeeded(saved);
    }
  }

  Future<void> _previewStore(BuildContext context) async {
    final String? url = _buildUrl();
    if (url == null || url.isEmpty) {
      AppSnackBar.show(
        context,
        message: AppStrings.sellerStoreSlugInvalid,
        type: AppSnackBarType.error,
      );
      return;
    }

    final Uri uri = Uri.parse(url);
    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!context.mounted) {
      return;
    }

    if (!launched) {
      AppSnackBar.show(
        context,
        message: AppStrings.errorGeneric,
        type: AppSnackBarType.error,
      );
    }
  }

  Future<void> _shareStore() async {
    final String? url = _buildUrl();
    if (url == null || url.isEmpty) {
      AppSnackBar.show(
        context,
        message: AppStrings.sellerStoreSlugInvalid,
        type: AppSnackBarType.error,
      );
      return;
    }

    await Share.share('${AppStrings.sellerStoreShareMessage} $url');
  }

  void _hydrateIfNeeded(SellerStoreSettings settings) {
    final String nextKey = [
      settings.slug,
      settings.description,
      settings.bannerUrl,
      settings.phone,
      settings.isPublished.toString(),
      settings.viewsCount.toString(),
      settings.whatsappClicks.toString(),
    ].join('|');

    if (_lastHydratedKey == nextKey) {
      return;
    }

    _lastHydratedKey = nextKey;
    _slugCtrl.text = settings.slug;
    _descriptionCtrl.text = settings.description;
    _bannerCtrl.text = settings.bannerUrl;
    _phoneCtrl.text = settings.phone;
    _isPublished = settings.isPublished;
  }

  String? _buildUrl() {
    final String slug = SellerStoreSettings.suggestSlug(_slugCtrl.text);
    if (slug.isEmpty) {
      return null;
    }
    return '${AppConfig.workerBaseUrl}/api/get-seller-store/$slug';
  }

  String? _validateSlug(String? value) {
    final String normalized = SellerStoreSettings.suggestSlug(value ?? '');
    if (!_slugPattern.hasMatch(normalized)) {
      return AppStrings.sellerStoreSlugInvalid;
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final String cleaned = (value ?? '').trim();
    if (cleaned.isEmpty) {
      return AppStrings.authInvalidPhone;
    }

    final String digitsOnly = cleaned.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return AppStrings.authInvalidPhone;
    }
    return null;
  }

  String? _validateBannerUrl(String? value) {
    final String cleaned = (value ?? '').trim();
    if (cleaned.isEmpty) {
      return null;
    }

    final Uri? uri = Uri.tryParse(cleaned);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return AppStrings.sellerStoreBannerInvalid;
    }

    if (uri.scheme != 'https' && uri.scheme != 'http') {
      return AppStrings.sellerStoreBannerInvalid;
    }

    return null;
  }

  String _toErrorMessage(Object error) {
    if (error is AppException) {
      return error.userMessage;
    }
    return AppStrings.sellerStoreLoadFailed;
  }
}

class _StoreLoadingView extends StatelessWidget {
  const _StoreLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: const <Widget>[
        ShimmerBox(width: double.infinity, height: 132),
        SizedBox(height: AppSpacing.md),
        ShimmerBox(width: double.infinity, height: 360),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.viewsCount,
    required this.whatsappClicks,
  });

  final int viewsCount;
  final int whatsappClicks;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _StatItem(
            label: AppStrings.sellerStoreViewsLabel,
            value: '$viewsCount',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatItem(
            label: AppStrings.sellerStoreClicksLabel,
            value: '$whatsappClicks',
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Column(
        children: <Widget>[
          Text(value, style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
