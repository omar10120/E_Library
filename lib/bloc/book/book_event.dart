part of 'book_bloc.dart';

abstract class BookEvent {}

class FetchBooks extends BookEvent {}

class SearchBooks extends BookEvent {
  final String title;
  SearchBooks(this.title);
}
