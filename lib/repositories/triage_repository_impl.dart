import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../models/triage_record.dart';
import 'triage_repository.dart';

class TriageRepositoryImpl implements TriageRepository {
  final Box<TriageRecord> box; // Hive box to store triage records
  final http.Client client; // HTTP client to make API requests
  final String apiUrl;  // URL of the API endpoint

  TriageRepositoryImpl({
    required this.box,
    required this.client,
    this.apiUrl = 'https://mockapi.Ogutu.com/api/triage',
  });

  @override
  Future<void> saveRecord(TriageRecord record) async {
    await box.put(record.id, record);  // Saves a record to Hive
  }

  @override
  Future<List<TriageRecord>> getPendingRecords() async {
    return box.values.where((record) => !record.isSynced).toList();  // Gets all pending records
  }

  @override
  Future<void> markSynced(String id) async { //  Marks a record as synced
    final record = box.get(id); // Gets the record from Hive
    if (record != null) {
      record.isSynced = true;
      record.syncAttempts = 0;
      record.lastSyncError = null;
      await record.save();  // Saves the record to Hive
    }
  }

  @override
  Future<void> markSyncFailed(String id, String error) async { // Marks a record as failed to sync
    final record = box.get(id);  // Gets the record from Hive
    if (record != null) {   // If the record exists
      record.syncAttempts += 1; // Increments the number of sync attempts
      record.lastSyncError = error;  // Sets the last sync error
      await record.save(); // Saves the record to Hive
    }
  }

  @override
  Future<void> syncPendingRecords() async { // Syncs all pending records
    final pending = await getPendingRecords(); // Gets all pending records
    for (final record in pending) { // For each pending record
      try {
        final response = await client.post( // Makes a POST request to the API
          Uri.parse(apiUrl), // URL of the API endpoint
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({  //  Sends the record as JSON
            'id': record.id,
            'patientName': record.patientName,
            'condition': record.condition,
            'priority': record.priority,
            'status': record.status.toString().split('.').last,
            'createdAt': record.createdAt.toIso8601String(),
          }),
        );
        if (response.statusCode == 201 || response.statusCode == 200) { // If the response is successful
          await markSynced(record.id); // Marks the record as synced
        } else {
          await markSyncFailed(record.id, 'Server error: ${response.statusCode}'); // Log the error
        }
      } catch (e) {
        await markSyncFailed(record.id, e.toString()); // Log the error
        print(e);
      }
    }
  }
}