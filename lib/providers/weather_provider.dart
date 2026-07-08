import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../core/errors/app_failure.dart';
import '../data/models/weather_model.dart';
import 'core_providers.dart';
import 'location_provider.dart';

class WeatherState {
  final WeatherData? data;
  final bool isLoading;
  final AppFailure? failure;
  final bool isFromCache;
  final DateTime? cachedAt;

  const WeatherState({
    this.data,
    this.isLoading = false,
    this.failure,
    this.isFromCache = false,
    this.cachedAt,
  });

  WeatherState copyWith({
    WeatherData? data,
    bool? isLoading,
    AppFailure? failure,
    bool clearFailure = false,
    bool? isFromCache,
    DateTime? cachedAt,
  }) {
    return WeatherState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      failure: clearFailure ? null : (failure ?? this.failure),
      isFromCache: isFromCache ?? this.isFromCache,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }
}

class WeatherNotifier extends StateNotifier<WeatherState> {
  final Ref _ref;
  WeatherNotifier(this._ref) : super(const WeatherState()) {
    _init();
  }

  Future<void> _init() async {
    final defaultCity = _ref.read(settingsDsProvider).getDefaultCity();
    if (defaultCity != null) {
      await loadByCoordinates(
        latitude: defaultCity['lat'] as double,
        longitude: defaultCity['lon'] as double,
        cityName: defaultCity['name'] as String,
      );
    } else {
      await loadByCurrentLocation();
    }
  }

  Future<void> loadByCurrentLocation() async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    final posResult = await _ref
        .read(locationServiceProvider)
        .getCurrentPosition();
    if (!posResult.isSuccess) {
      state = state.copyWith(isLoading: false, failure: posResult.failure);
      return;
    }
    final pos = posResult.data!;
    await loadByCoordinates(
      latitude: pos.latitude,
      longitude: pos.longitude,
      cityName: 'Current Location',
    );
  }

  Future<void> loadByCoordinates({
    required double latitude,
    required double longitude,
    required String cityName,
  }) async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    final result = await _ref
        .read(weatherRepositoryProvider)
        .getWeather(
          latitude: latitude,
          longitude: longitude,
          cityName: cityName,
        );
    if (result.isSuccess) {
      state = WeatherState(
        data: result.data,
        isLoading: false,
        isFromCache: result.isFromCache,
        cachedAt: result.cachedAt,
      );
    } else {
      state = state.copyWith(isLoading: false, failure: result.failure);
    }
  }

  Future<void> refresh() async {
    final d = state.data;
    if (d != null) {
      await loadByCoordinates(
        latitude: d.latitude,
        longitude: d.longitude,
        cityName: d.cityName,
      );
    } else {
      await _init();
    }
  }
}

final weatherProvider = StateNotifierProvider<WeatherNotifier, WeatherState>((
  ref,
) {
  return WeatherNotifier(ref);
});
