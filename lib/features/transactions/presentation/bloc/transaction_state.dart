import 'package:equatable/equatable.dart';
import '../../data/models/monthly_summary_model.dart';
import '../../domain/entities/transaction.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

class TransactionLoadingMore extends TransactionState {
  final List<Transaction> transactions;
  final TransactionFilters filters;

  const TransactionLoadingMore({
    required this.transactions,
    required this.filters,
  });

  @override
  List<Object?> get props => [transactions, filters];
}

class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  final TransactionFilters filters;
  final bool hasMore;
  final int currentPage;
  final double totalIncome;
  final double totalExpense;

  const TransactionLoaded({
    required this.transactions,
    required this.filters,
    this.hasMore = true,
    this.currentPage = 0,
    this.totalIncome = 0,
    this.totalExpense = 0,
  });

  TransactionLoaded copyWith({
    List<Transaction>? transactions,
    TransactionFilters? filters,
    bool? hasMore,
    int? currentPage,
    double? totalIncome,
    double? totalExpense,
  }) {
    return TransactionLoaded(
      transactions: transactions ?? this.transactions,
      filters: filters ?? this.filters,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
    );
  }

  @override
  List<Object?> get props =>
      [transactions, filters, hasMore, currentPage, totalIncome, totalExpense];
}

class TransactionError extends TransactionState {
  final String message;
  final TransactionFilters? filters;

  const TransactionError({
    required this.message,
    this.filters,
  });

  @override
  List<Object?> get props => [message, filters];
}

class TransactionOperationSuccess extends TransactionState {
  final String message;
  final Transaction? transaction;

  const TransactionOperationSuccess({
    required this.message,
    this.transaction,
  });
}

class TransactionFilters extends Equatable {
  final String? type;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? categoryId;

  const TransactionFilters({
    this.type,
    this.startDate,
    this.endDate,
    this.categoryId,
  });

  bool get hasFilters =>
      type != null ||
      startDate != null ||
      endDate != null ||
      categoryId != null;

  TransactionFilters copyWith({
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
  }) {
    return TransactionFilters(
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  TransactionFilters clearType() {
    return TransactionFilters(
      type: null,
      startDate: startDate,
      endDate: endDate,
      categoryId: categoryId,
    );
  }

  @override
  List<Object?> get props => [type, startDate, endDate, categoryId];
}

class MonthlySummaryLoaded extends TransactionState {
  final MonthlySummary summary;

  const MonthlySummaryLoaded({required this.summary});

  @override
  List<Object?> get props => [summary];
}

class InvoiceProcessing extends TransactionState {
  const InvoiceProcessing();
}

class InvoiceProcessingSuccess extends TransactionState {
  final String message;
  final Transaction? transaction;

  const InvoiceProcessingSuccess({
    required this.message,
    this.transaction,
  });

  @override
  List<Object?> get props => [message, transaction];
}

class InvoiceProcessingError extends TransactionState {
  final String message;

  const InvoiceProcessingError({required this.message});

  @override
  List<Object?> get props => [message];
}
