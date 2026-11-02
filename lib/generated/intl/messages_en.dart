// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(row, column) => "Cell ${row} ${column} circle";

  static String m1(row, column) => "Cell ${row} ${column} cross";

  static String m2(row, column) => "Cell ${row} ${column} empty";

  static String m3(code) => "Game code: ${code}";

  static String m4(player) => "${player} wins";

  static String m5(name, mark) => "${name} (${mark})";

  static String m6(player) => "Turn: ${player}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "ai": MessageLookupByLibrary.simpleMessage("AI"),
    "boardCellCircle": m0,
    "boardCellCross": m1,
    "boardCellEmpty": m2,
    "cellAlreadyTaken": MessageLookupByLibrary.simpleMessage("This cell is already taken."),
    "copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "create": MessageLookupByLibrary.simpleMessage("Create"),
    "createGame": MessageLookupByLibrary.simpleMessage("Create game"),
    "draw": MessageLookupByLibrary.simpleMessage("Draw"),
    "emptyClipboard": MessageLookupByLibrary.simpleMessage("Clipboard is empty"),
    "errorRetryLater": MessageLookupByLibrary.simpleMessage("An error occurred, please try again later."),
    "errorTitle": MessageLookupByLibrary.simpleMessage("Error"),
    "gameAlreadyFull": MessageLookupByLibrary.simpleMessage("This game already has two players."),
    "gameCodeValue": m3,
    "gameNotFound": MessageLookupByLibrary.simpleMessage("Game not found."),
    "gameNotStartedYet": MessageLookupByLibrary.simpleMessage("The game has not started yet."),
    "invalidCellIndex": MessageLookupByLibrary.simpleMessage("Invalid cell index."),
    "join": MessageLookupByLibrary.simpleMessage("Join"),
    "linkCopied": MessageLookupByLibrary.simpleMessage("Link copied"),
    "loading": MessageLookupByLibrary.simpleMessage("Loading"),
    "local1v1": MessageLookupByLibrary.simpleMessage("Local 1v1"),
    "notYourTurn": MessageLookupByLibrary.simpleMessage("It\'s not your turn."),
    "online1v1": MessageLookupByLibrary.simpleMessage("Online 1v1"),
    "onlineGame": MessageLookupByLibrary.simpleMessage("Online game"),
    "onlineUnavailable": MessageLookupByLibrary.simpleMessage("Online mode is unavailable in this build."),
    "opponentMustJoin": MessageLookupByLibrary.simpleMessage("An opponent must join the game."),
    "paste": MessageLookupByLibrary.simpleMessage("Paste"),
    "play": MessageLookupByLibrary.simpleMessage("Play"),
    "playAgain": MessageLookupByLibrary.simpleMessage("Play again"),
    "playAgainstAi": MessageLookupByLibrary.simpleMessage("Play against AI."),
    "playFriendOnline": MessageLookupByLibrary.simpleMessage("Play your friend online."),
    "playOnSameDevice": MessageLookupByLibrary.simpleMessage("Play on the same device."),
    "playerFirstName": MessageLookupByLibrary.simpleMessage("Player first name"),
    "playerOneFirstName": MessageLookupByLibrary.simpleMessage("Player 1 first name"),
    "playerTwoFirstName": MessageLookupByLibrary.simpleMessage("Player 2 first name"),
    "playerWins": m4,
    "playerWithMark": m5,
    "pleaseEnterFirstName": MessageLookupByLibrary.simpleMessage("Please enter a first name"),
    "pleaseProvideLink": MessageLookupByLibrary.simpleMessage("Please provide a link"),
    "pleaseRetry": MessageLookupByLibrary.simpleMessage("Please retry"),
    "quit": MessageLookupByLibrary.simpleMessage("Close"),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "roundIsOver": MessageLookupByLibrary.simpleMessage("The round is over."),
    "shareLinkToPaste": MessageLookupByLibrary.simpleMessage("Share link to paste"),
    "shareLinkToShare": MessageLookupByLibrary.simpleMessage("Shareable link"),
    "soloVsAi": MessageLookupByLibrary.simpleMessage("Solo vs AI"),
    "start": MessageLookupByLibrary.simpleMessage("Start"),
    "startGame": MessageLookupByLibrary.simpleMessage("Start the game"),
    "turnOf": m6,
    "waitingForOpponent": MessageLookupByLibrary.simpleMessage("Waiting for an opponent…"),
    "yourTurn": MessageLookupByLibrary.simpleMessage("Your turn"),
  };
}
