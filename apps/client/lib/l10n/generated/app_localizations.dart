import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Application name, shown in the window title and task switcher.
  ///
  /// In en, this message translates to:
  /// **'Memuki'**
  String get appTitle;

  /// Navigation destination for the home screen.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Navigation destination for the list of decks.
  ///
  /// In en, this message translates to:
  /// **'Decks'**
  String get navDecks;

  /// Navigation destination for application settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Heading on the home screen.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Memuki'**
  String get homeWelcomeTitle;

  /// Explanation below the home screen heading while the app has no study features.
  ///
  /// In en, this message translates to:
  /// **'Memuki is in early development. Studying is not available yet.'**
  String get homeWelcomeBody;

  /// Shown on the decks screen when there are no decks.
  ///
  /// In en, this message translates to:
  /// **'No decks yet.'**
  String get decksEmpty;

  /// Heading shown instead of the app when the database cannot be opened at startup.
  ///
  /// In en, this message translates to:
  /// **'Memuki could not open your data'**
  String get startupErrorTitle;

  /// Startup error when the database was written by a newer app version.
  ///
  /// In en, this message translates to:
  /// **'Your data was saved by a newer version of Memuki. Update Memuki to open it. Your data has not been changed.'**
  String get startupErrorTooNew;

  /// Startup error when upgrading the database to the current version failed.
  ///
  /// In en, this message translates to:
  /// **'Memuki could not update your data for this version. Your data has been left as it was.'**
  String get startupErrorMigration;

  /// Startup error for any other failure to open the database.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while opening your data.'**
  String get startupErrorUnknown;

  /// Label above the technical error details on the startup error screen.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get startupErrorDetails;

  /// Settings page for mode, accent colour, card style, and density, and its heading.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// Heading above the sample card that shows the chosen appearance.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get settingsPreview;

  /// Label for the colour mode setting (system, light, dark, sepia).
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get settingsMode;

  /// Colour mode that follows the operating system between light and dark.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsModeSystem;

  /// Light colour mode.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsModeLight;

  /// Dark colour mode.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsModeDark;

  /// Colour mode with warm, aged-paper colours.
  ///
  /// In en, this message translates to:
  /// **'Sepia'**
  String get settingsModeSepia;

  /// Label for the accent colour setting.
  ///
  /// In en, this message translates to:
  /// **'Accent colour'**
  String get settingsAccent;

  /// Name of the coral accent colour, read by screen readers.
  ///
  /// In en, this message translates to:
  /// **'Coral'**
  String get accentCoral;

  /// Name of the orange accent colour, read by screen readers.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get accentOrange;

  /// Name of the mustard accent colour, read by screen readers.
  ///
  /// In en, this message translates to:
  /// **'Mustard'**
  String get accentMustard;

  /// Name of the green accent colour, read by screen readers.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get accentGreen;

  /// Name of the blue accent colour, read by screen readers.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get accentBlue;

  /// Name of the purple accent colour, read by screen readers.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get accentPurple;

  /// Name of the grey accent colour, read by screen readers.
  ///
  /// In en, this message translates to:
  /// **'Grey'**
  String get accentGrey;

  /// Label for the setting for how study cards are drawn.
  ///
  /// In en, this message translates to:
  /// **'Card style'**
  String get settingsCardStyle;

  /// Card style: a plain rounded card.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get cardStyleStandard;

  /// Card style: a ruled notecard with a folded corner.
  ///
  /// In en, this message translates to:
  /// **'Notecard'**
  String get cardStyleNotecard;

  /// Card style: no card frame, content directly on the page.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get cardStyleMinimal;

  /// Label for the setting for how much space the interface uses.
  ///
  /// In en, this message translates to:
  /// **'Density'**
  String get settingsDensity;

  /// Density option with more space.
  ///
  /// In en, this message translates to:
  /// **'Comfortable'**
  String get densityComfortable;

  /// Density option with less space, fitting more on screen.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get densityCompact;

  /// Meaning of 猫 (ねこ) on the sample card in the appearance preview.
  ///
  /// In en, this message translates to:
  /// **'cat'**
  String get settingsPreviewMeaning;

  /// Grade: the answer was forgotten.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get gradeAgain;

  /// Grade: recalled with difficulty.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get gradeHard;

  /// Grade: recalled correctly.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get gradeGood;

  /// Grade: recalled easily.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get gradeEasy;

  /// A duration in minutes, such as the interval shown on a grade button.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 min} other{{count} min}}'**
  String durationMinutes(int count);

  /// A duration in days, such as the interval shown on a grade button.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String durationDays(int count);

  /// Field editor: marks the selection as base text with a reading above it.
  ///
  /// In en, this message translates to:
  /// **'Ruby'**
  String get editorRuby;

  /// Field editor: marks the selection as emphasised.
  ///
  /// In en, this message translates to:
  /// **'Emphasis'**
  String get editorEmphasis;

  /// Field editor: marks the selection as subscript.
  ///
  /// In en, this message translates to:
  /// **'Subscript'**
  String get editorSubscript;

  /// Field editor: marks the selection as superscript.
  ///
  /// In en, this message translates to:
  /// **'Superscript'**
  String get editorSuperscript;

  /// Field editor: marks the selection as text in another language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get editorLanguage;

  /// Field editor: label of the field for a ruby's reading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get editorReading;

  /// Field editor: label of the field for a language tag such as zh-Hans.
  ///
  /// In en, this message translates to:
  /// **'Language tag'**
  String get editorLanguageTag;

  /// Field editor: removes the mark the cursor is in, keeping its text.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get editorRemoveMark;

  /// Field editor: undoes the last change.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get editorUndo;

  /// Field editor: redoes the last undone change.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get editorRedo;

  /// Template editor: heading of the front of the card, what is asked.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get templateFront;

  /// Template editor: heading of the back of the card, the answer.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get templateBack;

  /// Template editor: shown in a side of the card that has no lines.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get templateEmptySide;

  /// Template editor: adds a line that shows a field.
  ///
  /// In en, this message translates to:
  /// **'Field'**
  String get templateAddField;

  /// Template editor: adds a line of text.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get templateAddText;

  /// Template editor: adds lines shown only when a field is filled.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get templateAddCondition;

  /// Template editor: label of the picker for which field a line shows.
  ///
  /// In en, this message translates to:
  /// **'Field'**
  String get templateField;

  /// Template editor: label of the picker for what a field is on the card, which decides its styling.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get templateRole;

  /// Template editor: the role choice for a field without a role, shown as body text.
  ///
  /// In en, this message translates to:
  /// **'No role'**
  String get templateNoRole;

  /// Template editor: the role of a field that asks the question, shown large.
  ///
  /// In en, this message translates to:
  /// **'Prompt'**
  String get templateRolePrompt;

  /// Template editor: the role of a field that gives a reading, such as kana for a word.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get templateRoleReading;

  /// Template editor: the role of a field that answers the prompt.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get templateRoleAnswer;

  /// Template editor: the role of a field with an example, such as a sentence.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get templateRoleExample;

  /// Template editor: label of the picker for the field that must be filled for the lines under it to show.
  ///
  /// In en, this message translates to:
  /// **'Only when filled'**
  String get templateConditionField;

  /// Template editor: label of a line that is edited as source, because it does not fit the other kinds of line.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get templateSource;

  /// Template editor: heading of the fields a note must fill for this template to make a card.
  ///
  /// In en, this message translates to:
  /// **'Required fields'**
  String get templateRequires;

  /// Template editor: explains the required fields.
  ///
  /// In en, this message translates to:
  /// **'A note makes this card only when all of these are filled.'**
  String get templateRequiresHint;

  /// Template editor: moves a line up.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get templateMoveUp;

  /// Template editor: moves a line down.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get templateMoveDown;

  /// Template editor: removes a line.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get templateRemove;

  /// Template editor: a field the template names that the note type does not have.
  ///
  /// In en, this message translates to:
  /// **'{name} (not in this note type)'**
  String templateMissingField(String name);

  /// Template editor: a line that shows a field. {field} and {role} are pickers for the field and its role, so keep both, in the order the language needs.
  ///
  /// In en, this message translates to:
  /// **'{field} as {role}'**
  String templateFieldAs(String field, String role);

  /// Template editor: a condition; the lines under it show only when the field is filled. {field} is a picker for the field.
  ///
  /// In en, this message translates to:
  /// **'If {field} is filled'**
  String templateIfFilled(String field);

  /// Template editor: opens a menu of the kinds of line to add to a side of the card.
  ///
  /// In en, this message translates to:
  /// **'Add line'**
  String get templateAddLine;

  /// Template editor: opens a menu of the kinds of line to add inside a condition.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get templateAddInCondition;

  /// Template editor: explains the Field entry of the Add line menu.
  ///
  /// In en, this message translates to:
  /// **'Shows a field, styled by its role.'**
  String get templateAddFieldHint;

  /// Template editor: explains the Text entry of the Add line menu.
  ///
  /// In en, this message translates to:
  /// **'The same text on every card.'**
  String get templateAddTextHint;

  /// Template editor: explains the Condition entry of the Add line menu.
  ///
  /// In en, this message translates to:
  /// **'Lines shown only when a field is filled.'**
  String get templateAddConditionHint;

  /// Template editor: the handle that reorders a line by dragging.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get templateDrag;

  /// Template editor: opens the menu to move or remove a line.
  ///
  /// In en, this message translates to:
  /// **'Line options'**
  String get templateLineMenu;

  /// Card: label before a word's spellings and readings, from a dictionary.
  ///
  /// In en, this message translates to:
  /// **'Forms'**
  String get contentForms;

  /// Card: names the button of a sound file, for screen readers.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get contentAudio;

  /// Field editor: label of the field that edits a block, such as a dictionary sense, as source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get editorSource;

  /// Field editor: toolbox item that adds one meaning of a word, with its tags, glosses, and examples.
  ///
  /// In en, this message translates to:
  /// **'Sense'**
  String get editorSense;

  /// Field editor: toolbox item that adds a list, such as the glosses of a sense.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get editorList;

  /// Field editor: toolbox item that adds an example sentence with its translation.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get editorExample;

  /// Field editor: toolbox item that adds a dictionary label, such as a part of speech, to a sense.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get editorTag;

  /// Field editor: name of an item of a list.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get editorItem;

  /// Field editor: name of, and placeholder in, the translation of an example sentence.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get editorTranslation;

  /// Field editor: placeholder in the sentence of an example.
  ///
  /// In en, this message translates to:
  /// **'Sentence'**
  String get editorSentence;

  /// Field editor: adds an item to the end of a list.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get editorAddItem;

  /// Field editor: removes an item from a list.
  ///
  /// In en, this message translates to:
  /// **'Remove item'**
  String get editorRemoveItem;

  /// Field editor: label of what a tag labels, such as a part of speech.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get editorTagCategory;

  /// Field editor: label of the text a tag shows, such as adverb.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get editorTagLabel;

  /// Field editor: tag category for parts of speech.
  ///
  /// In en, this message translates to:
  /// **'Part of speech'**
  String get editorTagPos;

  /// Field editor: tag category for other labels, such as how formal a word is.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get editorTagMisc;

  /// Field editor: tag category for subjects, such as computing.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get editorTagField;

  /// Field editor: tag category for dialects.
  ///
  /// In en, this message translates to:
  /// **'Dialect'**
  String get editorTagDialect;

  /// Field editor: finishes editing a tag.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get editorDone;

  /// Field editor: heading of the blocks that can be dragged into the field.
  ///
  /// In en, this message translates to:
  /// **'Blocks'**
  String get editorToolbox;

  /// Field editor: tooltip of a block in the toolbox.
  ///
  /// In en, this message translates to:
  /// **'Drag into the field, or tap to put in at the cursor'**
  String get editorToolboxHint;

  /// Field editor: adds a dictionary label, such as a part of speech, to a sense; shown in place of the tags while there are none.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get editorAddTag;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
