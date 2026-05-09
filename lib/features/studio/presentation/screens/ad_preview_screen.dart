// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dukaan_ai/core/constants/app_routes.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/errors/app_exception.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/catalogue/presentation/widgets/add_product_sheet.dart';
import 'package:dukaan_ai/features/studio/application/studio_provider.dart';
import 'package:dukaan_ai/features/studio/application/studio_state.dart';
import 'package:dukaan_ai/features/studio/domain/ad_creation_request.dart';
import 'package:dukaan_ai/features/studio/domain/ad_preview_args.dart';
import 'package:dukaan_ai/features/studio/domain/generated_ad.dart';
import 'package:dukaan_ai/features/studio/infrastructure/ad_generation_service.dart';
import 'package:dukaan_ai/features/studio/infrastructure/caption_service.dart';
import 'package:dukaan_ai/features/studio/presentation/widgets/caption_language_selector.dart';
import 'package:dukaan_ai/features/studio/presentation/widgets/save_as_product_banner.dart';
import 'package:dukaan_ai/shared/widgets/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class AdPreviewScreen extends ConsumerStatefulWidget {
  const AdPreviewScreen({super.key});

  @override
  ConsumerState<AdPreviewScreen> createState() => _AdPreviewScreenState();
}

class _AdPreviewScreenState extends ConsumerState<AdPreviewScreen> {
  static const String _freeTier = 'free';

