// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr locale. All the
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
  String get localeName => 'fr';

  static String m0(row, column) => "Case ${row} ${column} rond";

  static String m1(row, column) => "Case ${row} ${column} croix";

  static String m2(row, column) => "Case ${row} ${column} vide";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "boardCellCircle": m0,
    "boardCellCross": m1,
    "boardCellEmpty": m2,
    "cellAlreadyTaken": MessageLookupByLibrary.simpleMessage(
      "Cette case est déjà prise.",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Copier"),
    "create": MessageLookupByLibrary.simpleMessage("Créer"),
    "createGame": MessageLookupByLibrary.simpleMessage("Créer la partie"),
    "datePatternLong": MessageLookupByLibrary.simpleMessage("EEEE dd MMMM"),
    "datePatternLongWithYear": MessageLookupByLibrary.simpleMessage(
      "EEEE dd MMMM yyyy",
    ),
    "draw": MessageLookupByLibrary.simpleMessage("Égalité"),
    "emptyClipboard": MessageLookupByLibrary.simpleMessage(
      "Presse-papiers vide",
    ),
    "emptySnapshotAfterCreate": MessageLookupByLibrary.simpleMessage(
      "Données de création introuvables (aucune donnée retournée).",
    ),
    "errorLoading": MessageLookupByLibrary.simpleMessage(
      "Erreur de chargement",
    ),
    "errorRetryLater": MessageLookupByLibrary.simpleMessage(
      "Une erreur est survenue, veuillez réessayer plus tard.",
    ),
    "errorTitle": MessageLookupByLibrary.simpleMessage("Erreur"),
    "gameNotFound": MessageLookupByLibrary.simpleMessage("Partie introuvable."),
    "gameNotStartedYet": MessageLookupByLibrary.simpleMessage(
      "La partie n\'a pas encore commencé.",
    ),
    "invalidCellIndex": MessageLookupByLibrary.simpleMessage(
      "Index de case invalide.",
    ),
    "join": MessageLookupByLibrary.simpleMessage("Rejoindre"),
    "linkCopied": MessageLookupByLibrary.simpleMessage("Lien copié"),
    "local1v1": MessageLookupByLibrary.simpleMessage("1v1 local"),
    "notYourTurn": MessageLookupByLibrary.simpleMessage(
      "Ce n\'est pas ton tour.",
    ),
    "offline1v1": MessageLookupByLibrary.simpleMessage("1v1 hors ligne"),
    "online1v1": MessageLookupByLibrary.simpleMessage("1v1 en ligne"),
    "onlineGame": MessageLookupByLibrary.simpleMessage("Partie en ligne"),
    "opponentMustJoin": MessageLookupByLibrary.simpleMessage(
      "Un adversaire doit rejoindre la partie.",
    ),
    "paste": MessageLookupByLibrary.simpleMessage("Coller"),
    "play": MessageLookupByLibrary.simpleMessage("Jouer"),
    "playAgain": MessageLookupByLibrary.simpleMessage("Rejouer"),
    "playAgainstAi": MessageLookupByLibrary.simpleMessage("Affronte l’IA."),
    "playFriendOnline": MessageLookupByLibrary.simpleMessage(
      "Affronte ton ami en ligne.",
    ),
    "playOnSameDevice": MessageLookupByLibrary.simpleMessage(
      "Jouez à deux sur le même appareil.",
    ),
    "playerFirstName": MessageLookupByLibrary.simpleMessage("Prénom du Joueur"),
    "playerOWins": MessageLookupByLibrary.simpleMessage("Victoire Joueur O"),
    "playerOneFirstName": MessageLookupByLibrary.simpleMessage(
      "Prénom du Joueur 1",
    ),
    "playerTwoFirstName": MessageLookupByLibrary.simpleMessage(
      "Prénom du Joueur 2",
    ),
    "playerXWins": MessageLookupByLibrary.simpleMessage("Victoire Joueur X"),
    "pleaseEnterFirstName": MessageLookupByLibrary.simpleMessage(
      "Veuillez saisir un prénom",
    ),
    "pleaseProvideLink": MessageLookupByLibrary.simpleMessage(
      "Veuillez fournir un lien",
    ),
    "pleaseRetry": MessageLookupByLibrary.simpleMessage("Veuillez réessayer"),
    "quit": MessageLookupByLibrary.simpleMessage("Quitter"),
    "retry": MessageLookupByLibrary.simpleMessage("Réessayer"),
    "roundIsOver": MessageLookupByLibrary.simpleMessage(
      "La manche est terminée.",
    ),
    "shareLinkToPaste": MessageLookupByLibrary.simpleMessage(
      "Lien de partage à coller",
    ),
    "shareLinkToShare": MessageLookupByLibrary.simpleMessage(
      "Lien de partage à partager",
    ),
    "soloVsAi": MessageLookupByLibrary.simpleMessage("Solo vs IA"),
    "start": MessageLookupByLibrary.simpleMessage("Commencer"),
    "startGame": MessageLookupByLibrary.simpleMessage("Lancer la partie"),
    "versusAiOffline": MessageLookupByLibrary.simpleMessage(
      "Contre l’IA (hors ligne)",
    ),
    "waitingForOpponent": MessageLookupByLibrary.simpleMessage(
      "En attente d\'un adversaire…",
    ),
  };
}
