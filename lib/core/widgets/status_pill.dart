import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatusPill extends StatelessWidget {
  final bool summarized;
  const StatusPill({super.key, required this.summarized});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (summarized) {
      final color = AppColors.success(isDark);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: color.withValues(alpha: 0.30)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              'Summarized',
              style: TextStyle(fontSize: 12, color: color),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.elevated(isDark),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle_outlined, size: 12, color: AppColors.muted(isDark)),
          const SizedBox(width: 4),
          Text(
            'Not summarized',
            style: TextStyle(fontSize: 12, color: AppColors.muted(isDark)),
          ),
        ],
      ),
    );
  }
}
