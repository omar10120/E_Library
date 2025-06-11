import 'dart:io';

import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/Auth/authbloc.dart';
import 'bloc/book/book_bloc.dart';

import 'Services/api_service.dart';

import 'Screens/login/LoginPage.dart';
import 'Screens/register/RegisterPage.dart';
import 'Screens/splash/SplashPage.dart';
import 'Screens/BookList/BookListPage.dart';
import 'Screens/AdminHome/AdminHomePage.dart';
import 'Screens/UserHome/UserHomePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => BookBloc(ApiService())..add(FetchBooks())),
      ],
      child: MaterialApp(
        title: 'E_library',
        debugShowCheckedModeBanner: false,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashPage(),
          '/': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/books': (context) => const BookListPage(),
          '/admin': (context) => const AdminHomePage(),
          '/user': (context) => const UserHomePage(),
        },
      ),
    );
  }
}
