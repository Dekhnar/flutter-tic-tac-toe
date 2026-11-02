// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class I18nEn extends I18n {
  I18nEn([String locale = 'en']) : super(locale);

  @override
  String get retry => 'Retry';

  @override
  String get online1v1 => 'Online 1v1';

  @override
  String get local1v1 => 'Local 1v1';

  @override
  String get playAgainstAi => 'Play against AI.';

  @override
  String get playFriendOnline => 'Play your friend online.';

  @override
  String get notYourTurn => 'It\'s not your turn.';

  @override
  String get cellAlreadyTaken => 'This cell is already taken.';

  @override
  String get paste => 'Paste';

  @override
  String get start => 'Start';

  @override
  String get copy => 'Copy';

  @override
  String get create => 'Create';

  @override
  String get createGame => 'Create game';

  @override
  String get waitingForOpponent => 'Waiting for an opponent…';

  @override
  String get invalidCellIndex => 'Invalid cell index.';

  @override
  String get play => 'Play';

  @override
  String get playOnSameDevice => 'Play on the same device.';

  @override
  String get roundIsOver => 'The round is over.';

  @override
  String get gameNotStartedYet => 'The game has not started yet.';

  @override
  String get startGame => 'Start the game';

  @override
  String get onlineGame => 'Online game';

  @override
  String get gameNotFound => 'Game not found.';

  @override
  String get emptyClipboard => 'Clipboard is empty';

  @override
  String get playerFirstName => 'Player first name';

  @override
  String get playerOneFirstName => 'Player 1 first name';

  @override
  String get playerTwoFirstName => 'Player 2 first name';

  @override
  String get join => 'Join';

  @override
  String get playAgain => 'Play again';

  @override
  String get soloVsAi => 'Solo vs AI';

  @override
  String get opponentMustJoin => 'An opponent must join the game.';

  @override
  String get pleaseEnterFirstName => 'Please enter a first name';

  @override
  String get draw => 'Draw';

  @override
  String get pleaseRetry => 'Please retry';

  @override
  String get errorTitle => 'Error';

  @override
  String get errorRetryLater => 'An error occurred, please try again later.';

  @override
  String get quit => 'Quit';

  @override
  String boardCellEmpty(int row, int column) {
    return 'Cell $row $column empty';
  }

  @override
  String boardCellCross(int row, int column) {
    return 'Cell $row $column cross';
  }

  @override
  String boardCellCircle(int row, int column) {
    return 'Cell $row $column circle';
  }

  @override
  String turnOf(String player) {
    return 'Turn: $player';
  }

  @override
  String get onlineUnavailable => 'Online mode is unavailable in this build.';

  @override
  String get gameAlreadyFull => 'This game already has two players.';

  @override
  String get ai => 'AI';

  @override
  String get loading => 'Loading';

  @override
  String playerWithMark(String name, String mark) {
    return '$name ($mark)';
  }

  @override
  String gameCodeValue(String code) {
    return 'Game code: $code';
  }

  @override
  String playerWins(String player) {
    return '$player wins';
  }

  @override
  String get yourTurn => 'Your turn';

  @override
  String get codeCopied => 'Code copied';

  @override
  String get gameCode => 'Game code';

  @override
  String get pleaseEnterGameCode => 'Please enter the game code';

  @override
  String nameTooLong(int max) {
    return '$max characters at most';
  }

  @override
  String get share => 'Share';

  @override
  String shareInvitation(String code) {
    return 'Join my tic-tac-toe game with the code $code';
  }

  @override
  String get opponentLeft => 'Your opponent left the game.';

  @override
  String get gameAbandoned => 'This game is over: a player left it.';

  @override
  String get leaveGameTitle => 'Leave the game?';

  @override
  String get leaveGameMessage => 'Your opponent will see that you left, and the game will end for both of you.';

  @override
  String get stay => 'Stay';

  @override
  String get leave => 'Leave';
}
