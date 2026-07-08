import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';

class SettingsLocalDataSource {
  Box get _box => Hive.box(AppConstants.settingsBox);

  static const _kThemeMode = 'theme_mode'; // 'light' | 'dark' | 'system'
  static const _kDefaultCityName = 'default_city_name';
  static const _kDefaultCityLat = 'default_city_lat';
  static const _kDefaultCityLon = 'default_city_lon';

  String getThemeMode() => _box.get(_kThemeMode, defaultValue: 'system') as String;
  Future<void> setThemeMode(String mode) => _box.put(_kThemeMode, mode);

  Map<String, dynamic>? getDefaultCity() {
    final name = _box.get(_kDefaultCityName) as String?;
    final lat = _box.get(_kDefaultCityLat) as double?;
    final lon = _box.get(_kDefaultCityLon) as double?;
    if (name == null || lat == null || lon == null) return null;
    return {'name': name, 'lat': lat, 'lon': lon};
  }

  Future<void> setDefaultCity(String name, double lat, double lon) async {
    await _box.put(_kDefaultCityName, name);
    await _box.put(_kDefaultCityLat, lat);
    await _box.put(_kDefaultCityLon, lon);
  }

  Future<void> clearDefaultCity() async {
    await _box.delete(_kDefaultCityName);
    await _box.delete(_kDefaultCityLat);
    await _box.delete(_kDefaultCityLon);
  }
}
