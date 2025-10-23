import 'package:flutter/material.dart';

void main() {
  runApp(const MedicationApp());
}

class Medication {
  String name;
  String time;
  bool taken;

  Medication({required this.name, required this.time, this.taken = false});
}

class MedicationApp extends StatelessWidget {
  const MedicationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medication Scheduler',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 22),
          titleLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
      home: const MedicationHomePage(),
    );
  }
}

class MedicationHomePage extends StatefulWidget {
  const MedicationHomePage({super.key});

  @override
  State<MedicationHomePage> createState() => _MedicationHomePageState();
}

class _MedicationHomePageState extends State<MedicationHomePage> {
  final List<Medication> _medications = [
    Medication(name: 'Lipitor 10mg', time: '8:00 AM'),
    Medication(name: 'Metformin 500mg', time: '12:00 PM'),
    Medication(name: 'Vitamin D', time: '6:00 PM'),
  ];

  void _toggleTaken(int index) {
    setState(() {
      _medications[index].taken = !_medications[index].taken;
    });
  }

  void _addMedication(String name, String time) {
    setState(() {
      _medications.add(Medication(name: name, time: time));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Medications"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: _medications.length,
        itemBuilder: (context, index) {
          final med = _medications[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(med.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              subtitle: Text(med.time, style: const TextStyle(fontSize: 20, color: Colors.grey)),
              trailing: ElevatedButton(
                onPressed: med.taken ? null : () => _toggleTaken(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: med.taken ? Colors.grey[400] : Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  med.taken ? '✅ Taken' : 'Take',
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMedicationPage(onAdd: _addMedication)),
          );
        },
        label: const Text(
          '+ Add Medication',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class AddMedicationPage extends StatefulWidget {
  final Function(String, String) onAdd;
  const AddMedicationPage({super.key, required this.onAdd});

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final _nameController = TextEditingController();
  final _timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Medication')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Medication Name', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Enter medication name',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            const Text('Time to Take', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(
                hintText: 'e.g. 8:00 AM',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 20),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onAdd(_nameController.text, _timeController.text);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Colors.blue,
                ),
                child: const Text('Save', style: TextStyle(fontSize: 22, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
