import 'dart:typed_data';

import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/errors/app_exception.dart';
import 'package:dukaan_ai/core/services/image_pipeline.dart';
import 'package:dukaan_ai/features/studio/application/capture_state.dart';
import 'package:dukaan_ai/features/studio/infrastructure/background_removal_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'capture_provider.g.dart';

class CaptureImageProcessor {
  const CaptureImageProcessor();

  /// Prepares picked image bytes for upload in an isolate.
  Future<Uint8List> compress(XFile imageFile) {
    return ImagePipeline.prepareForUpload(imageFile);
  }

  Future<String> toBase64(Uint8List bytes) {
    return ImagePipeline.toBase64(bytes);
  }
}

@riverpod
ImagePicker imagePicker(Ref ref) {
  return ImagePicker();
}

@riverpod
CaptureImageProcessor captureImageProcessor(Ref ref) {
  return const CaptureImageProcessor();
}

@riverpod
class Capture extends _$Capture {
  @override
  CaptureState build() => const CaptureInitial();

  /// Backward-compatible alias for existing call sites.
  Future<void> captureAndProcess() {
    return captureAndProcessImage();
  }

  /// Main method: opens camera, compresses, shows preview.
  Future<void> captureAndProcessImage() async {
    state = const CaptureInitial();

    final ImagePicker picker = ref.read(imagePickerProvider);
    final XFile? picked;
    try {
      picked = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        imageQuality: 100,
      );
    } catch (_) {
      state = const CaptureError(
        message: AppStrings.cameraPermissionDenied,
      );
      return;
    }

    if (picked == null) {
      return;
    }

    try {
      final CaptureImageProcessor processor =
          ref.read(captureImageProcessorProvider);
      final Uint8List compressed = await processor.compress(picked);
      final String base64 = await processor.toBase64(compressed);

      state = CaptureImageReady(
        imageBytes: compressed,
        base64Image: base64,
      );
    } catch (_) {
      state = const CaptureError(
        message: AppStrings.imageLoadFailed,
      );
    }
  }

  /// Called when user taps "Retake" in the bottom sheet.
  Future<void> retake() async {
    state = const CaptureInitial();
    await captureAndProcess();
  }

  /// Called when user taps "Remove Background".
  Future<void> processImage({required String userId}) async {
    final CaptureState current = state;
    if (current is! CaptureImageReady) return;

    state = CaptureProcessing(imageBytes: current.imageBytes);

    try {
      final BackgroundRemovalService service =
          ref.read(backgroundRemovalServiceProvider);
      final String processedBase64 = await service.removeBackground(
        base64Image: current.base64Image,
        userId: userId,
      );

      state = CaptureProcessed(processedBase64: processedBase64);
    } on AppException catch (error) {
      state = CaptureError(message: error.userMessage);
    } catch (_) {
      state = const CaptureError(
        message: AppStrings.errorCaptureGeneric,
      );
    }
  }

  void resetError() {
    state = const CaptureInitial();
  }
}
