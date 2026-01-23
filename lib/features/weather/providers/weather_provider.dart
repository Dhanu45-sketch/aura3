import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../services/weather_service.dart';
import '../models/weather_data.dart';
import '../../../core/services/connectivity_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = weatherService;
  final ConnectivityService _connectivity = connectivityService;

  bool _isLoading = false;
  String? _errorMessage;
  WeatherData? _weatherData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  WeatherData? get weatherData => _weatherData;

  // Quick access getters
  String get temperature => _weatherData?.temperatureFormatted ?? '--';
  String get weatherCondition => _weatherData?.weatherCondition ?? 'Unknown';
  String get weatherDescription => _weatherData?.weatherDescription ?? 'No data';
  String get weatherIcon => _weatherService.getWeatherIcon(weatherCondition);
  int get humidity => _weatherData?.humidity ?? 0;
  double get windSpeed => _weatherData?.windSpeed ?? 0;
  String get cityName => _weatherData?.cityName ?? 'Unknown';
  String get locationString => _weatherData?.locationString ?? 'Location unknown';
  String? get recommendedElement => _weatherData?.recommendedElement;

  Future<void> fetchWeatherForCurrentLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check connectivity
      final isOnline = await _connectivity.checkConnectivity();
      if (!isOnline) {
        throw Exception('No internet connection. Please check your network.');
      }

      // Get current position
      debugPrint('📍 Getting current location...');
      final position = await _weatherService.getCurrentLocation();
      debugPrint('✅ Location obtained: ${position.latitude}, ${position.longitude}');

      // Get city name
      final cityName = await _weatherService.getCityName(
        position.latitude,
        position.longitude,
      );
      debugPrint('🏙️ City: $cityName');

      // Fetch weather data
      final weatherJson = await _weatherService.getWeatherByCoordinates(
        position.latitude,
        position.longitude,
      );

      // Parse to WeatherData model
      _weatherData = WeatherData.fromJson(weatherJson, cityName);

      debugPrint('🎵 Recommended element: ${_weatherData!.recommendedElement}');

    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Error fetching weather: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearWeatherData() {
    _weatherData = null;
    notifyListeners();
  }
}