import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPublisherPage extends StatefulWidget {
  const AddPublisherPage({super.key});

  @override
  State<AddPublisherPage> createState() => _AddPublisherPageState();
}

class _AddPublisherPageState extends State<AddPublisherPage> {
  final _formKey = GlobalKey<FormState>();
  final _pNameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  Future<void> _submitPublisher() async {
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
      "pName": _pNameCtrl.text,
      "city": _cityCtrl.text,
    };

    try {
      final res = await dio.post('/Publishers/Add', data: data);
      if (res.data['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Publisher added successfully")),
        );
        _formKey.currentState!.reset();
      } else {
        throw Exception(res.data['message'] ?? "Failed to add publisher");
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
        title: const Text("Add Publisher"),
        backgroundColor: Colors.indigo,
        foregroundColor: const Color.fromARGB(255, 232, 231, 233),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField("Publisher Name", _pNameCtrl),
              _buildField("City", _cityCtrl),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitPublisher,
                  icon: const Icon(
                    Icons.business,
                    color: Color.fromARGB(255, 232, 231, 233),
                  ),
                  label: const Text("Add Publisher"),
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
          prefixIcon: const Icon(Icons.edit_location_alt),
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
