import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/content/field_references.dart';
import '../../domain/ids.dart';
import '../../domain/note_type.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/providers.dart';
import '../../storage/providers.dart';
import '../components/buttons.dart';
import '../components/icons.dart';
import '../components/rows.dart';
import '../components/screen.dart';
import '../routing/router.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';

/// The note types of a collection, by name, as they change.
final noteTypesProvider = StreamProvider.family<List<NoteType>, CollectionId>(
  (ref, collection) =>
      ref.watch(noteTypeRepositoryProvider).watchNoteTypes(collection),
);

/// The note types of the active collection, each opening its editor, and a
/// button to make one.
class NoteTypesScreen extends ConsumerWidget {
  const NoteTypesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final collection = ref.watch(
      activeCollectionProvider(l10n.collectionDefaultName),
    );
    final noteTypes = switch (collection) {
      AsyncData(:final value) => ref.watch(noteTypesProvider(value)),
      AsyncError(:final error, :final stackTrace) => AsyncError<List<NoteType>>(
        error,
        stackTrace,
      ),
      _ => const AsyncLoading<List<NoteType>>(),
    };
    return Screen(
      title: l10n.settingsNoteTypes,
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          Align(
            alignment: AlignmentDirectional.topStart,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  switch (noteTypes) {
                    AsyncData(value: []) => Text(
                      l10n.noteTypesEmpty,
                      style: context.type.body.copyWith(
                        color: context.colors.textMuted,
                      ),
                    ),
                    AsyncData(:final value) => RowGroup(
                      children: [
                        for (final type in value)
                          ListRow(
                            title: type.name,
                            subtitle: l10n.noteTypeSummary(
                              type.fields.length,
                              type.templates.length,
                            ),
                            onTap: () =>
                                NoteTypeRoute(id: type.id.value).go(context),
                          ),
                      ],
                    ),
                    AsyncError(:final error) => throw error,
                    _ => const SizedBox.shrink(),
                  },
                  const SizedBox(height: Spacing.md),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Button(
                      label: l10n.noteTypesAdd,
                      icon: MemukiIcons.add,
                      onPressed: collection.value == null
                          ? null
                          : () => _add(context, ref, collection.value!),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Makes a note type with a front and a back field and one card, and
  /// opens it.
  Future<void> _add(
    BuildContext context,
    WidgetRef ref,
    CollectionId collection,
  ) async {
    final l10n = AppLocalizations.of(context);
    final fields = [
      FieldDefinition(
        id: FieldDefinitionId.generate(),
        name: l10n.noteTypeDefaultFront,
      ),
      FieldDefinition(
        id: FieldDefinitionId.generate(),
        name: l10n.noteTypeDefaultBack,
      ),
    ];
    final noteType = NoteType(
      id: NoteTypeId.generate(),
      collectionId: collection,
      name: l10n.noteTypeDefaultName,
      fields: fields,
      templates: [
        StudyCardTemplate(
          id: StudyCardTemplateId.generate(),
          name: l10n.noteTypeDefaultCard(1),
          source: basicTemplateSource([for (final f in fields) f.name]),
        ),
      ],
      duplicateCheck: fields.first.id,
    );
    await ref.read(noteTypeRepositoryProvider).createNoteType(noteType);
    if (context.mounted) NoteTypeRoute(id: noteType.id.value).go(context);
  }
}
