import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import 'add_user_page.dart';
import 'user_medication_list_page.dart';

class CaregiverDashboardPage extends StatefulWidget {
  final String caregiverId;
  const CaregiverDashboardPage({super.key, required this.caregiverId});

  @override
  State<CaregiverDashboardPage> createState() => _CaregiverDashboardPageState();
}

class _CaregiverDashboardPageState extends State<CaregiverDashboardPage> {
  final ApiService apiService = ApiService();
  List<User> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => isLoading = true);
    try {
      final fetched = await apiService.getUsersForCaregiver(widget.caregiverId);
      setState(() => users = fetched);
    } catch (e) {
      debugPrint('Error fetching users: $e');
    }
    setState(() => isLoading = false);
  }

  void _addUser() async {
    final newUser = await Navigator.push<User>(
      context,
      MaterialPageRoute(builder: (_) => AddUserPage(caregiverId: widget.caregiverId)),
    );

    if (newUser != null) {
      try {
        await apiService.addUser(widget.caregiverId, newUser);
        _loadUsers();
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to add user: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caregiver Dashboard')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text('${user.name} (${user.email})'),
                  subtitle: Text('Age: ${user.age}'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserMedicationListPage(
                        selectedUserId: user.id,
                        caregiverId: widget.caregiverId,
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addUser,
        child: const Icon(Icons.add),
        tooltip: 'Add User',
      ),
    );
  }
}
