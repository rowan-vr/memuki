import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/presentation/theme/breakpoints.dart';

void main() {
  test('WindowSize.fromWidth maps widths to size classes', () {
    expect(WindowSize.fromWidth(0), WindowSize.compact);
    expect(WindowSize.fromWidth(599.9), WindowSize.compact);
    expect(WindowSize.fromWidth(600), WindowSize.medium);
    expect(WindowSize.fromWidth(839.9), WindowSize.medium);
    expect(WindowSize.fromWidth(840), WindowSize.expanded);
    expect(WindowSize.fromWidth(2560), WindowSize.expanded);
  });
}
