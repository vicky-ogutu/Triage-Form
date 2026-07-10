import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'models/triage_record.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //Links Flutter framework with phone engine, also allows use of async functions
  await Hive.initFlutter(); // Initialize Hive, finds a location in the device to create the database
  //Hive.registerAdapter(TriageRecordAdapter());
  await Hive.openBox<TriageRecord>('emk_triage_records'); //emk_triage_records is the table name where triage record sits
  runApp(const MyApp());
}
