import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../enums/triage_status.dart';


@HiveType(typeId: 0)
class TriageRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String patientName;

  @HiveField(2)
  final String condition;

  @HiveField(3)
  final int priority; // 1 to 5

  @HiveField(4)
  final TriageStatus status;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  bool isSynced;

  @HiveField(7)
  int syncAttempts;

  @HiveField(8)
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