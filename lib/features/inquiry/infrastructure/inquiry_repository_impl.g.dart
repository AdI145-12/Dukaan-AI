// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inquiry_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(inquiryRepository)
final inquiryRepositoryProvider = InquiryRepositoryProvider._();

final class InquiryRepositoryProvider extends $FunctionalProvider<
    InquiryRepository,
    InquiryRepository,
    InquiryRepository> with $Provider<InquiryRepository> {
  InquiryRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'inquiryRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$inquiryRepositoryHash();

  @$internal
  @override
  $ProviderElement<InquiryRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  InquiryRepository create(Ref ref) {
    return inquiryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InquiryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InquiryRepository>(value),
    );
  }
}

String _$inquiryRepositoryHash() => r'6f2ea9a0f87800c7ccb19450879c6e110b086d82';
