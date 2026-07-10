import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';



class ConnectivityService {  // ConnectivityService class to handle connectivity changes and provide a stream of connection status changes
  final Connectivity _connectivity = Connectivity();  // Connectivity object to handle connectivity changes
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast(); // StreamController to handle connection changes

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen((result) {
      final isConnected = result != ConnectivityResult.none;
      _connectionController.add(isConnected);
    });
    // initial check
    _checkInitial();
  }

  Future<void> _checkInitial() async { // Checks the initial connection status
    final result = await _connectivity.checkConnectivity();
    _connectionController.add(result != ConnectivityResult.none);
  }

  Stream<bool> get onConnectionChange => _connectionController.stream; // Stream of connection changes

  Future<bool> get isConnected async {  // Checks if the device is connected to the internet
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void dispose() { // Disposes the service and closes the stream controller
    _connectionController.close();
  }
}