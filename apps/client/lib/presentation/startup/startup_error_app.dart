import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../settings/appearance_settings.dart';
import '../theme/spacing.dart';

/// Why the app could not start.
enum StartupError {
  /// The data was written by a newer version of the app.
  dataTooNew,

  /// Upgrading the data to this version failed.
  upgradeFailed,

  /// Any other failure.
  unknown,
}

/// Shown instead of the app when it cannot start, e.g. because the database
/// cannot be opened.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({
    super.key,
    required this.error,
    required this.details,
    this.appearance = const AppearanceSettings(),
  });

  final StartupError error;

  /// The device's appearance, read before storage failed to open.
  final AppearanceSettings appearance;

  /// Technical details for bug reports.
  final String details;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: appearance.theme,
      darkTheme: appearance.darkTheme,
      themeMode: appearance.themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: _StartupErrorScreen(error: error, details: details),
    );
  }
}

class _StartupErrorScreen extends StatelessWidget {
  const _StartupErrorScreen({required this.error, required this.details});

  final StartupError error;
  final String details;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final message = switch (error) {
      StartupError.dataTooNew => l10n.startupErrorTooNew,
      StartupError.upgradeFailed => l10n.startupErrorMigration,
      StartupError.unknown => l10n.startupErrorUnknown,
    };
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(Spacing.lg),
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: Spacing.md),
              Text(
                l10n.startupErrorTitle,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                message,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.lg),
              Text(l10n.startupErrorDetails, style: theme.textTheme.titleSmall),
              const SizedBox(height: Spacing.xs),
              SelectableText(details, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
