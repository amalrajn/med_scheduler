import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/medication.dart';
import 'add_medication_page.dart';

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
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit Medication',
                    onPressed: () => _addOrEditMedication(existingMed: med),
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
