// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capture_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(imagePicker)
final imagePickerProvider = ImagePickerProvider._();

final class ImagePickerProvider
    extends $FunctionalProvider<ImagePicker, ImagePicker, ImagePicker>
    with $Provider<ImagePicker> {
  ImagePickerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'imagePickerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$imagePickerHash();

  @$internal
  @override
  $ProviderElement<ImagePicker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ImagePicker create(Ref ref) {
    return imagePicker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImagePicker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImagePicker>(value),
    );
  }
}

String _$imagePickerHash() => r'7877699a862be48e962306635347623c45e91971';

@ProviderFor(captureImageProcessor)
final captureImageProcessorProvider = CaptureImageProcessorProvider._();

final class CaptureImageProcessorProvider extends $FunctionalProvider<
    CaptureImageProcessor,
    CaptureImageProcessor,
    CaptureImageProcessor> with $Provider<CaptureImageProcessor> {
  CaptureImageProcessorProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'captureImageProcessorProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$captureImageProcessorHash();

  @$internal
  @override
  $ProviderElement<CaptureImageProcessor> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CaptureImageProcessor create(Ref ref) {
    return captureImageProcessor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CaptureImageProcessor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CaptureImageProcessor>(value),
    );
  }
}

String _$captureImageProcessorHash() =>
    r'e349ba1cce3a88a6504cfd8c184b6accb11ed232';

@ProviderFor(Capture)
final captureProvider = CaptureProvider._();

final class CaptureProvider extends $NotifierProvider<Capture, CaptureState> {
  CaptureProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'captureProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$captureHash();

  @$internal
  @override
  Capture create() => Capture();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CaptureState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CaptureState>(value),
    );
  }
}

String _$captureHash() => r'231d93c0491d03841b61c50077f2dd800dcb8da1';

abstract class _$Capture extends $Notifier<CaptureState> {
  CaptureState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CaptureState, CaptureState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<CaptureState, CaptureState>,
        CaptureState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
