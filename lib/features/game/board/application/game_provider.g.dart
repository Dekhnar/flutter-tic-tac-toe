// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gameNotifierHash() => r'545860712b3d49879a0cf7427b0fac4a08a89c98';

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

abstract class _$GameNotifier extends BuildlessAutoDisposeStreamNotifier<Game> {
  late final GameSession session;

  Stream<Game> build({required GameSession session});
}

/// See also [GameNotifier].
@ProviderFor(GameNotifier)
const gameNotifierProvider = GameNotifierFamily();

/// See also [GameNotifier].
class GameNotifierFamily extends Family<AsyncValue<Game>> {
  /// See also [GameNotifier].
  const GameNotifierFamily();

  /// See also [GameNotifier].
  GameNotifierProvider call({required GameSession session}) {
    return GameNotifierProvider(session: session);
  }

  @override
  GameNotifierProvider getProviderOverride(
    covariant GameNotifierProvider provider,
  ) {
    return call(session: provider.session);
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
    extends AutoDisposeStreamNotifierProviderImpl<GameNotifier, Game> {
  /// See also [GameNotifier].
  GameNotifierProvider({required GameSession session})
    : this._internal(
        () => GameNotifier()..session = session,
        from: gameNotifierProvider,
        name: r'gameNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$gameNotifierHash,
        dependencies: GameNotifierFamily._dependencies,
        allTransitiveDependencies:
            GameNotifierFamily._allTransitiveDependencies,
        session: session,
      );

  GameNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.session,
  }) : super.internal();

  final GameSession session;

  @override
  Stream<Game> runNotifierBuild(covariant GameNotifier notifier) {
    return notifier.build(session: session);
  }

  @override
  Override overrideWith(GameNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: GameNotifierProvider._internal(
        () => create()..session = session,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        session: session,
      ),
    );
  }

  @override
  AutoDisposeStreamNotifierProviderElement<GameNotifier, Game> createElement() {
    return _GameNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GameNotifierProvider && other.session == session;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, session.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GameNotifierRef on AutoDisposeStreamNotifierProviderRef<Game> {
  /// The parameter `session` of this provider.
  GameSession get session;
}

class _GameNotifierProviderElement
    extends AutoDisposeStreamNotifierProviderElement<GameNotifier, Game>
    with GameNotifierRef {
  _GameNotifierProviderElement(super.provider);

  @override
  GameSession get session => (origin as GameNotifierProvider).session;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
