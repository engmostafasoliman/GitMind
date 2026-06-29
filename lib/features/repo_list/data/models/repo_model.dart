import '../../domain/entities/repo_entity.dart';
import 'repo_summary_model.dart';

class RepoModel extends RepoEntity {
  const RepoModel({
    required super.id,
    required super.name,
    required super.owner,
    required super.description,
    required super.language,
    required super.stars,
    required super.updatedAgo,
    required super.license,
    required super.lastCommit,
    required super.summarized,
    super.summary,
  });

  factory RepoModel.fromJson(Map<String, dynamic> json) => RepoModel(
        id: json['id'] as String,
        name: json['name'] as String,
        owner: json['owner'] as String,
        description: json['description'] as String,
        language: json['language'] as String,
        stars: json['stars'] as int,
        updatedAgo: json['updatedAgo'] as String,
        license: json['license'] as String,
        lastCommit: json['lastCommit'] as String,
        summarized: json['summarized'] as bool,
        summary: json['summary'] != null
            ? RepoSummaryModel.fromJson(
                json['summary'] as Map<String, dynamic>)
            : null,
      );

  factory RepoModel.fromGitHub(Map<String, dynamic> json) {
    final updatedAt = json['updated_at'] as String? ?? '';
    final pushedAt = json['pushed_at'] as String? ?? updatedAt;
    return RepoModel(
      id: (json['id'] as int).toString(),
      name: json['name'] as String? ?? '',
      owner: (json['owner'] as Map<String, dynamic>?)?['login'] as String? ?? '',
      description: json['description'] as String? ?? '',
      language: json['language'] as String? ?? 'Unknown',
      stars: json['stargazers_count'] as int? ?? 0,
      updatedAgo: _timeAgo(updatedAt),
      license: (json['license'] as Map<String, dynamic>?)?['spdx_id'] as String? ?? 'No license',
      lastCommit: _formatDate(pushedAt),
      summarized: false,
    );
  }

  static String _timeAgo(String iso) {
    if (iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  static String _formatDate(String iso) {
    if (iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'owner': owner,
        'description': description,
        'language': language,
        'stars': stars,
        'updatedAgo': updatedAgo,
        'license': license,
        'lastCommit': lastCommit,
        'summarized': summarized,
      };
}

