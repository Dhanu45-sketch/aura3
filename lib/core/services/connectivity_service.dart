import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  bool _isOnline = true;

  bool get isOnline => _isOnline;


  Stream<bool> get connectivityStream => _connectivity.onConnectivityChanged.map((result) {
    final isConnected = result != ConnectivityResult.none;
    _isOnline = isConnected;

    if (isConnected) {
      debugPrint('🌐 Network Status: ONLINE');
    } else {
      debugPrint('📴 Network Status: OFFLINE');
    }

    return isConnected;
  });


  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isOnline = result != ConnectivityResult.none;

      if (_isOnline) {
        debugPrint('🌐 Connectivity Check: ONLINE');
      } else {
        debugPrint('📴 Connectivity Check: OFFLINE');
      }

      return _isOnline;
    } catch (e) {
      debugPrint('❌ Error checking connectivity: $e');
      _isOnline = false;
      return false;
    }
  }


  Future<String> getConnectionType() async {
    try {
      final result = await _connectivity.checkConnectivity();
      switch (result) {
        case ConnectivityResult.wifi:
          return 'WiFi';
        case ConnectivityResult.mobile:
          return 'Mobile Data';
        case ConnectivityResult.ethernet:
          return 'Ethernet';
        case ConnectivityResult.vpn:
          return 'VPN';
        case ConnectivityResult.bluetooth:
          return 'Bluetooth';
        case ConnectivityResult.other:
          return 'Other';
        case ConnectivityResult.none:
          return 'Offline';
      }
    } catch (e) {
      debugPrint('❌ Error getting connection type: $e');
      return 'Unknown';
    }
  }


  Future<Map<String, dynamic>> getConnectivityInfo() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final connectionType = await getConnectionType();
      final isOnline = result != ConnectivityResult.none;

      return {
        'isOnline': isOnline,
        'connectionType': connectionType,
        'hasWifi': result == ConnectivityResult.wifi,
        'hasMobile': result == ConnectivityResult.mobile,
        'hasEthernet': result == ConnectivityResult.ethernet,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('❌ Error getting connectivity info: $e');
      return {
        'isOnline': false,
        'connectionType': 'Unknown',
        'error': e.toString(),
      };
    }
  }
}

// Global singleton
final connectivityService = ConnectivityService();
