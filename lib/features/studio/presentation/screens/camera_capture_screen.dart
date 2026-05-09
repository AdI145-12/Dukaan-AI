// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';

import 'package:dukaan_ai/core/constants/app_routes.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/core/services/credit_guard.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/core/theme/app_radius.dart';
import 'package:dukaan_ai/core/theme/app_spacing.dart';
import 'package:dukaan_ai/core/theme/app_typography.dart';
import 'package:dukaan_ai/features/studio/application/capture_provider.dart';
import 'package:dukaan_ai/features/studio/application/capture_state.dart';
import 'package:dukaan_ai/shared/widgets/app_bottom_sheet.dart';
import 'package:dukaan_ai/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CameraCaptureScreen extends ConsumerStatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  ConsumerState<CameraCaptureScreen> createState() =>
      _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends ConsumerState<CameraCaptureScreen> {
  bool _captureStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_captureStarted && mounted) {
        _captureStarted = true;
        await ref.read(captureProvider.notifier).captureAndProcessImage();

        if (mounted && ref.read(captureProvider) is CaptureInitial) {
          context.pop();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CaptureState>(captureProvider, (
      CaptureState? previous,
      CaptureState next,
    ) {
      _handleStateChange(context, previous, next);
    });

    final CaptureState captureState = ref.watch(captureProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppStrings.cameraCaptureTitle,
          style: AppTypography.headlineMedium.copyWith(color: Colors.white),
        ),
      ),
      body: _buildBody(captureState),
    );
  }

  void _handleStateChange(
    BuildContext context,
    CaptureState? previous,
    CaptureState next,
  ) {
    if (next is CaptureError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(next.message),
          backgroundColor: AppColors.error,
        ),
      );
      Future<void>.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          context.pop();
        }
      });
      ref.read(captureProvider.notifier).resetError();
    }

    if (next is CaptureImageReady && previous is! CaptureImageReady) {
      _showPreviewSheet(context, next);
    }

    if (next is CaptureProcessed) {
      if (context.mounted) {
        context.pushReplacement(
          AppRoutes.backgroundSelect,
          extra: next.processedBase64,
        );
      }
    }
  }

  void _showPreviewSheet(BuildContext context, CaptureImageReady state) {
    AppBottomSheet.show<void>(
      context: context,
      title: AppStrings.capturePreviewTitle,
      isDismissible: false,
      child: _PreviewSheetContent(imageBytes: state.imageBytes),
    );
  }

  Widget _buildBody(CaptureState state) {
    return switch (state) {
      CaptureInitial() => const _OpeningCameraBody(),
      CaptureImageReady(:final imageBytes) =>
        _ImagePreviewBody(imageBytes: imageBytes),
      CaptureProcessing(:final imageBytes) =>
        _ProcessingBody(imageBytes: imageBytes),
      CaptureProcessed() => const _OpeningCameraBody(),
      CaptureError() => const _OpeningCameraBody(),
    };
  }
}

class _OpeningCameraBody extends StatelessWidget {
  const _OpeningCameraBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: AppSpacing.md),
          Text(
            AppStrings.cameraOpening,
            style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _ImagePreviewBody extends StatelessWidget {
  const _ImagePreviewBody({required this.imageBytes});

  final Uint8List imageBytes;

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      imageBytes,
      fit: BoxFit.contain,
      width: double.infinity,
    );
  }
}

class _ProcessingBody extends StatelessWidget {
  const _ProcessingBody({required this.imageBytes});

  final Uint8List imageBytes;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Image.memory(
          imageBytes,
          fit: BoxFit.contain,
          width: double.infinity,
        ),
        Container(
          color: Colors.black54,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: AppSpacing.md),
                Text(
                  AppStrings.aiProcessing,
                  style: AppTypography.bodyMedium.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewSheetContent extends ConsumerWidget {
  const _PreviewSheetContent({required this.imageBytes});

  final Uint8List imageBytes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Image.memory(
            imageBytes,
            height: 240,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: AppStrings.removeBackground,
          onPressed: () async {
            final bool canProceed =
                await ref.read(creditGuardProvider).canGenerate(context);
            if (!canProceed) {
              return;
            }

            final String userId = FirebaseService.currentUserId ?? '';
            if (userId.isEmpty) {
              return;
            }

            Navigator.of(context).pop();
            await ref.read(captureProvider.notifier).processImage(userId: userId);
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: AppStrings.retake,
          variant: AppButtonVariant.secondary,
          onPressed: () async {
            Navigator.of(context).pop();
            await ref.read(captureProvider.notifier).retake();
            if (context.mounted && ref.read(captureProvider) is CaptureInitial) {
              context.pop();
            }
          },
        ),
      ],
    );
  }
}
