import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/top_bar.dart';
import '../cubit/repo_list_cubit.dart';
import '../cubit/repo_list_state.dart';
import '../widgets/repo_card.dart';
import '../widgets/repo_card_skeleton.dart';

class RepoListScreen extends StatelessWidget {
  final ValueChanged<String>? onRepoTap;
  final VoidCallback? onProfile;
  final VoidCallback? onSettings;

  const RepoListScreen({super.key, this.onRepoTap, this.onProfile, this.onSettings});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RepoListCubit>()..load(),
      child: _RepoListView(onRepoTap: onRepoTap, onProfile: onProfile, onSettings: onSettings),
    );
  }
}

class _RepoListView extends StatelessWidget {
  final ValueChanged<String>? onRepoTap;
  final VoidCallback? onProfile;
  final VoidCallback? onSettings;
  const _RepoListView({this.onRepoTap, this.onProfile, this.onSettings});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDark = themeMode == ThemeMode.dark;
        return Scaffold(
          backgroundColor: AppColors.bg(isDark),
          body: Column(
            children: [
              BlocBuilder<RepoListCubit, RepoListState>(
                buildWhen: (_, s) => s is RepoListLoaded,
                builder: (context, state) {
                  final query = state is RepoListLoaded ? state.searchQuery : '';
                  return TopBar(
                    searchQuery: query,
                    onSearch: (q) => context.read<RepoListCubit>().search(q),
                    onProfile: onProfile,
                    onSettings: onSettings,
                  );
                },
              ),
              Expanded(
                child: BlocBuilder<RepoListCubit, RepoListState>(
                  builder: (context, state) {
                    return switch (state) {
                      RepoListInitial() => const SizedBox.shrink(),
                      RepoListLoading() => _SkeletonList(isDark: isDark),
                      RepoListLoaded() => _LoadedContent(
                          state: state,
                          isDark: isDark,
                          onRepoTap: onRepoTap,
                        ),
                      RepoListError(:final message) => _ErrorView(
                          message: message,
                          isDark: isDark,
                          onRetry: () => context.read<RepoListCubit>().load(),
                        ),
                    };
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LoadedContent extends StatelessWidget {
  final RepoListLoaded state;
  final bool isDark;
  final ValueChanged<String>? onRepoTap;

  const _LoadedContent({
    required this.state,
    required this.isDark,
    this.onRepoTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: _Header(isDark: isDark),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: _FilterBar(state: state, isDark: isDark),
          ),
        ),
        if (state.filteredRepos.isEmpty)
          SliverFillRemaining(child: _EmptyView(isDark: isDark))
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList.separated(
              itemCount: state.filteredRepos.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final repo = state.filteredRepos[i];
                return RepoCard(
                  key: ValueKey(repo.id),
                  repo: repo,
                  onTap: () => onRepoTap?.call(repo.id),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final bool isDark;
  const _Header({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your repositories',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.text(isDark),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'AI-generated summaries for every repo',
          style: TextStyle(fontSize: 14, color: AppColors.muted(isDark)),
        ),
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  final RepoListLoaded state;
  final bool isDark;
  const _FilterBar({required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RepoListCubit>();
    return Row(
      children: [
        Expanded(
          child: _Dropdown<String>(
            value: state.selectedLanguage,
            label: 'Language',
            items: state.languages,
            itemLabel: (l) => l,
            onChanged: (l) => cubit.filterByLanguage(l),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Dropdown<RepoSort>(
            value: state.sort,
            label: 'Sort by',
            items: RepoSort.values,
            itemLabel: (s) => switch (s) {
              RepoSort.updated => 'Recently updated',
              RepoSort.stars => 'Most stars',
              RepoSort.name => 'Name (A–Z)',
            },
            onChanged: (s) => cubit.sortBy(s),
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final T value;
  final String label;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T> onChanged;
  final bool isDark;

  const _Dropdown({
    required this.value,
    required this.label,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.muted(isDark)),
          dropdownColor: AppColors.elevated(isDark),
          style: TextStyle(fontSize: 13, color: AppColors.text(isDark)),
          items: items
              .map((e) => DropdownMenuItem<T>(
                    value: e,
                    child: Text(itemLabel(e), overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }
}

class _SkeletonList extends StatelessWidget {
  final bool isDark;
  const _SkeletonList({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      itemCount: 6,
      separatorBuilder: (_, index) => const SizedBox(height: 12),
      itemBuilder: (_, index) => const RepoCardSkeleton(),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final bool isDark;
  const _EmptyView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: AppColors.muted(isDark)),
            const SizedBox(height: 16),
            Text(
              'No repositories found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.text(isDark)),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters.',
              style: TextStyle(fontSize: 14, color: AppColors.muted(isDark)),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => context.read<RepoListCubit>().clearFilters(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface(isDark),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border(isDark)),
                ),
                child: Text('Clear filters', style: TextStyle(fontSize: 13, color: AppColors.text(isDark))),
              ),
            ),
          ],
        ),
      ),
    );
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
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: AppColors.danger(isDark)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.secondary(isDark)),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.accent(isDark),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Retry', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
