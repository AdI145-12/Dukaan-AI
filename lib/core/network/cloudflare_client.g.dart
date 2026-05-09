// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloudflare_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cloudflareClient)
final cloudflareClientProvider = CloudflareClientProvider._();

final class CloudflareClientProvider extends $FunctionalProvider<
    CloudflareClient,
    CloudflareClient,
    CloudflareClient> with $Provider<CloudflareClient> {
  CloudflareClientProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'cloudflareClientProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cloudflareClientHash();

  @$internal
  @override
  $ProviderElement<CloudflareClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CloudflareClient create(Ref ref) {
    return cloudflareClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CloudflareClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CloudflareClient>(value),
    );
  }
}

String _$cloudflareClientHash() => r'58a22295e2275045e34110e566362749915129fb';
