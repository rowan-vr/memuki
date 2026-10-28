import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../theme/spacing.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navHome)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.homeWelcomeTitle, style: textTheme.headlineMedium),
              const SizedBox(height: Spacing.sm),
              Text(
                l10n.homeWelcomeBody,
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
