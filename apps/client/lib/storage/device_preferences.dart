import 'package:shared_preferences/shared_preferences.dart';

/// Settings that belong to this device and are not synced, such as its
/// appearance. Read synchronously, so they are available before the database
/// opens.
abstract interface class DevicePreferences {
  String? getString(String key);

  Future<void> setString(String key, String value);
}

/// [DevicePreferences] kept by the platform's preferences store.
class SharedDevicePreferences implements DevicePreferences {
  SharedDevicePreferences._(this._prefs);

  final SharedPreferencesWithCache _prefs;

  /// Opens the store and reads every preference into memory.
  static Future<SharedDevicePreferences> open() async =>
      SharedDevicePreferences._(
        await SharedPreferencesWithCache.create(
          cacheOptions: const SharedPreferencesWithCacheOptions(),
        ),
      );

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);
}

/// [DevicePreferences] held in memory only, for tests and as a fallback when
/// the platform store cannot be opened.
class MemoryDevicePreferences implements DevicePreferences {
  MemoryDevicePreferences([Map<String, String>? values])
    : _values = {...?values};

  final Map<String, String> _values;

  @override
  String? getString(String key) => _values[key];

  @override
  Future<void> setString(String key, String value) async =>
      _values[key] = value;
}
