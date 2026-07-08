import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_failure.dart';
import '../../core/utils/connectivity_service.dart';
import '../local/cache_local_datasource.dart';
import '../models/news_article_model.dart';

class NewsRepository {
  final Dio _dio;
  final NewsCacheLocalDataSource _cache;
  final ConnectivityService _connectivity;
  final String _apiKey;

  NewsRepository({
    required Dio dio,
    required NewsCacheLocalDataSource cache,
    required ConnectivityService connectivity,
    required String apiKey,
  })  : _dio = dio,
        _cache = cache,
        _connectivity = connectivity,
        _apiKey = apiKey;

  /// Fetches one page of top headlines. [page] is 1-indexed, matching
  /// NewsAPI's `page` query param. Only page 1 is cached/falls back to
  /// cache — later pages simply surface an error via [Result.failure] on
  /// the caller side (the list keeps what it already has).
  Future<Result<List<NewsArticle>>> getTopHeadlines({
    required int page,
    String country = 'us',
  }) async {
    final online = await _connectivity.isOnline;
    if (!online) {
      if (page == 1) return _fallbackToCache(const NoInternetFailure());
      return const Result.failure(NoInternetFailure());
    }

    try {
      final response = await _dio.get(
        '${AppConstants.newsApiBaseUrl}/top-headlines',
        queryParameters: {
          'country': country,
          'page': page,
          'pageSize': AppConstants.newsPageSize,
          'apiKey': _apiKey,
        },
      );
      final articlesJson = response.data['articles'] as List;
      final articles = articlesJson
          .map((e) => NewsArticle.fromJson(Map<String, dynamic>.from(e as Map)))
          .where((a) => a.title != '[Removed]')
          .toList();

      if (page == 1) await _cache.save(articles);
      return Result.success(articles);
    } on DioException catch (e) {
      final failure = _mapDioError(e);
      if (page == 1) return _fallbackToCache(failure);
      return Result.failure(failure);
    } catch (_) {
      if (page == 1) return _fallbackToCache(const UnknownFailure());
      return const Result.failure(UnknownFailure());
    }
  }

  Result<List<NewsArticle>> _fallbackToCache(AppFailure failure) {
    final cached = _cache.get();
    if (cached != null) {
      return Result.success(cached.articles, isFromCache: true, cachedAt: cached.cachedAt);
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
    // NewsAPI returns 426/401 for bad/missing key -> surfaced as ServerFailure.
    return ServerFailure(status, e.response?.data?['message'] as String?);
  }
}
