import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/news_article_model.dart';
import '../../../providers/bookmarks_provider.dart';

class NewsDetailsScreen extends ConsumerWidget {
  final NewsArticle article;
  const NewsDetailsScreen({super.key, required this.article});

  Future<void> _openInBrowser(BuildContext context) async {
    final uri = Uri.tryParse(article.url);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open article link.')),
        );
      }
    }
  }

  void _share() {
    Share.share('${article.title}\n${article.url}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarked = ref.watch(isBookmarkedProvider(article.id));

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
            onPressed: () => ref.read(bookmarksProvider.notifier).toggle(article),
          ),
          IconButton(icon: const Icon(Icons.share_rounded), onPressed: _share),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (article.urlToImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: article.urlToImage!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  height: 220,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.image_not_supported_outlined, size: 48),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(article.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            '${article.sourceName} · ${DateFormat('MMM d, yyyy h:mm a').format(article.publishedAt)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Text(
            article.description ?? article.content ?? 'No description available.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _openInBrowser(context),
            icon: const Icon(Icons.open_in_browser_rounded),
            label: const Text('Read full article'),
          ),
        ],
      ),
    );
  }
}
