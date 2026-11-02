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

  static String m3(code) => "Code de la partie : ${code}";

  static String m4(max) => "${max} caractères au maximum";

  static String m5(player) => "Victoire de ${player}";

  static String m6(name, mark) => "${name} (${mark})";

  static String m7(code) => "Rejoins ma partie de morpion avec le code ${code}";

  static String m8(player) => "Tour : ${player}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "ai": MessageLookupByLibrary.simpleMessage("IA"),
    "boardCellCircle": m0,
    "boardCellCross": m1,
    "boardCellEmpty": m2,
    "cellAlreadyTaken": MessageLookupByLibrary.simpleMessage("Cette case est déjà prise."),
    "codeCopied": MessageLookupByLibrary.simpleMessage("Code copié"),
    "copy": MessageLookupByLibrary.simpleMessage("Copier"),
    "create": MessageLookupByLibrary.simpleMessage("Créer"),
    "createGame": MessageLookupByLibrary.simpleMessage("Créer la partie"),
    "draw": MessageLookupByLibrary.simpleMessage("Égalité"),
    "emptyClipboard": MessageLookupByLibrary.simpleMessage("Presse-papiers vide"),
    "errorRetryLater": MessageLookupByLibrary.simpleMessage("Une erreur est survenue, veuillez réessayer plus tard."),
    "errorTitle": MessageLookupByLibrary.simpleMessage("Erreur"),
    "gameAbandoned": MessageLookupByLibrary.simpleMessage("Cette partie est terminée : un joueur l’a quittée."),
    "gameAlreadyFull": MessageLookupByLibrary.simpleMessage("Cette partie a déjà deux joueurs."),
    "gameCode": MessageLookupByLibrary.simpleMessage("Code de la partie"),
    "gameCodeValue": m3,
    "gameNotFound": MessageLookupByLibrary.simpleMessage("Partie introuvable."),
    "gameNotStartedYet": MessageLookupByLibrary.simpleMessage("La partie n\'a pas encore commencé."),
    "invalidCellIndex": MessageLookupByLibrary.simpleMessage("Index de case invalide."),
    "join": MessageLookupByLibrary.simpleMessage("Rejoindre"),
    "loading": MessageLookupByLibrary.simpleMessage("Chargement"),
    "local1v1": MessageLookupByLibrary.simpleMessage("1v1 local"),
    "nameTooLong": m4,
    "notYourTurn": MessageLookupByLibrary.simpleMessage("Ce n\'est pas ton tour."),
    "online1v1": MessageLookupByLibrary.simpleMessage("1v1 en ligne"),
    "onlineGame": MessageLookupByLibrary.simpleMessage("Partie en ligne"),
    "onlineUnavailable": MessageLookupByLibrary.simpleMessage(
      "Le mode en ligne n\'est pas disponible dans cette version.",
    ),
    "opponentLeft": MessageLookupByLibrary.simpleMessage("Ton adversaire a quitté la partie."),
    "opponentMustJoin": MessageLookupByLibrary.simpleMessage("Un adversaire doit rejoindre la partie."),
    "paste": MessageLookupByLibrary.simpleMessage("Coller"),
    "play": MessageLookupByLibrary.simpleMessage("Jouer"),
    "playAgain": MessageLookupByLibrary.simpleMessage("Rejouer"),
    "playAgainstAi": MessageLookupByLibrary.simpleMessage("Affronte l’IA."),
    "playFriendOnline": MessageLookupByLibrary.simpleMessage("Affronte ton ami en ligne."),
    "playOnSameDevice": MessageLookupByLibrary.simpleMessage("Jouez à deux sur le même appareil."),
    "playerFirstName": MessageLookupByLibrary.simpleMessage("Prénom du Joueur"),
    "playerOneFirstName": MessageLookupByLibrary.simpleMessage("Prénom du Joueur 1"),
    "playerTwoFirstName": MessageLookupByLibrary.simpleMessage("Prénom du Joueur 2"),
    "playerWins": m5,
    "playerWithMark": m6,
    "pleaseEnterFirstName": MessageLookupByLibrary.simpleMessage("Veuillez saisir un prénom"),
    "pleaseEnterGameCode": MessageLookupByLibrary.simpleMessage("Veuillez saisir le code de la partie"),
    "pleaseRetry": MessageLookupByLibrary.simpleMessage("Veuillez réessayer"),
    "quit": MessageLookupByLibrary.simpleMessage("Quitter"),
    "retry": MessageLookupByLibrary.simpleMessage("Réessayer"),
    "roundIsOver": MessageLookupByLibrary.simpleMessage("La manche est terminée."),
    "share": MessageLookupByLibrary.simpleMessage("Partager"),
    "shareInvitation": m7,
    "soloVsAi": MessageLookupByLibrary.simpleMessage("Solo vs IA"),
    "start": MessageLookupByLibrary.simpleMessage("Commencer"),
    "startGame": MessageLookupByLibrary.simpleMessage("Lancer la partie"),
    "turnOf": m8,
    "waitingForOpponent": MessageLookupByLibrary.simpleMessage("En attente d\'un adversaire…"),
    "yourTurn": MessageLookupByLibrary.simpleMessage("À toi de jouer"),
  };
}
