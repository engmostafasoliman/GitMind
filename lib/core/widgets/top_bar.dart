import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../di/injection.dart';
import '../theme/app_colors.dart';
import '../theme/theme_cubit.dart';
import '../../features/profile/domain/entities/user_entity.dart';

class TopBar extends StatelessWidget {
  final String? searchQuery;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onHome;
  final VoidCallback? onProfile;
  final VoidCallback? onSettings;
  final VoidCallback? onSignOut;

  const TopBar({
    super.key,
    this.searchQuery,
    this.onSearch,
    this.onHome,
    this.onProfile,
    this.onSettings,
    this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, AppThemeData>(
      builder: (context, theme) {
        final isDark = theme.isDark;
        return Container(
          height: 64 + MediaQuery.of(context).padding.top,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(
            color: AppColors.bg(isDark).withValues(alpha: 0.92),
            border: Border(
              bottom: BorderSide(color: AppColors.border(isDark)),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onHome,
                  child: _Logo(isDark: isDark),
                ),
                if (onSearch != null) ...[
                  const SizedBox(width: 12),
                  Expanded(child: _SearchField(isDark: isDark, query: searchQuery ?? '', onChanged: onSearch!)),
                ] else
                  const Spacer(),
                const SizedBox(width: 12),
                _ThemeToggle(isDark: isDark),
                const SizedBox(width: 8),
                _ProfileButton(
                  isDark: isDark,
                  onProfile: onProfile,
                  onSettings: onSettings,
                  onSignOut: onSignOut,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Logo extends StatelessWidget {
  final bool isDark;
  const _Logo({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Image.asset('assets/appicon.png', width: 28, height: 28, fit: BoxFit.cover),
        ),
        const SizedBox(width: 8),
        Text(
          'GitMind',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.text(isDark),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  final bool isDark;
  final String query;
  final ValueChanged<String> onChanged;
  const _SearchField({required this.isDark, required this.query, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.elevated(isDark),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(fontSize: 14, color: AppColors.text(isDark)),
        decoration: InputDecoration(
          hintText: 'Search repositories…',
          hintStyle: TextStyle(fontSize: 14, color: AppColors.muted(isDark)),
          prefixIcon: Icon(Icons.search, size: 16, color: AppColors.muted(isDark)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          isDense: true,
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  final bool isDark;
  const _ThemeToggle({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<ThemeCubit>().toggle(),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surface(isDark),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border(isDark)),
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          size: 15,
          color: AppColors.muted(isDark),
        ),
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback? onProfile;
  final VoidCallback? onSettings;
  final VoidCallback? onSignOut;
  const _ProfileButton({required this.isDark, this.onProfile, this.onSettings, this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 44),
      color: AppColors.elevated(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border(isDark)),
      ),
      onSelected: (val) {
        if (val == 'profile') onProfile?.call();
        if (val == 'settings') onSettings?.call();
        if (val == 'signout') onSignOut?.call();
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mostafa Soliman', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.text(isDark))),
              Text('@engmostafasoliman', style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: AppColors.muted(isDark))),
            ],
          ),
        ),
        PopupMenuDivider(color: AppColors.border(isDark), height: 1),
        PopupMenuItem(value: 'profile', child: Row(children: [Icon(Icons.person_outline, size: 16, color: AppColors.secondary(isDark)), const SizedBox(width: 8), Text('Profile', style: TextStyle(color: AppColors.text(isDark)))])),
        PopupMenuItem(value: 'settings', child: Row(children: [Icon(Icons.settings_outlined, size: 16, color: AppColors.secondary(isDark)), const SizedBox(width: 8), Text('Settings', style: TextStyle(color: AppColors.text(isDark)))])),
        PopupMenuDivider(color: AppColors.border(isDark), height: 1),
        PopupMenuItem(value: 'signout', child: Row(children: [Icon(Icons.logout, size: 16, color: AppColors.danger(isDark)), const SizedBox(width: 8), Text('Sign out', style: TextStyle(color: AppColors.danger(isDark)))])),
      ],
      child: _AvatarButton(),
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton();

  @override
  Widget build(BuildContext context) {
    final user = getIt.isRegistered<UserEntity>() ? getIt<UserEntity>() : null;
    final avatarUrl = user?.avatarUrl;
    final initials = user?.initials ?? '';

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: avatarUrl == null
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2F81F7), Color(0xFF9b6dff)],
              )
            : null,
      ),
      child: ClipOval(
        child: avatarUrl != null
            ? Image.network(
                avatarUrl,
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _InitialsFallback(initials: initials),
              )
            : _InitialsFallback(initials: initials),
      ),
    );
  }
}

class _InitialsFallback extends StatelessWidget {
  final String initials;
  const _InitialsFallback({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2F81F7), Color(0xFF9b6dff)],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
