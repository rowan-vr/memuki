import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/presentation/theme/contrast.dart';
import 'package:memuki/presentation/theme/memuki_colors.dart';

void main() {
  for (final mode in ColorMode.values) {
    for (final accent in MemukiAccent.values) {
      test('${mode.name} ${accent.name}: text meets WCAG AA contrast', () {
        final c = MemukiColors.of(mode, accent);
        final pairs = {
          'text on background': (c.text, c.background),
          'text on surface': (c.text, c.surface),
          'text on raised': (c.text, c.surfaceRaised),
          'text on sunken': (c.text, c.surfaceSunken),
          'muted on background': (c.textMuted, c.background),
          'muted on surface': (c.textMuted, c.surface),
          'muted on sunken': (c.textMuted, c.surfaceSunken),
          for (final (tone, name) in [
            (c.accent, 'accent'),
            (c.again, 'again'),
            (c.hard, 'hard'),
            (c.good, 'good'),
            (c.easy, 'easy'),
            (c.burned, 'burned'),
            for (final MapEntry(:key, :value) in c.swatches.entries)
              (value, 'swatch ${key.name}'),
          ]) ...{
            '$name on base': (tone.onBase, tone.base),
            '$name on soft': (tone.onSoft, tone.soft),
          },
        };
        for (final MapEntry(key: pair, value: (fg, bg)) in pairs.entries) {
          expect(
            contrastRatio(fg, bg),
            greaterThanOrEqualTo(4.5),
            reason: pair,
          );
        }
      });
    }
  }

  test('readableOn falls back to the target colour', () {
    const grey = Color(0xFF808080);
    expect(readableOn(grey, grey, grey), grey);
  });

  test('lerp blends between palettes', () {
    final light = MemukiColors.of(ColorMode.light, MemukiAccent.green);
    final dark = MemukiColors.of(ColorMode.dark, MemukiAccent.green);
    expect(light.lerp(dark, 0).background, light.background);
    expect(light.lerp(dark, 1).accent.base, dark.accent.base);
    expect(light.lerp(dark, 1).brightness, Brightness.dark);
    expect(light.lerp(null, 0.5), same(light));
    expect(light.copyWith(), same(light));
  });
}
