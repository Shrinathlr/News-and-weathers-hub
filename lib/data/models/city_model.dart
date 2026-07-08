class CityResult {
  final String name;
  final String? country;
  final double latitude;
  final double longitude;

  CityResult({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
  });

  String get displayName => country != null ? '$name, $country' : name;

  factory CityResult.fromJson(Map<String, dynamic> json) => CityResult(
        name: json['name'] as String,
        country: json['country'] as String?,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      );
}
