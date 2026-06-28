import '../models/repo_model.dart';

class RepoMockDataSource {
  Future<List<RepoModel>> getRepos() async {
    await Future.delayed(const Duration(milliseconds: 1100));
    return const [
      RepoModel(id: '1', name: 'atlas-cli', owner: 'octolabs', description: 'A fast, batteries-included command-line tool for managing database schema migrations across environments.', language: 'Go', stars: 8423, updatedAgo: '3d ago', license: 'Apache-2.0', lastCommit: 'Jun 16, 2026', summarized: true),
      RepoModel(id: '2', name: 'lumen-ui', owner: 'brightwork', description: 'An accessible, themeable React component library built on headless primitives and design tokens.', language: 'TypeScript', stars: 12950, updatedAgo: '1d ago', license: 'MIT', lastCommit: 'Jun 18, 2026', summarized: true),
      RepoModel(id: '3', name: 'fern-mobile', owner: 'fernhq', description: 'Cross-platform mobile client for the Fern productivity suite, with offline-first sync.', language: 'Dart', stars: 3120, updatedAgo: '5d ago', license: 'GPL-3.0', lastCommit: 'Jun 14, 2026', summarized: true),
      RepoModel(id: '4', name: 'vector-store', owner: 'neuralpath', description: 'A lightweight, embeddable vector database for semantic search and RAG pipelines.', language: 'Rust', stars: 6740, updatedAgo: '2d ago', license: 'MIT', lastCommit: 'Jun 17, 2026', summarized: true),
      RepoModel(id: '5', name: 'quill-notes', owner: 'minimalist', description: 'A keyboard-first markdown note editor with local-first storage and plugin support.', language: 'JavaScript', stars: 1840, updatedAgo: '11d ago', license: 'MIT', lastCommit: 'Jun 08, 2026', summarized: false),
      RepoModel(id: '6', name: 'sentinel-auth', owner: 'octolabs', description: 'Drop-in authentication and session management service with OAuth, SAML, and passkeys.', language: 'Python', stars: 5210, updatedAgo: '6h ago', license: 'Apache-2.0', lastCommit: 'Jun 19, 2026', summarized: true),
    ];
  }
}
