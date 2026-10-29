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
  String get settingsThemeMode => 'Theme';

  @override
  String get settingsThemeModeSystem => 'System';

  @override
  String get settingsThemeModeLight => 'Light';

  @override
  String get settingsThemeModeDark => 'Dark';

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
}
