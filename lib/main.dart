import 'package:flutter/material.dart';
import 'package:my_project/screens/login_screen.dart';

void main() {
  runApp(const UniversityScheduleApp());
}

class UniversityScheduleApp extends StatelessWidget {
  const UniversityScheduleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University Schedule',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
