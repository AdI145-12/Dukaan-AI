import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/studio/domain/generated_ad.dart';
import 'package:dukaan_ai/features/studio/presentation/widgets/caption_language_selector.dart';
import 'package:dukaan_ai/shared/widgets/app_snackbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

enum WhatsAppTarget { broadcast, status, group, single }

/// Isolate-safe image downloader for sharing flows.
Future<String> _downloadShareImage(Map<String, String> payload) async {
  final String imageUrl = payload['imageUrl'] ?? '';
  final String adId = payload['adId'] ?? 'share';
  if (imageUrl.isEmpty) {
    throw Exception('Image URL missing');
  }

  final http.Response response = await http.get(Uri.parse(imageUrl));
  if (response.statusCode != 200) {
    throw Exception('Image download failed');
  }

  final String filePath =
      '${Directory.systemTemp.path}${Platform.pathSeparator}dukaan_ai_ad_$adId.jpg';
  final File file = File(filePath);
  await file.writeAsBytes(response.bodyBytes, flush: true);
  return file.path;
}

class WhatsAppBroadcastScreen extends ConsumerStatefulWidget {
  const WhatsAppBroadcastScreen({
    super.key,
    required this.ad,
  });

  final GeneratedAd ad;

  @override
  ConsumerState<WhatsAppBroadcastScreen> createState() =>
      _WhatsAppBroadcastScreenState();
}

class _WhatsAppBroadcastScreenState extends ConsumerState<WhatsAppBroadcastScreen> {
  late final TextEditingController _captionController;
  late String _editedCaption;
  String _selectedLanguage = 'hinglish';
  bool _captionEdited = false;
  bool _isSharing = false;
  String? _cachedImagePath;

