import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/post.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;
  final ColorFilter colorFilter;
  final Future<void> Function(String postId) onRepost;

  const PostDetailScreen({
    super.key,
    required this.post,
    required this.colorFilter,
    required this.onRepost,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          post.username,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            SizedBox(
              width: double.infinity,
              child: ColorFiltered(
                colorFilter: colorFilter,
                child: post.imageUrl.startsWith('data:image')
                    ? Image.memory(
                        base64Decode(post.imageUrl.split(',').last),
                        fit: BoxFit.contain,
                        width: double.infinity,
                      )
                    : CachedNetworkImage(
                        imageUrl: post.imageUrl,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey[900], height: 300),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error, color: Colors.white),
                      ),
              ),
            ),

            // Actions row
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  // Likes
                  const Icon(Icons.favorite_border,
                      color: Colors.white70, size: 22),
                  const SizedBox(width: 6),
                  Text(
                    '${post.likes}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(width: 20),
                  // Repost button
                  GestureDetector(
                    onTap: () async {
                      await onRepost(post.id);
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.repeat, color: Colors.white70, size: 22),
                        SizedBox(width: 6),
                        Text(
                          'Repost',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Username
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                post.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            // Caption
            if (post.caption != null && post.caption!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                child: Text(
                  post.caption!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              )
            else
              const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
