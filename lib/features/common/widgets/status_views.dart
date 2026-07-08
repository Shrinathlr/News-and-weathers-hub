import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../../core/errors/app_failure.dart';

class ErrorRetryView extends StatelessWidget {
  final AppFailure failure;
  final VoidCallback onRetry;
  const ErrorRetryView({
    super.key,
    required this.failure,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isLocationPermission = failure is LocationPermissionFailure;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _iconFor(failure),
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(failure.message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
                if (isLocationPermission)
                  OutlinedButton.icon(
                    onPressed: () => Geolocator.openAppSettings(),
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text('Open Settings'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(AppFailure f) {
    if (f is NoInternetFailure) return Icons.wifi_off_rounded;
    if (f is LocationPermissionFailure) return Icons.location_off_rounded;
    if (f is LocationServiceDisabledFailure)
      return Icons.location_disabled_rounded;
    if (f is CityNotFoundFailure) return Icons.location_searching_rounded;
    if (f is RateLimitFailure) return Icons.hourglass_bottom_rounded;
    return Icons.error_outline_rounded;
  }
}

class OfflineBanner extends StatelessWidget {
  final DateTime? cachedAt;
  const OfflineBanner({super.key, this.cachedAt});

  @override
  Widget build(BuildContext context) {
    final timeStr = cachedAt != null
        ? DateFormat('MMM d, h:mm a').format(cachedAt!)
        : 'earlier';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing offline data from $timeStr',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String message;
  const EmptyStateView({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
