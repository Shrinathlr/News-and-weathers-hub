import 'package:hive/hive.dart';

class NewsArticle {
  final String title;
  final String? description;
  final String? content;
  final String url;
  final String? urlToImage;
  final String sourceName;
  final DateTime publishedAt;

  NewsArticle({
    required this.title,
    required this.url,
    required this.sourceName,
    required this.publishedAt,
    this.description,
    this.content,
    this.urlToImage,
  });

  /// Stable id used as the bookmark key — NewsAPI has no numeric id, so the
  /// article URL (unique per article) is used as the natural key.
  String get id => url;

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    final source = json['source'] as Map<String, dynamic>?;
    return NewsArticle(
      title: json['title'] as String? ?? '(untitled)',
      description: json['description'] as String?,
      content: json['content'] as String?,
      url: json['url'] as String,
      urlToImage: json['urlToImage'] as String?,
      sourceName: source?['name'] as String? ?? 'Unknown source',
      publishedAt: DateTime.tryParse(json['publishedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'content': content,
        'url': url,
        'urlToImage': urlToImage,
        'sourceName': sourceName,
        'publishedAt': publishedAt.toIso8601String(),
      };
}

/// typeId 2: single bookmarked / cached article.
class NewsArticleAdapter extends TypeAdapter<NewsArticle> {
  @override
  final int typeId = 2;

  @override
  NewsArticle read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.readMap());
    return NewsArticle(
      title: map['title'] as String,
      description: map['description'] as String?,
      content: map['content'] as String?,
      url: map['url'] as String,
      urlToImage: map['urlToImage'] as String?,
      sourceName: map['sourceName'] as String,
      publishedAt: DateTime.parse(map['publishedAt'] as String),
    );
  }

  @override
  void write(BinaryWriter writer, NewsArticle obj) {
    writer.writeMap(obj.toJson());
  }
}

/// Cache envelope for the news list (first page) so pull-to-refresh failures
/// can still show "showing offline data from [time]".
class CachedNews {
  final List<NewsArticle> articles;
  final DateTime cachedAt;
  CachedNews(this.articles, this.cachedAt);
}

class CachedNewsAdapter extends TypeAdapter<CachedNews> {
  @override
  final int typeId = 3;

  @override
  CachedNews read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.readMap());
    final list = (map['articles'] as List)
        .map((e) => NewsArticle.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return CachedNews(list, DateTime.parse(map['cachedAt'] as String));
  }

  @override
  void write(BinaryWriter writer, CachedNews obj) {
    writer.writeMap({
      'articles': obj.articles.map((a) => a.toJson()).toList(),
      'cachedAt': obj.cachedAt.toIso8601String(),
    });
  }
}
