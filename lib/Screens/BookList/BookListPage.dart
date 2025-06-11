import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../bloc/book/book_bloc.dart';
import '../../Models/book_model.dart';
import '../AddBook/AddBookPage.dart';

class BookListPage extends StatefulWidget {
  final bool showAppBar;
  const BookListPage({super.key, this.showAppBar = true});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  final _searchCtrl = TextEditingController();
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('userRole');
    if (mounted) {
      setState(() => _isAdmin = role == "Admin");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text("Books"),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<BookBloc>().add(FetchBooks());
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Logout',
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/', (_) => false);
                    }
                  },
                ),
              ],
            )
          : PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: AppBar(
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      context.read<BookBloc>().add(FetchBooks());
                    },
                  ),
                ],
              ),
            ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddBookPage()),
                );
                if (mounted) context.read<BookBloc>().add(FetchBooks());
              },
              tooltip: "Add Book",
              icon: const Icon(Icons.add),
              label: const Text("Add Book"),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  context.read<BookBloc>().add(SearchBooks(value.trim()));
                }
              },
              decoration: InputDecoration(
                hintText: "Search books by title...",
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
          Expanded(
            child: BlocBuilder<BookBloc, BookState>(
              builder: (context, state) {
                if (state is BookLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is BookLoaded) {
                  if (state.books.isEmpty) {
                    return const Center(child: Text("No books found."));
                  }
                  return ListView.builder(
                    itemCount: state.books.length,
                    itemBuilder: (_, i) => _buildBookCard(state.books[i]),
                  );
                } else if (state is BookError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(BookModel book) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                book.title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text("Author: ${book.authorFullName}",
                  style: const TextStyle(color: Colors.grey)),
              Text("Publisher: ${book.publisherName}",
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "\$${book.price.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
