import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/shimmer_box.dart';

class RepoCardSkeleton extends StatelessWidget {
  const RepoCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          Row(
            children: [
              const ShimmerBox(width: 128, height: 16),
              const Spacer(),
              ShimmerBox(width: 96, height: 22, radius: 100),
            ],
          ),
          const SizedBox(height: 16),
          const ShimmerBox(width: double.infinity, height: 14),
          const SizedBox(height: 8),
          const ShimmerBox(width: double.infinity, height: 14),
          const SizedBox(height: 20),
          Row(
            children: const [
              ShimmerBox(width: 64, height: 12),
              SizedBox(width: 16),
              ShimmerBox(width: 40, height: 12),
              SizedBox(width: 16),
              ShimmerBox(width: 80, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}
