class Post {
  final String id;
  final String imageUrl;
  final String username;
  final String caption;
  final int likes;
  final String? filter;

  Post({
    required this.id,
    required this.imageUrl,
    required this.username,
    required this.caption,
    required this.likes,
    this.filter,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'].toString(),
      imageUrl: json['imageUrl'],
      username: json['username'],
      caption: json['caption'] ?? '',
      likes: json['likes'] ?? 0,
      filter: json['filter'],
    );
  }
}
