import 'package:equatable/equatable.dart';
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

  const TransactionLoaded({
    required this.transactions,
    required this.filters,
    this.hasMore = true,
    this.currentPage = 0,
  });

  TransactionLoaded copyWith({
    List<Transaction>? transactions,
    TransactionFilters? filters,
    bool? hasMore,
    int? currentPage,
  }) {
    return TransactionLoaded(
      transactions: transactions ?? this.transactions,
      filters: filters ?? this.filters,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [transactions, filters, hasMore, currentPage];
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

  @override
  List<Object?> get props => [message, transaction];
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
      type != null || startDate != null || endDate != null || categoryId != null;

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
