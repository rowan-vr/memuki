import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import 'buttons.dart';

/// Asks to confirm an action, such as removing something, with [title],
/// [message], and a button labelled [confirm] beside Cancel. Completes with
/// whether it was confirmed.
Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String message,
  required String confirm,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      final colors = context.colors;
      final type = context.type;
      final l10n = AppLocalizations.of(context);
      return Dialog(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          side: BorderSide(color: colors.border),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: type.title.copyWith(color: colors.text)),
                const SizedBox(height: Spacing.sm),
                Text(
                  message,
                  style: type.body.copyWith(color: colors.textMuted),
                ),
                const SizedBox(height: Spacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    QuietButton(
                      label: l10n.commonCancel,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Button(
                      label: confirm,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  return confirmed ?? false;
}
