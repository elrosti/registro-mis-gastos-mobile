import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/confirmation_dialog.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/summary_header.dart';
import '../widgets/transaction_filters.dart';
import 'add_transaction_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<TransactionBloc>().add(const TransactionLoadMoreRequested());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Gastos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: BlocConsumer<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.successMain,
              ),
            );
          } else if (state is TransactionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.errorMain,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TransactionLoading) {
            return _buildLoading();
          }

          if (state is TransactionError && state is! TransactionLoaded) {
            return ErrorState(
              message: state.message,
              onRetry: () => context
                  .read<TransactionBloc>()
                  .add(const TransactionFetchRequested(refresh: true)),
            );
          }

          if (state is TransactionLoaded || state is TransactionLoadingMore) {
            return _buildContent(state);
          }

          return const EmptyState(
            icon: Icons.receipt_long,
            title: 'No hay transacciones',
            subtitle: 'Comienza agregando tu primera transacción',
          );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 5,
      itemBuilder: (context, index) => const TransactionShimmer(),
    );
  }

  Widget _buildContent(TransactionState state) {
    List<Transaction> transactions = [];
    TransactionFilters? filters;
    bool hasMore = false;

    if (state is TransactionLoaded) {
      transactions = state.transactions;
      filters = state.filters;
      hasMore = state.hasMore;
    } else if (state is TransactionLoadingMore) {
      transactions = state.transactions;
      filters = state.filters;
    }

    final totals = _calculateTotals(transactions);

    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<TransactionBloc>()
            .add(const TransactionFetchRequested(refresh: true));
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: SummaryHeader(
              totalIncome: totals['income'] ?? 0,
              totalExpense: totals['expense'] ?? 0,
              currency: 'UYU',
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: TransactionFilters(
                selectedType: filters?.type,
                onTypeChanged: (type) {
                  context.read<TransactionBloc>().add(
                        TransactionFilterChanged(type: type),
                      );
                },
                onClearFilters: () {
                  context
                      .read<TransactionBloc>()
                      .add(const TransactionFilterCleared());
                },
              ),
            ),
          ),
          if (transactions.isEmpty)
            const SliverFillRemaining(
              child: EmptyState(
                icon: Icons.receipt_long,
                title: 'No hay transacciones',
                subtitle: 'Comienza agregando tu primera transacción',
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= transactions.length) {
                    return hasMore
                        ? const Padding(
                            padding: EdgeInsets.all(AppSpacing.md),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : const SizedBox.shrink();
                  }

                  final transaction = transactions[index];
                  return TransactionListItem(
                    transaction: transaction,
                    onTap: () => _openTransactionDetail(transaction),
                    onEdit: () => _editTransaction(transaction),
                    onDelete: () => _deleteTransaction(transaction),
                  );
                },
                childCount: transactions.length + (hasMore ? 1 : 0),
              ),
            ),
        ],
      ),
    );
  }

  Map<String, double> _calculateTotals(List<Transaction> transactions) {
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

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Este mes'),
              onTap: () {
                final now = DateTime.now();
                context.read<TransactionBloc>().add(
                      TransactionFilterChanged(
                        startDate: DateTime(now.year, now.month, 1),
                        endDate: DateTime(now.year, now.month + 1, 0),
                      ),
                    );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Mes anterior'),
              onTap: () {
                final now = DateTime.now();
                context.read<TransactionBloc>().add(
                      TransactionFilterChanged(
                        startDate: DateTime(now.year, now.month - 1, 1),
                        endDate: DateTime(now.year, now.month, 0),
                      ),
                    );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('Limpiar filtros'),
              onTap: () {
                context
                    .read<TransactionBloc>()
                    .add(const TransactionFilterCleared());
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openTransactionDetail(Transaction transaction) {
    _editTransaction(transaction);
  }

  void _editTransaction(Transaction transaction) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<TransactionBloc>(),
          child: AddTransactionPage(transaction: transaction),
        ),
      ),
    );
  }

  Future<void> _deleteTransaction(Transaction transaction) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Eliminar transacción',
      message: '¿Estás seguro de que deseas eliminar "${transaction.shortName}"?',
      confirmText: 'Eliminar',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      context.read<TransactionBloc>().add(
            TransactionDeleteRequested(id: transaction.id),
          );
    }
  }
}
