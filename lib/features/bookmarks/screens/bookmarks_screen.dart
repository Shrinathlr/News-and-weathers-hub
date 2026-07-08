import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/bookmarks_provider.dart';
import '../../common/widgets/status_views.dart';
import '../../dashboard/widgets/news_list_item.dart';
import '../../news_details/screens/news_details_screen.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: bookmarks.isEmpty
          ? const EmptyStateView(icon: Icons.bookmark_border_rounded, message: 'No bookmarked articles yet.')
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: bookmarks.length,
              itemBuilder: (context, i) {
                final article = bookmarks[i];
                return Dismissible(
                  key: ValueKey(article.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: const Icon(Icons.delete_outline_rounded),
                  ),
                  onDismissed: (_) => ref.read(bookmarksProvider.notifier).remove(article.id),
                  child: NewsListItem(
                    article: article,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => NewsDetailsScreen(article: article)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
