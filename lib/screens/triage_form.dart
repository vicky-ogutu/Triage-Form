import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../enums/triage_status.dart';
import '../models/triage_record.dart';
import '../providers/providers.dart';
import '../utils/priority_utils.dart';
import '../state/sync_notifier.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';





class TriageForm extends ConsumerStatefulWidget {
  const TriageForm({super.key});

  @override
  ConsumerState<TriageForm> createState() => _TriageFormState();
}

class _TriageFormState extends ConsumerState<TriageForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _conditionController = TextEditingController();
  int? _priority;
  TriageStatus? _status;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Refresh pending count on startup (optional)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final syncService = ref.read(syncServiceProvider);
      syncService.refreshPendingCount();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _conditionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_priority == null || _status == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select priority and status')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final record = TriageRecord(
        patientName: _nameController.text.trim(),
        condition: _conditionController.text.trim(),
        priority: _priority!,
        status: _status!,
      );

      final repository = ref.read(triageRepositoryProvider);
      final connectivity = ref.read(connectivityServiceProvider);
      final syncService = ref.read(syncServiceProvider);

      // Save locally
      await repository.saveRecord(record);

      // Refresh pending count badge
      await syncService.refreshPendingCount();

      // Check connectivity for feedback
      final bool isConnected = await connectivity.isConnected;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isConnected
                ? 'Record saved and queued for sync'
                : 'Record saved offline, will sync when online',
          ),
          backgroundColor: isConnected ? Colors.green : Colors.orange,
        ),
      );

      // Clear form
      _nameController.clear();
      _conditionController.clear();
      setState(() {
        _priority = null;
        _status = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save record: $e'),
          backgroundColor: Colors.red,
        ),
      );
      print('Submit error: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch sync state
    final syncState = ref.watch(syncNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Triage Intake'),
        backgroundColor: Colors.red[900],
        actions: [
          // Sync status badge
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                // Show spinning icon when syncing
                if (syncState.status == SyncStatus.syncing)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else if (syncState.pendingCount > 0)
                  Badge(
                    label: Text('${syncState.pendingCount}'),
                    child: const Icon(Icons.sync),
                  )
                else
                  const Icon(Icons.sync_outlined),
                const SizedBox(width: 4),
                // Optional: show success/error briefly
                if (syncState.status == SyncStatus.success)
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                if (syncState.status == SyncStatus.error)
                  const Icon(Icons.error, color: Colors.red, size: 18),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Patient Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Patient Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Condition Description
              TextFormField(
                controller: _conditionController,
                decoration: const InputDecoration(
                  labelText: 'Condition Description *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Priority Dropdown
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Priority Level *',
                  border: OutlineInputBorder(),
                ),
                value: _priority,
                items: priorityValues.map((p) {
                  return DropdownMenuItem<int>(
                    value: p,
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          color: p.priorityColor,
                        ),
                        const SizedBox(width: 8),
                        Text('$p - ${p.priorityLabel}'),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _priority = value),
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Status Dropdown
              DropdownButtonFormField<TriageStatus>(
                decoration: const InputDecoration(
                  labelText: 'Status *',
                  border: OutlineInputBorder(),
                ),
                value: _status,
                items: TriageStatus.values
                    .map((s) => DropdownMenuItem<TriageStatus>(
                  value: s,
                  child: Text(s.toString().split('.').last),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _status = value),
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _priority != null && _priority! <= 2
                      ? Colors.red
                      : Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('SUBMIT', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

