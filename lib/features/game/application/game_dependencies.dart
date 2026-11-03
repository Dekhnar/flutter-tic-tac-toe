import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/application/online_play.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_repository.dart';

part 'game_dependencies.g.dart';

// Contracts the app binds in `lib/composition.dart`: the domain and the application never import an implementation.
// An unbound contract throws: a missing binding fails loudly instead of degrading.

/// Kept alive: it is the database of the local games, created on the home screen and played on the board.
@Riverpod(keepAlive: true)
LocalGameRepository localGameRepository(Ref ref) =>
    throw UnimplementedError('localGameRepositoryProvider is bound in composition');

@riverpod
OnlinePlay onlinePlay(Ref ref) => throw UnimplementedError('onlinePlayProvider is bound in composition');
