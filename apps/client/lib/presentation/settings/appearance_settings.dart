import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../storage/device_preferences.dart';
import '../../storage/providers.dart';
import '../theme/app_theme.dart';
import '../theme/memuki_colors.dart';
import '../theme/memuki_layout.dart';

/// The colour mode the user chose. [system] follows the platform between
/// light and dark; sepia is only ever chosen explicitly.
enum ModeChoice { system, light, dark, sepia }

/// The appearance the user chose for this device.
@immutable
class AppearanceSettings {
  const AppearanceSettings({
    this.mode = ModeChoice.system,
    this.accent = MemukiAccent.blue,
    this.cardStyle = CardStyle.notecard,
    this.density = Density.comfortable,
  });

  /// Reads the settings from [prefs]. Missing or unknown values fall back to
  /// the defaults.
  factory AppearanceSettings.read(DevicePreferences prefs) {
    T read<T extends Enum>(String key, List<T> values, T fallback) {
      final name = prefs.getString(key);
      return values.where((v) => v.name == name).firstOrNull ?? fallback;
    }

    const defaults = AppearanceSettings();
    return AppearanceSettings(
      mode: read(_modeKey, ModeChoice.values, defaults.mode),
      accent: read(_accentKey, MemukiAccent.values, defaults.accent),
      cardStyle: read(_cardStyleKey, CardStyle.values, defaults.cardStyle),
      density: read(_densityKey, Density.values, defaults.density),
    );
  }

  static const _modeKey = 'appearance.mode';
  static const _accentKey = 'appearance.accent';
  static const _cardStyleKey = 'appearance.cardStyle';
  static const _densityKey = 'appearance.density';

  final ModeChoice mode;
  final MemukiAccent accent;
  final CardStyle cardStyle;
  final Density density;

  AppearanceSettings copyWith({
    ModeChoice? mode,
    MemukiAccent? accent,
    CardStyle? cardStyle,
    Density? density,
  }) => AppearanceSettings(
    mode: mode ?? this.mode,
    accent: accent ?? this.accent,
    cardStyle: cardStyle ?? this.cardStyle,
    density: density ?? this.density,
  );

  Future<void> write(DevicePreferences prefs) async {
    await prefs.setString(_modeKey, mode.name);
    await prefs.setString(_accentKey, accent.name);
    await prefs.setString(_cardStyleKey, cardStyle.name);
    await prefs.setString(_densityKey, density.name);
  }

  /// The theme used while the platform is light: light, or sepia when
  /// chosen.
  ThemeData get theme =>
      _build(mode == ModeChoice.sepia ? ColorMode.sepia : ColorMode.light);

  /// The theme used while the platform is dark.
  ThemeData get darkTheme => _build(ColorMode.dark);

  /// Which of [theme] and [darkTheme] applies.
  ThemeMode get themeMode => switch (mode) {
    ModeChoice.system => ThemeMode.system,
    ModeChoice.light || ModeChoice.sepia => ThemeMode.light,
    ModeChoice.dark => ThemeMode.dark,
  };

  ThemeData _build(ColorMode colorMode) => AppTheme.build(
    Appearance(
      mode: colorMode,
      accent: accent,
      cardStyle: cardStyle,
      density: density,
    ),
  );

  @override
  bool operator ==(Object other) =>
      other is AppearanceSettings &&
      other.mode == mode &&
      other.accent == accent &&
      other.cardStyle == cardStyle &&
      other.density == density;

  @override
  int get hashCode => Object.hash(mode, accent, cardStyle, density);
}

/// The appearance for this device, saved in its preferences.
final appearanceProvider =
    NotifierProvider<AppearanceNotifier, AppearanceSettings>(
      AppearanceNotifier.new,
    );

class AppearanceNotifier extends Notifier<AppearanceSettings> {
  @override
  AppearanceSettings build() =>
      AppearanceSettings.read(ref.watch(devicePreferencesProvider));

  /// Applies [change] to the current settings at once and saves the result.
  Future<void> change(
    AppearanceSettings Function(AppearanceSettings current) change,
  ) {
    state = change(state);
    return state.write(ref.read(devicePreferencesProvider));
  }
}
