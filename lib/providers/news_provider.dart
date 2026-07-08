import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../core/errors/app_failure.dart';
import '../data/models/news_article_model.dart';
import 'core_providers.dart';

class NewsState {
  final List<NewsArticle> articles;
  final bool isLoadingFirstPage;
  final bool isLoadingMore;
  final bool hasMore;
  final AppFailure? failure;
  final bool isFromCache;
  final DateTime? cachedAt;
  final int page;

  const NewsState({
    this.articles = const [],
    this.isLoadingFirstPage = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.failure,
    this.isFromCache = false,
    this.cachedAt,
    this.page = 1,
  });

  NewsState copyWith({
    List<NewsArticle>? articles,
    bool? isLoadingFirstPage,
    bool? isLoadingMore,
    bool? hasMore,
    AppFailure? failure,
    bool clearFailure = false,
    bool? isFromCache,
    DateTime? cachedAt,
    int? page,
  }) {
    return NewsState(
      articles: articles ?? this.articles,
      isLoadingFirstPage: isLoadingFirstPage ?? this.isLoadingFirstPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      failure: clearFailure ? null : (failure ?? this.failure),
      isFromCache: isFromCache ?? this.isFromCache,
      cachedAt: cachedAt ?? this.cachedAt,
      page: page ?? this.page,
    );
  }
}

class NewsNotifier extends StateNotifier<NewsState> {
  final Ref _ref;
  NewsNotifier(this._ref) : super(const NewsState()) {
    loadFirstPage();
  }

  Future<void> loadFirstPage() async {
    state = state.copyWith(isLoadingFirstPage: true, clearFailure: true);
    final result = await _ref
        .read(newsRepositoryProvider)
        .getTopHeadlines(page: 1);

    if (result.isSuccess) {
      state = NewsState(
        articles: result.data ?? [],
        page: 1,
        hasMore: (result.data?.length ?? 0) >= 20,
        isFromCache: result.isFromCache,
        cachedAt: result.cachedAt,
      );
    } else {
      state = state.copyWith(
        isLoadingFirstPage: false,
        failure: result.failure,
      );
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoadingFirstPage)
      return;
    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.page + 1;
    final result = await _ref
        .read(newsRepositoryProvider)
        .getTopHeadlines(page: nextPage);

    if (result.isSuccess) {
      final newArticles = result.data ?? [];
      state = state.copyWith(
        articles: [...state.articles, ...newArticles],
        page: nextPage,
        isLoadingMore: false,
        hasMore: newArticles.isNotEmpty,
      );
    } else {
      // Keep existing list; just surface the error without wiping the page.
      state = state.copyWith(isLoadingMore: false, failure: result.failure);
    }
  }

  Future<void> refresh() => loadFirstPage();
}

final newsProvider = StateNotifierProvider<NewsNotifier, NewsState>((ref) {
  return NewsNotifier(ref);
});
