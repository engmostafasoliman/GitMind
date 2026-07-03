import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.name,
    required super.handle,
    required super.initials,
    super.avatarUrl,
    required super.bio,
    required super.location,
    required super.company,
    required super.joined,
    required super.followers,
    required super.following,
    required super.publicRepos,
    required super.stars,
  });

  factory UserModel.fromGitHub(Map<String, dynamic> json) {
    final login = json['login'] as String? ?? '';
    final name = json['name'] as String? ?? login;
    final initials = _initials(name.isNotEmpty ? name : login);
    final createdAt = json['created_at'] as String? ?? '';
    final joined = createdAt.isNotEmpty
        ? 'Joined ${_monthYear(createdAt)}'
        : '';
    return UserModel(
      name: name,
      handle: login,
      initials: initials,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String? ?? '',
      location: json['location'] as String? ?? '',
      company: (json['company'] as String? ?? '').replaceAll('@', ''),
      joined: joined,
      followers: json['followers'] as int? ?? 0,
      following: json['following'] as int? ?? 0,
      publicRepos: json['public_repos'] as int? ?? 0,
      stars: 0,
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  static String _monthYear(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }
}
