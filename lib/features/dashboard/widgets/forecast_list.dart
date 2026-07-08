import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/weather_code_info.dart';
import '../../../data/models/weather_model.dart';

class ForecastList extends StatelessWidget {
  final List<DailyForecast> daily;
  const ForecastList({super.key, required this.daily});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: daily.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final f = daily[i];
          final isToday = i == 0;
          return Container(
            width: 84,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isToday ? 'Today' : DateFormat.E().format(f.date),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 8),
                Icon(WeatherCodeInfo.icon(f.weatherCode), size: 26),
                const SizedBox(height: 8),
                Text('${f.maxTemp.round()}°', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${f.minTemp.round()}°', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          );
        },
      ),
    );
  }
}
