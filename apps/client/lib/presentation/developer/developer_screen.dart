import 'package:flutter/material.dart';

import '../components/rows.dart';
import '../components/screen.dart';
import '../routing/router.dart';
import '../theme/spacing.dart';

/// Lists the development tools. Shown only in debug builds, so its text is
/// not localized.
class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Screen(
      title: 'Developer',
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          RowGroup(
            children: [
              ListRow(
                title: 'Component catalogue',
                subtitle: 'Design tokens and components',
                onTap: () => const CatalogueRoute().go(context),
              ),
              ListRow(
                title: 'Visual concepts',
                subtitle: 'Candidate looks on a mock review screen',
                onTap: () => const ConceptsRoute().go(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
