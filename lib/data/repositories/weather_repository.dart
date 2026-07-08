import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_failure.dart';
import '../../core/utils/connectivity_service.dart';
import '../local/cache_local_datasource.dart';
import '../models/weather_model.dart';

class WeatherRepository {
  final Dio _dio;
  final WeatherCacheLocalDataSource _cache;
  final ConnectivityService _connectivity;

  WeatherRepository({
    required Dio dio,
    required WeatherCacheLocalDataSource cache,
    required ConnectivityService connectivity,
  })  : _dio = dio,
        _cache = cache,
        _connectivity = connectivity;

  Future<Result<WeatherData>> getWeather({
    required double latitude,
    required double longitude,
    required String cityName,
  }) async {
    final online = await _connectivity.isOnline;
    if (!online) {
      return _fallbackToCache(const NoInternetFailure());
    }

    try {
      final response = await _dio.get(
        AppConstants.openMeteoBaseUrl,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'current_weather': true,
          'daily': 'temperature_2m_max,temperature_2m_min,weathercode',
          'hourly': 'relativehumidity_2m',
          'timezone': 'auto',
        },
      );

      final data = WeatherData.fromOpenMeteoJson(
        Map<String, dynamic>.from(response.data as Map),
        cityName: cityName,
      );
      await _cache.save(data);
      return Result.success(data);
    } on DioException catch (e) {
      return _fallbackToCache(_mapDioError(e));
    } catch (_) {
      return _fallbackToCache(const UnknownFailure());
    }
  }

  Result<WeatherData> _fallbackToCache(AppFailure failure) {
    final cached = _cache.get();
    if (cached != null) {
      return Result.success(cached.data, isFromCache: true, cachedAt: cached.cachedAt);
    }
    return Result.failure(failure);
  }

  AppFailure _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const TimeoutFailure();
    }
    if (e.type == DioExceptionType.connectionError) {
      return const NoInternetFailure();
    }
    final status = e.response?.statusCode;
    if (status == 429) return const RateLimitFailure();
    return ServerFailure(status);
  }
}
