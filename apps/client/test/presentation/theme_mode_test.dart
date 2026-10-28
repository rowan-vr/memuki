import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

Brightness _brightness(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(Scaffold).last)).brightness;

void main() {
  testWidgets('theme mode setting switches between light and dark', (
    tester,
  ) async {
    await tester.pumpApp();

    await tester.tap(find.text('Settings').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(_brightness(tester), Brightness.dark);

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    expect(_brightness(tester), Brightness.light);
  });

  testWidgets('system theme mode follows platform brightness', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpApp();
    expect(_brightness(tester), Brightness.dark);
  });
}
