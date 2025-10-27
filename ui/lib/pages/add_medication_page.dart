import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../services/api_service.dart';

class AddMedicationPage extends StatefulWidget {
  final String userId;
  final Medication? existingMed;

  const AddMedicationPage({
    super.key,
    required this.userId,
    this.existingMed,
  });

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String selectedUnit = 'mg';
  List<String> units = ['mg', 'ml', 'pills', 'drops'];
  List<String> selectedDays = [];

  int selectedHour = 8;
  int selectedMinute = 0;
  bool isAM = true;

  @override
  void initState() {
    super.initState();
    if (widget.existingMed != null) {
      final med = widget.existingMed!;
      _nameController.text = med.name;
      _amountController.text = med.amount.toString();
      selectedUnit = med.unit;
      selectedDays = List.from(med.days);

      // Parse time string
      final parts = med.time.split(RegExp(r'[: ]')); // ["08","30","AM"]
      selectedHour = int.parse(parts[0]);
      selectedMinute = int.parse(parts[1]);
      isAM = parts[2] == 'AM';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveMedication() async {
    final med = Medication(
      id: widget.existingMed?.id ?? '',
      name: _nameController.text,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      unit: selectedUnit,
      time:
          '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')} ${isAM ? 'AM' : 'PM'}',
      days: selectedDays,
      userId: widget.userId
    );

    final apiService = ApiService();
    if (widget.existingMed != null) {
      await apiService.updateMedication(widget.userId, med.id, med);
    } else {
      await apiService.addMedication(widget.userId, med);
    }

    Navigator.pop(context, med);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingMed != null ? 'Edit Medication' : 'Add Medication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Medication Name'),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            DropdownButton<String>(
              value: selectedUnit,
              items: units.map((unit) => DropdownMenuItem(
                value: unit,
                child: Text(unit),
              )).toList(),
              onChanged: (val) {
                if (val != null) setState(() => selectedUnit = val);
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hour picker
                SizedBox(
                  width: 60,
                  height: 120,
                  child: CupertinoPicker(
                    scrollController:
                        FixedExtentScrollController(initialItem: selectedHour - 1),
                    itemExtent: 32,
                    onSelectedItemChanged: (index) {
                      setState(() => selectedHour = index + 1);
                    },
                    children: List.generate(12, (i) => Center(child: Text('${i + 1}'))),
                  ),
                ),
                const Text(':'),
                // Minute picker
                SizedBox(
                  width: 60,
                  height: 120,
                  child: CupertinoPicker(
                    scrollController:
                        FixedExtentScrollController(initialItem: selectedMinute),
                    itemExtent: 32,
                    onSelectedItemChanged: (index) {
                      setState(() => selectedMinute = index);
                    },
                    children: List.generate(60, (i) => Center(child: Text(i.toString().padLeft(2,'0')))),
                  ),
                ),
                // AM/PM picker
                SizedBox(
                  width: 60,
                  height: 120,
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(initialItem: isAM ? 0 : 1),
                    itemExtent: 32,
                    onSelectedItemChanged: (index) {
                      setState(() => isAM = index == 0);
                    },
                    children: const [Center(child: Text('AM')), Center(child: Text('PM'))],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveMedication,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