  @override
  void initState() {
    super.initState();
    _editedCaption = _captionForLanguage(_selectedLanguage);
    _captionController = TextEditingController(text: _editedCaption);
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  String _captionForLanguage(String language) {
    return switch (language) {
      'english' => widget.ad.captionEnglish ?? widget.ad.captionHindi ?? '',
      'hindi' => widget.ad.captionHindi ?? widget.ad.captionEnglish ?? '',
      _ => widget.ad.captionHindi ?? widget.ad.captionEnglish ?? '',
    };
  }

  void _setCaptionText(String text) {
    _editedCaption = text;
    _captionController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _onLanguageChanged(String language) {
    if (language == _selectedLanguage) {
      return;
    }

    setState(() {
      _selectedLanguage = language;
      if (!_captionEdited) {
        _setCaptionText(_captionForLanguage(language));
      }
    });
  }

  void _onCaptionChanged(String value) {
    setState(() {
      _editedCaption = value;
      _captionEdited = true;
    });
  }

  void _restoreOriginalCaption() {
    setState(() {
      _captionEdited = false;
      _setCaptionText(_captionForLanguage(_selectedLanguage));
    });
  }

  Future<void> _copyCaption() async {
    await Clipboard.setData(ClipboardData(text: _editedCaption));
    if (!mounted) {
      return;
    }

    AppSnackBar.show(
      context,
      message: AppStrings.captionCopied,
      type: AppSnackBarType.success,
    );
  }

  Future<void> _onBackPressed() async {
    if (!_captionEdited) {
      if (mounted) {
        context.pop();
      }
      return;
    }

    final bool confirmExit = await _showBackConfirmDialog();
    if (confirmExit && mounted) {
      context.pop();
    }
  }

  Future<bool> _showBackConfirmDialog() async {
    final bool? decision = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(AppStrings.captionBackConfirmTitle),
          content: const Text(AppStrings.captionBackConfirmBody),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(AppStrings.cancelButton),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(AppStrings.captionBackConfirmAction),
            ),
          ],
        );
      },
    );
    return decision ?? false;
  }

  Future<void> _shareToWhatsApp(WhatsAppTarget target) async {
    assert(WhatsAppTarget.values.contains(target));
    if (_isSharing) {
      return;
    }

    setState(() => _isSharing = true);
    AppSnackBar.show(context, message: AppStrings.shareDownloading);

    try {
      final String imagePath = await _resolveShareImagePath();
      final String caption = _editedCaption.trim().isEmpty
          ? '#DukaanAI'
          : '${_editedCaption.trim()}\n\n#DukaanAI';

      await Share.shareXFiles(
        <XFile>[XFile(imagePath)],
        text: caption,
        sharePositionOrigin: _shareOriginRect(),
      );

      if (!mounted) {
        return;
      }
      AppSnackBar.show(
        context,
        message: AppStrings.adSharedSuccess,
        type: AppSnackBarType.success,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppSnackBar.show(
        context,
        message: AppStrings.errorShareFailed,
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<void> _shareToInstagram() async {
    if (_isSharing) {
      return;
    }

    setState(() => _isSharing = true);
    AppSnackBar.show(context, message: AppStrings.shareDownloading);

    try {
      final String imagePath = await _resolveShareImagePath();
      await Share.shareXFiles(
        <XFile>[XFile(imagePath)],
        sharePositionOrigin: _shareOriginRect(),
      );

      if (!mounted) {
        return;
      }
      AppSnackBar.show(
        context,
        message: AppStrings.adSharedSuccess,
        type: AppSnackBarType.success,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppSnackBar.show(
        context,
        message: AppStrings.errorShareFailed,
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<String> _resolveShareImagePath() async {
    final String? cachedPath = _cachedImagePath;
    if (cachedPath != null) {
      final bool fileExists = await File(cachedPath).exists();
      if (fileExists) {
        return cachedPath;
      }
    }

    final String path = await compute<Map<String, String>, String>(
      _downloadShareImage,
      <String, String>{
        'adId': widget.ad.id,
        'imageUrl': widget.ad.imageUrl,
      },
    );
    _cachedImagePath = path;
    return path;
  }

  Rect _shareOriginRect() {
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return Rect.zero;
    }
    return renderObject.localToGlobal(Offset.zero) & renderObject.size;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: !_captionEdited,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        await _onBackPressed();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: const Text(
            AppStrings.whatsappBroadcastTitle,
            style: AppTypography.headlineMedium,
          ),
          leading: IconButton(
            onPressed: () => unawaited(_onBackPressed()),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _AdPreviewRow(
                imageUrl: widget.ad.imageUrl,
                caption: _editedCaption,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                AppStrings.captionCustomize.toUpperCase(),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              CaptionLanguageSelector(
                selectedLanguage: _selectedLanguage,
                onChanged: _onLanguageChanged,
              ),
              const SizedBox(height: AppSpacing.md - AppSpacing.xs),
              TextField(
                key: const Key('broadcast_caption_field'),
                controller: _captionController,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: AppStrings.captionEditHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  suffixIcon: _captionEdited
                      ? IconButton(
                          key: const Key('broadcast_restore_caption_button'),
                          icon: const Icon(Icons.refresh),
                          tooltip: AppStrings.captionRestoreTooltip,
                          onPressed: _restoreOriginalCaption,
                        )
                      : null,
                ),
                onChanged: _onCaptionChanged,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton.icon(
                key: const Key('broadcast_copy_caption_button'),
                onPressed: _copyCaption,
                icon: const Icon(Icons.copy, size: 16),
                label: Text(
                  AppStrings.captionCopyBtn,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Divider(color: AppColors.divider, height: AppSpacing.xl),
              Text(
                AppStrings.whereToShare,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.md - AppSpacing.xs),
              _ShareDestinationCard(
                icon: Icons.campaign_outlined,
                title: AppStrings.broadcastListTitle,
                subtitle: AppStrings.broadcastListSubtitle,
                onTap: _isSharing
                    ? null
                    : () => unawaited(
                          _shareToWhatsApp(WhatsAppTarget.broadcast),
                        ),
              ),
              _ShareDestinationCard(
                icon: Icons.circle_outlined,
                title: AppStrings.whatsappStatusTitle,
                subtitle: AppStrings.whatsappStatusSubtitle,
                onTap: _isSharing
                    ? null
                    : () => unawaited(
                          _shareToWhatsApp(WhatsAppTarget.status),
                        ),
              ),
              _ShareDestinationCard(
                icon: Icons.group_outlined,
                title: AppStrings.groupShareTitle,
                subtitle: AppStrings.groupShareSubtitle,
                onTap: _isSharing
                    ? null
                    : () => unawaited(
                          _shareToWhatsApp(WhatsAppTarget.group),
                        ),
              ),
              _ShareDestinationCard(
                icon: Icons.person_outlined,
                title: AppStrings.singleContactTitle,
                subtitle: AppStrings.singleContactSubtitle,
                onTap: _isSharing
                    ? null
                    : () => unawaited(
                          _shareToWhatsApp(WhatsAppTarget.single),
                        ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isSharing ? null : () => unawaited(_shareToInstagram()),
                  icon: const Icon(Icons.share),
                  label: const Text(AppStrings.shareInstagram),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdPreviewRow extends StatelessWidget {
  const _AdPreviewRow({
    required this.imageUrl,
    required this.caption,
  });

  final String imageUrl;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.button),
            child: SizedBox(
              width: AppSpacing.xxl * 2,
              height: AppSpacing.xxl * 2,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                errorWidget: (BuildContext context, String url, Object error) {
                  return Container(
                    color: AppColors.divider,
                    child: const Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              caption.isEmpty ? AppStrings.captionEditHint : caption,
              style: AppTypography.bodyMedium,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareDestinationCard extends StatelessWidget {
  const _ShareDestinationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: <Widget>[
              Container(
                width: AppSpacing.xl + AppSpacing.sm,
                height: AppSpacing.xl + AppSpacing.sm,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
                child: Icon(icon, size: AppSpacing.lg, color: AppColors.success),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: AppTypography.labelLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}