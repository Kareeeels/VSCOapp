import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../app_config.dart';
import '../session.dart';
import 'feed_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    // For testing purposes, if it's mock, just navigate
    if (_emailController.text == 'user@vsco.com' && _passwordController.text == 'password') {
      Session.username = 'KAREL_VSCO';
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const FeedScreen()),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        AppConfig.uri('/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final email = _emailController.text.trim();
        if (email == 'user@vsco.com') {
          Session.username = 'KAREL_VSCO';
        } else if (email.contains('@')) {
          Session.username = email.split('@').first;
        } else if (email.isNotEmpty) {
          Session.username = email;
        }
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const FeedScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Fallback for demo if backend is not reachable
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e. Using local demo mode.')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const FeedScreen()),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'VSCO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 10,
                ),
              ),
              const SizedBox(height: 60),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Password',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      child: const Text(
                        'SIGN IN',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Navigate to sign up
                },
                child: const Text(
                  'DON\'T HAVE AN ACCOUNT? SIGN UP',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
