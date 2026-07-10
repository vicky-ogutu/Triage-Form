import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/triage_repository.dart';
import '../state/sync_notifier.dart';
import '../providers/providers.dart'; // for triageRepositoryProvider
import 'connectivity_service.dart';   // for connectivityServiceProvider



final syncServiceProvider = Provider<SyncService>((ref) {
  final repository = ref.watch(triageRepositoryProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  final notifier = ref.watch(syncNotifierProvider.notifier);
  return SyncService(repository, connectivity, notifier);
});

class SyncService {
  final TriageRepository repository;
  final ConnectivityService connectivity;
  final SyncNotifier _notifier;
  StreamSubscription<bool>? _subscription;
  bool _isSyncing = false;

  SyncService(this.repository, this.connectivity, this._notifier) {
    _startListening();
  }

  void _startListening() {
    _subscription = connectivity.onConnectionChange.listen((connected) async {
      if (connected && !_isSyncing) {
        await _sync();
      }
    });
  }

  Future<void> _sync() async {
    if (_isSyncing) return;
    _isSyncing = true;
    _notifier.setSyncing();

    try {
      await repository.syncPendingRecords();
      final pending = await repository.getPendingRecords();
      _notifier.setPendingCount(pending.length);
      _notifier.setSuccess();
    } catch (e) {
      _notifier.setError(e.toString());
    } finally {
      _isSyncing = false;
      Future.delayed(const Duration(seconds: 2), () {
        _notifier.resetStatus();
      });
    }
  }

  Future<void> onAppResumed() async {
    if (await connectivity.isConnected && !_isSyncing) {
      await _sync();
    }
  }

  Future<void> refreshPendingCount() async {
    final pending = await repository.getPendingRecords();
    _notifier.setPendingCount(pending.length);
  }

  void dispose() {
    _subscription?.cancel();
  }
}