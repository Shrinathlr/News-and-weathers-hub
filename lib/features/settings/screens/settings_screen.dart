import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../providers/settings_provider.dart';
import '../../dashboard/widgets/city_search_bar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Theme', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode_outlined)),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode_outlined)),
              ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.brightness_auto_outlined)),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (s) => ref.read(settingsProvider.notifier).setThemeMode(s.first),
          ),
          const SizedBox(height: 28),
          Text('Default City', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (settings.defaultCity != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on_rounded),
                title: Text(settings.defaultCity!['name'] as String),
                trailing: IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => ref.read(settingsProvider.notifier).clearDefaultCity(),
                ),
              ),
            ),
          CitySearchBar(
            tag: 'settings',
            onCitySelected: (city) {
              ref.read(settingsProvider.notifier).setDefaultCity(city.displayName, city.latitude, city.longitude);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Default city set to ${city.displayName}')),
              );
            },
          ),
          const SizedBox(height: 28),
          Text('About', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const _AboutTile(),
        ],
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  const _AboutTile();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        return Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('App version'),
                trailing: Text(info?.version ?? '—'),
              ),
              ListTile(
                leading: const Icon(Icons.build_outlined),
                title: const Text('Build number'),
                trailing: Text(info?.buildNumber ?? '—'),
              ),
            ],
          ),
        );
      },
    );
  }
}
