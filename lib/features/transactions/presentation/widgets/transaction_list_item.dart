import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/transaction.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(transaction.id),
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => onEdit?.call(),
            backgroundColor: AppColors.primaryMain,
            foregroundColor: AppColors.primaryContrast,
            icon: Icons.edit,
            label: 'Editar',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => onDelete?.call(),
            backgroundColor: AppColors.errorMain,
            foregroundColor: AppColors.primaryContrast,
            icon: Icons.delete,
            label: 'Eliminar',
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: transaction.isIncome
                    ? AppColors.successMain
                    : AppColors.errorMain,
                width: 4,
              ),
            ),
          ),
          child: Row(
            children: [
              _CategoryIcon(transaction: transaction),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.shortName,
                      style: AppTypography.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      transaction.category?.name ?? 'Sin categoría',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.formatWithSign(
                      transaction.amount,
                      transaction.currency,
                      transaction.isIncome,
                    ),
                    style: AppTypography.titleMedium.copyWith(
                      color: transaction.isIncome
                          ? AppColors.successMain
                          : AppColors.errorMain,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    DateFormatter.formatRelative(transaction.transactionDate),
                    style: AppTypography.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final Transaction transaction;

  const _CategoryIcon({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final color = transaction.category?.color != null
        ? Color(int.parse(transaction.category!.color!.replaceFirst('#', '0xFF')))
        : AppColors.primaryMain;

    final iconData = _getIconData(transaction.category?.icon);

    return Container(
      width: AppSpacing.avatarSize,
      height: AppSpacing.avatarSize,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: color,
        size: 20,
      ),
    );
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'directions_car':
        return Icons.directions_car;
      case 'home':
        return Icons.home;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'entertainment':
        return Icons.movie;
      case 'flight':
        return Icons.flight;
      default:
        return Icons.attach_money;
    }
  }
}
