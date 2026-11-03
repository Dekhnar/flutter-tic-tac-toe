import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of I18n
/// returned by `I18n.of(context)`.
///
/// Applications need to include `I18n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: I18n.localizationsDelegates,
///   supportedLocales: I18n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the I18n.supportedLocales
/// property.
abstract class I18n {
  I18n(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static I18n of(BuildContext context) {
    return Localizations.of<I18n>(context, I18n)!;
  }

  static const LocalizationsDelegate<I18n> delegate = _I18nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('fr')];

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @online1v1.
  ///
  /// In en, this message translates to:
  /// **'Online 1v1'**
  String get online1v1;

  /// No description provided for @local1v1.
  ///
  /// In en, this message translates to:
  /// **'Local 1v1'**
  String get local1v1;

  /// No description provided for @playAgainstAi.
  ///
  /// In en, this message translates to:
  /// **'Play against AI.'**
  String get playAgainstAi;

  /// No description provided for @playFriendOnline.
  ///
  /// In en, this message translates to:
  /// **'Play your friend online.'**
  String get playFriendOnline;

  /// No description provided for @notYourTurn.
  ///
  /// In en, this message translates to:
  /// **'It\'s not your turn.'**
  String get notYourTurn;

  /// No description provided for @cellAlreadyTaken.
  ///
  /// In en, this message translates to:
  /// **'This cell is already taken.'**
  String get cellAlreadyTaken;

  /// No description provided for @paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @createGame.
  ///
  /// In en, this message translates to:
  /// **'Create game'**
  String get createGame;

  /// No description provided for @waitingForOpponent.
  ///
  /// In en, this message translates to:
  /// **'Waiting for an opponent…'**
  String get waitingForOpponent;

  /// No description provided for @invalidCellIndex.
  ///
  /// In en, this message translates to:
  /// **'Invalid cell index.'**
  String get invalidCellIndex;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @playOnSameDevice.
  ///
  /// In en, this message translates to:
  /// **'Play on the same device.'**
  String get playOnSameDevice;

  /// No description provided for @roundIsOver.
  ///
  /// In en, this message translates to:
  /// **'The round is over.'**
  String get roundIsOver;

  /// No description provided for @gameNotStartedYet.
  ///
  /// In en, this message translates to:
  /// **'The game has not started yet.'**
  String get gameNotStartedYet;

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'Start the game'**
  String get startGame;

  /// No description provided for @onlineGame.
  ///
  /// In en, this message translates to:
  /// **'Online game'**
  String get onlineGame;

  /// No description provided for @gameNotFound.
  ///
  /// In en, this message translates to:
  /// **'Game not found.'**
  String get gameNotFound;

  /// No description provided for @playerFirstName.
  ///
  /// In en, this message translates to:
  /// **'Player first name'**
  String get playerFirstName;

  /// No description provided for @playerOneFirstName.
  ///
  /// In en, this message translates to:
  /// **'Player 1 first name'**
  String get playerOneFirstName;

  /// No description provided for @playerTwoFirstName.
  ///
  /// In en, this message translates to:
  /// **'Player 2 first name'**
  String get playerTwoFirstName;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get playAgain;

  /// No description provided for @soloVsAi.
  ///
  /// In en, this message translates to:
  /// **'Solo vs AI'**
  String get soloVsAi;

  /// No description provided for @opponentMustJoin.
  ///
  /// In en, this message translates to:
  /// **'An opponent must join the game.'**
  String get opponentMustJoin;

  /// No description provided for @pleaseEnterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a first name'**
  String get pleaseEnterFirstName;

  /// No description provided for @draw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get draw;

  /// No description provided for @pleaseRetry.
  ///
  /// In en, this message translates to:
  /// **'Please retry'**
  String get pleaseRetry;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @errorRetryLater.
  ///
  /// In en, this message translates to:
  /// **'An error occurred, please try again later.'**
  String get errorRetryLater;

  /// No description provided for @quit.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quit;

  /// No description provided for @boardCellEmpty.
  ///
  /// In en, this message translates to:
  /// **'Cell {row} {column} empty'**
  String boardCellEmpty(int row, int column);

