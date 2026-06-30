import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/repo_summary_model.dart';

class GeminiRepoSummaryService {
  final String _apiKey;

  static const _model = 'gemini-flash-latest';
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
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/$_model:generateContent'),
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

    if (response.statusCode != 200) {
      throw Exception('Gemini API error ${response.statusCode}: ${response.body}');
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
    final langList = languages.entries
        .map((e) => '${e.key}: ${e.value} bytes')
        .join(', ');

    final readmeSection = readme.isNotEmpty
        ? 'README (truncated to 3000 chars):\n${readme.substring(0, readme.length.clamp(0, 3000))}'
        : 'No README available.';

    return '''
Analyze this GitHub repository and return a JSON summary.

Repository: $owner/$name
Description: ${description.isNotEmpty ? description : 'No description'}
Primary language: $language
Languages: $langList
Stars: $stars

$readmeSection

Return ONLY valid JSON with this exact structure (no markdown, no explanation):
{
  "whatItDoes": "One clear sentence describing what this project does and who it is for.",
  "techStack": ["Tech1", "Tech2", "Tech3"],
  "strengths": ["Strength 1", "Strength 2", "Strength 3"],
  "weaknesses": ["Weakness 1", "Weakness 2"],
  "confidence": "high"
}

Rules:
- confidence must be "high", "medium", or "low" based on how much info is available
- techStack: list the main technologies, frameworks, and tools (3-6 items)
- strengths: specific, concrete strengths observed from the code/README (2-4 items)
- weaknesses: honest limitations or gaps (1-3 items)
- Return ONLY the JSON object, nothing else
''';
  }
}
