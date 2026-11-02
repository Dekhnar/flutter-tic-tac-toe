import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_repository_interface.dart';
import 'package:tic_tac_toe_app/features/game/domain/player_identity.dart';

part 'game_dependencies.g.dart';

// Contracts the app binds in `lib/composition.dart`: the domain and the application never import an implementation.
// An unbound contract throws: a missing binding fails loudly instead of degrading.

/// Kept alive: it is the database of the local games, created on the home screen and played on the board.
@Riverpod(keepAlive: true)
LocalGameRepositoryInterface localGameRepository(Ref ref) =>
    throw UnimplementedError('localGameRepositoryProvider is bound in composition');

@riverpod
OnlineGameRepositoryInterface onlineGameRepository(Ref ref) =>
    throw UnimplementedError('onlineGameRepositoryProvider is bound in composition when Firebase is available');

@riverpod
PlayerIdentity playerIdentity(Ref ref) =>
    throw UnimplementedError('playerIdentityProvider is bound in composition when Firebase is available');
