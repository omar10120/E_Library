import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/author_model.dart';
import '../AddAuthor/AddAuthorPage.dart';

class AuthorListPage extends StatefulWidget {
  final bool isAdmin;
  const AuthorListPage({super.key, this.isAdmin = true});

  @override
  State<AuthorListPage> createState() => _AuthorListPageState();
}

class _AuthorListPageState extends State<AuthorListPage> {
  final _searchCtrl = TextEditingController();
  List<AuthorModel> _authors = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAuthors();
  }

  Future<void> _fetchAuthors({String? query}) async {
    if (!mounted) return;
    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final dio = Dio(BaseOptions(
      baseUrl: 'http://amr10140-001-site1.qtempurl.com/',
      headers: {'Authorization': 'Bearer $token'},
    ));

    try {
      final res = query == null || query.isEmpty
          ? await dio.get('/Author')
          : await dio.get('/Author/Search', queryParameters: {'name': query});
      final list = List<Map<String, dynamic>>.from(res.data['data']);
      if (!mounted) return;
      setState(() {
        _authors = list.map((e) => AuthorModel.fromMap(e)).toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching authors: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => _fetchAuthors(),
          )
        ],
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddAuthorPage()),
                );
                if (mounted) _fetchAuthors();
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Author"),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: (val) => _fetchAuthors(query: val),
              decoration: InputDecoration(
                hintText: "Search by first or last name...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_authors.isEmpty)
            const Expanded(child: Center(child: Text("No authors found.")))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _authors.length,
                itemBuilder: (_, i) => _buildAuthorCard(_authors[i]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAuthorCard(AuthorModel a) {
    final name = "${a.fName} ${a.lName}";
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              a.fName.isNotEmpty ? a.fName[0].toUpperCase() : '?',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text("City: ${a.city}, ${a.country}",
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 2),
              Text(a.address, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
