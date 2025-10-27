import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'medication_home_page.dart';
import 'caregiver_dashboard_page.dart';

class LoginPage extends StatefulWidget {
  final bool isCaregiver; // set by the app when showing this page

  const LoginPage({super.key, required this.isCaregiver});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  final ApiService apiService = ApiService();

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final User user = await apiService.login(
        _emailController.text,
        _passwordController.text,
        widget.isCaregiver, // backend determines role
      );

      // Navigate based on user role
      if (widget.isCaregiver) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CaregiverDashboardPage(caregiverId: user.id),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MedicationHomePage(userId: user.id),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
