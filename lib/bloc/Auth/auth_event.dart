part of 'authbloc.dart';

abstract class AuthEvent {}

class LoginButtonPressed extends AuthEvent {
  final String usernameOrEmail;
  final String password;

  LoginButtonPressed(this.usernameOrEmail, this.password);
}

class RegisterButtonPressed extends AuthEvent {
  final String username;
  final String fName;
  final String lName;
  final String email;
  final String password;

  RegisterButtonPressed({
    required this.username,
    required this.fName,
    required this.lName,
    required this.email,
    required this.password,
  });
}
