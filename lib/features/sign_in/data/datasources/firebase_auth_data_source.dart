import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../profile/domain/entities/user_entity.dart';

class FirebaseAuthDataSource {
  final FirebaseAuth _auth;
  final FlutterSecureStorage _storage;

  FirebaseAuthDataSource({
    FirebaseAuth? auth,
    FlutterSecureStorage? storage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? const FlutterSecureStorage();

  Future<UserEntity> signInWithGitHub() async {
    final provider = GithubAuthProvider()
      ..addScope('read:user')
      ..addScope('public_repo');

    final userCredential = await _auth.signInWithProvider(provider);

    // Extract token — on iOS the runtime type may differ from OAuthCredential
    // so we fall back to dynamic access to avoid a hard-cast TypeError
    String? token;
    final raw = userCredential.credential;
    if (raw is OAuthCredential) {
      token = raw.accessToken;
    } else {
      try {
        token = (raw as dynamic)?.accessToken as String?;
      } catch (_) {}
    }

    if (token != null) {
      await _storage.write(key: 'github_access_token', value: token);
    }

    return _buildUserEntity(token);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _storage.delete(key: 'github_access_token');
  }

  User? get currentFirebaseUser => _auth.currentUser;

  Future<String?> get accessToken => _storage.read(key: 'github_access_token');

  Future<UserEntity?> getPersistedUser() async {
    if (_auth.currentUser == null) return null;
    try {
      final token = await _storage.read(key: 'github_access_token');
      return await _buildUserEntity(token);
    } catch (_) {
      return null;
    }
  }

  Future<UserEntity> _buildUserEntity(String? token) async {
    if (token == null) {
      final fb = _auth.currentUser!;
      final name = fb.displayName ?? '';
      return UserEntity(
        name: name,
        handle: fb.providerData.firstOrNull?.uid ?? '',
        initials: _initials(name),
        avatarUrl: fb.photoURL,
        bio: '', location: '', company: '', joined: '',
        followers: 0, following: 0, publicRepos: 0, stars: 0,
      );
    }

    final response = await http.get(
      Uri.parse('https://api.github.com/user'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github.v3+json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('GitHub API error: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final name = (json['name'] as String?)?.isNotEmpty == true
        ? json['name'] as String
        : json['login'] as String? ?? '';

    return UserEntity(
      name: name,
      handle: json['login'] as String? ?? '',
      initials: _initials(name),
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String? ?? '',
      location: json['location'] as String? ?? '',
      company: json['company'] as String? ?? '',
      joined: _formatDate(json['created_at'] as String?),
      followers: json['followers'] as int? ?? 0,
      following: json['following'] as int? ?? 0,
      publicRepos: json['public_repos'] as int? ?? 0,
      stars: 0,
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return 'Joined ${months[dt.month - 1]} ${dt.year}';
  }
}
