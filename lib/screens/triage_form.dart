import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../enums/triage_status.dart';
import '../models/triage_record.dart';
import '../providers/providers.dart';

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
    // Listen to sync service when app resumes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final syncService = ref.read(syncServiceProvider);
      // We can also listen to lifecycle events, but we'll rely on connectivity listener.
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _conditionController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_priority == null || _status == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select priority and status')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final record = TriageRecord(
      patientName: _nameController.text.trim(),
      condition: _conditionController.text.trim(),
      priority: _priority!,
      status: _status!,
    );

    final repository = ref.read(triageRepositoryProvider);
    final connectivity = ref.read(connectivityServiceProvider);

    // Save locally immediately
    await repository.saveRecord(record);

    // If online, trigger sync manually (the background service also listens)
    if (await connectivity.isConnected) {
      final syncService = ref.read(syncServiceProvider);
      // This will call syncPendingRecords, which will attempt to upload all pending including this one
      // But syncService has a listener; we can also call sync manually to be immediate.
      // We'll just call the repository sync directly or notify sync service.
      // For immediate feedback, we can call repository.syncPendingRecords()
      // but we should avoid double sync. We'll let the background service handle it.
      // However, we want to show "submitted" and not wait for sync.
    }

    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          await connectivity.isConnected
              ? 'Record saved and queued for sync'
              : 'Record saved offline, will sync when online',
        ),
        backgroundColor: await connectivity.isConnected ? Colors.green : Colors.orange,
      ),
    );

    // Clear form
    _nameController.clear();
    _conditionController.clear();
    setState(() {
      _priority = null;
      _status = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Triage Intake'),
        backgroundColor: Colors.red[900],
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
              // Condition
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
              // Priority (1-5) - use dropdown or segmented buttons
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Priority Level *',
                  border: OutlineInputBorder(),
                ),
                value: _priority,
                items: List.generate(5, (i) => i + 1)
                    .map((p) => DropdownMenuItem<int>(
                  value: p,
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        color: _priorityColor(p),
                      ),
                      const SizedBox(width: 8),
                      Text('$p - ${_priorityLabel(p)}'),
                    ],
                  ),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _priority = value),
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              // Status
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
              // Submit button
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

  Color _priorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red[900]!;
      case 2:
        return Colors.orange[800]!;
      case 3:
        return Colors.yellow[700]!;
      case 4:
        return Colors.green[300]!;
      case 5:
        return Colors.blue[200]!;
      default:
        return Colors.grey;
    }
  }

  String _priorityLabel(int priority) {
    switch (priority) {
      case 1:
        return 'Critical';
      case 2:
        return 'Urgent';
      case 3:
        return 'Moderate';
      case 4:
        return 'Minor';
      case 5:
        return 'Non-urgent';
      default:
        return '';
    }
  }
}