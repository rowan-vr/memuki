import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../theme/spacing.dart';

class DecksScreen extends StatelessWidget {
  const DecksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navDecks)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Text(
            l10n.decksEmpty,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
