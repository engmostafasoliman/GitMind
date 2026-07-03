import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user_model.dart';

class ProfileDataSource {
  static const _apiBase = 'https://api.github.com';

  Future<UserModel> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$_apiBase/user'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github.v3+json',
      },
    );
    if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    }
    if (response.statusCode != 200) {
      throw Exception('GitHub API error: ${response.statusCode}');
    }
    return UserModel.fromGitHub(
        jsonDecode(response.body) as Map<String, dynamic>);
  }
}
