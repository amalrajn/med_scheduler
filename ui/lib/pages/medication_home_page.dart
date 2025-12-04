import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/medication.dart';
import 'add_medication_page.dart';
// Import the ReportPage
import 'report_page.dart'; // ASSUMING you have created this file

class MedicationHomePage extends StatefulWidget {
  final String userId;

  const MedicationHomePage({super.key, required this.userId});

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

  Future<void> _markTaken(Medication med) async {
    try {
      await apiService.markTaken(widget.userId, med.id);
      await _loadMedications();
    } catch (e) {
      debugPrint('Error marking taken: $e');
    }
  }

  // --- NEW REPORT FUNCTION ---
  void _reportIssue(Medication med) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        // Patient is not a caregiver (default is false)
        builder: (_) => ChatPage( 
          userId: widget.userId,
          medication: med,
          isCaregiver: false, // Explicitly set patient role
        ),
      ),
    );
  }
  // ---------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Medications")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : meds.isEmpty
              ? const Center(child: Text('No medications scheduled.'))
              : ListView.builder(
                  itemCount: meds.length,
                  itemBuilder: (context, index) {
                    final med = meds[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text('${med.name} - ${med.amount} ${med.unit} at ${med.time}'),
                        subtitle: Text('Days: ${med.days.join(", ")}'),
                        trailing: Row( // <-- CHANGED: Use Row to put two buttons side-by-side
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // CHAT BUTTON
                              IconButton(
                                icon: const Icon(Icons.chat_bubble_outline, color: Colors.blue),
                                tooltip: 'Chat about ${med.name}',
                                onPressed: () => _reportIssue(med),
                              ),
                            const SizedBox(width: 8),

                            // 2. EXISTING MARK TAKEN BUTTON
                            ElevatedButton(
                              onPressed: med.taken ? null : () => _markTaken(med),
                              child: Text(med.taken ? "Taken ✅" : "Take 💊"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}