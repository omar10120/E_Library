import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/publisher_model.dart';
import '../AddPublisher/AddPublisherPage .dart';

class PublisherListPage extends StatefulWidget {
  final bool isAdmin;
  const PublisherListPage({super.key, this.isAdmin = true});

  @override
  State<PublisherListPage> createState() => _PublisherListPageState();
}

class _PublisherListPageState extends State<PublisherListPage> {
  final _searchCtrl = TextEditingController();
  List<PublisherModel> _publishers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchPublishers();
  }

  Future<void> _fetchPublishers({String? name}) async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final dio = Dio(BaseOptions(
      baseUrl: 'http://amr10140-001-site1.qtempurl.com/',
      headers: {'Authorization': 'Bearer $token'},
    ));

    try {
      final res = name == null || name.isEmpty
          ? await dio.get('/Publishers')
          : await dio
              .get('/Publishers/Search', queryParameters: {'name': name});
      final list = List<Map<String, dynamic>>.from(res.data['data']);
      if (mounted)
        setState(() {
          _publishers = list.map((e) => PublisherModel.fromMap(e)).toList();
        });
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Error: $e"), backgroundColor: Colors.redAccent));
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
            onPressed: () => _fetchPublishers(),
          ),
        ],
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddPublisherPage()),
                );
                _fetchPublishers();
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Publisher"),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: (val) => _fetchPublishers(name: val),
              decoration: InputDecoration(
                hintText: "Search by publisher name...",
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
          else if (_publishers.isEmpty)
            const Expanded(child: Center(child: Text("No publishers found.")))
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _publishers.length,
                itemBuilder: (_, i) => _buildPublisherCard(_publishers[i]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPublisherCard(PublisherModel pub) {
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
              pub.pName.isNotEmpty ? pub.pName[0].toUpperCase() : '',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            pub.pName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            pub.city,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
