import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/top_bar.dart';
import '../../../profile/domain/entities/user_entity.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSignOut;
  final VoidCallback? onProfile;

  const SettingsScreen({super.key, this.onBack, this.onSignOut, this.onProfile});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoSummarize = true;
  bool _cacheResults = true;
  String _model = 'gemini-2.5-pro';
  String _confidence = 'medium';
  bool _emailDigest = false;
  bool _pushDone = true;
  String _density = 'comfortable';
  String _accent = 'indigo';

  static const _accentSwatches = [
    (id: 'indigo', color: Color(0xFF6D8BFF)),
    (id: 'violet', color: Color(0xFF9b6dff)),
    (id: 'teal', color: Color(0xFF00B4AB)),
    (id: 'green', color: Color(0xFF3FB950)),
  ];

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings saved'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Summary cache cleared'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

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
                onHome: widget.onBack ?? () => Navigator.of(context).pop(),
                onProfile: widget.onProfile,
                onSignOut: widget.onSignOut,
                onSettings: () {},
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: GestureDetector(
                          onTap: widget.onBack ?? () => Navigator.of(context).pop(),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.text(isDark))),
                            const SizedBox(height: 4),
                            Text('Manage your account, summaries, and preferences.', style: TextStyle(fontSize: 14, color: AppColors.secondary(isDark))),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                      sliver: SliverList.separated(
                        itemCount: 5,
                        separatorBuilder: (_, index) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => [
                          _accountCard(isDark),
                          _aiCard(isDark),
                          _appearanceCard(isDark),
                          _notificationsCard(isDark),
                          _dangerCard(isDark),
                        ][i],
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _GhostButton(
                              label: 'Cancel',
                              isDark: isDark,
                              onTap: widget.onBack ?? () => Navigator.of(context).pop(),
                            ),
                            const SizedBox(width: 12),
                            _PrimaryButton(label: 'Save changes', isDark: isDark, onTap: _save),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _accountCard(bool isDark) => _SettingsCard(
        title: 'Account',
        icon: Icons.person_outline_rounded,
        isDark: isDark,
        rows: [
          _SettingsRow(
            label: 'Display name',
            description: kMockUser.name,
            isDark: isDark,
            control: Text('@${kMockUser.handle}', style: TextStyle(fontFamily: 'monospace', fontSize: 13, color: AppColors.muted(isDark))),
            isLast: false,
          ),
          _SettingsRow(
            label: 'Connected via GitHub',
            description: 'Read-only access to public metadata',
            isDark: isDark,
            control: _ConnectedBadge(isDark: isDark),
            isLast: true,
          ),
        ],
      );

  Widget _aiCard(bool isDark) => _SettingsCard(
        title: 'AI summaries',
        icon: Icons.auto_awesome_rounded,
        isDark: isDark,
        rows: [
          _SettingsRow(
            label: 'Model',
            description: 'Engine used to generate repository summaries',
            isDark: isDark,
            control: _SettingsDropdown(
              value: _model,
              width: 180,
              items: const {'gemini-2.5-pro': 'Gemini 2.5 Pro', 'gemini-2.5-flash': 'Gemini 2.5 Flash'},
              isDark: isDark,
              onChanged: (v) => setState(() => _model = v),
            ),
            isLast: false,
          ),
          _SettingsRow(
            label: 'Auto-summarize new repos',
            description: 'Generate a summary the first time you open a repo',
            isDark: isDark,
            control: _SettingsSwitch(value: _autoSummarize, isDark: isDark, onChanged: (v) => setState(() => _autoSummarize = v)),
            isLast: false,
          ),
          _SettingsRow(
            label: 'Cache results',
            description: 'Reuse cached summaries until you regenerate',
            isDark: isDark,
            control: _SettingsSwitch(value: _cacheResults, isDark: isDark, onChanged: (v) => setState(() => _cacheResults = v)),
            isLast: false,
          ),
          _SettingsRow(
            label: 'Minimum confidence to show',
            description: 'Hide summaries below this confidence level',
            isDark: isDark,
            control: _SettingsDropdown(
              value: _confidence,
              width: 130,
              items: const {'low': 'Low', 'medium': 'Medium', 'high': 'High'},
              isDark: isDark,
              onChanged: (v) => setState(() => _confidence = v),
            ),
            isLast: true,
          ),
        ],
      );

  Widget _appearanceCard(bool isDark) => _SettingsCard(
        title: 'Appearance',
        icon: Icons.palette_outlined,
        isDark: isDark,
        rows: [
          _SettingsRow(
            label: 'Accent color',
            isDark: isDark,
            control: Row(
              mainAxisSize: MainAxisSize.min,
              children: _accentSwatches.map((s) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _accent = s.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: s.color,
                      shape: BoxShape.circle,
                      border: _accent == s.id
                          ? Border.all(color: AppColors.bg(isDark), width: 2)
                          : null,
                      boxShadow: _accent == s.id
                          ? [BoxShadow(color: s.color.withValues(alpha: 0.6), blurRadius: 0, spreadRadius: 2)]
                          : null,
                    ),
                  ),
                ),
              )).toList(),
            ),
            isLast: false,
          ),
          _SettingsRow(
            label: 'Density',
            description: 'Spacing of cards and lists',
            isDark: isDark,
            control: _SettingsDropdown(
              value: _density,
              width: 150,
              items: const {'comfortable': 'Comfortable', 'compact': 'Compact'},
              isDark: isDark,
              onChanged: (v) => setState(() => _density = v),
            ),
            isLast: true,
          ),
        ],
      );

  Widget _notificationsCard(bool isDark) => _SettingsCard(
        title: 'Notifications',
        icon: Icons.notifications_none_rounded,
        isDark: isDark,
        rows: [
          _SettingsRow(
            label: 'Weekly email digest',
            description: 'A summary of repos that changed this week',
            isDark: isDark,
            control: _SettingsSwitch(value: _emailDigest, isDark: isDark, onChanged: (v) => setState(() => _emailDigest = v)),
            isLast: false,
          ),
          _SettingsRow(
            label: 'Notify when a summary is ready',
            description: 'Get notified after a generation completes',
            isDark: isDark,
            control: _SettingsSwitch(value: _pushDone, isDark: isDark, onChanged: (v) => setState(() => _pushDone = v)),
            isLast: true,
          ),
        ],
      );

  Widget _dangerCard(bool isDark) => _SettingsCard(
        title: 'Danger zone',
        icon: Icons.warning_amber_rounded,
        isDark: isDark,
        rows: [
          _SettingsRow(
            label: 'Clear summary cache',
            description: 'Force every repo to regenerate on next open',
            isDark: isDark,
            control: _OutlineButton(label: 'Clear cache', isDark: isDark, onTap: _clearCache),
            isLast: false,
          ),
          _SettingsRow(
            label: 'Disconnect GitHub',
            description: 'Revoke access and sign out of Repo Insights',
            isDark: isDark,
            control: _DangerButton(label: 'Disconnect', isDark: isDark, onTap: widget.onSignOut ?? () {}),
            isLast: true,
          ),
        ],
      );
}

