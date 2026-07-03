import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/repo_model.dart';

class GitHubRepoHttpSource {
  static const _apiBase = 'https://api.github.com';

  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github.v3+json',
      };

  Future<List<RepoModel>> getRepos(String token) async {
    final response = await http.get(
      Uri.parse('$_apiBase/user/repos?per_page=100&sort=updated&type=all'),
      headers: _headers(token),
    );
    if (response.statusCode != 200) {
      throw Exception('GitHub API error: ${response.statusCode}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((json) => RepoModel.fromGitHub(json as Map<String, dynamic>))
        .toList();
  }

  Future<RepoModel> getRepoById(String token, String id) async {
    final response = await http.get(
      Uri.parse('$_apiBase/repositories/$id'),
      headers: _headers(token),
    );
    if (response.statusCode != 200) {
      throw Exception('Repository not found');
    }
    return RepoModel.fromGitHub(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Map<String, int>> getLanguages(
      String token, String owner, String name) async {
    final response = await http.get(
      Uri.parse('$_apiBase/repos/$owner/$name/languages'),
      headers: _headers(token),
    );
    if (response.statusCode != 200) return {};
    return (jsonDecode(response.body) as Map<String, dynamic>)
        .cast<String, int>();
  }

  Future<String> getReadme(
      String token, String owner, String name) async {
    final response = await http.get(
      Uri.parse('$_apiBase/repos/$owner/$name/readme'),
      headers: _headers(token),
    );
    if (response.statusCode != 200) return '';
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final encoded = json['content'] as String? ?? '';
    return utf8.decode(base64.decode(encoded.replaceAll('\n', '')));
  }
}
