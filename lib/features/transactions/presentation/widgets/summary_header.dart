import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';

class SummaryHeader extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final String currency;

  const SummaryHeader({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.currency,
  });

  double get balance => totalIncome - totalExpense;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundPaper,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Balance del mes',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            CurrencyFormatter.format(balance, currency),
            style: AppTypography.kpiValue.copyWith(
              color: balance >= 0 ? AppColors.successMain : AppColors.errorMain,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'Ingresos',
                  amount: totalIncome,
                  currency: currency,
                  color: AppColors.successMain,
                  icon: Icons.arrow_upward,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.borderMain,
              ),
              Expanded(
                child: _SummaryItem(
                  label: 'Gastos',
                  amount: totalExpense,
                  currency: currency,
                  color: AppColors.errorMain,
                  icon: Icons.arrow_downward,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double amount;
  final String currency;
  final Color color;
  final IconData icon;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.currency,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelSmall,
            ),
            Text(
              CurrencyFormatter.format(amount, currency),
              style: AppTypography.titleMedium.copyWith(color: color),
            ),
          ],
        ),
      ],
    );
  }
}
