import 'dart:io'; // ⬅️ Required for SocketException
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/token_model.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginButtonPressed>(_onLogin);
    on<RegisterButtonPressed>(_onRegister);
  }

  Future<void> _onLogin(
      LoginButtonPressed event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final response = await Dio().post(
        'http://amr10140-001-site1.qtempurl.com/Users/Login',
        data: {
          "usernameOrEmail": event.usernameOrEmail,
          "password": event.password,
        },
      );

      final tokenJson = response.data["data"];
      if (tokenJson == null || tokenJson["token"] == null) {
        emit(AuthFailure("Invalid token received"));
        return;
      }

      final token = TokenModel.fromMap(tokenJson);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', token.token);
      await prefs.setString('userRole', token.userRole ?? '');

      emit(AuthSuccess(role: token.userRole));
    } on DioException catch (e) {
      final msg = e.response?.data["message"] ?? e.message ?? "Login failed";
      emit(AuthFailure(msg));
    } on SocketException {
      emit(AuthFailure("No internet connection. Please check your network."));
    } catch (e) {
      emit(AuthFailure("Unexpected error: $e"));
    }
  }

  Future<void> _onRegister(
      RegisterButtonPressed event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final response = await Dio().post(
        'http://amr10140-001-site1.qtempurl.com/Users/Register',
        data: {
          "username": event.username,
          "fName": event.fName,
          "lName": event.lName,
          "email": event.email,
          "password": event.password,
        },
      );

      final success = response.data["isSuccess"] ?? false;
      final message = response.data["message"] ?? "Unknown error";

      if (!success) {
        emit(AuthFailure(message));
        return;
      }

      if (success) {
        emit(AuthSuccess(
            role: "RedirectToLogin")); // ✅ This will trigger navigation
      }
      // emit(AuthSuccess(role: "RedirectToLogin"));
    } on DioException catch (e) {
      if (e.response != null && e.response?.statusCode == 400) {
        final errorData = e.response?.data;

        if (errorData != null && errorData["errors"] != null) {
          final errors = errorData["errors"] as Map<String, dynamic>;
          final messages = errors.entries
              .expand((entry) => (entry.value as List).map((e) => "- $e"))
              .join("\n");
          emit(AuthFailure("Validation errors:\n$messages"));
        } else {
          emit(AuthFailure("Bad request"));
        }
      } else {
        final msg =
            e.response?.data["message"] ?? e.message ?? "Registration failed";
        emit(AuthFailure(msg));
      }
    } on SocketException {
      emit(AuthFailure("No internet connection. Please check your network."));
    } catch (e) {
      emit(AuthFailure("Unexpected error: $e"));
    }
  }
}
