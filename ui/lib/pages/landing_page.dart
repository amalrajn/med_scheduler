import 'package:flutter/material.dart';
import 'package:med_scheduler/pages/signup_page.dart';
import '../models/user_role.dart';
import 'login_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'SeniorSched',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 80),
                _roleButton(context, 'I am a Patient', UserRole.senior, Colors.blue),
                const SizedBox(height: 24),
                _roleButton(context, 'I am a Caregiver', UserRole.caregiver, Colors.green),
                const SizedBox(height: 24),
                _signupButton(context, 'Sign Up', const Color.fromARGB(255, 142, 172, 35)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleButton(BuildContext context, String label, UserRole role, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage(isCaregiver: role == UserRole.caregiver)),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          backgroundColor: color,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }

  Widget _signupButton(BuildContext context, String label, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignupPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          backgroundColor: color,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}
