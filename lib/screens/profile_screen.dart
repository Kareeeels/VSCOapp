import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../app_config.dart';
import '../models/post.dart';
import '../models/user_profile.dart';
import '../session.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  bool _isLoading = true;
  List<Post> _recent = [];
  List<Post> _reposts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);

    try {
      final userRes = await http.get(AppConfig.uri('/api/users/${Session.username}'));
      final postsRes = await http.get(AppConfig.uri('/api/posts'));
      final repostsRes = await http.get(AppConfig.uri('/api/users/${Session.username}/reposts'));

      if (userRes.statusCode == 200) {
        final json = jsonDecode(userRes.body) as Map<String, dynamic>;
        _profile = UserProfile.fromJson(json);
      }

      if (postsRes.statusCode == 200) {
        final data = jsonDecode(postsRes.body) as List<dynamic>;
        final posts = data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
        _recent = posts.where((p) => p.username == Session.username).toList();
      }

      if (repostsRes.statusCode == 200) {
        final data = jsonDecode(repostsRes.body) as List<dynamic>;
        _reposts = data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openEdit() async {
    final profile = _profile;
    if (profile == null) return;
    final updated = await Navigator.of(context).push<UserProfile>(
      MaterialPageRoute(builder: (_) => EditProfileScreen(profile: profile)),
    );
    if (updated != null) {
      _profile = updated;
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            Session.username,
            style: const TextStyle(fontWeight: FontWeight.w200, letterSpacing: 1.5),
          ),
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white38,
            tabs: [
              Tab(text: 'RECENT'),
              Tab(text: 'REPOSTS'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Column(
                children: [
                  _buildHeader(),
                  const Divider(height: 1, color: Colors.white12),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildGrid(_recent),
                        _buildGrid(_reposts),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    final profile = _profile;
    final avatarUrl = profile?.profilePicture;
    final displayName = (profile?.displayName?.isNotEmpty ?? false) ? profile!.displayName! : Session.username;
    final bio = profile?.bio ?? '';
    final website = profile?.website ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white12,
            backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
                ),
                if (bio.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(bio, style: const TextStyle(color: Colors.white70)),
                ],
                if (website.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(website, style: const TextStyle(color: Colors.white54)),
                ],
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: _openEdit,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                  ),
                  child: const Text('EDIT PROFILE'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<Post> posts) {
    if (posts.isEmpty) {
      return const Center(child: Text('No posts', style: TextStyle(color: Colors.white54)));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: CachedNetworkImage(
            imageUrl: post.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.grey[900]),
            errorWidget: (context, url, error) => Container(color: Colors.grey[900]),
          ),
        );
      },
    );
  }
}

