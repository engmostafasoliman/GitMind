import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/language_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../../core/widgets/top_bar.dart';
import '../../../repo_list/domain/entities/repo_entity.dart';
import '../../../repo_list/domain/entities/repo_summary_entity.dart';
import '../../../repo_list/presentation/cubit/repo_list_cubit.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../../settings/presentation/cubit/settings_state.dart';
import '../cubit/repo_detail_cubit.dart';
import '../widgets/repo_detail_skeleton.dart';
import '../cubit/repo_detail_state.dart';
import '../widgets/confidence_badge.dart';
import '../widgets/tech_chip.dart';

class RepoDetailScreen extends StatelessWidget {
  final String repoId;
  final VoidCallback? onBack;
  final VoidCallback? onProfile;
  final VoidCallback? onSettings;
  final VoidCallback? onSignOut;
  final ValueChanged<RepoEntity>? onChat;

  const RepoDetailScreen({
    super.key,
    required this.repoId,
    this.onBack,
    this.onProfile,
    this.onSettings,
    this.onSignOut,
    this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RepoDetailCubit>()..load(repoId),
      child: _RepoDetailView(
        repoId: repoId,
        onBack: onBack,
        onProfile: onProfile,
        onSettings: onSettings,
        onSignOut: onSignOut,
        onChat: onChat,
      ),
    );
  }
}

