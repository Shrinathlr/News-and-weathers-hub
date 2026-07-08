import 'package:hive/hive.dart';

class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'maxTemp': maxTemp,
        'minTemp': minTemp,
        'weatherCode': weatherCode,
      };

  factory DailyForecast.fromJson(Map<String, dynamic> json) => DailyForecast(
        date: DateTime.parse(json['date'] as String),
        maxTemp: (json['maxTemp'] as num).toDouble(),
        minTemp: (json['minTemp'] as num).toDouble(),
        weatherCode: json['weatherCode'] as int,
      );
}

class WeatherData {
  final String cityName;
  final double latitude;
  final double longitude;
  final double currentTemp;
  final int weatherCode;
  final double humidity;
  final double windSpeed;
  final List<DailyForecast> daily;

  WeatherData({
    required this.cityName,
    required this.latitude,
    required this.longitude,
    required this.currentTemp,
    required this.weatherCode,
    required this.humidity,
    required this.windSpeed,
    required this.daily,
  });

  /// Open-Meteo `current_weather` block does not include humidity directly;
  /// we pull it from the hourly array at the closest hour to "now" (see
  /// WeatherRepository for the parsing logic that builds this object).
  factory WeatherData.fromOpenMeteoJson(Map<String, dynamic> json, {required String cityName}) {
    final current = json['current_weather'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;
    final hourly = json['hourly'] as Map<String, dynamic>?;

    final List<String> dailyTimes = List<String>.from(daily['time'] as List);
    final List<num> tMax = List<num>.from(daily['temperature_2m_max'] as List);
    final List<num> tMin = List<num>.from(daily['temperature_2m_min'] as List);
    final List<num> codes = List<num>.from(daily['weathercode'] as List);

    final forecasts = <DailyForecast>[
      for (var i = 0; i < dailyTimes.length; i++)
        DailyForecast(
          date: DateTime.parse(dailyTimes[i]),
          maxTemp: tMax[i].toDouble(),
          minTemp: tMin[i].toDouble(),
          weatherCode: codes[i].toInt(),
        ),
    ];

    double humidity = 0;
    if (hourly != null) {
      final times = List<String>.from(hourly['time'] as List);
      final humidities = List<num>.from(hourly['relativehumidity_2m'] as List);
      final currentTimeStr = current['time'] as String;
      final idx = times.indexOf(currentTimeStr);
      if (idx != -1 && idx < humidities.length) {
        humidity = humidities[idx].toDouble();
      } else if (humidities.isNotEmpty) {
        humidity = humidities.first.toDouble();
      }
    }

    return WeatherData(
      cityName: cityName,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      currentTemp: (current['temperature'] as num).toDouble(),
      weatherCode: (current['weathercode'] as num).toInt(),
      humidity: humidity,
      windSpeed: (current['windspeed'] as num).toDouble(),
      daily: forecasts.take(5).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'cityName': cityName,
        'latitude': latitude,
        'longitude': longitude,
        'currentTemp': currentTemp,
        'weatherCode': weatherCode,
        'humidity': humidity,
        'windSpeed': windSpeed,
        'daily': daily.map((d) => d.toJson()).toList(),
      };

  factory WeatherData.fromJson(Map<String, dynamic> json) => WeatherData(
        cityName: json['cityName'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        currentTemp: (json['currentTemp'] as num).toDouble(),
        weatherCode: json['weatherCode'] as int,
        humidity: (json['humidity'] as num).toDouble(),
        windSpeed: (json['windSpeed'] as num).toDouble(),
        daily: (json['daily'] as List)
            .map((d) => DailyForecast.fromJson(Map<String, dynamic>.from(d as Map)))
            .toList(),
      );
}

/// Cache envelope stored in Hive: payload + timestamp, so the UI can show
/// "showing offline data from [time]" when serving stale data.
class CachedWeather {
  final WeatherData data;
  final DateTime cachedAt;
  CachedWeather(this.data, this.cachedAt);
}

/// Hand-written Hive adapter (stores as JSON map under typeId 1).
/// We store the raw json map rather than generating adapters for nested
/// classes, keeping the schema simple: { 'data': {...}, 'cachedAt': iso }.
class CachedWeatherAdapter extends TypeAdapter<CachedWeather> {
  @override
  final int typeId = 1;

  @override
  CachedWeather read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.readMap());
    return CachedWeather(
      WeatherData.fromJson(Map<String, dynamic>.from(map['data'] as Map)),
      DateTime.parse(map['cachedAt'] as String),
    );
  }

  @override
  void write(BinaryWriter writer, CachedWeather obj) {
    writer.writeMap({
      'data': obj.data.toJson(),
      'cachedAt': obj.cachedAt.toIso8601String(),
    });
  }
}
