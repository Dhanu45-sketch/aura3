class WeatherData {
  final String cityName;
  final double latitude;
  final double longitude;
  final double temperature;
  final String weatherCondition;
  final String weatherDescription;
  final String weatherIcon;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final int visibility;
  final DateTime sunrise;
  final DateTime sunset;
  final String recommendedElement;

  WeatherData({
    required this.cityName,
    required this.latitude,
    required this.longitude,
    required this.temperature,
    required this.weatherCondition,
    required this.weatherDescription,
    required this.weatherIcon,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.visibility,
    required this.sunrise,
    required this.sunset,
    required this.recommendedElement,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json, String cityName) {

    double toDouble(dynamic val) => (val is int) ? val.toDouble() : (val ?? 0.0);

    final main = json['main'] ?? {};
    final weather = (json['weather'] as List?)?.first ?? {};
    final wind = json['wind'] ?? {};
    final sys = json['sys'] ?? {};
    final coord = json['coord'] ?? {};

    return WeatherData(
      cityName: cityName,
      latitude: toDouble(coord['lat']),
      longitude: toDouble(coord['lon']),
      temperature: toDouble(main['temp']),
      weatherCondition: weather['main'] ?? 'Unknown',
      weatherDescription: weather['description'] ?? 'No description',
      weatherIcon: weather['icon'] ?? '',
      humidity: main['humidity'] ?? 0,
      windSpeed: toDouble(wind['speed']),
      pressure: main['pressure'] ?? 0,
      visibility: json['visibility'] ?? 0,
      sunrise: DateTime.fromMillisecondsSinceEpoch((sys['sunrise'] ?? 0) * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch((sys['sunset'] ?? 0) * 1000),
      recommendedElement: _getRecommendedElement(weather['main'] ?? ''),
    );
  }


  static String _getRecommendedElement(String weatherCondition) {
    switch (weatherCondition.toLowerCase()) {
      case 'rain':
      case 'drizzle':
      case 'thunderstorm':
        return 'water';
      case 'clear':
      case 'sunny':
        return 'fire';
      case 'clouds':
      case 'mist':
      case 'fog':
        return 'wind';
      case 'snow':
        return 'earth';
      default:
        return 'wind';
    }
  }

  String get temperatureFormatted => '${temperature.round()}°C';
  String get locationString => '$cityName (${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)})';
}
