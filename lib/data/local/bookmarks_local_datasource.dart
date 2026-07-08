import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';
import '../models/news_article_model.dart';

class BookmarksLocalDataSource {
  Box<NewsArticle> get _box => Hive.box<NewsArticle>(AppConstants.bookmarksBox);

  List<NewsArticle> getAll() => _box.values.toList()
    ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

  bool isBookmarked(String articleId) => _box.containsKey(articleId);

  Future<void> add(NewsArticle article) => _box.put(article.id, article);

  Future<void> remove(String articleId) => _box.delete(articleId);

  Stream<void> watch() => _box.watch().map((_) {});
}
