import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/app.dart';

extension PumpApp on WidgetTester {
  /// Pumps the full app in a window of [size] logical pixels.
  Future<void> pumpApp({Size size = const Size(1280, 800)}) async {
    view.physicalSize = size;
    view.devicePixelRatio = 1;
    addTearDown(view.reset);

    await pumpWidget(const ProviderScope(child: MemukiApp()));
    await pumpAndSettle();
  }
}
