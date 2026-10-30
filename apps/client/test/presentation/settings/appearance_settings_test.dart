import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/presentation/settings/appearance_settings.dart';
import 'package:memuki/presentation/startup/startup_error_app.dart';
import 'package:memuki/presentation/theme/app_theme.dart';
import 'package:memuki/presentation/theme/memuki_colors.dart';
import 'package:memuki/presentation/theme/memuki_layout.dart';
import 'package:memuki/storage/device_preferences.dart';

import '../../helpers/pump_app.dart';

/// A context inside the app's current theme.
BuildContext _app(WidgetTester tester) =>
    tester.element(find.byType(Scaffold).last);

Future<void> _openSettings(WidgetTester tester) async {
  await tester.tap(find.text('Settings').first);
  await tester.pumpAndSettle();
}

void main() {
  group('AppearanceSettings', () {
    test('reads what it wrote', () async {
      final prefs = MemoryDevicePreferences();
      const settings = AppearanceSettings(
        mode: ModeChoice.sepia,
        accent: MemukiAccent.green,
        cardStyle: CardStyle.minimal,
        density: Density.compact,
      );
      await settings.write(prefs);
      expect(AppearanceSettings.read(prefs), settings);
    });

    test('falls back to the defaults for missing or unknown values', () {
      final prefs = MemoryDevicePreferences({
        'appearance.mode': 'neon',
        'appearance.accent': 'green',
      });
      expect(
        AppearanceSettings.read(prefs),
        const AppearanceSettings(accent: MemukiAccent.green),
      );
    });

    test('system follows the platform, sepia replaces light', () {
      const system = AppearanceSettings();
      expect(system.themeMode, ThemeMode.system);
      expect(system.theme.extension<MemukiColors>()!.mode, ColorMode.light);
      expect(system.darkTheme.extension<MemukiColors>()!.mode, ColorMode.dark);

      const sepia = AppearanceSettings(mode: ModeChoice.sepia);
      expect(sepia.themeMode, ThemeMode.light);
      expect(sepia.theme.extension<MemukiColors>()!.mode, ColorMode.sepia);

      expect(
        const AppearanceSettings(mode: ModeChoice.dark).themeMode,
        ThemeMode.dark,
      );
      expect(
        const AppearanceSettings(mode: ModeChoice.light).themeMode,
        ThemeMode.light,
      );
    });
  });

  testWidgets('settings change the appearance at once and save it', (
    tester,
  ) async {
    final prefs = MemoryDevicePreferences();
    await tester.pumpApp(size: const Size(1280, 1400), preferences: prefs);
    await _openSettings(tester);

    await tester.tap(find.text('Sepia'));
    await tester.pumpAndSettle();
    expect(_app(tester).colors.mode, ColorMode.sepia);

    await tester.tap(find.bySemanticsLabel('Green'));
    await tester.pumpAndSettle();
    expect(
      _app(tester).colors.accent.base,
      MemukiColors.of(ColorMode.sepia, MemukiAccent.green).accent.base,
    );

    await tester.tap(find.text('Minimal'));
    await tester.tap(find.text('Compact'));
    await tester.pumpAndSettle();
    expect(_app(tester).layout.cardStyle, CardStyle.minimal);
    expect(_app(tester).layout.density, Density.compact);

    expect(
      AppearanceSettings.read(prefs),
      const AppearanceSettings(
        mode: ModeChoice.sepia,
        accent: MemukiAccent.green,
        cardStyle: CardStyle.minimal,
        density: Density.compact,
      ),
    );

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(_app(tester).colors.mode, ColorMode.dark);
  });

  testWidgets('the app starts in the saved appearance', (tester) async {
    await tester.pumpApp(
      preferences: MemoryDevicePreferences({
        'appearance.mode': 'dark',
        'appearance.accent': 'purple',
      }),
    );
    expect(_app(tester).colors.mode, ColorMode.dark);
    expect(
      _app(tester).colors.accent.base,
      MemukiColors.of(ColorMode.dark, MemukiAccent.purple).accent.base,
    );
  });

  testWidgets('system mode follows platform brightness', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpApp();
    expect(_app(tester).colors.mode, ColorMode.dark);
  });

  testWidgets('sepia stays sepia when the platform is dark', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpApp(
      preferences: MemoryDevicePreferences({'appearance.mode': 'sepia'}),
    );
    expect(_app(tester).colors.mode, ColorMode.sepia);
  });

  testWidgets('a startup error shows in the saved appearance', (tester) async {
    await tester.pumpWidget(
      const StartupErrorApp(
        error: StartupError.unknown,
        details: 'boom',
        appearance: AppearanceSettings(mode: ModeChoice.sepia),
      ),
    );
    expect(tester.element(find.byType(Scaffold)).colors.mode, ColorMode.sepia);
  });
}
