import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  final bool isAdmin;
  const ProfilePage({super.key, this.isAdmin = false});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loading = true, _editing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameCtrl, _lastNameCtrl, _userNameCtrl;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController();
    _lastNameCtrl = TextEditingController();
    _userNameCtrl = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _userNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    try {
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';
      final res =
          await dio.get('http://amr10140-001-site1.qtempurl.com/Users/Profile');
      final list = res.data['data'] as List;
      if (list.isNotEmpty) {
        final data = list.first as Map<String, dynamic>;
        _firstNameCtrl.text = data['fName'] ?? '';
        _lastNameCtrl.text = data['lName'] ?? '';
        _userNameCtrl.text = data['userName'] ?? '';
      }
    } on DioException catch (e) {
      _showError(e.response?.data['message'] ?? e.message ?? 'Fetch failed');
    } on SocketException {
      _showError("No internet connection.");
    } catch (e) {
      _showError("Error: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    try {
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';
      final res = await dio.patch(
        'http://amr10140-001-site1.qtempurl.com/Users/Update',
        data: {
          'username': _userNameCtrl.text.trim(),
          'fName': _firstNameCtrl.text.trim(),
          'lName': _lastNameCtrl.text.trim(),
        },
      );
      final success = res.data['success'] ?? res.data['isSuccess'] ?? false;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Profile updated"), backgroundColor: Colors.green),
        );
        setState(() => _editing = false);
      } else {
        final msg = res.data['message'] ?? 'Update failed';
        _showError(msg);
      }
    } catch (e) {
      _showError("Error: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: Text(widget.isAdmin ? 'Admin Profile' : 'My Profile'),
        actions: [
          IconButton(
            icon: Icon(_editing ? Icons.save : Icons.edit),
            onPressed: _editing
                ? _updateProfile
                : () => setState(() => _editing = true),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfile,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade50, Colors.blue.shade100],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue.shade700,
                        child: Text(
                          _firstNameCtrl.text.isNotEmpty
                              ? _firstNameCtrl.text[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              fontSize: 40, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInput("First Name", _firstNameCtrl),
                      _buildInput("Last Name", _lastNameCtrl),
                      _buildInput("Username", _userNameCtrl),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: ctrl,
        readOnly: !_editing,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
      ),
    );
  }
}
