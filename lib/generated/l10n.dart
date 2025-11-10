// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class I18n {
  I18n();

  static I18n? _current;

  static I18n get current {
    assert(
      _current != null,
      'No instance of I18n was loaded. Try to initialize the I18n delegate before accessing I18n.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<I18n> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = I18n();
      I18n._current = instance;

      return instance;
    });
  }

  static I18n of(BuildContext context) {
    final instance = I18n.maybeOf(context);
    assert(
      instance != null,
      'No instance of I18n present in the widget tree. Did you add I18n.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static I18n? maybeOf(BuildContext context) {
    return Localizations.of<I18n>(context, I18n);
  }

  /// `Retry`
  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
  }

  /// `Loading error`
  String get errorLoading {
    return Intl.message(
      'Loading error',
      name: 'errorLoading',
      desc: '',
      args: [],
    );
  }

  /// `Online 1v1`
  String get online1v1 {
    return Intl.message('Online 1v1', name: 'online1v1', desc: '', args: []);
  }

  /// `Offline 1v1`
  String get offline1v1 {
    return Intl.message('Offline 1v1', name: 'offline1v1', desc: '', args: []);
  }

  /// `Local 1v1`
  String get local1v1 {
    return Intl.message('Local 1v1', name: 'local1v1', desc: '', args: []);
  }

  /// `Play against AI.`
  String get playAgainstAi {
    return Intl.message(
      'Play against AI.',
      name: 'playAgainstAi',
      desc: '',
      args: [],
    );
  }

  /// `Play your friend online.`
  String get playFriendOnline {
    return Intl.message(
      'Play your friend online.',
      name: 'playFriendOnline',
      desc: '',
      args: [],
    );
  }

  /// `It's not your turn.`
  String get notYourTurn {
    return Intl.message(
      'It\'s not your turn.',
      name: 'notYourTurn',
      desc: '',
      args: [],
    );
  }

  /// `This cell is already taken.`
  String get cellAlreadyTaken {
    return Intl.message(
      'This cell is already taken.',
      name: 'cellAlreadyTaken',
      desc: '',
      args: [],
    );
  }

  /// `Paste`
  String get paste {
    return Intl.message('Paste', name: 'paste', desc: '', args: []);
  }

  /// `Start`
  String get start {
    return Intl.message('Start', name: 'start', desc: '', args: []);
  }

  /// `Versus AI (offline)`
  String get versusAiOffline {
    return Intl.message(
      'Versus AI (offline)',
      name: 'versusAiOffline',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get copy {
    return Intl.message('Copy', name: 'copy', desc: '', args: []);
  }

  /// `Create`
  String get create {
    return Intl.message('Create', name: 'create', desc: '', args: []);
  }

  /// `Create game`
  String get createGame {
    return Intl.message('Create game', name: 'createGame', desc: '', args: []);
  }

  /// `EEEE dd MMMM`
  String get datePatternLong {
    return Intl.message(
      'EEEE dd MMMM',
      name: 'datePatternLong',
      desc: '',
      args: [],
    );
  }

  /// `EEEE dd MMMM yyyy`
  String get datePatternLongWithYear {
    return Intl.message(
      'EEEE dd MMMM yyyy',
      name: 'datePatternLongWithYear',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for an opponent…`
  String get waitingForOpponent {
    return Intl.message(
      'Waiting for an opponent…',
      name: 'waitingForOpponent',
      desc: '',
      args: [],
    );
  }

  /// `Invalid cell index.`
  String get invalidCellIndex {
    return Intl.message(
      'Invalid cell index.',
      name: 'invalidCellIndex',
      desc: '',
      args: [],
    );
  }

  /// `Play`
  String get play {
    return Intl.message('Play', name: 'play', desc: '', args: []);
  }

  /// `Play on the same device.`
  String get playOnSameDevice {
    return Intl.message(
      'Play on the same device.',
      name: 'playOnSameDevice',
      desc: '',
      args: [],
    );
  }

  /// `The round is over.`
  String get roundIsOver {
    return Intl.message(
      'The round is over.',
      name: 'roundIsOver',
      desc: '',
      args: [],
    );
  }

  /// `The game has not started yet.`
  String get gameNotStartedYet {
    return Intl.message(
      'The game has not started yet.',
      name: 'gameNotStartedYet',
      desc: '',
      args: [],
    );
  }

  /// `Start the game`
  String get startGame {
    return Intl.message(
      'Start the game',
      name: 'startGame',
      desc: '',
      args: [],
    );
  }

  /// `Link copied`
  String get linkCopied {
    return Intl.message('Link copied', name: 'linkCopied', desc: '', args: []);
  }

  /// `Share link to paste`
  String get shareLinkToPaste {
    return Intl.message(
      'Share link to paste',
      name: 'shareLinkToPaste',
      desc: '',
      args: [],
    );
  }

  /// `Shareable link`
  String get shareLinkToShare {
    return Intl.message(
      'Shareable link',
      name: 'shareLinkToShare',
      desc: '',
      args: [],
    );
  }

  /// `Online game`
  String get onlineGame {
    return Intl.message('Online game', name: 'onlineGame', desc: '', args: []);
  }

  /// `Game not found.`
  String get gameNotFound {
    return Intl.message(
      'Game not found.',
      name: 'gameNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Clipboard is empty`
  String get emptyClipboard {
    return Intl.message(
      'Clipboard is empty',
      name: 'emptyClipboard',
      desc: '',
      args: [],
    );
  }

  /// `Player first name`
  String get playerFirstName {
    return Intl.message(
      'Player first name',
      name: 'playerFirstName',
      desc: '',
      args: [],
    );
  }

  /// `Player 1 first name`
  String get playerOneFirstName {
    return Intl.message(
      'Player 1 first name',
      name: 'playerOneFirstName',
      desc: '',
      args: [],
    );
  }

  /// `Player 2 first name`
  String get playerTwoFirstName {
    return Intl.message(
      'Player 2 first name',
      name: 'playerTwoFirstName',
      desc: '',
      args: [],
    );
  }

  /// `Join`
  String get join {
    return Intl.message('Join', name: 'join', desc: '', args: []);
  }

  /// `Play again`
  String get playAgain {
    return Intl.message('Play again', name: 'playAgain', desc: '', args: []);
  }

  /// `Solo vs AI`
  String get soloVsAi {
    return Intl.message('Solo vs AI', name: 'soloVsAi', desc: '', args: []);
  }

  /// `An opponent must join the game.`
  String get opponentMustJoin {
    return Intl.message(
      'An opponent must join the game.',
      name: 'opponentMustJoin',
      desc: '',
      args: [],
    );
  }

  /// `Please provide a link`
  String get pleaseProvideLink {
    return Intl.message(
      'Please provide a link',
      name: 'pleaseProvideLink',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a first name`
  String get pleaseEnterFirstName {
    return Intl.message(
      'Please enter a first name',
      name: 'pleaseEnterFirstName',
      desc: '',
      args: [],
    );
  }

  /// `Player O wins`
  String get playerOWins {
    return Intl.message(
      'Player O wins',
      name: 'playerOWins',
      desc: '',
      args: [],
    );
  }

  /// `Player X wins`
  String get playerXWins {
    return Intl.message(
      'Player X wins',
      name: 'playerXWins',
      desc: '',
      args: [],
    );
  }

  /// `Draw`
  String get draw {
    return Intl.message('Draw', name: 'draw', desc: '', args: []);
  }

  /// `Empty snapshot after create (no data returned).`
  String get emptySnapshotAfterCreate {
    return Intl.message(
      'Empty snapshot after create (no data returned).',
      name: 'emptySnapshotAfterCreate',
      desc: '',
      args: [],
    );
  }

  /// `Please retry`
  String get pleaseRetry {
    return Intl.message(
      'Please retry',
      name: 'pleaseRetry',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get errorTitle {
    return Intl.message('Error', name: 'errorTitle', desc: '', args: []);
  }

  /// `An error occurred, please try again later.`
  String get errorRetryLater {
    return Intl.message(
      'An error occurred, please try again later.',
      name: 'errorRetryLater',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get quit {
    return Intl.message('Close', name: 'quit', desc: '', args: []);
  }

  /// `Cell {row} {column} empty`
  String boardCellEmpty(Object row, Object column) {
    return Intl.message(
      'Cell $row $column empty',
      name: 'boardCellEmpty',
      desc: '',
      args: [row, column],
    );
  }

  /// `Cell {row} {column} cross`
  String boardCellCross(Object row, Object column) {
    return Intl.message(
      'Cell $row $column cross',
      name: 'boardCellCross',
      desc: '',
      args: [row, column],
    );
  }

  /// `Cell {row} {column} circle`
  String boardCellCircle(Object row, Object column) {
    return Intl.message(
      'Cell $row $column circle',
      name: 'boardCellCircle',
      desc: '',
      args: [row, column],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<I18n> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'fr'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<I18n> load(Locale locale) => I18n.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