// ── Reusable sub-widgets ──────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;
  final List<Widget> rows;
  const _SettingsCard({required this.title, required this.icon, required this.isDark, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border(isDark))),
            ),
            child: Row(
              children: [
                Icon(icon, size: 15, color: AppColors.secondary(isDark)),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(fontSize: 12, letterSpacing: 0.8, color: AppColors.secondary(isDark), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          ...rows,
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final String? description;
  final bool isDark;
  final Widget control;
  final bool isLast;
  const _SettingsRow({required this.label, this.description, required this.isDark, required this.control, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: isLast
          ? null
          : BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border(isDark)))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 15, color: AppColors.text(isDark))),
                if (description != null) ...[
                  const SizedBox(height: 2),
                  Text(description!, style: TextStyle(fontSize: 13, color: AppColors.secondary(isDark))),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          control,
        ],
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final bool value;
  final bool isDark;
  final ValueChanged<bool> onChanged;
  const _SettingsSwitch({required this.value, required this.isDark, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.accent(isDark),
      activeTrackColor: AppColors.accent(isDark).withValues(alpha: 0.5),
    );
  }
}

class _SettingsDropdown extends StatelessWidget {
  final String value;
  final double width;
  final Map<String, String> items;
  final bool isDark;
  final ValueChanged<String> onChanged;
  const _SettingsDropdown({required this.value, required this.width, required this.items, required this.isDark, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.elevated(isDark),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.muted(isDark)),
          dropdownColor: AppColors.elevated(isDark),
          style: TextStyle(fontSize: 13, color: AppColors.text(isDark)),
          items: items.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }
}

class _ConnectedBadge extends StatelessWidget {
  final bool isDark;
  const _ConnectedBadge({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.success(isDark);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Text('Connected', style: TextStyle(fontSize: 13, color: color)),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final bool isDark;
  final VoidCallback onTap;
  const _OutlineButton({required this.label, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface(isDark),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border(isDark)),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, color: AppColors.text(isDark))),
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  final String label;
  final bool isDark;
  final VoidCallback onTap;
  const _DangerButton({required this.label, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final danger = AppColors.danger(isDark);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: danger.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: danger.withValues(alpha: 0.40)),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, color: danger)),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  final String label;
  final bool isDark;
  final VoidCallback onTap;
  const _GhostButton({required this.label, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border(isDark)),
        ),
        child: Text(label, style: TextStyle(fontSize: 14, color: AppColors.secondary(isDark))),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isDark;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.accent(isDark),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
