import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/app.dart';
import 'package:memuki/storage/device_preferences.dart';
import 'package:memuki/storage/providers.dart';

extension PumpApp on WidgetTester {
  /// Pumps the full app in a window of [size] logical pixels, with
  /// [overrides] applied to its providers. Device preferences are
  /// [preferences], empty by default.
  Future<void> pumpApp({
    Size size = const Size(1280, 800),
    List<Override> overrides = const [],
    DevicePreferences? preferences,
  }) async {
    view.physicalSize = size;
    view.devicePixelRatio = 1;
    addTearDown(view.reset);

    await pumpWidget(
      ProviderScope(
        overrides: [
          devicePreferencesProvider.overrideWithValue(
            preferences ?? MemoryDevicePreferences(),
          ),
          ...overrides,
        ],
        child: const MemukiApp(),
      ),
    );
    await pumpAndSettle();
  }
}
