import 'package:hive/hive.dart';
import 'package:emk_triage_form/models/triage_record.dart';
import 'package:emk_triage_form/enums/triage_status.dart';


class TriageRecordAdapter extends TypeAdapter<TriageRecord> {
  @override
  final int typeId = 0;

  @override
  TriageRecord read(BinaryReader reader) {
    return TriageRecord(
      id: reader.readString(),
      patientName: reader.readString(),
      condition: reader.readString(),
      priority: reader.readInt(),
      status: TriageStatus.values[reader.readInt()],
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      isSynced: reader.readBool(),
      syncAttempts: reader.readInt(),
      lastSyncError: reader.readString() == '' ? null : reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, TriageRecord obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.patientName);
    writer.writeString(obj.condition);
    writer.writeInt(obj.priority);
    writer.writeInt(obj.status.index);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeBool(obj.isSynced);
    writer.writeInt(obj.syncAttempts);
    writer.writeString(obj.lastSyncError ?? '');
  }
}