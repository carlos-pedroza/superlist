import 'package:Shopping/presenter/home/my_home_page.dart';
import 'package:flutter/material.dart';

class SApp extends StatefulWidget {
  const SApp({super.key});

  @override
  State<SApp> createState() => _SAppState();
}

class _SAppState extends State<SApp> {
  final customPrimaryColor = const Color(0xFF9d1a50); // Definir tu color personalizado

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Colors.white, fontSize: 24),
          displayLarge: TextStyle(color: Colors.white, fontSize: 32),
          displayMedium: TextStyle(color: Colors.white, fontSize: 18),
          displaySmall: TextStyle(color: Colors.white, fontSize: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.pink[800]),
            foregroundColor: MaterialStateProperty.all(Colors.white),
          ),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}