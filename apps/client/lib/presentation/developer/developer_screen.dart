import 'package:flutter/material.dart';

import '../routing/router.dart';
import '../theme/spacing.dart';

/// Lists the development tools. Shown only in debug builds, so its text is
/// not localized.
class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Developer')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
        children: [
          ListTile(
            title: const Text('Component catalogue'),
            subtitle: const Text('Design tokens and components'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => const CatalogueRoute().go(context),
          ),
          ListTile(
            title: const Text('Visual concepts'),
            subtitle: const Text('Candidate looks on a mock review screen'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => const ConceptsRoute().go(context),
          ),
        ],
      ),
    );
  }
}
