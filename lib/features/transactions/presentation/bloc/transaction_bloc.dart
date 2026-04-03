import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/invoice_remote_datasource.dart';
import '../../domain/usecases/transaction_usecases.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactions getTransactionsUseCase;
  final GetMonthlySummary getMonthlySummaryUseCase;
  final CreateTransaction createTransactionUseCase;
  final UpdateTransaction updateTransactionUseCase;
  final DeleteTransaction deleteTransactionUseCase;
  final InvoiceRemoteDataSource invoiceRemoteDataSource;

  static const int _pageSize = 20;

  double _monthlyIncome = 0;
  double _monthlyExpense = 0;

  TransactionBloc({
    required this.getTransactionsUseCase,
    required this.getMonthlySummaryUseCase,
    required this.createTransactionUseCase,
    required this.updateTransactionUseCase,
    required this.deleteTransactionUseCase,
    required this.invoiceRemoteDataSource,
  }) : super(const TransactionInitial()) {
    on<TransactionFetchRequested>(_onFetchRequested);
    on<TransactionLoadMoreRequested>(_onLoadMoreRequested);
    on<TransactionCreateRequested>(_onCreateRequested);
    on<TransactionUpdateRequested>(_onUpdateRequested);
    on<TransactionDeleteRequested>(_onDeleteRequested);
    on<TransactionFilterChanged>(_onFilterChanged);
    on<TransactionFilterCleared>(_onFilterCleared);
    on<MonthlySummaryFetchRequested>(_onMonthlySummaryFetchRequested);
    on<MonthChanged>(_onMonthChanged);
    on<InvoiceImageProcessRequested>(_onInvoiceImageProcessRequested);
  }

  Future<void> _onFetchRequested(
    TransactionFetchRequested event,
    Emitter<TransactionState> emit,
  ) async {
    developer.log('_onFetchRequested called, refresh=${event.refresh}',
        name: 'TransactionBloc');

    final currentFilters = _getCurrentFilters();

    final currentState = state;
    if (event.refresh) {
      emit(const TransactionLoading());
    } else if (currentState is TransactionInitial ||
        currentState is TransactionOperationSuccess) {
      emit(const TransactionLoading());
    }

    final result = await getTransactionsUseCase(
      page: 0,
      size: _pageSize,
      type: currentFilters.type,
      startDate: currentFilters.startDate,
      endDate: currentFilters.endDate,
      categoryId: currentFilters.categoryId,
    );

    result.fold(
      (failure) {
        developer.log('TransactionFetchRequested error: ${failure.message}',
            name: 'TransactionBloc');
        emit(TransactionError(
          message:
              failure.message.isEmpty ? 'Error desconhecido' : failure.message,
          filters: currentFilters,
        ));
      },
      (transactions) {
        developer.log(
            'TransactionFetchRequested success: ${transactions.length} transactions',
            name: 'TransactionBloc');
        developer.log(
            'TransactionFetchRequested: about to emit TransactionLoaded with ${transactions.length} transactions',
            name: 'TransactionBloc');
        emit(TransactionLoaded(
          transactions: transactions,
          filters: currentFilters,
          hasMore: transactions.length >= _pageSize,
          currentPage: 0,
          totalIncome: _monthlyIncome,
          totalExpense: _monthlyExpense,
        ));
        developer.log(
            'TransactionFetchRequested: TransactionLoaded emitted, current state is ${state.runtimeType}',
            name: 'TransactionBloc');
      },
    );
  }

  Future<void> _onLoadMoreRequested(
    TransactionLoadMoreRequested event,
    Emitter<TransactionState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TransactionLoaded || !currentState.hasMore) return;
    if (currentState is TransactionLoadingMore) return;

    emit(TransactionLoadingMore(
      transactions: currentState.transactions,
      filters: currentState.filters,
    ));

    final nextPage = currentState.currentPage + 1;
    final result = await getTransactionsUseCase(
      page: nextPage,
      size: _pageSize,
      type: currentState.filters.type,
      startDate: currentState.filters.startDate,
      endDate: currentState.filters.endDate,
      categoryId: currentState.filters.categoryId,
    );

    result.fold(
      (failure) => emit(TransactionError(
        message: failure.message,
        filters: currentState.filters,
      )),
      (newTransactions) => emit(TransactionLoaded(
        transactions: [...currentState.transactions, ...newTransactions],
        filters: currentState.filters,
        hasMore: newTransactions.length >= _pageSize,
        currentPage: nextPage,
        totalIncome: _monthlyIncome,
        totalExpense: _monthlyExpense,
      )),
    );
  }

  Future<void> _onCreateRequested(
    TransactionCreateRequested event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await createTransactionUseCase(
      type: event.type,
      shortName: event.shortName,
      description: event.description,
      amount: event.amount,
      currency: event.currency,
      transactionDate: event.transactionDate,
      categoryId: event.categoryId,
      tagIds: event.tagIds,
    );

    result.fold(
      (failure) => emit(TransactionError(
        message: failure.message,
        filters: _getCurrentFilters(),
      )),
      (transaction) {
        final currentFilters = _getCurrentFilters();
        emit(TransactionOperationSuccess(
          message: 'Transacción creada',
          transaction: transaction,
        ));
        add(const TransactionFetchRequested(refresh: true));
        add(MonthlySummaryFetchRequested(
          year: currentFilters.startDate?.year,
          month: currentFilters.startDate?.month,
        ));
      },
    );
  }

  Future<void> _onUpdateRequested(
    TransactionUpdateRequested event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await updateTransactionUseCase(
      id: event.id,
      type: event.type,
      shortName: event.shortName,
      description: event.description,
      amount: event.amount,
      currency: event.currency,
      transactionDate: event.transactionDate,
      categoryId: event.categoryId,
      tagIds: event.tagIds,
    );

    result.fold(
      (failure) => emit(TransactionError(
        message: failure.message,
        filters: _getCurrentFilters(),
      )),
      (transaction) {
        final currentFilters = _getCurrentFilters();
        emit(TransactionOperationSuccess(
          message: 'Transacción actualizada',
          transaction: transaction,
        ));
        add(const TransactionFetchRequested(refresh: true));
        add(MonthlySummaryFetchRequested(
          year: currentFilters.startDate?.year,
          month: currentFilters.startDate?.month,
        ));
      },
    );
  }

  Future<void> _onDeleteRequested(
    TransactionDeleteRequested event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await deleteTransactionUseCase(event.id);

    result.fold(
      (failure) => emit(TransactionError(
        message: failure.message,
        filters: _getCurrentFilters(),
      )),
      (_) {
        final currentFilters = _getCurrentFilters();
        emit(const TransactionOperationSuccess(
          message: 'Transacción eliminada',
        ));
        add(const TransactionFetchRequested(refresh: true));
        add(MonthlySummaryFetchRequested(
          year: currentFilters.startDate?.year,
          month: currentFilters.startDate?.month,
        ));
      },
    );
  }

  Future<void> _onFilterChanged(
    TransactionFilterChanged event,
    Emitter<TransactionState> emit,
  ) async {
    final newFilters = TransactionFilters(
      type: event.type,
      startDate: event.startDate,
      endDate: event.endDate,
      categoryId: event.categoryId,
    );

    emit(TransactionLoading());

    final result = await getTransactionsUseCase(
      page: 0,
      size: _pageSize,
      type: newFilters.type,
      startDate: newFilters.startDate,
      endDate: newFilters.endDate,
      categoryId: newFilters.categoryId,
    );

    result.fold(
      (failure) => emit(TransactionError(
        message: failure.message,
        filters: newFilters,
      )),
      (transactions) => emit(TransactionLoaded(
        transactions: transactions,
        filters: newFilters,
        hasMore: transactions.length >= _pageSize,
        currentPage: 0,
        totalIncome: _monthlyIncome,
        totalExpense: _monthlyExpense,
      )),
    );
  }

  Future<void> _onFilterCleared(
    TransactionFilterCleared event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());

    final result = await getTransactionsUseCase(
      page: 0,
      size: _pageSize,
    );

    result.fold(
      (failure) => emit(TransactionError(
        message: failure.message,
        filters: const TransactionFilters(),
      )),
      (transactions) => emit(TransactionLoaded(
        transactions: transactions,
        filters: const TransactionFilters(),
        hasMore: transactions.length >= _pageSize,
        currentPage: 0,
      )),
    );
  }

  TransactionFilters _getCurrentFilters() {
    final currentState = state;
    if (currentState is TransactionLoaded) {
      return currentState.filters;
    }
    if (currentState is TransactionLoadingMore) {
      return currentState.filters;
    }
    if (currentState is TransactionError) {
      return currentState.filters ?? const TransactionFilters();
    }
    return const TransactionFilters();
  }

  Future<void> _onMonthlySummaryFetchRequested(
    MonthlySummaryFetchRequested event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await getMonthlySummaryUseCase(
      year: event.year,
      month: event.month,
    );

    result.fold(
      (failure) {
        developer.log('MonthlySummaryFetchRequested error: ${failure.message}',
            name: 'TransactionBloc');
      },
      (summary) {
        developer.log(
            'MonthlySummaryFetchRequested success: income=${summary.totalIncome}, expense=${summary.totalExpenses}',
            name: 'TransactionBloc');
        _monthlyIncome = summary.totalIncome;
        _monthlyExpense = summary.totalExpenses;

        final currentState = state;
        if (currentState is TransactionLoaded) {
          emit(TransactionLoaded(
            transactions: currentState.transactions,
            filters: currentState.filters,
            hasMore: currentState.hasMore,
            currentPage: currentState.currentPage,
            totalIncome: _monthlyIncome,
            totalExpense: _monthlyExpense,
          ));
        }
      },
    );
  }

  Future<void> _onMonthChanged(
    MonthChanged event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());

    final summaryResult = await getMonthlySummaryUseCase(
      year: event.year,
      month: event.month,
    );

    summaryResult.fold(
      (failure) {},
      (summary) {
        _monthlyIncome = summary.totalIncome;
        _monthlyExpense = summary.totalExpenses;
      },
    );

    final newFilters = TransactionFilters(
      startDate: DateTime(event.year, event.month, 1),
      endDate: DateTime(event.year, event.month + 1, 0),
    );

    final result = await getTransactionsUseCase(
      page: 0,
      size: _pageSize,
      type: newFilters.type,
      startDate: newFilters.startDate,
      endDate: newFilters.endDate,
      categoryId: newFilters.categoryId,
    );

    result.fold(
      (failure) => emit(TransactionError(
        message: failure.message,
        filters: newFilters,
      )),
      (transactions) => emit(TransactionLoaded(
        transactions: transactions,
        filters: newFilters,
        hasMore: transactions.length >= _pageSize,
        currentPage: 0,
        totalIncome: _monthlyIncome,
        totalExpense: _monthlyExpense,
      )),
    );
  }

  Future<void> _onInvoiceImageProcessRequested(
    InvoiceImageProcessRequested event,
    Emitter<TransactionState> emit,
  ) async {
    developer.log('_onInvoiceImageProcessRequested called',
        name: 'TransactionBloc');

    final currentFilters = TransactionFilters(
      type: event.type,
      startDate: event.startDate,
      endDate: event.endDate,
      categoryId: event.categoryId,
    );

    emit(const InvoiceProcessing());

    try {
      final result = await invoiceRemoteDataSource.processInvoiceImage(
        filePath: event.filePath,
        fileName: event.fileName,
      );

      if (result.success) {
        int? year;
        int? month;
        if (event.startDate != null) {
          year = event.startDate!.year;
          month = event.startDate!.month;
        }

        final summaryResult = await getMonthlySummaryUseCase(
          year: year,
          month: month,
        );
        summaryResult.fold(
          (failure) {
            developer.log(
                'InvoiceProcessing: failed to fetch summary: ${failure.message}',
                name: 'TransactionBloc');
          },
          (summary) {
            _monthlyIncome = summary.totalIncome;
            _monthlyExpense = summary.totalExpenses;
          },
        );

        final transactionsResult = await getTransactionsUseCase(
          page: 0,
          size: _pageSize,
          type: currentFilters.type,
          startDate: currentFilters.startDate,
          endDate: currentFilters.endDate,
          categoryId: currentFilters.categoryId,
        );

        transactionsResult.fold(
          (failure) {
            emit(InvoiceProcessingError(
              message: failure.message,
            ));
          },
          (transactions) {
            emit(TransactionLoaded(
              transactions: transactions,
              filters: currentFilters,
              hasMore: transactions.length >= _pageSize,
              currentPage: 0,
              totalIncome: _monthlyIncome,
              totalExpense: _monthlyExpense,
            ));
            developer.log(
                'InvoiceProcessing: emitted TransactionLoaded with ${transactions.length} transactions, income=$_monthlyIncome, expense=$_monthlyExpense',
                name: 'TransactionBloc');
          },
        );
      } else {
        emit(InvoiceProcessingError(
          message: result.error ?? 'Error al procesar la imagen',
        ));
      }
    } catch (e) {
      developer.log('InvoiceImageProcessRequested error: $e',
          name: 'TransactionBloc');
      emit(InvoiceProcessingError(
        message: 'Error al procesar la imagen: $e',
      ));
    }
  }
}
