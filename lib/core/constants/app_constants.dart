class AppConstants {
  AppConstants._();

  // Open-Meteo (no key required)
  static const String openMeteoBaseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String geocodingBaseUrl = 'https://geocoding-api.open-meteo.com/v1/search';

  // NewsAPI
  static const String newsApiBaseUrl = 'https://newsapi.org/v2';

  // Pagination
  static const int newsPageSize = 20;

  // Networking
  static const int maxRetries = 2;
  static const Duration retryBaseDelay = Duration(milliseconds: 600);
  static const Duration requestTimeout = Duration(seconds: 12);

  // Debounce
  static const Duration citySearchDebounce = Duration(milliseconds: 450);

  // Hive box names
  static const String weatherCacheBox = 'weather_cache_box';
  static const String newsCacheBox = 'news_cache_box';
  static const String bookmarksBox = 'bookmarks_box';
  static const String settingsBox = 'settings_box';
}
