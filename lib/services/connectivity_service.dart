import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionController.stream;

  ConnectivityService() {
    _init();
  }

  Future<void> _init() async {
    await _checkConnection();

    _connectivity.onConnectivityChanged.listen((result) {
      _checkConnection();
    });
  }

  Future<void> _checkConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final hasConnection = connectivityResult != ConnectivityResult.none;

      _connectionController.add(hasConnection);
    } catch (e) {
      _connectionController.add(false);
    }
  }

  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _connectionController.close();
  }
}
