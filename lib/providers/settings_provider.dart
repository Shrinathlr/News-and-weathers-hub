import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'core_providers.dart';

class SettingsState {
  final ThemeMode themeMode;
  final Map<String, dynamic>? defaultCity; // {name, lat, lon}
  const SettingsState({required this.themeMode, this.defaultCity});
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final Ref _ref;
  SettingsNotifier(this._ref) : super(_loadInitial(_ref));

  static SettingsState _loadInitial(Ref ref) {
    final ds = ref.read(settingsDsProvider);
    return SettingsState(
      themeMode: _stringToThemeMode(ds.getThemeMode()),
      defaultCity: ds.getDefaultCity(),
    );
  }

  static ThemeMode _stringToThemeMode(String s) {
    switch (s) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final str = mode == ThemeMode.light
        ? 'light'
        : (mode == ThemeMode.dark ? 'dark' : 'system');
    await _ref.read(settingsDsProvider).setThemeMode(str);
    state = SettingsState(themeMode: mode, defaultCity: state.defaultCity);
  }

  Future<void> setDefaultCity(String name, double lat, double lon) async {
    await _ref.read(settingsDsProvider).setDefaultCity(name, lat, lon);
    state = SettingsState(
      themeMode: state.themeMode,
      defaultCity: {'name': name, 'lat': lat, 'lon': lon},
    );
  }

  Future<void> clearDefaultCity() async {
    await _ref.read(settingsDsProvider).clearDefaultCity();
    state = SettingsState(themeMode: state.themeMode, defaultCity: null);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    return SettingsNotifier(ref);
  },
);
