import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';

class WeatherService {
  static const String _apiKey = '165c6c43cac91e6c806795bf80033a02';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  // Get current position
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Get city name from coordinates
  Future<String> getCityName(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        return placemarks.first.locality ?? 'Unknown Location';
      }
      return 'Unknown Location';
    } catch (e) {
      debugPrint('Error getting city name: $e');
      return 'Unknown Location';
    }
  }

  // Fetch weather data from API
  Future<Map<String, dynamic>> getWeatherByCoordinates(
      double lat,
      double lon,
      ) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric',
      );

      debugPrint('🌐 Fetching weather from: $url');

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timed out');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('✅ Weather data received: ${data['weather'][0]['main']}');
        return data;
      } else {
        throw Exception('Failed to load weather: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Weather fetch error: $e');
      rethrow;
    }
  }

  // Get recommended element based on weather
  String getRecommendedElement(String weatherCondition) {
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

  // Get weather icon
  String getWeatherIcon(String weatherCondition) {
    switch (weatherCondition.toLowerCase()) {
      case 'rain':
      case 'drizzle':
        return '🌧️';
      case 'thunderstorm':
        return '⛈️';
      case 'clear':
      case 'sunny':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'mist':
      case 'fog':
        return '🌫️';
      case 'snow':
        return '❄️';
      case 'wind':
        return '💨';
      default:
        return '🌤️';
    }
  }
}

final weatherService = WeatherService();
