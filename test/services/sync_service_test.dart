import 'package:emk_triage_form/repositories/triage_repository.dart';
import 'package:emk_triage_form/services/connectivity_service.dart';
import 'package:emk_triage_form/services/sync_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'dart:async';

// Mock classes
class MockRepository extends Mock implements TriageRepository {}

class MockConnectivity extends Mock implements ConnectivityService {

  @override
  Stream<bool> get onConnectionChange => _controller.stream;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  // Helper to emit connection state
  void emitConnection(bool connected) {
    _controller.add(connected);
  }

  @override
  Future<bool> get isConnected async => true; // default, can override in test

  void dispose() {
    _controller.close();
  }
}

void main() {
  group('SyncService', () {
    late MockRepository repository;
    late MockConnectivity connectivity;
    late  SyncService syncService;

    setUp(() {
      repository = MockRepository();
      connectivity = MockConnectivity();
      // Provide a fallback for onConnectionChange – we override it anyway.
      syncService = SyncService(repository, connectivity);
    });

    tearDown(() {
      syncService.dispose();
      connectivity.dispose();
    });

    test('should trigger sync when connection becomes available', () async {
      // Given: repository has pending records
      when(repository.syncPendingRecords()).thenAnswer((_) async => Future.value());

      // When: we simulate connection restored
      connectivity.emitConnection(true);

      // Then: syncPendingRecords should be called eventually
      // Allow async operations to complete
      await Future.delayed(const Duration(milliseconds: 200));
      verify(repository.syncPendingRecords()).called(1);
    });

    test('should not trigger sync when connection is lost', () async {
      when(repository.syncPendingRecords()).thenAnswer((_) async => Future.value());

      // Emit disconnected
      connectivity.emitConnection(false);

      await Future.delayed(const Duration(milliseconds: 200));
      verifyNever(repository.syncPendingRecords());
    });

    test('should not trigger sync if already syncing', () async {
      // Simulate long sync
      final completer = Completer<void>();
      when(repository.syncPendingRecords()).thenAnswer((_) => completer.future);

      // Trigger first sync
      connectivity.emitConnection(true);
      // Give time for the sync to start
      await Future.delayed(Duration.zero);

      // Trigger another connection change while still syncing
      connectivity.emitConnection(true);
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify only one sync call (the first) was made
      verify(repository.syncPendingRecords()).called(1);
      // Complete the sync to avoid hanging
      completer.complete();
    });

    test('should call onAppResumed and sync if connected', () async {
      when(repository.syncPendingRecords()).thenAnswer((_) async => Future.value());
      // Mock isConnected to return true
      when(connectivity.isConnected).thenAnswer((_) async => true);

      await syncService.onAppResumed();

      verify(repository.syncPendingRecords()).called(1);
    });

    test('should not call sync onAppResumed if not connected', () async {
      when(repository.syncPendingRecords()).thenAnswer((_) async => Future.value());
      when(connectivity.isConnected).thenAnswer((_) async => false);

      await syncService.onAppResumed();

      verifyNever(repository.syncPendingRecords());
    });
  });
}