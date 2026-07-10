import 'package:emk_triage_form/enums/triage_status.dart';
import 'package:emk_triage_form/models/triage_record.dart';
import 'package:emk_triage_form/repositories/triage_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'models/triage_record_adapter.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  group('TriageRepositoryImpl', () {
    late Box<TriageRecord> box;
    late TriageRepositoryImpl repository;
    late MockClient mockClient;

    setUpAll(() async {
      await Hive.initFlutter();
      Hive.registerAdapter(TriageRecordAdapter());
    });

    setUp(() async {
      box = await Hive.openBox<TriageRecord>('test_box');
      mockClient = MockClient();
      repository = TriageRepositoryImpl(box: box, client: mockClient);
    });

    tearDown(() async {
      await box.clear();
      await box.close();
    });

    test('saveRecord stores record locally', () async {
      final record = TriageRecord(
        patientName: 'John Doe',
        condition: 'Chest pain',
        priority: 1,
        status: TriageStatus.pending,
      );
      await repository.saveRecord(record);
      final stored = box.get(record.id);
      expect(stored, isNotNull);
      expect(stored?.patientName, 'John Doe');
    });

    test('getPendingRecords returns unsynced records', () async {
      final synced = TriageRecord(
        patientName: 'Synced',
        condition: 'A',
        priority: 3,
        status: TriageStatus.pending,
        isSynced: true,
      );
      final pending = TriageRecord(
        patientName: 'Pending',
        condition: 'B',
        priority: 2,
        status: TriageStatus.pending,
        isSynced: false,
      );
      await repository.saveRecord(synced);
      await repository.saveRecord(pending);
      final pendingList = await repository.getPendingRecords();
      expect(pendingList.length, 1);
      expect(pendingList.first.patientName, 'Pending');
    });
  });
}