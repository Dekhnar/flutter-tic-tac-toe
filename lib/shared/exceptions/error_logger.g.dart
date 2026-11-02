// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_logger.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(errorLoggerService)
const errorLoggerServiceProvider = ErrorLoggerServiceProvider._();

final class ErrorLoggerServiceProvider
    extends $FunctionalProvider<ErrorLoggerService, ErrorLoggerService, ErrorLoggerService>
    with $Provider<ErrorLoggerService> {
  const ErrorLoggerServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'errorLoggerServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$errorLoggerServiceHash();

  @$internal
  @override
  $ProviderElement<ErrorLoggerService> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  ErrorLoggerService create(Ref ref) {
    return errorLoggerService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ErrorLoggerService value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<ErrorLoggerService>(value));
  }
}

String _$errorLoggerServiceHash() => r'4bd2fb0b66d5ae0947f017e0769fcbf589a736b1';
