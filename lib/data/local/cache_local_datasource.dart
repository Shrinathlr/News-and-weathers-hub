import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';
import '../models/weather_model.dart';
import '../models/news_article_model.dart';

const _kLastKey = 'last';

class WeatherCacheLocalDataSource {
  Box<CachedWeather> get _box => Hive.box<CachedWeather>(AppConstants.weatherCacheBox);

  CachedWeather? get() => _box.get(_kLastKey);

  Future<void> save(WeatherData data) =>
      _box.put(_kLastKey, CachedWeather(data, DateTime.now()));
}

class NewsCacheLocalDataSource {
  Box<CachedNews> get _box => Hive.box<CachedNews>(AppConstants.newsCacheBox);

  CachedNews? get() => _box.get(_kLastKey);

  Future<void> save(List<NewsArticle> articles) =>
      _box.put(_kLastKey, CachedNews(articles, DateTime.now()));
}
