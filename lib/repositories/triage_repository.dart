import '../models/triage_record.dart';

abstract class TriageRepository {
  Future<void> saveRecord(TriageRecord record); // Saves a record
  Future<List<TriageRecord>> getPendingRecords(); // Gets all pending records
  Future<void> markSynced(String id); // Marks a record as synced
  Future<void> markSyncFailed(String id, String error); // Marks a record as failed to sync
  Future<void> syncPendingRecords(); // Syncs all pending records
}