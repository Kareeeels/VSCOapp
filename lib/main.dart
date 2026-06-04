import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const VscoCloneApp());
}

class VscoCloneApp extends StatelessWidget {
  const VscoCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VSCO Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const LoginScreen(),
    );
  }
}