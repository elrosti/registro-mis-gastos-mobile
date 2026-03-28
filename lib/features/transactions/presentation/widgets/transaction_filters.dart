import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class TransactionFilters extends StatelessWidget {
  final String? selectedType;
  final ValueChanged<String?> onTypeChanged;
  final VoidCallback? onClearFilters;

  const TransactionFilters({
    super.key,
    this.selectedType,
    required this.onTypeChanged,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          _FilterChip(
            label: 'Todos',
            isSelected: selectedType == null,
            onTap: () => onTypeChanged(null),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(
            label: 'Ingresos',
            isSelected: selectedType == 'INCOME',
            onTap: () => onTypeChanged('INCOME'),
            color: AppColors.successMain,
          ),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(
            label: 'Gastos',
            isSelected: selectedType == 'EXPENSE',
            onTap: () => onTypeChanged('EXPENSE'),
            color: AppColors.errorMain,
          ),
          if (selectedType != null) ...[
            const SizedBox(width: AppSpacing.sm),
            ActionChip(
              label: const Text('Limpiar'),
              onPressed: onClearFilters,
              labelStyle: AppTypography.labelSmall.copyWith(
                color: AppColors.primaryMain,
              ),
              side: const BorderSide(color: AppColors.primaryMain),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primaryMain;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: AppColors.backgroundPaper,
      selectedColor: chipColor.withAlpha(51),
      checkmarkColor: chipColor,
      labelStyle: AppTypography.labelSmall.copyWith(
        color: isSelected ? chipColor : AppColors.textSecondary,
      ),
      side: BorderSide(
        color: isSelected ? chipColor : AppColors.borderMain,
      ),
    );
  }
}
