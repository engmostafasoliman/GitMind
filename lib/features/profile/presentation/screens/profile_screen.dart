import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/top_bar.dart';
import '../../../repo_list/domain/entities/repo_entity.dart';
import '../../../repo_list/presentation/widgets/repo_card.dart';
import '../../domain/entities/user_entity.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final ValueChanged<String>? onRepoTap;
  final VoidCallback? onSettings;
  final VoidCallback? onSignOut;

  const ProfileScreen({
    super.key,
    this.onBack,
    this.onRepoTap,
    this.onSettings,
    this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..load(),
      child: _ProfileView(
        onBack: onBack,
        onRepoTap: onRepoTap,
        onSettings: onSettings,
        onSignOut: onSignOut,
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  final VoidCallback? onBack;
  final ValueChanged<String>? onRepoTap;
  final VoidCallback? onSettings;
  final VoidCallback? onSignOut;

  const _ProfileView({this.onBack, this.onRepoTap, this.onSettings, this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDark = themeMode == ThemeMode.dark;
        return Scaffold(
          backgroundColor: AppColors.bg(isDark),
          body: Column(
            children: [
              TopBar(
                onHome: onBack ?? () => Navigator.of(context).pop(),
                onSettings: onSettings,
                onSignOut: onSignOut,
              ),
              Expanded(
                child: BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) => switch (state) {
                    ProfileInitial() || ProfileLoading() => Center(
                        child: CircularProgressIndicator(color: AppColors.accent(isDark)),
                      ),
                    ProfileLoaded(:final user, :final ownedRepos) => _LoadedContent(
                        user: user,
                        ownedRepos: ownedRepos,
                        isDark: isDark,
                        onBack: onBack,
                        onRepoTap: onRepoTap,
                      ),
                    ProfileError(:final message) => _ErrorView(
                        message: message,
                        isDark: isDark,
                        onRetry: () => context.read<ProfileCubit>().load(),
                      ),
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
  final UserEntity user;
  final List<RepoEntity> ownedRepos;
  final bool isDark;
  final VoidCallback? onBack;
  final ValueChanged<String>? onRepoTap;

  const _LoadedContent({
    required this.user,
    required this.ownedRepos,
    required this.isDark,
    this.onBack,
    this.onRepoTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: GestureDetector(
              onTap: onBack ?? () => Navigator.of(context).pop(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back, size: 16, color: AppColors.secondary(isDark)),
                  const SizedBox(width: 6),
                  Text('Back', style: TextStyle(fontSize: 13, color: AppColors.secondary(isDark))),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: _ProfileHeader(user: user, isDark: isDark),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _StatsGrid(user: user, isDark: isDark),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('Repositories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.text(isDark))),
                Text('${ownedRepos.length} shown', style: TextStyle(fontFamily: 'monospace', fontSize: 13, color: AppColors.muted(isDark))),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
          sliver: SliverList.separated(
            itemCount: ownedRepos.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (_, i) => RepoCard(
              repo: ownedRepos[i],
              onTap: () => onRepoTap?.call(ownedRepos[i].id),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserEntity user;
  final bool isDark;
  const _ProfileHeader({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(isDark);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      clipBehavior: Clip.none,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                child: SizedBox(
                  height: 96,
                  width: double.infinity,
                  child: CustomPaint(painter: _BannerPainter(isDark: isDark)),
                ),
              ),
              Positioned(
                bottom: -40,
                left: 24,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2F81F7), Color(0xFF9b6dff)],
                    ),
                    border: Border.all(color: AppColors.surface(isDark), width: 4),
                  ),
                  child: Center(
                    child: Text(
                      user.initials,
                      style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.text(isDark))),
                          const SizedBox(height: 2),
                          Text('@${user.handle}', style: TextStyle(fontFamily: 'monospace', fontSize: 13, color: AppColors.muted(isDark))),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('View on GitHub', style: TextStyle(fontSize: 13, color: accent)),
                        const SizedBox(width: 4),
                        Icon(Icons.open_in_new, size: 14, color: accent),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(user.bio, style: TextStyle(fontSize: 14, color: AppColors.secondary(isDark), height: 1.6)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 20,
                  runSpacing: 8,
                  children: [
                    _MetaItem(icon: Icons.business_rounded, label: user.company, isDark: isDark),
                    _MetaItem(icon: Icons.location_on_outlined, label: user.location, isDark: isDark),
                    _MetaItem(icon: Icons.calendar_today_outlined, label: user.joined, isDark: isDark),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  const _MetaItem({required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.secondary(isDark)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 13, color: AppColors.secondary(isDark))),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final UserEntity user;
  final bool isDark;
  const _StatsGrid({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final stats = [
      (label: 'Repositories', value: _fmt(user.publicRepos), icon: Icons.folder_copy_outlined),
      (label: 'Stars earned', value: _fmt(user.stars), icon: Icons.star_border_rounded),
      (label: 'Followers', value: _fmt(user.followers), icon: Icons.people_outline_rounded),
      (label: 'Following', value: _fmt(user.following), icon: Icons.person_add_alt_rounded),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.2,
      children: stats
          .map((s) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface(isDark),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border(isDark)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(s.icon, size: 14, color: AppColors.muted(isDark)),
                        const SizedBox(width: 6),
                        Text(s.label, style: TextStyle(fontSize: 12, color: AppColors.muted(isDark))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.value,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text(isDark),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}

class _BannerPainter extends CustomPainter {
  final bool isDark;
  const _BannerPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = const LinearGradient(
      colors: [Color(0x1A2F81F7), Color(0x1A9b6dff)],
    ).createShader(rect);
    canvas.drawRect(rect, Paint()..shader = gradient);

    final dotPaint = Paint()..color = isDark ? const Color(0x1F2F81F7) : const Color(0x1A0969DA);
    const spacing = 22.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BannerPainter old) => old.isDark != isDark;
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
            Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.secondary(isDark))),
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
