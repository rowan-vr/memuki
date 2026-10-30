import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/presentation/theme/memuki_layout.dart';

void main() {
  const comfortable = MemukiLayout(
    cardStyle: CardStyle.notecard,
    density: Density.comfortable,
  );

  test('copyWith replaces only the given settings', () {
    final compact = comfortable.copyWith(density: Density.compact);
    expect(compact.density, Density.compact);
    expect(compact.cardStyle, CardStyle.notecard);
    expect(
      comfortable.copyWith(cardStyle: CardStyle.minimal).cardStyle,
      CardStyle.minimal,
    );
  });

  test('lerp switches halfway, since layout settings cannot blend', () {
    final compact = comfortable.copyWith(density: Density.compact);
    expect(comfortable.lerp(compact, 0.4), same(comfortable));
    expect(comfortable.lerp(compact, 0.6), same(compact));
    expect(comfortable.lerp(null, 0.6), same(comfortable));
  });

  test('dense scales spacing for the density', () {
    expect(comfortable.dense(16), 16);
    expect(comfortable.copyWith(density: Density.compact).dense(16), 12);
  });
}
