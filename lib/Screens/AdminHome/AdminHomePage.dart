import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../BookList/BookListPage.dart';
import '../AddBook/AddBookPage.dart';
import '../AddAuthor/AddAuthorPage.dart';
import '../AddPublisher/AddPublisherPage .dart';
import '../BookList/BookListPage.dart';
import '../AuthorList/AuthorListPage.dart';
import '../PublisherList/PublisherListPage.dart';
import '../Profile/ProfilePage.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _currentIndex = 0;

  final _pages = [
    const BookListPage(showAppBar: false),
    const AuthorListPage(), // 🔍 List + Search
    const PublisherListPage(), // 🔍 List + Search
  ];

  final _titles = [
    "Books",
    "Authors",
    "Publishers",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
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
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
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
