// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gameNotifierHash() => r'599cb29c5128d5c66b4256fa4d77a325ebddaa62';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$GameNotifier extends BuildlessAutoDisposeAsyncNotifier<Game> {
  late final GameCreateInput gameCreateInput;

  FutureOr<Game> build({required GameCreateInput gameCreateInput});
}

/// See also [GameNotifier].
@ProviderFor(GameNotifier)
const gameNotifierProvider = GameNotifierFamily();

/// See also [GameNotifier].
class GameNotifierFamily extends Family<AsyncValue<Game>> {
  /// See also [GameNotifier].
  const GameNotifierFamily();

  /// See also [GameNotifier].
  GameNotifierProvider call({required GameCreateInput gameCreateInput}) {
    return GameNotifierProvider(gameCreateInput: gameCreateInput);
  }

  @override
  GameNotifierProvider getProviderOverride(
    covariant GameNotifierProvider provider,
  ) {
    return call(gameCreateInput: provider.gameCreateInput);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'gameNotifierProvider';
}

/// See also [GameNotifier].
class GameNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<GameNotifier, Game> {
  /// See also [GameNotifier].
  GameNotifierProvider({required GameCreateInput gameCreateInput})
    : this._internal(
        () => GameNotifier()..gameCreateInput = gameCreateInput,
        from: gameNotifierProvider,
        name: r'gameNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$gameNotifierHash,
        dependencies: GameNotifierFamily._dependencies,
        allTransitiveDependencies:
            GameNotifierFamily._allTransitiveDependencies,
        gameCreateInput: gameCreateInput,
      );

  GameNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gameCreateInput,
  }) : super.internal();

  final GameCreateInput gameCreateInput;

  @override
  FutureOr<Game> runNotifierBuild(covariant GameNotifier notifier) {
    return notifier.build(gameCreateInput: gameCreateInput);
  }

  @override
  Override overrideWith(GameNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: GameNotifierProvider._internal(
        () => create()..gameCreateInput = gameCreateInput,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        gameCreateInput: gameCreateInput,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<GameNotifier, Game> createElement() {
    return _GameNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GameNotifierProvider &&
        other.gameCreateInput == gameCreateInput;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gameCreateInput.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GameNotifierRef on AutoDisposeAsyncNotifierProviderRef<Game> {
  /// The parameter `gameCreateInput` of this provider.
  GameCreateInput get gameCreateInput;
}

class _GameNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<GameNotifier, Game>
    with GameNotifierRef {
  _GameNotifierProviderElement(super.provider);

  @override
  GameCreateInput get gameCreateInput =>
      (origin as GameNotifierProvider).gameCreateInput;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
