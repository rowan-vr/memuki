import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/storage/device_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  test('the platform store keeps values across openings', () async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();

    final first = await SharedDevicePreferences.open();
    expect(first.getString('appearance.mode'), isNull);
    await first.setString('appearance.mode', 'sepia');

    final second = await SharedDevicePreferences.open();
    expect(second.getString('appearance.mode'), 'sepia');
  });

  test('the memory store starts from the given values', () async {
    final prefs = MemoryDevicePreferences({'a': '1'});
    expect(prefs.getString('a'), '1');
    await prefs.setString('a', '2');
    expect(prefs.getString('a'), '2');
  });
}
