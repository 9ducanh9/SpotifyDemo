import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to monitor network connectivity
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Check if device is connected to internet
  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Get connectivity stream
  Stream<ConnectivityResult> get connectivityStream =>
      _connectivity.onConnectivityChanged;

  /// Check if connected to WiFi
  Future<bool> isWiFi() async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.wifi;
  }

  /// Check if connected to mobile data
  Future<bool> isMobile() async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.mobile;
  }
}
