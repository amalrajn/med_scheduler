import 'package:flutter/material.dart';
import 'pages/landing_page.dart';

class MedicationApp extends StatelessWidget {
  const MedicationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SeniorSched',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 22),
          titleLarge:
              TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      home: const LandingPage(),
    );
  }
}
