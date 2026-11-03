// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i3;
import 'package:flutter/material.dart' as _i4;
import 'package:tic_tac_toe_app/features/game/application/game_session.dart'
    as _i5;
import 'package:tic_tac_toe_app/features/game/presentation/board/game_board_screen.dart'
    as _i1;
import 'package:tic_tac_toe_app/features/game/presentation/home/game_mode_selection_screen.dart'
    as _i2;

/// generated route for
/// [_i1.GameBoardScreen]
class GameBoardScreenRoute extends _i3.PageRouteInfo<GameBoardScreenRouteArgs> {
  GameBoardScreenRoute({
    _i4.Key? key,
    required _i5.GameSession session,
    List<_i3.PageRouteInfo>? children,
  }) : super(
         GameBoardScreenRoute.name,
         args: GameBoardScreenRouteArgs(key: key, session: session),
         initialChildren: children,
       );

  static const String name = 'GameBoardScreenRoute';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<GameBoardScreenRouteArgs>();
      return _i1.GameBoardScreen(key: args.key, session: args.session);
    },
  );
}

class GameBoardScreenRouteArgs {
  const GameBoardScreenRouteArgs({this.key, required this.session});

  final _i4.Key? key;

  final _i5.GameSession session;

  @override
  String toString() {
    return 'GameBoardScreenRouteArgs{key: $key, session: $session}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GameBoardScreenRouteArgs) return false;
    return key == other.key && session == other.session;
  }

  @override
  int get hashCode => key.hashCode ^ session.hashCode;
}

/// generated route for
/// [_i2.GameModeSelectionScreen]
class GameModeSelectionScreenRoute extends _i3.PageRouteInfo<void> {
  const GameModeSelectionScreenRoute({List<_i3.PageRouteInfo>? children})
    : super(GameModeSelectionScreenRoute.name, initialChildren: children);

  static const String name = 'GameModeSelectionScreenRoute';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      return const _i2.GameModeSelectionScreen();
    },
  );
}
