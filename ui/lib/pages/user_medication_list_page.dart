import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/medication.dart';
import 'add_medication_page.dart';
import 'report_page.dart';

class UserMedicationListPage extends StatefulWidget {
  final String selectedUserId;
  final String caregiverId;

  const UserMedicationListPage({
    super.key,
    required this.selectedUserId,
    required this.caregiverId,
  });

  @override
  State<UserMedicationListPage> createState() => _UserMedicationListPageState();
}

class _UserMedicationListPageState extends State<UserMedicationListPage> {
  final ApiService apiService = ApiService();
  List<Medication> medications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    setState(() => isLoading = true);
    try {
      final fetched = await apiService.fetchMedications(widget.selectedUserId);
      setState(() => medications = fetched);
    } catch (e) {
      debugPrint('Error fetching medications: $e');
    }
    setState(() => isLoading = false);
  }

  Future<void> _addOrEditMedication({Medication? existingMed}) async {
    final result = await Navigator.push<Medication>(
      context,
      MaterialPageRoute(
        builder: (_) => AddMedicationPage(
          userId: widget.selectedUserId,
          existingMed: existingMed,
        ),
      ),
    );

    if (result != null) {
      try {
        if (existingMed == null) {
          //await apiService.addMedication(widget.selectedUserId, result);
        } else {
          await apiService.updateMedication(widget.selectedUserId, existingMed.id, result);
        }
        _loadMedications();
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to save medication: $e')));
      }
    }
  }

   Future<void> _deleteMedication(Medication med) async {
    final bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete ${med.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        await apiService.deleteMedication(widget.selectedUserId, med.id);
        await _loadMedications();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${med.name} deleted successfully.'), backgroundColor: Colors.orange),
          );
        }
      } catch (e) {
        debugPrint('Error deleting medication: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete medication.'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _startChat(Medication med) async {
    // Navigate to the chat/report page, passing the patient's userId and medication.
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportPage( // Reusing ReportPage for the chat interface
          userId: widget.selectedUserId,
          medication: med,
        ),
      ),
    );
    // Optionally, you could reload the medication list or pending reports here.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medications')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: medications.length,
              itemBuilder: (context, index) {
                final med = medications[index];
                return ListTile(
                  title: Text('${med.name} - ${med.amount} ${med.unit} at ${med.time}'),
                  subtitle: Text('Days: ${med.days.join(", ")}'),
                  trailing: Row( // Use a Row to hold multiple buttons in caregiver view
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // CHAT BUTTON
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline, color: Colors.blue),
                          tooltip: 'Chat about ${med.name}',
                          onPressed: () => _startChat(med),
                        ),
                        // EDIT BUTTON
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _addOrEditMedication(existingMed: med),
                        ),
                        // DELETE BUTTON (NEW)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteMedication(med),
                        ),
                      ],
                    ),
                  onTap: () => _addOrEditMedication(existingMed: med),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditMedication(),
        child: const Icon(Icons.add),
        tooltip: 'Add Medication',
      ),
    );
  }
}
