part of 'authbloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String role;
  AuthSuccess({required this.role});
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}
