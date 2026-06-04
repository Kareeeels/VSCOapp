import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../app_config.dart';
import '../models/user_profile.dart';
import '../session.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _usernameController;
  late final TextEditingController _displayNameController;
  late final TextEditingController _bioController;
  late final TextEditingController _websiteController;
  late final TextEditingController _profilePictureController;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.profile.username);
    _displayNameController = TextEditingController(text: widget.profile.displayName ?? '');
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
    _websiteController = TextEditingController(text: widget.profile.website ?? '');
    _profilePictureController = TextEditingController(text: widget.profile.profilePicture ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _profilePictureController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final update = UserProfile(
        username: _usernameController.text.trim(),
        displayName: _displayNameController.text.trim().isEmpty ? null : _displayNameController.text.trim(),
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
        profilePicture: _profilePictureController.text.trim().isEmpty ? null : _profilePictureController.text.trim(),
      );

      final res = await http.put(
        AppConfig.uri('/api/users/${widget.profile.username}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(update.toUpdateJson()),
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final saved = UserProfile.fromJson(json);
        Session.username = saved.username;
        Navigator.of(context).pop(saved);
        return;
      }

      if (res.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ese username ya existe')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar (${res.statusCode})')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EDIT PROFILE', style: TextStyle(fontWeight: FontWeight.w200, letterSpacing: 2)),
        backgroundColor: Colors.black,
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? '...' : 'SAVE', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _field('Username', _usernameController),
          const SizedBox(height: 12),
          _field('Display name', _displayNameController),
          const SizedBox(height: 12),
          _field('Bio', _bioController, maxLines: 3),
          const SizedBox(height: 12),
          _field('Website', _websiteController),
          const SizedBox(height: 12),
          _field('Profile photo URL', _profilePictureController),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}

