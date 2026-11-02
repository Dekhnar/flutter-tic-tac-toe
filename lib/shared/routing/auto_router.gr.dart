// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i6;
import 'package:flutter/material.dart' as _i7;
import 'package:tic_tac_toe_app/features/game/application/game_session.dart'
    as _i8;
import 'package:tic_tac_toe_app/features/game/board/presentation/game_board_screen.dart'
    as _i2;
import 'package:tic_tac_toe_app/features/game/creation/presentation/game_create_offline_dialog.dart'
    as _i3;
import 'package:tic_tac_toe_app/features/game/creation/presentation/game_create_online_dialog.dart'
    as _i4;
import 'package:tic_tac_toe_app/features/game/home/presentation/game_modes_selection_screen.dart'
    as _i5;
import 'package:tic_tac_toe_app/shared/routing/empty_router.dart' as _i1;

/// generated route for
/// [_i1.EmptyRouter]
class EmptyRouter extends _i6.PageRouteInfo<void> {
  const EmptyRouter({List<_i6.PageRouteInfo>? children})
    : super(EmptyRouter.name, initialChildren: children);

  static const String name = 'EmptyRouter';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i1.EmptyRouter();
    },
  );
}

/// generated route for
/// [_i2.GameBoardScreen]
class GameBoardScreenRoute extends _i6.PageRouteInfo<GameBoardScreenRouteArgs> {
  GameBoardScreenRoute({
    _i7.Key? key,
    required _i8.GameSession session,
    List<_i6.PageRouteInfo>? children,
  }) : super(
         GameBoardScreenRoute.name,
         args: GameBoardScreenRouteArgs(key: key, session: session),
         initialChildren: children,
       );

  static const String name = 'GameBoardScreenRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<GameBoardScreenRouteArgs>();
      return _i2.GameBoardScreen(key: args.key, session: args.session);
    },
  );
}

class GameBoardScreenRouteArgs {
  const GameBoardScreenRouteArgs({this.key, required this.session});

  final _i7.Key? key;

  final _i8.GameSession session;

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
/// [_i3.GameCreateOfflineDialog]
class GameCreateOfflineDialogRoute
    extends _i6.PageRouteInfo<GameCreateOfflineDialogRouteArgs> {
  GameCreateOfflineDialogRoute({
    _i7.Key? key,
    bool vsAi = false,
    List<_i6.PageRouteInfo>? children,
  }) : super(
         GameCreateOfflineDialogRoute.name,
         args: GameCreateOfflineDialogRouteArgs(key: key, vsAi: vsAi),
         initialChildren: children,
       );

  static const String name = 'GameCreateOfflineDialogRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<GameCreateOfflineDialogRouteArgs>(
        orElse: () => const GameCreateOfflineDialogRouteArgs(),
      );
      return _i3.GameCreateOfflineDialog(key: args.key, vsAi: args.vsAi);
    },
  );
}

class GameCreateOfflineDialogRouteArgs {
  const GameCreateOfflineDialogRouteArgs({this.key, this.vsAi = false});

  final _i7.Key? key;

  final bool vsAi;

  @override
  String toString() {
    return 'GameCreateOfflineDialogRouteArgs{key: $key, vsAi: $vsAi}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GameCreateOfflineDialogRouteArgs) return false;
    return key == other.key && vsAi == other.vsAi;
  }

  @override
  int get hashCode => key.hashCode ^ vsAi.hashCode;
}

/// generated route for
/// [_i4.GameCreateOnlineDialog]
class GameCreateOnlineDialogRoute extends _i6.PageRouteInfo<void> {
  const GameCreateOnlineDialogRoute({List<_i6.PageRouteInfo>? children})
    : super(GameCreateOnlineDialogRoute.name, initialChildren: children);

  static const String name = 'GameCreateOnlineDialogRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i4.GameCreateOnlineDialog();
    },
  );
}

/// generated route for
/// [_i5.GameModeSelectionScreen]
class GameModeSelectionScreenRoute extends _i6.PageRouteInfo<void> {
  const GameModeSelectionScreenRoute({List<_i6.PageRouteInfo>? children})
    : super(GameModeSelectionScreenRoute.name, initialChildren: children);

  static const String name = 'GameModeSelectionScreenRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i5.GameModeSelectionScreen();
    },
  );
}
