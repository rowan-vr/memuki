import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../components/animations.dart';
import '../components/screen.dart';
import '../theme/spacing.dart';

class DecksScreen extends StatelessWidget {
  const DecksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Screen(
      title: l10n.navDecks,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Entrance(
            child: Text(
              l10n.decksEmpty,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
