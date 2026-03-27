import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactions {
  final TransactionRepository repository;

  GetTransactions(this.repository);

  Future<Either<Failure, List<Transaction>>> call({
    int page = 0,
    int size = 20,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? type,
  }) {
    return repository.getTransactions(
      page: page,
      size: size,
      startDate: startDate,
      endDate: endDate,
      categoryId: categoryId,
      type: type,
    );
  }
}

class GetTransactionById {
  final TransactionRepository repository;

  GetTransactionById(this.repository);

  Future<Either<Failure, Transaction>> call(String id) {
    return repository.getTransactionById(id);
  }
}

class CreateTransaction {
  final TransactionRepository repository;

  CreateTransaction(this.repository);

  Future<Either<Failure, Transaction>> call({
    required String type,
    required String shortName,
    String? description,
    required double amount,
    required String currency,
    required DateTime transactionDate,
    String? categoryId,
    List<String>? tagIds,
  }) {
    return repository.createTransaction(
      type: type,
      shortName: shortName,
      description: description,
      amount: amount,
      currency: currency,
      transactionDate: transactionDate,
      categoryId: categoryId,
      tagIds: tagIds,
    );
  }
}

class UpdateTransaction {
  final TransactionRepository repository;

  UpdateTransaction(this.repository);

  Future<Either<Failure, Transaction>> call({
    required String id,
    String? type,
    String? shortName,
    String? description,
    double? amount,
    String? currency,
    DateTime? transactionDate,
    String? categoryId,
    List<String>? tagIds,
  }) {
    return repository.updateTransaction(
      id: id,
      type: type,
      shortName: shortName,
      description: description,
      amount: amount,
      currency: currency,
      transactionDate: transactionDate,
      categoryId: categoryId,
      tagIds: tagIds,
    );
  }
}

class DeleteTransaction {
  final TransactionRepository repository;

  DeleteTransaction(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteTransaction(id);
  }
}

class GetCategories {
  final CategoryRepository repository;

  GetCategories(this.repository);

  Future<Either<Failure, List<Category>>> call() {
    return repository.getCategories();
  }
}

class GetMostUsedCategories {
  final CategoryRepository repository;

  GetMostUsedCategories(this.repository);

  Future<Either<Failure, List<Category>>> call() {
    return repository.getMostUsedCategories();
  }
}
