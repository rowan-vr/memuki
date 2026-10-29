import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/presentation/startup/startup_error_app.dart';

void main() {
  for (final (error, message) in [
    (StartupError.dataTooNew, 'saved by a newer version'),
    (StartupError.upgradeFailed, 'could not update your data'),
    (StartupError.unknown, 'Something went wrong'),
  ]) {
    testWidgets('explains $error and shows the details', (tester) async {
      await tester.pumpWidget(
        StartupErrorApp(error: error, details: 'SomeException: boom'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Memuki could not open your data'), findsOneWidget);
      expect(find.textContaining(message), findsOneWidget);
      expect(
        find.widgetWithText(SelectableText, 'SomeException: boom'),
        findsOneWidget,
      );
    });
  }
}
