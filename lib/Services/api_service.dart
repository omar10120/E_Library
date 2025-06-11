import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://amr10140-001-site1.qtempurl.com/', // ✅ Replace if needed
    headers: {'Content-Type': 'application/json'},
  ));

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('accessToken');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<List<dynamic>> getAllBooks() async {
    final res = await _dio.get('/Books');
    return res.data['data'] ?? [];
  }

  Future<List<dynamic>> searchBooksByTitle(String title) async {
    final res =
        await _dio.get('/Books/Search', queryParameters: {'title': title});
    return res.data['data'] ?? [];
  }

  Future<List<dynamic>> searchAuthorsByName(String name) async {
    final res =
        await _dio.get('/Authors/Search', queryParameters: {'name': name});
    return res.data['data'] ?? [];
  }

  Future<List<dynamic>> searchPublishersByName(String name) async {
    final res =
        await _dio.get('/Publishers/Search', queryParameters: {'name': name});
    return res.data['data'] ?? [];
  }
}
