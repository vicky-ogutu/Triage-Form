import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/triage_repository.dart';
import 'connectivity_service.dart';


class SyncService { // SyncService class to handle syncing of records
  final TriageRepository repository;
  final ConnectivityService connectivity;
  StreamSubscription<bool>? _subscription;
  bool _isSyncing = false;

  SyncService(this.repository, this.connectivity) {
    _startListening();
  }

  void _startListening() {
    _subscription = connectivity.onConnectionChange.listen((connected) async {
      if (connected && !_isSyncing) {
        await _sync();
      }
    });
  }

  Future<void> _sync() async { // Syncs the records
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      await repository.syncPendingRecords();
    } catch (e) {
      // log error
    } finally {
      _isSyncing = false;
    }
  }


  Future<void> onAppResumed() async {  // Called when the app resumes from background
    if (await connectivity.isConnected && !_isSyncing) {
      await _sync();
    }
  }

  void dispose() {
    _subscription?.cancel(); // Disposes the service and cancels the subscription
  }
}