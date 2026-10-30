import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/app.dart';

extension PumpApp on WidgetTester {
  /// Pumps the full app in a window of [size] logical pixels, with
  /// [overrides] applied to its providers.
  Future<void> pumpApp({
    Size size = const Size(1280, 800),
    List<Override> overrides = const [],
  }) async {
    view.physicalSize = size;
    view.devicePixelRatio = 1;
    addTearDown(view.reset);

    await pumpWidget(
      ProviderScope(overrides: overrides, child: const MemukiApp()),
    );
    await pumpAndSettle();
  }
}
