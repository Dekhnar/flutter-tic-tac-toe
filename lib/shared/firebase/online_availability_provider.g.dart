// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'online_availability_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether Firebase is initialized; `main` overrides it once the initialization settled.

@ProviderFor(isOnlineAvailable)
const isOnlineAvailableProvider = IsOnlineAvailableProvider._();

/// Whether Firebase is initialized; `main` overrides it once the initialization settled.

final class IsOnlineAvailableProvider extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  /// Whether Firebase is initialized; `main` overrides it once the initialization settled.
  const IsOnlineAvailableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isOnlineAvailableProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isOnlineAvailableHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isOnlineAvailable(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<bool>(value));
  }
}

String _$isOnlineAvailableHash() => r'ff5d6115db01b373cd252a7d44c3cea689dd9210';