  /// No description provided for @boardCellCross.
  ///
  /// In en, this message translates to:
  /// **'Cell {row} {column} cross'**
  String boardCellCross(int row, int column);

  /// No description provided for @boardCellCircle.
  ///
  /// In en, this message translates to:
  /// **'Cell {row} {column} circle'**
  String boardCellCircle(int row, int column);

  /// No description provided for @turnOf.
  ///
  /// In en, this message translates to:
  /// **'Turn: {player}'**
  String turnOf(String player);

  /// No description provided for @onlineUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Online mode is unavailable in this build.'**
  String get onlineUnavailable;

  /// No description provided for @gameAlreadyFull.
  ///
  /// In en, this message translates to:
  /// **'This game already has two players.'**
  String get gameAlreadyFull;

  /// No description provided for @ai.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get ai;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @playerWithMark.
  ///
  /// In en, this message translates to:
  /// **'{name} ({mark})'**
  String playerWithMark(String name, String mark);

  /// No description provided for @gameCodeValue.
  ///
  /// In en, this message translates to:
  /// **'Game code: {code}'**
  String gameCodeValue(String code);

  /// No description provided for @playerWins.
  ///
  /// In en, this message translates to:
  /// **'{player} wins'**
  String playerWins(String player);

  /// No description provided for @yourTurn.
  ///
  /// In en, this message translates to:
  /// **'Your turn'**
  String get yourTurn;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get codeCopied;

  /// No description provided for @gameCode.
  ///
  /// In en, this message translates to:
  /// **'Game code'**
  String get gameCode;

  /// No description provided for @pleaseEnterGameCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the game code'**
  String get pleaseEnterGameCode;

  /// No description provided for @nameTooLong.
  ///
  /// In en, this message translates to:
  /// **'{max} characters at most'**
  String nameTooLong(int max);

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareInvitation.
  ///
  /// In en, this message translates to:
  /// **'Join my tic-tac-toe game with the code {code}'**
  String shareInvitation(String code);

  /// No description provided for @opponentLeft.
  ///
  /// In en, this message translates to:
  /// **'Your opponent left the game.'**
  String get opponentLeft;

  /// No description provided for @gameAbandoned.
  ///
  /// In en, this message translates to:
  /// **'This game is over: a player left it.'**
  String get gameAbandoned;

  /// No description provided for @leaveGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave the game?'**
  String get leaveGameTitle;

  /// No description provided for @leaveGameMessage.
  ///
  /// In en, this message translates to:
  /// **'Your opponent will see that you left, and the game will end for both of you.'**
  String get leaveGameMessage;

  /// No description provided for @stay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @onlineFailedToStart.
  ///
  /// In en, this message translates to:
  /// **'Online mode could not start. Restart the app to try again.'**
  String get onlineFailedToStart;

  /// No description provided for @serverNotAnswering.
  ///
  /// In en, this message translates to:
  /// **'The server is not answering. Check your connection and try again.'**
  String get serverNotAnswering;

  /// No description provided for @noGameCodeInClipboard.
  ///
  /// In en, this message translates to:
  /// **'The clipboard holds no game code.'**
  String get noGameCodeInClipboard;

  /// No description provided for @invalidGameCode.
  ///
  /// In en, this message translates to:
  /// **'A game code has {length} letters and digits.'**
  String invalidGameCode(int length);

  /// No description provided for @boardCellPlaying.
  ///
  /// In en, this message translates to:
  /// **'Cell {row} {column} being played'**
  String boardCellPlaying(int row, int column);

  /// No description provided for @serverRefused.
  ///
  /// In en, this message translates to:
  /// **'The server refused this action. Update the app, then try again.'**
  String get serverRefused;
}

class _I18nDelegate extends LocalizationsDelegate<I18n> {
  const _I18nDelegate();

  @override
  Future<I18n> load(Locale locale) {
    return SynchronousFuture<I18n>(lookupI18n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_I18nDelegate old) => false;
}

I18n lookupI18n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return I18nEn();
    case 'fr':
      return I18nFr();
  }

  throw FlutterError(
    'I18n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
