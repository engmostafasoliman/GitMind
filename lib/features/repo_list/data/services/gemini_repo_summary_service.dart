import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/error/app_exception.dart';
import '../models/repo_summary_model.dart';

class GeminiRepoSummaryService {
  final String _apiKey;

  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  const GeminiRepoSummaryService(this._apiKey);

  Future<RepoSummaryModel> summarize({
    required String name,
    required String owner,
    required String description,
    required String language,
    required Map<String, int> languages,
    required int stars,
    required String readme,
    String model = 'gemini-2.0-flash',
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/$model:generateContent'),
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': _apiKey,
      },
      body: jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [{'text': _prompt(name, owner, description, language, languages, stars, readme)}],
          }
        ],
        'generationConfig': {'temperature': 0.2},
      }),
    ).timeout(const Duration(seconds: 45));

    if (response.statusCode == 429) {
      throw const RateLimitException();
    }
    if (response.statusCode != 200) {
      throw ServerException(response.statusCode);
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final text = (json['candidates'] as List<dynamic>)[0]['content']['parts'][0]['text'] as String;

    // Strip markdown code fences if present (```json ... ```)
    final cleaned = text
        .replaceAll(RegExp(r'```json\s*'), '')
        .replaceAll(RegExp(r'```\s*'), '')
        .trim();

    final summaryJson = jsonDecode(cleaned) as Map<String, dynamic>;
    return RepoSummaryModel.fromJson(summaryJson);
  }

  String _prompt(
    String name,
    String owner,
    String description,
    String language,
    Map<String, int> languages,
    int stars,
    String readme,
  ) {
    final langList = languages.keys.take(6).join(', ');

    final readmeSection = readme.isNotEmpty
        ? 'README:\n${readme.substring(0, readme.length.clamp(0, 1500))}'
        : '';

    return '''
Summarize this GitHub repo as JSON only — no markdown, no explanation.

$owner/$name · $language · $stars stars
${description.isNotEmpty ? description : ''}
${langList.isNotEmpty ? 'Languages: $langList' : ''}
$readmeSection

{"whatItDoes":"...","techStack":["..."],"strengths":["..."],"weaknesses":["..."],"confidence":"high|medium|low"}''';
  }
}
