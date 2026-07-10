import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../repositories/triage_repository.dart';
import '../repositories/triage_repository_impl.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';

final hiveBoxProvider = Provider<Box>((ref) {
  return Hive.box('triage_records');
});

final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

final triageRepositoryProvider = Provider<TriageRepository>((ref) {
  final box = ref.watch(hiveBoxProvider);
  final client = ref.watch(httpClientProvider);
  return TriageRepositoryImpl(box: box, client: client);
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final repository = ref.watch(triageRepositoryProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  return SyncService(repository, connectivity);
});
