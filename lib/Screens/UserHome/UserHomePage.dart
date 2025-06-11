import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../BookList/BookListPage.dart';
import '../AuthorList/AuthorListPage.dart';
import '../PublisherList/PublisherListPage.dart';
import '../Profile/ProfilePage.dart'; // Make sure this exists and is routed properly

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _index = 0;

  final _titles = ["Books", "Authors", "Publishers"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
              }
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          BookListPage(showAppBar: false),
          AuthorListPage(isAdmin: false),
          PublisherListPage(isAdmin: false),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Books"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Authors"),
          BottomNavigationBarItem(
              icon: Icon(Icons.business), label: "Publishers"),
        ],
      ),
    );
  }
}
