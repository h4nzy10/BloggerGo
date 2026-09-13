import 'package:ats/pages/landing.dart';
import 'package:ats/pages/home.dart';
import 'package:ats/pages/detail.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => LandingPage(),
        '/home': (context) => HomePage(),
        '/detail': (context) => DetailPostPage(),
      },
    );
  }
}