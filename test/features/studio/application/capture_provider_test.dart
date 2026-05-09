import 'dart:typed_data';

import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/errors/app_exception.dart';
import 'package:dukaan_ai/features/studio/application/capture_provider.dart';
import 'package:dukaan_ai/features/studio/application/capture_state.dart';
import 'package:dukaan_ai/features/studio/infrastructure/background_removal_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

class MockImagePicker extends Mock implements ImagePicker {}

class MockBackgroundRemovalService extends Mock
    implements BackgroundRemovalService {}

class TestCaptureImageProcessor extends CaptureImageProcessor {
  TestCaptureImageProcessor({
    required this.onCompress,
    required this.onToBase64,
  });

  final Future<Uint8List> Function(XFile imageFile) onCompress;
  final Future<String> Function(Uint8List bytes) onToBase64;

  @override
  Future<Uint8List> compress(XFile imageFile) => onCompress(imageFile);

  @override
  Future<String> toBase64(Uint8List bytes) => onToBase64(bytes);
}

void main() {
  ProviderContainer createContainer({
    required ImagePicker picker,
    required CaptureImageProcessor processor,
    BackgroundRemovalService? backgroundRemovalService,
  }) {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        imagePickerProvider.overrideWith((Ref ref) => picker),
        captureImageProcessorProvider.overrideWith(
          (Ref ref) => processor,
        ),
        if (backgroundRemovalService != null)
          backgroundRemovalServiceProvider.overrideWith(
            (Ref ref) => backgroundRemovalService,
          ),
      ],
    );

    addTearDown(container.dispose);
    return container;
  }

  group('captureAndProcess', () {
    test('captureAndProcess should store compressed preview when camera succeeds',
        () async {
      // Arrange
      final MockImagePicker picker = MockImagePicker();
      final Uint8List rawBytes = Uint8List.fromList(<int>[1, 2, 3, 4]);
      final Uint8List compressedBytes = Uint8List.fromList(<int>[9, 8, 7]);
      final XFile picked = XFile.fromData(
        rawBytes,
        name: 'capture.jpg',
        mimeType: 'image/jpeg',
      );

      when(
        () => picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          imageQuality: 100,
        ),
      ).thenAnswer((_) async => picked);

      final TestCaptureImageProcessor processor = TestCaptureImageProcessor(
        onCompress: (_) async => compressedBytes,
        onToBase64: (_) async => 'base64-raw',
      );

      final ProviderContainer container = createContainer(
        picker: picker,
        processor: processor,
      );

      // Act
      await container.read(captureProvider.notifier).captureAndProcess();

      // Assert
      final CaptureState state = container.read(captureProvider);
      expect(state, isA<CaptureImageReady>());
      final CaptureImageReady readyState = state as CaptureImageReady;
      expect(readyState.imageBytes, orderedEquals(compressedBytes));
      expect(readyState.base64Image, 'base64-raw');
    });

    test('captureAndProcess should remain initial when user cancels camera',
        () async {
      // Arrange
      final MockImagePicker picker = MockImagePicker();
      when(
        () => picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          imageQuality: 100,
        ),
      ).thenAnswer((_) async => null);

      final TestCaptureImageProcessor processor = TestCaptureImageProcessor(
        onCompress: (_) async => Uint8List.fromList(<int>[1]),
        onToBase64: (_) async => 'unused',
      );

      final ProviderContainer container = createContainer(
        picker: picker,
        processor: processor,
      );

      // Act
      await container.read(captureProvider.notifier).captureAndProcess();

      // Assert
      expect(container.read(captureProvider), isA<CaptureInitial>());
    });

    test('captureAndProcess should return capture error when processing fails',
        () async {
      // Arrange
      final MockImagePicker picker = MockImagePicker();
      final XFile picked = XFile.fromData(
        Uint8List.fromList(<int>[1, 2]),
        name: 'capture.jpg',
        mimeType: 'image/jpeg',
      );

      when(
        () => picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          imageQuality: 100,
        ),
      ).thenAnswer((_) async => picked);

      final TestCaptureImageProcessor processor = TestCaptureImageProcessor(
        onCompress: (_) => throw Exception('compress failed'),
        onToBase64: (_) async => 'unused',
      );

      final ProviderContainer container = createContainer(
        picker: picker,
        processor: processor,
      );

      // Act
      await container.read(captureProvider.notifier).captureAndProcess();

      // Assert
      final CaptureState state = container.read(captureProvider);
      expect(state, isA<CaptureError>());
      expect((state as CaptureError).message, AppStrings.imageLoadFailed);
    });

    test('captureAndProcess should return permission error when picker throws',
        () async {
      // Arrange
      final MockImagePicker picker = MockImagePicker();
      when(
        () => picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          imageQuality: 100,
        ),
      ).thenThrow(Exception('permission denied'));

      final TestCaptureImageProcessor processor = TestCaptureImageProcessor(
        onCompress: (_) async => Uint8List.fromList(<int>[1]),
        onToBase64: (_) async => 'unused',
      );

      final ProviderContainer container = createContainer(
        picker: picker,
        processor: processor,
      );

      // Act
      await container.read(captureProvider.notifier).captureAndProcess();

      // Assert
      final CaptureState state = container.read(captureProvider);
      expect(state, isA<CaptureError>());
      expect(
        (state as CaptureError).message,
        AppStrings.cameraPermissionDenied,
      );
    });
  });

  group('processImage', () {
    test(
        'processImage should return processed base64 when service succeeds from preview state',
        () async {
      // Arrange
      final MockImagePicker picker = MockImagePicker();
      final MockBackgroundRemovalService bgService =
          MockBackgroundRemovalService();
      final XFile picked = XFile.fromData(
        Uint8List.fromList(<int>[5, 6, 7]),
        name: 'capture.jpg',
        mimeType: 'image/jpeg',
      );
      final Uint8List previewBytes = Uint8List.fromList(<int>[10, 11, 12]);

      when(
        () => picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          imageQuality: 100,
        ),
      ).thenAnswer((_) async => picked);

      when(
        () => bgService.removeBackground(
          base64Image: 'base64-raw',
          userId: 'user-1',
        ),
      ).thenAnswer((_) async => 'base64-processed');

      final TestCaptureImageProcessor processor = TestCaptureImageProcessor(
        onCompress: (_) async => previewBytes,
        onToBase64: (_) async => 'base64-raw',
      );

      final ProviderContainer container = createContainer(
        picker: picker,
        processor: processor,
        backgroundRemovalService: bgService,
      );

      await container.read(captureProvider.notifier).captureAndProcess();

      // Act
      await container
          .read(captureProvider.notifier)
          .processImage(userId: 'user-1');

      // Assert
      final CaptureState state = container.read(captureProvider);
      expect(state, isA<CaptureProcessed>());
      final CaptureProcessed processed = state as CaptureProcessed;
      expect(processed.processedBase64, isNotEmpty);
      verify(
        () => bgService.removeBackground(
          base64Image: 'base64-raw',
          userId: 'user-1',
        ),
      ).called(1);
    });

    test('processImage should return rate limit error when service throws AppException',
        () async {
      // Arrange
      final MockImagePicker picker = MockImagePicker();
      final MockBackgroundRemovalService bgService =
          MockBackgroundRemovalService();
      final XFile picked = XFile.fromData(
        Uint8List.fromList(<int>[5, 6, 7]),
        name: 'capture.jpg',
        mimeType: 'image/jpeg',
      );

      when(
        () => picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          imageQuality: 100,
        ),
      ).thenAnswer((_) async => picked);

      when(
        () => bgService.removeBackground(
          base64Image: 'base64-raw',
          userId: 'user-2',
        ),
      ).thenThrow(
        const AppException.workerRateLimit(AppStrings.errorRateLimit),
      );

      final TestCaptureImageProcessor processor = TestCaptureImageProcessor(
        onCompress: (_) async => Uint8List.fromList(<int>[10]),
        onToBase64: (_) async => 'base64-raw',
      );

      final ProviderContainer container = createContainer(
        picker: picker,
        processor: processor,
        backgroundRemovalService: bgService,
      );

      await container.read(captureProvider.notifier).captureAndProcess();

      // Act
      await container
          .read(captureProvider.notifier)
          .processImage(userId: 'user-2');

      // Assert
      final CaptureState state = container.read(captureProvider);
      expect(state, isA<CaptureError>());
      expect(
        (state as CaptureError).message,
        AppStrings.errorRateLimit,
      );
    });

    test('processImage should do nothing when state is not preview ready', () async {
      // Arrange
      final MockImagePicker picker = MockImagePicker();
      final MockBackgroundRemovalService bgService =
          MockBackgroundRemovalService();
      final TestCaptureImageProcessor processor = TestCaptureImageProcessor(
        onCompress: (_) async => Uint8List.fromList(<int>[1]),
        onToBase64: (_) async => 'unused',
      );
      final ProviderContainer container = createContainer(
        picker: picker,
        processor: processor,
        backgroundRemovalService: bgService,
      );

      // Act
      await container.read(captureProvider.notifier).processImage(userId: 'x');

      // Assert
      expect(container.read(captureProvider), isA<CaptureInitial>());
      verifyNever(
        () => bgService.removeBackground(
          base64Image: any(named: 'base64Image'),
          userId: any(named: 'userId'),
        ),
      );
    });
  });
}
