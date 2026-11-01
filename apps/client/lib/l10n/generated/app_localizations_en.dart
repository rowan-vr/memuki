// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Memuki';

  @override
  String get navHome => 'Home';

  @override
  String get navDecks => 'Decks';

  @override
  String get navSettings => 'Settings';

  @override
  String get homeWelcomeTitle => 'Welcome to Memuki';

  @override
  String get homeWelcomeBody =>
      'Memuki is in early development. Studying is not available yet.';

  @override
  String get decksEmpty => 'No decks yet.';

  @override
  String get startupErrorTitle => 'Memuki could not open your data';

  @override
  String get startupErrorTooNew =>
      'Your data was saved by a newer version of Memuki. Update Memuki to open it. Your data has not been changed.';

  @override
  String get startupErrorMigration =>
      'Memuki could not update your data for this version. Your data has been left as it was.';

  @override
  String get startupErrorUnknown =>
      'Something went wrong while opening your data.';

  @override
  String get startupErrorDetails => 'Details';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsPreview => 'Preview';

  @override
  String get settingsMode => 'Mode';

  @override
  String get settingsModeSystem => 'System';

  @override
  String get settingsModeLight => 'Light';

  @override
  String get settingsModeDark => 'Dark';

  @override
  String get settingsModeSepia => 'Sepia';

  @override
  String get settingsAccent => 'Accent colour';

  @override
  String get accentCoral => 'Coral';

  @override
  String get accentOrange => 'Orange';

  @override
  String get accentMustard => 'Mustard';

  @override
  String get accentGreen => 'Green';

  @override
  String get accentBlue => 'Blue';

  @override
  String get accentPurple => 'Purple';

  @override
  String get accentGrey => 'Grey';

  @override
  String get settingsCardStyle => 'Card style';

  @override
  String get cardStyleStandard => 'Standard';

  @override
  String get cardStyleNotecard => 'Notecard';

  @override
  String get cardStyleMinimal => 'Minimal';

  @override
  String get settingsDensity => 'Density';

  @override
  String get densityComfortable => 'Comfortable';

  @override
  String get densityCompact => 'Compact';

  @override
  String get settingsPreviewMeaning => 'cat';

  @override
  String get gradeAgain => 'Again';

  @override
  String get gradeHard => 'Hard';

  @override
  String get gradeGood => 'Good';

  @override
  String get gradeEasy => 'Easy';

  @override
  String durationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min',
      one: '1 min',
    );
    return '$_temp0';
  }

  @override
  String durationDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get editorRuby => 'Ruby';

  @override
  String get editorEmphasis => 'Emphasis';

  @override
  String get editorSubscript => 'Subscript';

  @override
  String get editorSuperscript => 'Superscript';

  @override
  String get editorLanguage => 'Language';

  @override
  String get editorReading => 'Reading';

  @override
  String get editorLanguageTag => 'Language tag';

  @override
  String get editorRemoveMark => 'Remove';

  @override
  String get editorUndo => 'Undo';

  @override
  String get editorRedo => 'Redo';

  @override
  String get templateFront => 'Front';

  @override
  String get templateBack => 'Back';

  @override
  String get templateEmptySide => 'Nothing here yet.';

  @override
  String get templateAddField => 'Field';

  @override
  String get templateAddText => 'Text';

  @override
  String get templateAddCondition => 'Condition';

  @override
  String get templateField => 'Field';

  @override
  String get templateRole => 'Role';

  @override
  String get templateNoRole => 'No role';

  @override
  String get templateRolePrompt => 'Prompt';

  @override
  String get templateRoleReading => 'Reading';

  @override
  String get templateRoleAnswer => 'Answer';

  @override
  String get templateRoleExample => 'Example';

  @override
  String get templateConditionField => 'Only when filled';

  @override
  String get templateSource => 'Source';

  @override
  String get templateRequires => 'Required fields';

  @override
  String get templateRequiresHint =>
      'A note makes this card only when all of these are filled.';

  @override
  String get templateMoveUp => 'Move up';

  @override
  String get templateMoveDown => 'Move down';

  @override
  String get templateRemove => 'Remove';

  @override
  String templateMissingField(String name) {
    return '$name (not in this note type)';
  }

  @override
  String templateFieldAs(String field, String role) {
    return '$field as $role';
  }

  @override
  String templateIfFilled(String field) {
    return 'If $field is filled';
  }

  @override
  String get templateAddLine => 'Add line';

  @override
  String get templateAddInCondition => 'Add';

  @override
  String get templateAddFieldHint => 'Shows a field, styled by its role.';

  @override
  String get templateAddTextHint => 'The same text on every card.';

  @override
  String get templateAddConditionHint =>
      'Lines shown only when a field is filled.';

  @override
  String get templateDrag => 'Drag to reorder';

  @override
  String get templateLineMenu => 'Line options';

  @override
  String get contentForms => 'Forms';

  @override
  String get contentAudio => 'Audio';

  @override
  String get editorSource => 'Source';

  @override
  String get editorSense => 'Sense';

  @override
  String get editorList => 'List';

  @override
  String get editorExample => 'Example';

  @override
  String get editorTag => 'Tag';

  @override
  String get editorItem => 'Item';

  @override
  String get editorTranslation => 'Translation';

  @override
  String get editorSentence => 'Sentence';

  @override
  String get editorAddItem => 'Add item';

  @override
  String get editorRemoveItem => 'Remove item';

  @override
  String get editorTagCategory => 'Category';

  @override
  String get editorTagLabel => 'Label';

  @override
  String get editorTagPos => 'Part of speech';

  @override
  String get editorTagMisc => 'Usage';

  @override
  String get editorTagField => 'Subject';

  @override
  String get editorTagDialect => 'Dialect';

  @override
  String get editorDone => 'Done';

  @override
  String get editorToolbox => 'Blocks';

  @override
  String get editorToolboxHint =>
      'Drag into the field, or tap to put in at the cursor';

  @override
  String get editorAddTag => 'Add tag';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get collectionDefaultName => 'My collection';

  @override
  String get settingsNoteTypes => 'Note types';

  @override
  String get noteTypesEmpty => 'No note types yet.';

  @override
  String get noteTypesAdd => 'New note type';

  @override
  String get noteTypeDefaultName => 'New note type';

  @override
  String get noteTypeDefaultFront => 'Front';

  @override
  String get noteTypeDefaultBack => 'Back';

  @override
  String noteTypeDefaultField(int number) {
    return 'Field $number';
  }

  @override
  String noteTypeDefaultCard(int number) {
    return 'Card $number';
  }

  @override
  String noteTypeSummary(int fieldCount, int cardCount) {
    String _temp0 = intl.Intl.pluralLogic(
      fieldCount,
      locale: localeName,
      other: '$fieldCount fields',
      one: '1 field',
    );
    String _temp1 = intl.Intl.pluralLogic(
      cardCount,
      locale: localeName,
      other: '$cardCount cards',
      one: '1 card',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get noteTypeName => 'Name';

  @override
  String get noteTypeFields => 'Fields';

  @override
  String get noteTypeCards => 'Cards';

  @override
  String get noteTypeAddField => 'Add field';

  @override
  String get noteTypeAddCard => 'Add card';

  @override
  String get noteTypeFieldName => 'Field name';

  @override
  String get noteTypeCardName => 'Card name';

  @override
  String get noteTypeFieldSettings => 'Settings';

  @override
  String get noteTypeFieldLanguage => 'Language';

  @override
  String get noteTypeFieldLanguageHint => 'A language tag, such as ja';

  @override
  String get noteTypeFieldRequired => 'Required';

  @override
  String get noteTypeFieldDuplicates => 'Check for duplicates';

  @override
  String get noteTypeFieldMarks => 'Marks';

  @override
  String get noteTypeFieldAllMarks => 'All';

  @override
  String get noteTypeRemoveField => 'Remove field';

  @override
  String noteTypeRemoveFieldTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String noteTypeRemoveFieldUsed(String cards) {
    return 'It is taken out of $cards. Notes keep its values, hidden.';
  }

  @override
  String get noteTypeRemoveFieldUnused => 'Notes keep its values, hidden.';

  @override
  String get noteTypeRemove => 'Remove';

  @override
  String get noteTypeRemoveCard => 'Remove card';

  @override
  String get noteTypeDelete => 'Delete note type';

  @override
  String noteTypeDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get noteTypeDeleteBody => 'Its fields and cards go with it.';

  @override
  String get noteTypeDeleteConfirm => 'Delete';

  @override
  String get noteTypeInUse =>
      'Notes use this note type, so it cannot be deleted.';

  @override
  String get noteTypeCardStudied =>
      'A removed card has been studied, so it cannot be removed.';

  @override
  String get noteTypeDiscardTitle => 'Discard changes?';

  @override
  String get noteTypeDiscardBody =>
      'Your changes to this note type are not saved.';

  @override
  String get noteTypeDiscard => 'Discard';

  @override
  String get noteTypeNameEmpty => 'A name is needed.';

  @override
  String get noteTypeNameTaken => 'Another one has this name.';

  @override
  String noteTypeMissingFields(String card, String fields) {
    return '$card shows fields this note type does not have: $fields';
  }

  @override
  String noteTypeCardProblem(String card) {
    return '$card needs a front and a back, with nothing outside them.';
  }

  @override
  String get noteTypePreview => 'Preview';

  @override
  String get noteTypeVisual => 'Visual';

  @override
  String get noteTypeNotArrangeable =>
      'This card can only be arranged visually once it has one front and one back, with nothing else outside them but requires and comments.';
}
