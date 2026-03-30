import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/transaction.dart';

class CategorySelector extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final ValueChanged<Category> onCategorySelected;
  final String? errorText;

  const CategorySelector({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
    this.errorText,
  });

  Category? get _selectedCategory {
    if (selectedCategoryId == null) return null;
    try {
      return categories.firstWhere((c) => c.id == selectedCategoryId);
    } catch (_) {
      return null;
    }
  }

  void _showCategoryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundPaper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLarge),
        ),
      ),
      builder: (context) => _CategoryPickerSheet(
        categories: categories,
        selectedCategoryId: selectedCategoryId,
        onCategorySelected: (category) {
          onCategorySelected(category);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = _selectedCategory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: () => _showCategoryPicker(context),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.backgroundPaper,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              border: Border.all(
                color: errorText != null
                    ? AppColors.errorMain
                    : AppColors.borderMain,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedCategory?.name ?? 'Seleccionar categoría',
                    style: AppTypography.bodyMedium.copyWith(
                      color: selectedCategory == null
                          ? AppColors.textSecondary
                          : null,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorText!,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.errorMain,
            ),
          ),
        ],
      ],
    );
  }
}

class _CategoryPickerSheet extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final ValueChanged<Category> onCategorySelected;

  const _CategoryPickerSheet({
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.borderMain,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Seleccionar Categoría',
          style: AppTypography.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category.id == selectedCategoryId;
              final color = category.color != null
                  ? Color(int.parse(category.color!.replaceFirst('#', '0xFF')))
                  : AppColors.primaryMain;

              return ListTile(
                title: Text(
                  category.name,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        Icons.check,
                        color: color,
                      )
                    : null,
                onTap: () => onCategorySelected(category),
              );
            },
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
      ],
    );
  }
}
