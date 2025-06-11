import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String? _selectedAuthorId, _selectedPublisherId;

  List<Map<String, dynamic>> _authors = [];
  List<Map<String, dynamic>> _publishers = [];

  @override
  void initState() {
    super.initState();
    _fetchAuthorsAndPublishers();
  }

  Future<void> _fetchAuthorsAndPublishers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final dio = Dio(BaseOptions(
      baseUrl: 'http://amr10140-001-site1.qtempurl.com/',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ));

    try {
      final authorsRes = await dio.get('/Author');
      final pubsRes = await dio.get('/Publishers');
      if (!mounted) return;
      setState(() {
        _authors = List<Map<String, dynamic>>.from(authorsRes.data['data']);
        _publishers = List<Map<String, dynamic>>.from(pubsRes.data['data']);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load data: $e")),
      );
    }
  }

  Future<void> _submitBook() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAuthorId == null || _selectedPublisherId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select author and publisher")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final dio = Dio(BaseOptions(
      baseUrl: 'http://amr10140-001-site1.qtempurl.com/',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ));

    try {
      final res = await dio.post('/Books/Add', data: {
        "title": _titleCtrl.text.trim(),
        "type": _typeCtrl.text.trim(),
        "price": double.tryParse(_priceCtrl.text.trim()) ?? 0,
        "authorId": _selectedAuthorId,
        "pubId": _selectedPublisherId,
      });
      if (!mounted) return;
      if (res.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Book added successfully")),
        );
        _formKey.currentState!.reset();
        setState(() {
          _selectedAuthorId = null;
          _selectedPublisherId = null;
        });
      } else {
        throw Exception(res.data['message'] ?? "Unknown error");
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
        title: const Text("Add Book"),
        backgroundColor: Colors.indigo,
        foregroundColor: const Color.fromARGB(255, 232, 231, 233),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField("Title", _titleCtrl),
              _buildTextField("Type", _typeCtrl),
              _buildTextField("Price", _priceCtrl, isNumber: true),
              const SizedBox(height: 16),
              _buildDropdownField(
                "Select Author",
                _selectedAuthorId,
                _authors.map((a) {
                  return DropdownMenuItem(
                    value: a['id'].toString(),
                    child: Text("${a['fName']} ${a['lName']}"),
                  );
                }).toList(),
                (val) => setState(() => _selectedAuthorId = val),
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                "Select Publisher",
                _selectedPublisherId,
                _publishers.map((p) {
                  return DropdownMenuItem(
                    value: p['id'].toString(),
                    child: Text(p['pName']),
                  );
                }).toList(),
                (val) => setState(() => _selectedPublisherId = val),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitBook,
                  icon: const Icon(
                    Icons.bookmark_add,
                    color: Color.fromARGB(255, 232, 231, 233),
                  ),
                  label: const Text("Add Book"),
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

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.edit),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.indigo.shade50,
        ),
        validator: (val) =>
            val == null || val.trim().isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    List<DropdownMenuItem<String>> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.arrow_drop_down),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.indigo.shade50,
      ),
      items: items,
      onChanged: onChanged,
      validator: (val) => val == null ? 'Required' : null,
    );
  }
}
