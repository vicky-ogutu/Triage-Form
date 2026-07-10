import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../models/triage_record.dart';
import '../repositories/triage_repository.dart';
import '../repositories/triage_repository_impl.dart';

final hiveBoxProvider = Provider<Box<TriageRecord>>((ref) {
  return Hive.box<TriageRecord>('emk_triage_records');
});

final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

final triageRepositoryProvider = Provider<TriageRepository>((ref) {
  final box = ref.watch(hiveBoxProvider);
  final client = ref.watch(httpClientProvider);
  return TriageRepositoryImpl(box: box, client: client);
});


