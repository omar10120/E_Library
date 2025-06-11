import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Models/book_model.dart';
import '../../Services/api_service.dart';
import 'dart:io';
part 'book_event.dart';
part 'book_state.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  final ApiService _apiService;

  BookBloc(this._apiService) : super(BookInitial()) {
    on<FetchBooks>(_onFetchBooks);
    on<SearchBooks>(_onSearchBooks);
  }

  Future<void> _onFetchBooks(FetchBooks event, Emitter<BookState> emit) async {
    emit(BookLoading());
    try {
      final data = await _apiService.getAllBooks();
      final books = data.map<BookModel>((e) => BookModel.fromMap(e)).toList();
      emit(BookLoaded(books));
    } on DioException catch (e) {
      emit(BookError("Failed to load books: $e"));
    } on SocketException {
      emit(BookError("No internet connection. Please check your network."));
    } catch (e) {
      emit(BookError("Unexpected error: $e"));
    }
  }

  Future<void> _onSearchBooks(
      SearchBooks event, Emitter<BookState> emit) async {
    emit(BookLoading());
    try {
      final data = await _apiService.searchBooksByTitle(event.title);
      final books = data.map<BookModel>((e) => BookModel.fromMap(e)).toList();
      emit(BookLoaded(books));
    } on DioException catch (e) {
      emit(BookError("Search failed: $e"));
    } on SocketException {
      emit(BookError("No internet connection. Please check your network."));
    } catch (e) {
      emit(BookError("Unexpected error: $e"));
    }
  }
}
