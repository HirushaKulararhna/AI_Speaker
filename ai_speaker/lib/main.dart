import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const AIConsultantApp());
}

class AIConsultantApp extends StatelessWidget {
  const AIConsultantApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Speaker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}