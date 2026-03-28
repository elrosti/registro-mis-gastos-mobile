import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class LoadingShimmer extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const LoadingShimmer({
    super.key,
    this.height = 20,
    this.width = double.infinity,
    this.borderRadius = AppSpacing.radiusSmall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class TransactionShimmer extends StatelessWidget {
  const TransactionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          const LoadingShimmer(
            height: 40,
            width: 40,
            borderRadius: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                LoadingShimmer(width: 150),
                SizedBox(height: AppSpacing.xs),
                LoadingShimmer(width: 100),
              ],
            ),
          ),
          const LoadingShimmer(width: 80),
        ],
      ),
    );
  }
}

class SummaryCardShimmer extends StatelessWidget {
  const SummaryCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundPaper,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LoadingShimmer(width: 100),
          SizedBox(height: AppSpacing.sm),
          LoadingShimmer(height: 36, width: 150),
          SizedBox(height: AppSpacing.sm),
          LoadingShimmer(width: 80),
        ],
      ),
    );
  }
}
