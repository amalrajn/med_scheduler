import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/medication.dart';

class ApiService {
  final String baseUrl = 'http://localhost:8000'; // Adjust if needed

  // ---------------- Users ----------------
  Future<List<User>> getUsersForCaregiver(String caregiverId) async {
    final res = await http.get(Uri.parse('$baseUrl/caregivers/$caregiverId/users'));
    if (res.statusCode == 200) {
      final List<dynamic> data = json.decode(res.body);
      return data.map((e) => User.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch users');
    }
  }

  Future<void> addUser(String caregiverId, User user) async {
    final res = await http.post(
      Uri.parse('$baseUrl/caregivers/$caregiverId/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user.toJson()),
    );
    if (res.statusCode != 201) {
      throw Exception('Failed to add user');
    }
  }

  // ---------------- Medications ----------------
  Future<List<Medication>> fetchMedications(String userId) async {
    final res = await http.get(Uri.parse('$baseUrl/medications/$userId'));
    if (res.statusCode == 200) {
      final List<dynamic> data = json.decode(res.body);
      return data.map((e) => Medication.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch medications');
    }
  }

  Future<void> addMedication(String userId, Medication med) async {
    final res = await http.post(
      Uri.parse('$baseUrl/medications/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(med.toJson()),
    );
    if (res.statusCode != 201) {
      throw Exception('Failed to add medication');
    }
  }

  Future<void> updateMedication(String userId, String medicationId, Medication med) async {
    final res = await http.put(
      Uri.parse('$baseUrl/medications/$userId/$medicationId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(med.toJson()),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to update medication');
    }
  }

  Future<void> markTaken(String userId, String medicationId) async {
    final res = await http.post(Uri.parse('$baseUrl/medications/$userId/$medicationId/taken'));
    if (res.statusCode != 200) {
      throw Exception('Failed to mark as taken');
    }
  }

  Future<void> deleteMedication(String userId, String medicationId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/medications/$userId/$medicationId'),
    );
    if (res.statusCode != 204) { // 204 No Content is the standard success code for DELETE
      throw Exception('Failed to delete medication');
    }
  }

  // ---------------- Login ----------------
  Future<User> login(String email, String password, bool isCaregiver) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password, 'isCaregiver': isCaregiver}),
    );
    if (res.statusCode == 200) {
      return User.fromJson(json.decode(res.body));
    } else {
      throw Exception('Login failed');
    }
  }

  // ---------------- Sign Up ----------------
  Future<User> signup(
    String email,
    String name,
    String password,
    int age,
    bool isCaregiver,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'name': name,
        'password': password,
        'age': age,
        'isCaregiver': isCaregiver,
      }),
    );

    if (res.statusCode == 201) {
      return User.fromJson(json.decode(res.body));
    } else {
      throw Exception('Signup failed: ${res.body}');
    }
  }
}
