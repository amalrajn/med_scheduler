import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/medication.dart';
import 'add_medication_page.dart';

class MedicationHomePage extends StatefulWidget {
  final String userId;
  final bool isCaregiverView;

  const MedicationHomePage({super.key, required this.userId, this.isCaregiverView = false});

  @override
  State<MedicationHomePage> createState() => _MedicationHomePageState();
}

class _MedicationHomePageState extends State<MedicationHomePage> {
  final ApiService apiService = ApiService();
  List<Medication> meds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    setState(() => isLoading = true);
    try {
      final fetched = await apiService.fetchMedications(widget.userId);
      setState(() => meds = fetched);
    } catch (e) {
      debugPrint('Error fetching medications: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _addOrEditMedication([Medication? med]) async {
    final updated = await Navigator.push<Medication>(
      context,
      MaterialPageRoute(
        builder: (_) => AddMedicationPage(
          userId: widget.userId,
          existingMed: med,
        ),
      ),
    );
    if (updated != null) {
      await _loadMedications();
    }
  }

  Future<void> _markTaken(Medication med) async {
    try {
      await apiService.markTaken(widget.userId, med.id);
      await _loadMedications();
    } catch (e) {
      debugPrint('Error marking taken: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isCaregiverView ? 'Patient Medications' : "My Medications")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: meds.length,
              itemBuilder: (context, index) {
                final med = meds[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                  title: Text('${med.name} - ${med.amount} ${med.unit} at ${med.time}'),
                  subtitle: Text('Days: ${med.days.join(", ")}'),
                  trailing: widget.isCaregiverView
                      ? IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _addOrEditMedication(med),
                        )
                      : ElevatedButton(
                          onPressed: med.taken ? null : () => _markTaken(med),
                          child: Text(med.taken ? "✅ Taken" : "Done"),
                        ),
                  ),
                );
              },
            ),
      floatingActionButton: widget.isCaregiverView
          ? FloatingActionButton(
              onPressed: () => _addOrEditMedication(),
              child: const Icon(Icons.add),
              tooltip: 'Add Medication',
            )
          : null,
    );
  }
}
