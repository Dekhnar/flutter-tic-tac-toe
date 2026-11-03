// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class I18nFr extends I18n {
  I18nFr([String locale = 'fr']) : super(locale);

  @override
  String get retry => 'Réessayer';

  @override
  String get online1v1 => '1v1 en ligne';

  @override
  String get local1v1 => '1v1 local';

  @override
  String get playAgainstAi => 'Affronte l’IA.';

  @override
  String get playFriendOnline => 'Affronte ton ami en ligne.';

  @override
  String get notYourTurn => 'Ce n\'est pas ton tour.';

  @override
  String get cellAlreadyTaken => 'Cette case est déjà prise.';

  @override
  String get paste => 'Coller';

  @override
  String get start => 'Commencer';

  @override
  String get copy => 'Copier';

  @override
  String get create => 'Créer';

  @override
  String get createGame => 'Créer la partie';

  @override
  String get waitingForOpponent => 'En attente d\'un adversaire…';

  @override
  String get invalidCellIndex => 'Index de case invalide.';

  @override
  String get play => 'Jouer';

  @override
  String get playOnSameDevice => 'Jouez à deux sur le même appareil.';

  @override
  String get roundIsOver => 'La manche est terminée.';

  @override
  String get gameNotStartedYet => 'La partie n\'a pas encore commencé.';

  @override
  String get startGame => 'Lancer la partie';

  @override
  String get onlineGame => 'Partie en ligne';

  @override
  String get gameNotFound => 'Partie introuvable.';

  @override
  String get playerFirstName => 'Prénom du Joueur';

  @override
  String get playerOneFirstName => 'Prénom du Joueur 1';

  @override
  String get playerTwoFirstName => 'Prénom du Joueur 2';

  @override
  String get join => 'Rejoindre';

  @override
  String get playAgain => 'Rejouer';

  @override
  String get soloVsAi => 'Solo vs IA';

  @override
  String get opponentMustJoin => 'Un adversaire doit rejoindre la partie.';

  @override
  String get pleaseEnterFirstName => 'Veuillez saisir un prénom';

  @override
  String get draw => 'Égalité';

  @override
  String get pleaseRetry => 'Veuillez réessayer';

  @override
  String get errorTitle => 'Erreur';

  @override
  String get errorRetryLater => 'Une erreur est survenue, veuillez réessayer plus tard.';

  @override
  String get quit => 'Quitter';

  @override
  String boardCellEmpty(int row, int column) {
    return 'Case $row $column vide';
  }

  @override
  String boardCellCross(int row, int column) {
    return 'Case $row $column croix';
  }

  @override
  String boardCellCircle(int row, int column) {
    return 'Case $row $column rond';
  }

  @override
  String turnOf(String player) {
    return 'Tour : $player';
  }

  @override
  String get onlineUnavailable => 'Le mode en ligne n\'est pas disponible dans cette version.';

  @override
  String get gameAlreadyFull => 'Cette partie a déjà deux joueurs.';

  @override
  String get ai => 'IA';

  @override
  String get loading => 'Chargement';

  @override
  String playerWithMark(String name, String mark) {
    return '$name ($mark)';
  }

  @override
  String gameCodeValue(String code) {
    return 'Code de la partie : $code';
  }

  @override
  String playerWins(String player) {
    return 'Victoire de $player';
  }

  @override
  String get yourTurn => 'À toi de jouer';

  @override
  String get codeCopied => 'Code copié';

  @override
  String get gameCode => 'Code de la partie';

  @override
  String get pleaseEnterGameCode => 'Veuillez saisir le code de la partie';

  @override
  String nameTooLong(int max) {
    return '$max caractères au maximum';
  }

  @override
  String get share => 'Partager';

  @override
  String shareInvitation(String code) {
    return 'Rejoins ma partie de morpion avec le code $code';
  }

  @override
  String get opponentLeft => 'Ton adversaire a quitté la partie.';

  @override
  String get gameAbandoned => 'Cette partie est terminée : un joueur l’a quittée.';

  @override
  String get leaveGameTitle => 'Quitter la partie ?';

  @override
  String get leaveGameMessage => 'Ton adversaire verra que tu es parti, et la partie s’arrêtera pour vous deux.';

  @override
  String get stay => 'Rester';

  @override
  String get leave => 'Quitter';

  @override
  String get cancel => 'Annuler';

  @override
  String get onlineFailedToStart => 'Le mode en ligne n\'a pas pu démarrer. Relance l\'application pour réessayer.';

  @override
  String get serverNotAnswering => 'Le serveur ne répond pas. Vérifie ta connexion et réessaie.';

  @override
  String get noGameCodeInClipboard => 'Le presse-papiers ne contient pas de code de partie.';

  @override
  String invalidGameCode(int length) {
    return 'Un code de partie compte $length lettres et chiffres.';
  }

  @override
  String boardCellPlaying(int row, int column) {
    return 'Case $row $column en cours';
  }

  @override
  String get serverRefused => 'Le serveur a refusé cette action. Mets l\'application à jour, puis réessaie.';
}
