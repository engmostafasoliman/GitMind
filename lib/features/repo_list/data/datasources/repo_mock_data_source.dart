import '../../domain/entities/repo_summary_entity.dart';
import '../models/repo_model.dart';
import '../models/repo_summary_model.dart';
import 'repo_data_source.dart';

class RepoMockDataSource implements RepoDataSource {
  static const _summaries = {
    '1': RepoSummaryModel(
      whatItDoes: 'A CLI tool that automates database schema migrations across dev, staging, and production using a declarative HCL schema format with versioned migration plans.',
      techStack: ['Go', 'HCL', 'PostgreSQL', 'MySQL', 'SQLite'],
      strengths: ['Zero-downtime migration support', 'Built-in rollback on failure', 'Native GitHub Actions integration'],
      weaknesses: ['Limited NoSQL support', 'HCL learning curve for new users'],
      confidence: ConfidenceLevel.high,
    ),
    '2': RepoSummaryModel(
      whatItDoes: 'An accessible React component library built on Radix primitives with full design token theming, tree-shakeable exports, and auto-generated Storybook docs.',
      techStack: ['TypeScript', 'React', 'Radix UI', 'Storybook', 'CSS Variables'],
      strengths: ['Full WCAG 2.1 AA compliance', 'Zero runtime CSS-in-JS overhead', 'Comprehensive Storybook documentation'],
      weaknesses: ['React-only (no Vue or Svelte support)', 'Bundle grows with full imports'],
      confidence: ConfidenceLevel.high,
    ),
    '3': RepoSummaryModel(
      whatItDoes: 'Cross-platform Flutter app for the Fern productivity suite with offline-first SQLite sync, background task management, and conflict resolution.',
      techStack: ['Dart', 'Flutter', 'SQLite', 'Riverpod', 'Drift'],
      strengths: ['Offline-first with CRDT conflict resolution', 'Battery-efficient background sync', 'Clean architecture with feature modules'],
      weaknesses: ['iOS background fetch restrictions', 'Large initial APK size (~42 MB)'],
      confidence: ConfidenceLevel.medium,
    ),
    '4': RepoSummaryModel(
      whatItDoes: 'An embeddable vector database using HNSW indexing for sub-millisecond semantic search, designed for RAG pipelines and AI-powered search applications.',
      techStack: ['Rust', 'HNSW', 'SIMD', 'gRPC', 'Python bindings'],
      strengths: ['Sub-millisecond query latency at 1M vectors', 'Memory-mapped storage for low RAM usage', 'Python and Node.js FFI bindings included'],
      weaknesses: ['No distributed / cluster mode yet', 'Steep Rust API learning curve'],
      confidence: ConfidenceLevel.high,
    ),
    '6': RepoSummaryModel(
      whatItDoes: 'A drop-in authentication service supporting OAuth 2.0, SAML 2.0, and passkeys with session management, MFA, and SIEM-ready audit logging.',
      techStack: ['Python', 'FastAPI', 'PostgreSQL', 'Redis', 'JWT'],
      strengths: ['Passkey / WebAuthn support out of the box', 'Pluggable identity providers via adapters', 'Structured audit log with SIEM export'],
      weaknesses: ['Requires Redis for session storage', 'Limited multi-tenant isolation controls'],
      confidence: ConfidenceLevel.medium,
    ),
  };

  static const _repos = [
    RepoModel(id: '1', name: 'atlas-cli', owner: 'octolabs', description: 'A fast, batteries-included command-line tool for managing database schema migrations across environments.', language: 'Go', stars: 8423, updatedAgo: '3d ago', license: 'Apache-2.0', lastCommit: 'Jun 16, 2026', summarized: true),
    RepoModel(id: '2', name: 'lumen-ui', owner: 'brightwork', description: 'An accessible, themeable React component library built on headless primitives and design tokens.', language: 'TypeScript', stars: 12950, updatedAgo: '1d ago', license: 'MIT', lastCommit: 'Jun 18, 2026', summarized: true),
    RepoModel(id: '3', name: 'fern-mobile', owner: 'fernhq', description: 'Cross-platform mobile client for the Fern productivity suite, with offline-first sync.', language: 'Dart', stars: 3120, updatedAgo: '5d ago', license: 'GPL-3.0', lastCommit: 'Jun 14, 2026', summarized: true),
    RepoModel(id: '4', name: 'vector-store', owner: 'neuralpath', description: 'A lightweight, embeddable vector database for semantic search and RAG pipelines.', language: 'Rust', stars: 6740, updatedAgo: '2d ago', license: 'MIT', lastCommit: 'Jun 17, 2026', summarized: true),
    RepoModel(id: '5', name: 'quill-notes', owner: 'minimalist', description: 'A keyboard-first markdown note editor with local-first storage and plugin support.', language: 'JavaScript', stars: 1840, updatedAgo: '11d ago', license: 'MIT', lastCommit: 'Jun 08, 2026', summarized: false),
    RepoModel(id: '6', name: 'sentinel-auth', owner: 'octolabs', description: 'Drop-in authentication and session management service with OAuth, SAML, and passkeys.', language: 'Python', stars: 5210, updatedAgo: '6h ago', license: 'Apache-2.0', lastCommit: 'Jun 19, 2026', summarized: true),
  ];

  @override
  Future<List<RepoModel>> getRepos() async {
    await Future.delayed(const Duration(milliseconds: 1100));
    return _repos.map((r) => _withSummary(r)).toList();
  }

  @override
  Future<RepoModel> getRepoById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final repo = _repos.firstWhere((r) => r.id == id);
    return _withSummary(repo);
  }

  @override
  Future<RepoSummaryModel> generateSummary(String repoId) async {
    await Future.delayed(const Duration(milliseconds: 2200));
    return const RepoSummaryModel(
      whatItDoes: 'A keyboard-first markdown editor with a plugin architecture, local-first storage via IndexedDB, and live preview rendering using unified/remark.',
      techStack: ['JavaScript', 'CodeMirror', 'unified', 'remark', 'IndexedDB'],
      strengths: ['Fully offline — no server required', 'Extensible plugin system', 'Fast live preview with incremental parsing'],
      weaknesses: ['No mobile / touch support', 'Plugin API not yet stable across versions'],
      confidence: ConfidenceLevel.medium,
    );
  }

  RepoModel _withSummary(RepoModel r) {
    final summary = _summaries[r.id];
    if (summary == null) return r;
    return RepoModel(
      id: r.id,
      name: r.name,
      owner: r.owner,
      description: r.description,
      language: r.language,
      stars: r.stars,
      updatedAgo: r.updatedAgo,
      license: r.license,
      lastCommit: r.lastCommit,
      summarized: r.summarized,
      summary: summary,
    );
  }
}
