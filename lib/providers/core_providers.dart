import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/utils/connectivity_service.dart';
import '../data/local/bookmarks_local_datasource.dart';
import '../data/local/cache_local_datasource.dart';
import '../data/local/settings_local_datasource.dart';
import '../data/repositories/geocoding_repository.dart';
import '../data/repositories/news_repository.dart';
import '../data/repositories/weather_repository.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) => ConnectivityService());

final weatherDioProvider = Provider<Dio>((ref) => ApiClient.create());
final geocodingDioProvider = Provider<Dio>((ref) => ApiClient.create());
final newsDioProvider = Provider<Dio>((ref) => ApiClient.create());

final weatherCacheDsProvider = Provider((ref) => WeatherCacheLocalDataSource());
final newsCacheDsProvider = Provider((ref) => NewsCacheLocalDataSource());
final bookmarksDsProvider = Provider((ref) => BookmarksLocalDataSource());
final settingsDsProvider = Provider((ref) => SettingsLocalDataSource());

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepository(
    dio: ref.watch(weatherDioProvider),
    cache: ref.watch(weatherCacheDsProvider),
    connectivity: ref.watch(connectivityServiceProvider),
  );
});

final geocodingRepositoryProvider = Provider<GeocodingRepository>((ref) {
  return GeocodingRepository(dio: ref.watch(geocodingDioProvider));
});

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  final apiKey = dotenv.env['NEWS_API_KEY'] ?? '';
  return NewsRepository(
    dio: ref.watch(newsDioProvider),
    cache: ref.watch(newsCacheDsProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    apiKey: apiKey,
  );
});
