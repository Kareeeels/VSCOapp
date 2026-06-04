import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../app_config.dart';
import '../models/post.dart';
import '../session.dart';
import 'post_detail_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'studio_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Post> _posts = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    try {
      final response = await http.get(AppConfig.uri('/api/posts'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _posts = data.map((json) => Post.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        _setFallbackPosts();
      }
    } catch (e) {
      _setFallbackPosts();
    }
  }

  void _setFallbackPosts() {
    setState(() {
      _posts = [
        Post(
          id: '1',
          imageUrl:
              'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
          username: 'nature_explorer',
          caption: 'Quiet morning in the mountains.',
          likes: 124,
        ),
        Post(
          id: '2',
          imageUrl:
              'https://images.unsplash.com/photo-1534067783941-51c9c23ecefd',
          username: 'urban_lines',
          caption: 'Steel and glass.',
          likes: 89,
        ),
      ];
      _isLoading = false;
    });
  }

  Future<void> _repost(String postId) async {
    try {
      final res = await http
          .post(AppConfig.uri('/api/users/${Session.username}/reposts/$postId'));
      if (!mounted) return;
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Repost agregado')),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al repost (${res.statusCode})')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // FIX: AppBar aquí en el Scaffold raíz, no en _buildFeedBody
      appBar: _selectedIndex == 0
          ? AppBar(
              title: const Text(
                'VSCO',
                style: TextStyle(fontWeight: FontWeight.w200, letterSpacing: 4),
              ),
              backgroundColor: Colors.black,
              elevation: 0,
              centerTitle: true,
            )
          : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildFeedBody(),
          SearchScreen(),
          const StudioScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white24,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_outlined), label: 'Studio'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildFeedBody() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }

    return RefreshIndicator(
      onRefresh: _fetchPosts,
      color: Colors.white,
      backgroundColor: Colors.black,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          childAspectRatio: 1,
        ),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          final filter = _getFilterFromWebString(post.filter);
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PostDetailScreen(
                    post: post,
                    colorFilter: filter,
                    onRepost: _repost,
                  ),
                ),
              );
            },
            child: ColorFiltered(
              colorFilter: filter,
              child: post.imageUrl.startsWith('data:image')
                  ? Image.memory(
                      base64Decode(post.imageUrl.split(',').last),
                      fit: BoxFit.cover,
                    )
                  : CachedNetworkImage(
                      imageUrl: post.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey[900]),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
            ),
          );
        },
      ),
    );
  }

  ColorFilter _getFilterFromWebString(String? filterStr) {
    if (filterStr == null || filterStr == 'none') {
      // FIX: BlendMode.dst deja la imagen intacta (antes usaba multiply con
      // transparent, lo que oscurecía la imagen)
      return const ColorFilter.mode(Colors.transparent, BlendMode.dst);
    }
    if (filterStr.contains('sepia')) {
      return const ColorFilter.matrix([
        1, 0, 0, 0, 30,
        0, 1, 0, 0, 10,
        0, 0, 1, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    }
    if (filterStr.contains('hue-rotate')) {
      return const ColorFilter.matrix([
        0.9, 0, 0, 0, 0,
        0, 0.9, 0, 0, 0,
        0, 0, 1.1, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    }
    if (filterStr.contains('grayscale')) {
      return const ColorFilter.matrix([
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    }
    return const ColorFilter.mode(Colors.transparent, BlendMode.dst);
  }
}
