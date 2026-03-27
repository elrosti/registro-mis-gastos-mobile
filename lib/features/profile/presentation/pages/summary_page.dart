import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../transactions/presentation/bloc/transaction_bloc.dart';
import '../../../transactions/presentation/bloc/transaction_event.dart';
import '../../../transactions/presentation/bloc/transaction_state.dart';
import '../../../transactions/presentation/widgets/summary_header.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen'),
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<TransactionBloc>().add(
                    TransactionFetchRequested(refresh: true),
                  );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _MonthSelector(
                    selectedMonth: _selectedMonth,
                    onMonthChanged: (month) {
                      setState(() {
                        _selectedMonth = month;
                      });
                    },
                  ),
                  _buildSummaryContent(state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryContent(TransactionState state) {
    if (state is TransactionLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: SummaryCardShimmer(),
      );
    }

    if (state is TransactionError) {
      return ErrorState(
        message: state.message,
        onRetry: () => context
            .read<TransactionBloc>()
            .add(const TransactionFetchRequested(refresh: true)),
      );
    }

    if (state is TransactionLoaded) {
      final totals = _calculateTotals(state.transactions);
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            _KpiCards(
              totalIncome: totals['income'] ?? 0,
              totalExpense: totals['expense'] ?? 0,
              currency: 'UYU',
            ),
            const SizedBox(height: AppSpacing.lg),
            _CategoryBreakdown(
              transactions: state.transactions,
              currency: 'UYU',
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Map<String, double> _calculateTotals(List<dynamic> transactions) {
    double income = 0;
    double expense = 0;

    for (final t in transactions) {
      if (t.isIncome) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    return {'income': income, 'expense': expense};
  }
}

class _MonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onMonthChanged;

  const _MonthSelector({
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              onMonthChanged(
                DateTime(selectedMonth.year, selectedMonth.month - 1),
              );
            },
          ),
          Text(
            DateFormatter.formatMonthYear(selectedMonth),
            style: AppTypography.titleLarge,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final nextMonth = DateTime(
                selectedMonth.year,
                selectedMonth.month + 1,
              );
              if (nextMonth
                  .isBefore(DateTime.now().add(const Duration(days: 1)))) {
                onMonthChanged(nextMonth);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _KpiCards extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final String currency;

  const _KpiCards({
    required this.totalIncome,
    required this.totalExpense,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final balance = totalIncome - totalExpense;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                label: 'Ingresos',
                value: CurrencyFormatter.format(totalIncome, currency),
                color: AppColors.successMain,
                icon: Icons.arrow_upward,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _KpiCard(
                label: 'Gastos',
                value: CurrencyFormatter.format(totalExpense, currency),
                color: AppColors.errorMain,
                icon: Icons.arrow_downward,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _KpiCard(
          label: 'Balance',
          value: CurrencyFormatter.format(balance, currency),
          color: balance >= 0 ? AppColors.successMain : AppColors.errorMain,
          icon: balance >= 0 ? Icons.trending_up : Icons.trending_down,
          isLarge: true,
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool isLarge;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: isLarge
                ? AppTypography.kpiValue.copyWith(color: color)
                : AppTypography.titleLarge.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final List<dynamic> transactions;
  final String currency;

  const _CategoryBreakdown({
    required this.transactions,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final categoryTotals = _groupByCategory();

    if (categoryTotals.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalExpense = sortedCategories.fold<double>(
      0,
      (sum, entry) => sum + entry.value,
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundPaper,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gastos por categoría',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          ...sortedCategories.take(5).map((entry) {
            final percentage = totalExpense > 0
                ? (entry.value / totalExpense * 100).toStringAsFixed(1)
                : '0';
            return _CategoryBar(
              categoryName: entry.key,
              amount: entry.value,
              percentage: double.parse(percentage),
              currency: currency,
            );
          }),
        ],
      ),
    );
  }

  Map<String, double> _groupByCategory() {
    final Map<String, double> totals = {};
    for (final t in transactions) {
      if (t.isExpense) {
        final categoryName = t.category?.name ?? 'Sin categoría';
        totals[categoryName] = (totals[categoryName] ?? 0) + t.amount;
      }
    }
    return totals;
  }
}

class _CategoryBar extends StatelessWidget {
  final String categoryName;
  final double amount;
  final double percentage;
  final String currency;

  const _CategoryBar({
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(categoryName, style: AppTypography.bodyMedium),
              Text(
                '${CurrencyFormatter.format(amount, currency)} ($percentage%)',
                style: AppTypography.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: AppColors.borderLight,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primaryMain),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
