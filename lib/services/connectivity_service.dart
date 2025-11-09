import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionController.stream;

  ConnectivityService() {
    _init();
  }

  Future<void> _init() async {
    if (kIsWeb) {
      _connectionController.add(true);
      return;
    }

    await _checkConnection();
    _connectivity.onConnectivityChanged.listen((result) {
      _checkConnection();
    });
  }

  Future<void> _checkConnection() async {
    try {
      if (kIsWeb) {
        _connectionController.add(true);
        return;
      }

      final connectivityResult = await _connectivity.checkConnectivity();
      final hasConnection = connectivityResult != ConnectivityResult.none;
      _connectionController.add(hasConnection);
    } catch (e) {
      _connectionController.add(kIsWeb);
    }
  }

  Future<bool> hasInternetConnection() async {
    try {
      if (kIsWeb) {
        return true;
      }

      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return kIsWeb;
    }
  }

  void dispose() {
    if (!_connectionController.isClosed) {
      _connectionController.close();
    }
  }
}
