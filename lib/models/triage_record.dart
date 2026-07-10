import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../enums/triage_status.dart';

/// Model representing a triage record.
class TriageRecord extends HiveObject {
  final String id;
  final String patientName;
  final String condition;
  final int priority; // 1 to 5
  final TriageStatus status;
  final DateTime createdAt;
  bool isSynced;
  int syncAttempts;
  String? lastSyncError;

  TriageRecord({
    String? id,
    required this.patientName,
    required this.condition,
    required this.priority,
    required this.status,
    DateTime? createdAt,
    this.isSynced = false,
    this.syncAttempts = 0,
    this.lastSyncError,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();
}