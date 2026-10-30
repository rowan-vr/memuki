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
}