class _RepoDetailView extends StatelessWidget {
  final String repoId;
  final VoidCallback? onBack;
  final VoidCallback? onProfile;
  final VoidCallback? onSettings;
  final VoidCallback? onSignOut;
  final ValueChanged<RepoEntity>? onChat;
  const _RepoDetailView({
    required this.repoId,
    this.onBack,
    this.onProfile,
    this.onSettings,
    this.onSignOut,
    this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<RepoDetailCubit, RepoDetailState>(
      listenWhen: (previous, current) =>
          previous is RepoDetailGenerating && current is RepoDetailLoaded,
      listener: (context, state) {
        if (state is RepoDetailLoaded && state.repo.summary != null) {
          context.read<RepoListCubit>().markSummarized(repoId, state.repo.summary!);
          final settingsState = context.read<SettingsCubit>().state;
          if (settingsState is SettingsLoaded && settingsState.settings.notifyOnDone) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Summary ready for ${state.repo.name}'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      },
      child: BlocBuilder<ThemeCubit, AppThemeData>(
        builder: (context, theme) {
          final isDark = theme.isDark;
          return Scaffold(
            backgroundColor: AppColors.bg(isDark),
            floatingActionButton: onChat == null
                ? null
                : BlocBuilder<RepoDetailCubit, RepoDetailState>(
                    builder: (context, state) {
                      if (state is! RepoDetailLoaded || !state.repo.summarized) {
                        return const SizedBox.shrink();
                      }
                      final repo = state.repo;
                      return FloatingActionButton.extended(
                        onPressed: () => onChat!(repo),
                        backgroundColor: AppColors.accent(isDark),
                        foregroundColor: Colors.white,
                        icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                        label: const Text(
                          'Ask AI',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      );
                    },
                  ),
            body: Column(
              children: [
                TopBar(
                  onHome: onBack ?? () => Navigator.of(context).pop(),
                  onProfile: onProfile,
                  onSettings: onSettings,
                  onSignOut: onSignOut,
                ),
                Expanded(
                  child: BlocBuilder<RepoDetailCubit, RepoDetailState>(
                    builder: (context, state) => switch (state) {
                      RepoDetailInitial() || RepoDetailLoading() =>
                        _LoadingView(isDark: isDark),
                      RepoDetailLoaded(:final repo) => _DetailContent(
                          repo: repo,
                          isDark: isDark,
                          generating: false,
                        ),
                      RepoDetailGenerating(:final repo) => _DetailContent(
                          repo: repo,
                          isDark: isDark,
                          generating: true,
                        ),
                      RepoDetailRateLimit(:final repo, :final secondsRemaining) =>
                        _RateLimitView(
                          repo: repo,
                          secondsRemaining: secondsRemaining,
                          isDark: isDark,
                        ),
                      RepoDetailError(:final message) => _ErrorView(
                          message: message,
                          isDark: isDark,
                          onRetry: () =>
                              context.read<RepoDetailCubit>().load(repoId),
                        ),
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final RepoEntity repo;
  final bool isDark;
  final bool generating;
  final Widget? rateLimitBanner;

  const _DetailContent({
    required this.repo,
    required this.isDark,
    required this.generating,
    this.rateLimitBanner,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        if (rateLimitBanner != null)
          SliverToBoxAdapter(child: rateLimitBanner!),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _BackRow(isDark: isDark),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: _RepoHeader(repo: repo, isDark: isDark),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            child: repo.summarized && repo.summary != null
                ? _SummaryContent(
                    summary: repo.summary!,
                    isDark: isDark,
                    generating: generating,
                    onRegenerate: () =>
                        context.read<RepoDetailCubit>().regenerateSummary(),
                  )
                : _NotSummarizedCard(
                    isDark: isDark,
                    generating: generating,
                    onGenerate: () =>
                        context.read<RepoDetailCubit>().generateSummary(),
                  ),
          ),
        ),
      ],
    );
  }
}

class _BackRow extends StatelessWidget {
  final bool isDark;
  const _BackRow({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chevron_left, size: 18, color: AppColors.accent(isDark)),
          const SizedBox(width: 4),
          Text(
            'Repositories',
            style: TextStyle(fontSize: 14, color: AppColors.accent(isDark)),
          ),
        ],
      ),
    );
  }
}

class _RepoHeader extends StatelessWidget {
  final RepoEntity repo;
  final bool isDark;
  const _RepoHeader({required this.repo, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final langColor = languageColor(repo.language);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${repo.owner} / ${repo.name}',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: AppColors.muted(isDark),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  repo.name,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text(isDark),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              StatusPill(summarized: repo.summarized),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            repo.description,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.secondary(isDark),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: langColor, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(repo.language, style: TextStyle(fontSize: 13, color: AppColors.secondary(isDark))),
              ]),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.star_border_rounded, size: 14, color: AppColors.secondary(isDark)),
                const SizedBox(width: 4),
                Text(_fmtStars(repo.stars), style: TextStyle(fontSize: 13, color: AppColors.secondary(isDark))),
              ]),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.balance_rounded, size: 13, color: AppColors.muted(isDark)),
                const SizedBox(width: 4),
                Text(repo.license, style: TextStyle(fontSize: 13, color: AppColors.secondary(isDark))),
              ]),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.commit_rounded, size: 13, color: AppColors.muted(isDark)),
                const SizedBox(width: 4),
                Text(repo.lastCommit, style: TextStyle(fontSize: 13, color: AppColors.secondary(isDark))),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtStars(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}

class _SummaryContent extends StatelessWidget {
  final RepoSummaryEntity summary;
  final bool isDark;
  final bool generating;
  final VoidCallback onRegenerate;

  const _SummaryContent({
    required this.summary,
    required this.isDark,
    required this.generating,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(isDark);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ConfidenceBadge(confidence: summary.confidence),
            const Spacer(),
            GestureDetector(
              onTap: generating ? null : onRegenerate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface(isDark),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border(isDark)),
                ),
                child: generating
                    ? SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 1.5, color: accent),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh_rounded, size: 14, color: accent),
                          const SizedBox(width: 6),
                          Text(
                            'Re-summarize',
                            style: TextStyle(fontSize: 13, color: accent),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _Section(
          title: 'What it does',
          isDark: isDark,
          child: Text(
            summary.whatItDoes,
            style: TextStyle(fontSize: 14, color: AppColors.secondary(isDark), height: 1.7),
          ),
        ),
        const SizedBox(height: 20),
        _Section(
          title: 'Tech Stack',
          isDark: isDark,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: summary.techStack.map((t) => TechChip(label: t)).toList(),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Section(
                title: 'Strengths',
                isDark: isDark,
                child: _BulletList(
                  items: summary.strengths,
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.success(isDark),
                  isDark: isDark,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Section(
                title: 'Weaknesses',
                isDark: isDark,
                child: _BulletList(
                  items: summary.weaknesses,
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.warning(isDark),
                  isDark: isDark,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final bool isDark;
  final Widget child;
  const _Section({required this.title, required this.isDark, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.text(isDark),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;
  final IconData icon;
  final Color color;
  final bool isDark;
  const _BulletList({required this.items, required this.icon, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 14, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(fontSize: 13, color: AppColors.secondary(isDark), height: 1.5),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _NotSummarizedCard extends StatelessWidget {
  final bool isDark;
  final bool generating;
  final VoidCallback onGenerate;
  const _NotSummarizedCard({required this.isDark, required this.generating, required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(isDark);
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: generating ? accent.withValues(alpha: 0.40) : AppColors.border(isDark),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(color: accent.withValues(alpha: 0.25)),
            ),
            child: generating
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: CircularProgressIndicator(strokeWidth: 2, color: accent),
                  )
                : Icon(Icons.auto_awesome_rounded, size: 24, color: accent),
          ),
          const SizedBox(height: 16),
          Text(
            generating ? 'Generating AI summary…' : 'No AI summary yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.text(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            generating
                ? 'Analysing the repository structure, code patterns, and commit history.'
                : 'Let AI analyse this repository and generate an instant summary.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.muted(isDark), height: 1.6),
          ),
          if (!generating) ...[
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onGenerate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text('Generate Summary', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RateLimitView extends StatelessWidget {
  final RepoEntity repo;
  final int secondsRemaining;
  final bool isDark;
  const _RateLimitView({required this.repo, required this.secondsRemaining, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(isDark);
    return _DetailContent(
      repo: repo,
      isDark: isDark,
      generating: false,
      rateLimitBanner: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.warning(isDark).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.warning(isDark).withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.hourglass_top_rounded, size: 16, color: AppColors.warning(isDark)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'API quota reached — retrying in ${secondsRemaining}s',
                style: TextStyle(fontSize: 13, color: AppColors.warning(isDark)),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.read<RepoDetailCubit>().generateSummary(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(6)),
                child: const Text('Now', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  final bool isDark;
  const _LoadingView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return RepoDetailSkeleton(isDark: isDark);
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final bool isDark;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.isDark, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: AppColors.danger(isDark)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: AppColors.secondary(isDark)),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(color: AppColors.accent(isDark), borderRadius: BorderRadius.circular(8)),
                child: const Text('Retry', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
