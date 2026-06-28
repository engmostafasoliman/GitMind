import '../../domain/entities/repo_entity.dart';

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
      );

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
