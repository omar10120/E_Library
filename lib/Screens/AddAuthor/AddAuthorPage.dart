import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddAuthorPage extends StatefulWidget {
  const AddAuthorPage({super.key});

  @override
  State<AddAuthorPage> createState() => _AddAuthorPageState();
}

class _AddAuthorPageState extends State<AddAuthorPage> {
  final _formKey = GlobalKey<FormState>();
  final _fNameCtrl = TextEditingController();
  final _lNameCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  Future<void> _submitAuthor() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final dio = Dio(BaseOptions(
      baseUrl: 'http://amr10140-001-site1.qtempurl.com/',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ));

    final data = {
      "fName": _fNameCtrl.text,
      "lName": _lNameCtrl.text,
      "country": _countryCtrl.text,
      "city": _cityCtrl.text,
      "address": _addressCtrl.text,
    };

    try {
      final res = await dio.post('/Author/Add', data: data);
      if (res.data['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Author added successfully")),
        );
        _formKey.currentState!.reset();
      } else {
        throw Exception(res.data['message'] ?? "Failed to add author");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Author"),
        backgroundColor: Colors.indigo,
        foregroundColor: const Color.fromARGB(255, 232, 231, 233),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField("First Name", _fNameCtrl),
              _buildField("Last Name", _lNameCtrl),
              _buildField("Country", _countryCtrl),
              _buildField("City", _cityCtrl),
              _buildField("Address", _addressCtrl),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitAuthor,
                  icon: const Icon(
                    Icons.person_add_alt_1,
                    color: Color.fromARGB(255, 232, 231, 233),
                  ),
                  label: const Text("Add Author"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: const Color.fromARGB(255, 232, 231, 233),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.edit),
          filled: true,
          fillColor: Colors.indigo.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
      ),
    );
  }
}
