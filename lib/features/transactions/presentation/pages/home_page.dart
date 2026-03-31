import 'dart:developer' as developer;

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
import '../widgets/transaction_filters.dart' as widgets;
import 'add_transaction_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMonthData();
  }

  void _loadMonthData() {
    context.read<TransactionBloc>().add(MonthChanged(
          year: _selectedMonth.year,
          month: _selectedMonth.month,
        ));
  }

  void _onMonthChanged(DateTime month) {
    setState(() {
      _selectedMonth = month;
    });
    _loadMonthData();
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
          developer.log('HomePage listener state: ${state.runtimeType}',
              name: 'HomePage');

          if (state is TransactionOperationSuccess) {
            developer.log('HomePage: TransactionOperationSuccess received',
                name: 'HomePage');
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
        listenWhen: (previous, current) {
          final shouldListen = current is TransactionOperationSuccess ||
              current is TransactionError;
          developer.log(
              'HomePage listenWhen: $shouldListen (prev=${previous.runtimeType}, curr=${current.runtimeType})',
              name: 'HomePage');
          return shouldListen;
        },
        builder: (context, state) {
          developer.log('HomePage builder state: ${state.runtimeType}',
              name: 'HomePage');

          if (state is TransactionLoading) {
            developer.log('HomePage: showing _buildLoading', name: 'HomePage');
            return _buildLoading();
          }

          if (state is TransactionError && state is! TransactionLoaded) {
            developer.log('HomePage: showing ErrorState', name: 'HomePage');
            return ErrorState(
              message: state.message,
              onRetry: () => context
                  .read<TransactionBloc>()
                  .add(const TransactionFetchRequested(refresh: true)),
            );
          }

          developer.log(
              'HomePage: checking TransactionLoaded, state is ${state.runtimeType}',
              name: 'HomePage');
          if (state is TransactionLoaded || state is TransactionLoadingMore) {
            developer.log(
                'HomePage: state is TransactionLoaded, going to _buildContent',
                name: 'HomePage');
            return _buildContent(state);
          }

          if (state is TransactionOperationSuccess) {
            return _buildLoading();
          }

          developer.log('HomePage: no matching state, showing EmptyState',
              name: 'HomePage');
          return const EmptyState(
            icon: Icons.receipt_long,
            title: 'No hay transacciones',
            subtitle: 'Comienza agregando tu primera transacción',
          );
        },
      ),
    );
  }

  Widget _buildLoading([List<Transaction> existingTransactions = const []]) {
    developer.log(
        '_buildLoading called with ${existingTransactions.length} transactions',
        name: 'HomePage');
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount:
          existingTransactions.isNotEmpty ? existingTransactions.length : 5,
      itemBuilder: (context, index) {
        if (existingTransactions.isNotEmpty) {
          return TransactionListItem(
            transaction: existingTransactions[index],
            onTap: () {},
            onEdit: () {},
            onDelete: () {},
          );
        }
        return const TransactionShimmer();
      },
    );
  }

  Widget _buildContent(TransactionState state) {
    developer.log('_buildContent called', name: 'HomePage');

    List<Transaction> transactions = [];
    TransactionFilters? filters;
    bool hasMore = false;
    double totalIncome = 0;
    double totalExpense = 0;
    bool isLoadingMore = false;

    if (state is TransactionLoaded) {
      transactions = state.transactions;
      filters = state.filters;
      hasMore = state.hasMore;
      totalIncome = state.totalIncome;
      totalExpense = state.totalExpense;
      developer.log(
          '_buildContent: loaded ${transactions.length} transactions, income=$totalIncome, expense=$totalExpense',
          name: 'HomePage');
    } else if (state is TransactionLoadingMore) {
      transactions = state.transactions;
      filters = state.filters;
      isLoadingMore = true;
    }

    developer.log(
        '_buildContent: returning widget with ${transactions.length} transactions',
        name: 'HomePage');

    final itemCount = transactions.length + 1 + (hasMore ? 1 : 0);

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
              totalIncome: totalIncome,
              totalExpense: totalExpense,
              currency: 'UYU',
              selectedMonth: _selectedMonth,
              onMonthChanged: _onMonthChanged,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final txIndex = index;
                if (txIndex >= transactions.length) {
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Center(
                      child: isLoadingMore
                          ? const CircularProgressIndicator()
                          : const SizedBox.shrink(),
                    ),
                  );
                }
                final transaction = transactions[txIndex];
                return TransactionListItem(
                  transaction: transaction,
                  onTap: () => _openTransactionDetail(transaction),
                  onEdit: () => _editTransaction(transaction),
                  onDelete: () => _deleteTransaction(transaction),
                );
              },
              childCount: itemCount - 1,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
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
              leading: const Icon(Icons.calendar_month),
              title: const Text('Rango de fechas'),
              onTap: () async {
                Navigator.pop(context);
                final bloc = context.read<TransactionBloc>();
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: DateTimeRange(
                    start: DateTime.now().subtract(const Duration(days: 30)),
                    end: DateTime.now(),
                  ),
                );
                if (range != null) {
                  bloc.add(
                    TransactionFilterChanged(
                      startDate: range.start,
                      endDate: range.end,
                    ),
                  );
                }
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
      message:
          '¿Estás seguro de que deseas eliminar "${transaction.shortName}"?',
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
