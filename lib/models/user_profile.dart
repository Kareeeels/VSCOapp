class UserProfile {
  final String username;
  final String? displayName;
  final String? bio;
  final String? website;
  final String? profilePicture;

  const UserProfile({
    required this.username,
    this.displayName,
    this.bio,
    this.website,
    this.profilePicture,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: (json['username'] ?? '').toString(),
      displayName: json['displayName']?.toString(),
      bio: json['bio']?.toString(),
      website: json['website']?.toString(),
      profilePicture: json['profilePicture']?.toString(),
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'username': username,
      'displayName': displayName,
      'bio': bio,
      'website': website,
      'profilePicture': profilePicture,
    };
  }
}
