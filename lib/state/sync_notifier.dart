import 'package:flutter_riverpod/flutter_riverpod.dart'; // <-- critical

enum SyncStatus { idle, syncing, success, error }

class SyncState {
  final int pendingCount;
  final SyncStatus status;
  final String? lastError;

  SyncState({this.pendingCount = 0, this.status = SyncStatus.idle, this.lastError});

  SyncState copyWith({int? pendingCount, SyncStatus? status, String? lastError}) {
    return SyncState(
      pendingCount: pendingCount ?? this.pendingCount,
      status: status ?? this.status,
      lastError: lastError ?? this.lastError,
    );
  }
}

class SyncNotifier extends StateNotifier<SyncState> {
  SyncNotifier() : super(SyncState());

  void setPendingCount(int count) => state = state.copyWith(pendingCount: count);
  void setSyncing() => state = state.copyWith(status: SyncStatus.syncing);
  void setSuccess() => state = state.copyWith(status: SyncStatus.success);
  void setError(String error) => state = state.copyWith(status: SyncStatus.error, lastError: error);
  void resetStatus() => state = state.copyWith(status: SyncStatus.idle, lastError: null);
}

final syncNotifierProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  return SyncNotifier();
});