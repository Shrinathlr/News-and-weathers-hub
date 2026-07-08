import 'package:flutter/material.dart';
import '../../../core/utils/weather_code_info.dart';
import '../../../data/models/weather_model.dart';

class WeatherCard extends StatelessWidget {
  final WeatherData weather;
  const WeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.primary.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  weather.cityName,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: scheme.onPrimary, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(WeatherCodeInfo.icon(weather.weatherCode), color: scheme.onPrimary, size: 32),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            WeatherCodeInfo.describe(weather.weatherCode),
            style: TextStyle(color: scheme.onPrimary.withOpacity(0.9)),
          ),
          const SizedBox(height: 16),
          Text(
            '${weather.currentTemp.round()}°C',
            style: Theme.of(context)
                .textTheme
                .displayMedium
                ?.copyWith(color: scheme.onPrimary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MetricChip(icon: Icons.water_drop_rounded, label: '${weather.humidity.round()}%', color: scheme.onPrimary),
              const SizedBox(width: 16),
              _MetricChip(icon: Icons.air_rounded, label: '${weather.windSpeed.round()} km/h', color: scheme.onPrimary),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MetricChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color.withOpacity(0.9)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color.withOpacity(0.9))),
      ],
    );
  }
}
