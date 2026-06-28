import 'package:flutter/material.dart';
import '../../../../core/constants/language_colors.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/entities/repo_entity.dart';

class RepoCard extends StatefulWidget {
  final RepoEntity repo;
  final VoidCallback onTap;

  const RepoCard({super.key, required this.repo, required this.onTap});

  @override
  State<RepoCard> createState() => _RepoCardState();
}

class _RepoCardState extends State<RepoCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppColors.accent(isDark);

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface(isDark),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovered
                  ? accent.withValues(alpha: 0.40)
                  : AppColors.border(isDark),
            ),
            boxShadow: _hovered
                ? [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08), blurRadius: 24, offset: const Offset(0, 8))]
                : [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.0 : 0.04), blurRadius: 1, offset: const Offset(0, 1))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 160),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _hovered ? accent : AppColors.text(isDark),
                      ),
                      child: Text(widget.repo.name, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusPill(summarized: widget.repo.summarized),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.repo.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: AppColors.secondary(isDark), height: 1.5),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _LanguageDot(language: widget.repo.language, isDark: isDark),
                  const SizedBox(width: 16),
                  Icon(Icons.star_border_rounded, size: 14, color: AppColors.secondary(isDark)),
                  const SizedBox(width: 4),
                  Text(_formatStars(widget.repo.stars), style: TextStyle(fontSize: 13, color: AppColors.secondary(isDark))),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'updated ${widget.repo.updatedAgo}',
                      style: TextStyle(fontSize: 13, color: AppColors.muted(isDark)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatStars(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}

class _LanguageDot extends StatelessWidget {
  final String language;
  final bool isDark;
  const _LanguageDot({required this.language, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: languageColor(language),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(language, style: TextStyle(fontSize: 13, color: AppColors.secondary(isDark))),
      ],
    );
  }
}
