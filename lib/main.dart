import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await Hive.initFlutter(); //
  Hive.registerAdapter(TriageRecordAdapter());
  await Hive.openBox<TriageRecord>('emk_triage_records'); //emk_triage_records is the table name where triage record sits
  runApp(const MyApp());
}
