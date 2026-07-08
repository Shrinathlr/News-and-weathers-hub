import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../data/models/news_article_model.dart';
import 'core_providers.dart';

class BookmarksNotifier extends StateNotifier<List<NewsArticle>> {
  final Ref _ref;
  BookmarksNotifier(this._ref) : super(_ref.read(bookmarksDsProvider).getAll());

  bool isBookmarked(String articleId) =>
      _ref.read(bookmarksDsProvider).isBookmarked(articleId);

  Future<void> toggle(NewsArticle article) async {
    final ds = _ref.read(bookmarksDsProvider);
    if (ds.isBookmarked(article.id)) {
      await ds.remove(article.id);
    } else {
      await ds.add(article);
    }
    state = ds.getAll();
  }

  Future<void> remove(String articleId) async {
    await _ref.read(bookmarksDsProvider).remove(articleId);
    state = _ref.read(bookmarksDsProvider).getAll();
  }
}

final bookmarksProvider =
    StateNotifierProvider<BookmarksNotifier, List<NewsArticle>>((ref) {
      return BookmarksNotifier(ref);
    });

/// Convenience provider for a single article's bookmark status, so list
/// items don't rebuild the whole bookmarks list on every toggle.
final isBookmarkedProvider = Provider.family<bool, String>((ref, articleId) {
  final list = ref.watch(bookmarksProvider);
  return list.any((a) => a.id == articleId);
});
