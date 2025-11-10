// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i7;
import 'package:flutter/material.dart' as _i8;
import 'package:tic_tac_toe_app/features/game/board/application/game_state.dart'
    as _i9;
import 'package:tic_tac_toe_app/features/game/board/presentation/game_board_screen.dart'
    as _i2;
import 'package:tic_tac_toe_app/features/game/creation/presentation/game_create_offline_dialog.dart'
    as _i3;
import 'package:tic_tac_toe_app/features/game/creation/presentation/game_create_online_dialog.dart'
    as _i4;
import 'package:tic_tac_toe_app/features/game/home/presentation/game_modes_selection_screen.dart'
    as _i6;
import 'package:tic_tac_toe_app/shared/routing/empty_router.dart' as _i1;
import 'package:uuid/uuid.dart' as _i5;

/// generated route for
/// [_i1.EmptyRouter]
class EmptyRouter extends _i7.PageRouteInfo<void> {
  const EmptyRouter({List<_i7.PageRouteInfo>? children})
    : super(EmptyRouter.name, initialChildren: children);

  static const String name = 'EmptyRouter';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i1.EmptyRouter();
    },
  );
}

/// generated route for
/// [_i2.GameBoardScreen]
class GameBoardScreenRoute extends _i7.PageRouteInfo<GameBoardScreenRouteArgs> {
  GameBoardScreenRoute({
    _i8.Key? key,
    required _i9.GameCreateInput input,
    List<_i7.PageRouteInfo>? children,
  }) : super(
         GameBoardScreenRoute.name,
         args: GameBoardScreenRouteArgs(key: key, input: input),
         initialChildren: children,
       );

  static const String name = 'GameBoardScreenRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<GameBoardScreenRouteArgs>();
      return _i2.GameBoardScreen(key: args.key, input: args.input);
    },
  );
}

class GameBoardScreenRouteArgs {
  const GameBoardScreenRouteArgs({this.key, required this.input});

  final _i8.Key? key;

  final _i9.GameCreateInput input;

  @override
  String toString() {
    return 'GameBoardScreenRouteArgs{key: $key, input: $input}';
  }
}

/// generated route for
/// [_i3.GameCreateOfflineDialog]
class GameCreateOfflineDialogRoute
    extends _i7.PageRouteInfo<GameCreateOfflineDialogRouteArgs> {
  GameCreateOfflineDialogRoute({
    _i8.Key? key,
    bool vsAi = false,
    List<_i7.PageRouteInfo>? children,
  }) : super(
         GameCreateOfflineDialogRoute.name,
         args: GameCreateOfflineDialogRouteArgs(key: key, vsAi: vsAi),
         initialChildren: children,
       );

  static const String name = 'GameCreateOfflineDialogRoute';

  static _i7.PageInfo page = _i7.PageInfo(
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

  final _i8.Key? key;

  final bool vsAi;

  @override
  String toString() {
    return 'GameCreateOfflineDialogRouteArgs{key: $key, vsAi: $vsAi}';
  }
}

/// generated route for
/// [_i4.GameCreateOnlineDialog]
class GameCreateOnlineDialogRoute
    extends _i7.PageRouteInfo<GameCreateOnlineDialogRouteArgs> {
  GameCreateOnlineDialogRoute({
    _i8.Key? key,
    _i5.Uuid uuid = const _i5.Uuid(),
    List<_i7.PageRouteInfo>? children,
  }) : super(
         GameCreateOnlineDialogRoute.name,
         args: GameCreateOnlineDialogRouteArgs(key: key, uuid: uuid),
         initialChildren: children,
       );

  static const String name = 'GameCreateOnlineDialogRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<GameCreateOnlineDialogRouteArgs>(
        orElse: () => const GameCreateOnlineDialogRouteArgs(),
      );
      return _i4.GameCreateOnlineDialog(key: args.key, uuid: args.uuid);
    },
  );
}

class GameCreateOnlineDialogRouteArgs {
  const GameCreateOnlineDialogRouteArgs({
    this.key,
    this.uuid = const _i5.Uuid(),
  });

  final _i8.Key? key;

  final _i5.Uuid uuid;

  @override
  String toString() {
    return 'GameCreateOnlineDialogRouteArgs{key: $key, uuid: $uuid}';
  }
}

/// generated route for
/// [_i6.GameModeSelectionScreen]
class GameModeSelectionScreenRoute extends _i7.PageRouteInfo<void> {
  const GameModeSelectionScreenRoute({List<_i7.PageRouteInfo>? children})
    : super(GameModeSelectionScreenRoute.name, initialChildren: children);

  static const String name = 'GameModeSelectionScreenRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i6.GameModeSelectionScreen();
    },
  );
}
