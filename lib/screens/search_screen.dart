import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../app_config.dart';
import '../models/post.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<Post> _allPosts = [];
  List<Post> _filteredPosts = [];
  bool _isLoading = true;
  String _query = '';

  // Simulated follow state per username
  final Set<String> _followed = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchPosts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPosts() async {
    try {
      final response = await http.get(AppConfig.uri('/api/posts'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final posts = data.map((json) => Post.fromJson(json)).toList();
        if (mounted) {
          setState(() {
            _allPosts = posts;
            _filteredPosts = posts;
            _isLoading = false;
          });
        }
      } else {
        _useFallback();
      }
    } catch (_) {
      _useFallback();
    }
  }

  void _useFallback() {
    if (!mounted) return;
    setState(() {
      _allPosts = [
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
      _filteredPosts = _allPosts;
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      _query = q;
      if (q.isEmpty) {
        _filteredPosts = _allPosts;
      } else {
        _filteredPosts = _allPosts.where((p) {
          final usernameMatch =
              p.username.toLowerCase().contains(q);
          final captionMatch =
              (p.caption ?? '').toLowerCase().contains(q);
          return usernameMatch || captionMatch;
        }).toList();
      }
    });
  }

  // Unique users derived from posts
  List<Post> get _uniqueUserPosts {
    final seen = <String>{};
    return _filteredPosts.where((p) => seen.add(p.username)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────
            Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(Icons.search,
                              size: 20, color: Colors.grey[500]),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                          suffixIcon: _query.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                  },
                                  child: Icon(Icons.close,
                                      size: 18, color: Colors.grey[500]),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Tabs ─────────────────────────────────────────────
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
                indicatorWeight: 1.5,
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
                tabs: const [
                  Tab(text: 'PEOPLE'),
                  Tab(text: 'IMAGES'),
                  Tab(text: 'BLOGS'),
                ],
              ),
            ),

            // ── Content ──────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.black))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPeopleTab(),
                        _buildImagesTab(),
                        _buildBlogsTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── People Tab ─────────────────────────────────────────────────────────────
  Widget _buildPeopleTab() {
    final people = _uniqueUserPosts;
    if (people.isEmpty) {
      return _emptyState('No people found');
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: people.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
      itemBuilder: (context, index) {
        final post = people[index];
        return _PeopleCard(
          post: post,
          isFollowed: _followed.contains(post.username),
          onFollow: () {
            setState(() {
              if (_followed.contains(post.username)) {
                _followed.remove(post.username);
              } else {
                _followed.add(post.username);
              }
            });
          },
        );
      },
    );
  }

  // ── Images Tab ─────────────────────────────────────────────────────────────
  Widget _buildImagesTab() {
    if (_filteredPosts.isEmpty) {
      return _emptyState('No images found');
    }
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemCount: _filteredPosts.length,
      itemBuilder: (context, index) {
        final post = _filteredPosts[index];
        return _buildThumbnail(post);
      },
    );
  }

  Widget _buildThumbnail(Post post) {
    if (post.imageUrl.startsWith('data:image')) {
      return Image.memory(
        base64Decode(post.imageUrl.split(',').last),
        fit: BoxFit.cover,
      );
    }
    return CachedNetworkImage(
      imageUrl: post.imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) =>
          Container(color: const Color(0xFFE0E0E0)),
      errorWidget: (context, url, error) =>
          Container(color: const Color(0xFFE0E0E0)),
    );
  }

  // ── Blogs Tab ──────────────────────────────────────────────────────────────
  Widget _buildBlogsTab() {
    // No blog endpoint — show posts with caption as blog-style cards
    final withCaption =
        _filteredPosts.where((p) => (p.caption ?? '').isNotEmpty).toList();
    if (withCaption.isEmpty) {
      return _emptyState('No blogs found');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: withCaption.length,
      itemBuilder: (context, index) {
        final post = withCaption[index];
        return _BlogCard(post: post);
      },
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// ── People Card Widget ────────────────────────────────────────────────────────
class _PeopleCard extends StatelessWidget {
  final Post post;
  final bool isFollowed;
  final VoidCallback onFollow;

  const _PeopleCard({
    required this.post,
    required this.isFollowed,
    required this.onFollow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Avatar
          ClipOval(
            child: SizedBox(
              width: 44,
              height: 44,
              child: post.imageUrl.startsWith('data:image')
                  ? Image.memory(
                      base64Decode(post.imageUrl.split(',').last),
                      fit: BoxFit.cover,
                    )
                  : CachedNetworkImage(
                      imageUrl: post.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey[200]),
                      errorWidget: (context, url, error) =>
                          Container(color: Colors.grey[200]),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Username + caption
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.username,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                if ((post.caption ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      post.caption!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Follow button
          GestureDetector(
            onTap: onFollow,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isFollowed ? Colors.white : Colors.black,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                isFollowed ? 'FOLLOWING' : 'FOLLOW',
                style: TextStyle(
                  color: isFollowed ? Colors.black : Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Blog Card Widget ──────────────────────────────────────────────────────────
class _BlogCard extends StatelessWidget {
  final Post post;

  const _BlogCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              bottomLeft: Radius.circular(4),
            ),
            child: SizedBox(
              width: 80,
              height: 80,
              child: post.imageUrl.startsWith('data:image')
                  ? Image.memory(
                      base64Decode(post.imageUrl.split(',').last),
                      fit: BoxFit.cover,
                    )
                  : CachedNetworkImage(
                      imageUrl: post.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey[200]),
                      errorWidget: (context, url, error) =>
                          Container(color: Colors.grey[200]),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.username,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.caption ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