  late AdPreviewArgs _args;
  late GeneratedAd _currentAd;
  bool _didReadArgs = false;
  bool _isRegenerating = false;
  bool _isSaving = false;
  bool _analyticsTracked = false;
  bool _captionGenerated = false;
  String _selectedLanguage = 'hinglish';
  Uint8List? _imageBytes;
  final ValueNotifier<bool> _showSaveAsBannerNotifier =
      ValueNotifier<bool>(true);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_didReadArgs) {
      _didReadArgs = true;
      _args = GoRouterState.of(context).extra! as AdPreviewArgs;
      _currentAd = _args.generatedAd;
      _showSaveAsBannerNotifier.value = true;
    }

    if (!_analyticsTracked) {
      _analyticsTracked = true;
      _trackAnalytics();
    }

    if (!_captionGenerated) {
      _captionGenerated = true;
      _generateCaptionInBackground();
    }
  }

  @override
  void dispose() {
    _showSaveAsBannerNotifier.dispose();
    super.dispose();
  }

  /// Tracks ad generation analytics without blocking user actions.
  void _trackAnalytics() {
    final String userId = FirebaseService.currentUserId ?? '';
    if (userId.isEmpty) {
      return;
    }

    unawaited(
      ref.read(studioRepositoryProvider).trackUsageEvent(
        userId: userId,
        eventType: 'adgenerated',
        creditsUsed: 1,
        metadata: <String, dynamic>{
          'backgroundstyle': _currentAd.backgroundStyle,
        },
      ),
    );
  }

  Future<Uint8List> _getImageBytes() async {
    if (_imageBytes != null) {
      return _imageBytes!;
    }

    final http.Response response =
        await http.get(Uri.parse(_currentAd.imageUrl));
    if (response.statusCode != 200) {
      throw const AppException.network(AppStrings.errorImageDownload);
    }

    _imageBytes = response.bodyBytes;
    return _imageBytes!;
  }

  Future<void> _openBroadcastManager() {
    return context.push(
      AppRoutes.whatsappBroadcast,
      extra: _currentAd,
    );
  }

  Future<void> _openSaveAsProductSheet() async {
    _showSaveAsBannerNotifier.value = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AddProductSheet(prefillImageUrl: _currentAd.imageUrl);
      },
    );
  }

  Future<void> _saveToGallery() async {
    if (_isSaving) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      final Uint8List bytes = await _getImageBytes();
      final int timestamp = DateTime.now().millisecondsSinceEpoch;

      final bool isSuccess = await _saveImageOnAndroidGalleryPath(
        bytes: bytes,
        name: 'dukaan_ad_$timestamp',
      );

      if (!isSuccess) {
        throw const AppException.storage(AppStrings.errorSaveFailed);
      }

      unawaited(
        ref
            .read(studioRepositoryProvider)
            .incrementDownloadCount(_currentAd.id),
      );
      _showSnackBar(AppStrings.saveSuccessMessage, AppColors.success);
    } on AppException catch (error) {
      _showSnackBar(error.userMessage, AppColors.error);
    } catch (_) {
      _showSnackBar(AppStrings.errorSaveFailed, AppColors.error);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _copyCaption() async {
    final String? caption = _selectedLanguage == 'english'
        ? (_currentAd.captionEnglish ?? _currentAd.captionHindi)
        : (_currentAd.captionHindi ?? _currentAd.captionEnglish);
    if (caption == null || caption.isEmpty) {
      _showSnackBar(AppStrings.captionNotAvailableYet, AppColors.warning);
      return;
    }

    await Clipboard.setData(ClipboardData(text: caption));
    _showSnackBar(AppStrings.captionCopiedMessage, AppColors.success);
  }

  Future<void> _regenerate() async {
    if (_isRegenerating) {
      return;
    }

    setState(() {
      _isRegenerating = true;
      _imageBytes = null;
    });

    final String userId = FirebaseService.currentUserId ?? '';

    try {
      final AdGenerationService service = ref.read(adGenerationServiceProvider);
      final GeneratedAd newAd = await service.generateAd(
        AdCreationRequest(
          processedImageBase64: _args.processedBase64,
          backgroundStyleId: _args.backgroundStyleId,
          userId: userId,
          customPrompt: _args.customPrompt,
        ),
      );

      ref.invalidate(studioProvider);
      if (mounted) {
        setState(() => _currentAd = newAd);
      }
    } on AppException catch (error) {
      _showSnackBar(error.userMessage, AppColors.error);
    } catch (_) {
      _showSnackBar(AppStrings.errorGeneric, AppColors.error);
    } finally {
      if (mounted) {
        setState(() => _isRegenerating = false);
      }
    }
  }

  Future<void> _generateCaptionInBackground([String? language]) async {
    final String lang = language ?? _selectedLanguage;
    final String userId = FirebaseService.currentUserId ?? '';
    if (userId.isEmpty) {
      return;
    }

    try {
      final CaptionService service = ref.read(captionServiceProvider);
      final result = await service.generateCaption(
        userId: userId,
        productName: '',
        category: 'general',
        language: lang,
      );

      final bool isEnglish = result.language == 'english';

      await ref.read(studioRepositoryProvider).updateCaption(
            adId: _currentAd.id,
            captionHindi: isEnglish ? null : result.caption,
            captionEnglish: isEnglish ? result.caption : null,
          );

      if (mounted) {
        setState(() {
          _selectedLanguage = result.language;
          _currentAd = _currentAd.copyWith(
            captionHindi: isEnglish ? _currentAd.captionHindi : result.caption,
            captionEnglish:
                isEnglish ? result.caption : _currentAd.captionEnglish,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.captionReadyMessage),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      debugPrint('_generateCaptionInBackground failed: $error');
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  Future<bool> _saveImageOnAndroidGalleryPath({
    required Uint8List bytes,
    required String name,
  }) async {
    // ASSUMPTION: image_gallery_saver is unavailable in current dependency graph.
    // We save into Android Pictures/DukaanAI as a best-effort fallback.
    if (!Platform.isAndroid) {
      return false;
    }

    try {
      final Directory directory =
          Directory('/storage/emulated/0/Pictures/DukaanAI');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final File file =
          File('${directory.path}${Platform.pathSeparator}$name.jpg');
      await file.writeAsBytes(bytes, flush: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  String? _firstRecentAdId(AsyncValue<StudioState>? value) {
    final List<GeneratedAd> ads =
        value?.asData?.value.recentAds ?? const <GeneratedAd>[];
    if (ads.isEmpty) {
      return null;
    }
    return ads.first.id;
  }

  void _handleStudioStateBannerReset(
    AsyncValue<StudioState>? previous,
    AsyncValue<StudioState> next,
  ) {
    if (!_didReadArgs) {
      return;
    }

    final String? previousId = _firstRecentAdId(previous);
    final String? nextId = _firstRecentAdId(next);
    if (nextId == null || nextId == previousId) {
      return;
    }

    if (nextId == _currentAd.id) {
      _showSaveAsBannerNotifier.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<StudioState> studioAsync = ref.watch(studioProvider);
    ref.listen<AsyncValue<StudioState>>(
      studioProvider,
      _handleStudioStateBannerReset,
    );

    final String tier = studioAsync.value?.profile?.tier ?? _freeTier;
    final bool isFreeTier = tier == _freeTier;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: _buildBody(isFreeTier),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        AppStrings.adPreviewTitle,
        style: AppTypography.headlineMedium.copyWith(color: Colors.white),
      ),
      actions: <Widget>[
        if (_isRegenerating)
          const Padding(
            padding: EdgeInsets.only(right: AppSpacing.md),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          )
        else
          TextButton(
            onPressed: _regenerate,
            child: Text(
              AppStrings.regenerateButton,
              style:
                  AppTypography.labelLarge.copyWith(color: AppColors.primary),
            ),
          ),
      ],
    );
  }

  Widget _buildBody(bool isFreeTier) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Center(
                child: RepaintBoundary(
                  child: CachedNetworkImage(
                    imageUrl: _currentAd.imageUrl,
                    key: ValueKey<String>(_currentAd.id),
                    placeholder: (BuildContext context, String url) =>
                        const ShimmerBox(
                      width: double.infinity,
                      height: 400,
                    ),
                    errorWidget:
                        (BuildContext context, String url, Object error) {
                      return const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white54,
                          size: 64,
                        ),
                      );
                    },
                    fit: BoxFit.contain,
                    memCacheWidth: 720,
                  ),
                ),
              ),
              if (_isRegenerating)
                Container(
                  color: const Color(0xB3000000),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const CircularProgressIndicator(
                            color: AppColors.primary),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          AppStrings.regeneratingMessage,
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (isFreeTier)
                const Positioned(
                  bottom: AppSpacing.lg + 120,
                  right: AppSpacing.md,
                  child: Text(
                    'Made with Dukaan AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      shadows: <Shadow>[
                        Shadow(
                          color: Colors.black87,
                          blurRadius: 4,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _showSaveAsBannerNotifier,
          builder: (BuildContext context, bool showBanner, Widget? child) {
            if (!showBanner || _currentAd.imageUrl.trim().isEmpty) {
              return const SizedBox.shrink();
            }

            return SaveAsProductBanner(
              imageUrl: _currentAd.imageUrl,
              onSave: () => unawaited(_openSaveAsProductSheet()),
              onDismiss: () => _showSaveAsBannerNotifier.value = false,
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomActionBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: CaptionLanguageSelector(
            selectedLanguage: _selectedLanguage,
            onChanged: (String newLang) {
              if (newLang == _selectedLanguage) {
                return;
              }

              setState(() {
                _selectedLanguage = newLang;
                _captionGenerated = false;
              });

              _generateCaptionInBackground(newLang);
            },
          ),
        ),
        Container(
          height: 120,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _ActionColumn(
                    icon: Icons.save_alt_rounded,
                    label: AppStrings.saveButton,
                    isLoading: _isSaving,
                    onTap: _saveToGallery,
                  ),
                ),
                const VerticalDivider(
                  width: 1,
                  color: AppColors.divider,
                  indent: AppSpacing.md,
                  endIndent: AppSpacing.md,
                ),
                Expanded(
                  child: _ActionColumn(
                    icon: Icons.share_rounded,
                    label: AppStrings.shareWhatsAppButton,
                    isLoading: false,
                    onTap: () => unawaited(_openBroadcastManager()),
                  ),
                ),
                const VerticalDivider(
                  width: 1,
                  color: AppColors.divider,
                  indent: AppSpacing.md,
                  endIndent: AppSpacing.md,
                ),
                Expanded(
                  child: _ActionColumn(
                    icon: Icons.copy_rounded,
                    label: AppStrings.copyCaptionButton,
                    isLoading: false,
                    onTap: _copyCaption,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionColumn extends StatelessWidget {
  const _ActionColumn({
    required this.icon,
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Icon(icon, color: AppColors.primary, size: 26),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
