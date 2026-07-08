import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../models/weather_model.dart';
import '../models/news_article_model.dart';

/// Central place that wires up Hive. Schema:
/// - weather_cache_box: single key "last" -> CachedWeather (typeId 1)
/// - news_cache_box: single key "last" -> CachedNews (typeId 3)
/// - bookmarks_box: keyed by article.url -> NewsArticle (typeId 2)
/// - settings_box: plain key/value (theme mode, default city, etc.)
class HiveSetup {
  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(CachedWeatherAdapter());
    Hive.registerAdapter(NewsArticleAdapter());
    Hive.registerAdapter(CachedNewsAdapter());

    await Future.wait([
      Hive.openBox<CachedWeather>(AppConstants.weatherCacheBox),
      Hive.openBox<CachedNews>(AppConstants.newsCacheBox),
      Hive.openBox<NewsArticle>(AppConstants.bookmarksBox),
      Hive.openBox(AppConstants.settingsBox),
    ]);
  }
}
