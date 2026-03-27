import 'package:equatable/equatable.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class TransactionFetchRequested extends TransactionEvent {
  final bool refresh;

  const TransactionFetchRequested({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class TransactionLoadMoreRequested extends TransactionEvent {
  const TransactionLoadMoreRequested();
}

class TransactionCreateRequested extends TransactionEvent {
  final String type;
  final String shortName;
  final String? description;
  final double amount;
  final String currency;
  final DateTime transactionDate;
  final String? categoryId;
  final List<String>? tagIds;

  const TransactionCreateRequested({
    required this.type,
    required this.shortName,
    this.description,
    required this.amount,
    required this.currency,
    required this.transactionDate,
    this.categoryId,
    this.tagIds,
  });

  @override
  List<Object?> get props => [
        type,
        shortName,
        description,
        amount,
        currency,
        transactionDate,
        categoryId,
        tagIds,
      ];
}

class TransactionUpdateRequested extends TransactionEvent {
  final String id;
  final String? type;
  final String? shortName;
  final String? description;
  final double? amount;
  final String? currency;
  final DateTime? transactionDate;
  final String? categoryId;
  final List<String>? tagIds;

  const TransactionUpdateRequested({
    required this.id,
    this.type,
    this.shortName,
    this.description,
    this.amount,
    this.currency,
    this.transactionDate,
    this.categoryId,
    this.tagIds,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        shortName,
        description,
        amount,
        currency,
        transactionDate,
        categoryId,
        tagIds,
      ];
}

class TransactionDeleteRequested extends TransactionEvent {
  final String id;

  const TransactionDeleteRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

class TransactionFilterChanged extends TransactionEvent {
  final String? type;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? categoryId;

  const TransactionFilterChanged({
    this.type,
    this.startDate,
    this.endDate,
    this.categoryId,
  });

  @override
  List<Object?> get props => [type, startDate, endDate, categoryId];
}

class TransactionFilterCleared extends TransactionEvent {
  const TransactionFilterCleared();
}
