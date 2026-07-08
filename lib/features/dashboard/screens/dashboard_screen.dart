import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/news_provider.dart';
import '../../../providers/weather_provider.dart';
import '../../common/widgets/status_views.dart';
import '../../news_details/screens/news_details_screen.dart';
import '../widgets/city_search_bar.dart';
import '../widgets/forecast_list.dart';
import '../widgets/news_list_item.dart';
import '../widgets/weather_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(newsProvider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      ref.read(weatherProvider.notifier).refresh(),
      ref.read(newsProvider.notifier).refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(weatherProvider);
    final newsState = ref.watch(newsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('News & Weather Hub')),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: CitySearchBar(
                tag: 'dashboard',
                onCitySelected: (city) => ref
                    .read(weatherProvider.notifier)
                    .loadByCoordinates(
                      latitude: city.latitude,
                      longitude: city.longitude,
                      cityName: city.displayName,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildWeatherSection(weatherState),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Latest News',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            if (newsState.isFromCache)
              OfflineBanner(cachedAt: newsState.cachedAt),
            _buildNewsSection(newsState),
          ],
        ),
      ),
      floatingActionButton: IconButton.filled(
        onPressed: weatherState.isLoading
            ? null
            : () => ref.read(weatherProvider.notifier).loadByCurrentLocation(),
        icon: weatherState.isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.my_location_rounded),
      ),
    );
  }

  Widget _buildWeatherSection(WeatherState state) {
    if (state.isLoading && state.data == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.failure != null && state.data == null) {
      return ErrorRetryView(
        failure: state.failure!,
        onRetry: () =>
            ref.read(weatherProvider.notifier).loadByCurrentLocation(),
      );
    }
    if (state.data == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.isFromCache) ...[
          OfflineBanner(cachedAt: state.cachedAt),
          const SizedBox(height: 12),
        ],
        WeatherCard(weather: state.data!),
        const SizedBox(height: 16),
        Text('Next 5 Days', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ForecastList(daily: state.data!.daily),
      ],
    );
  }

  Widget _buildNewsSection(NewsState state) {
    if (state.isLoadingFirstPage && state.articles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.failure != null && state.articles.isEmpty) {
      return ErrorRetryView(
        failure: state.failure!,
        onRetry: () => ref.read(newsProvider.notifier).refresh(),
      );
    }
    if (state.articles.isEmpty) {
      return const EmptyStateView(
        icon: Icons.newspaper_outlined,
        message: 'No news available right now.',
      );
    }

    return Column(
      children: [
        ...state.articles.map(
          (article) => NewsListItem(
            article: article,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => NewsDetailsScreen(article: article),
              ),
            ),
          ),
        ),
        if (state.isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        if (state.failure != null && state.articles.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Could not load more: ${state.failure!.message}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
