import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/application/online_play.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_repository.dart';

part 'game_dependencies.g.dart';

// Bound in `lib/composition.dart`. An unbound contract throws, so that a missing binding fails loudly.

/// Kept alive: local games are created on the home screen, then played on the board.
@Riverpod(keepAlive: true)
LocalGameRepository localGameRepository(Ref ref) =>
    throw UnimplementedError('localGameRepositoryProvider is bound in composition');

@riverpod
OnlinePlay onlinePlay(Ref ref) => throw UnimplementedError('onlinePlayProvider is bound in composition');
