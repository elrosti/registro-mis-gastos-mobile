import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/monthly_summary_model.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<Transaction>>> getTransactions({
    int page = 0,
    int size = 20,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? type,
  });

  Future<Either<Failure, MonthlySummary>> getMonthlySummary(
      {int? year, int? month, DateTime? startDate, DateTime? endDate});

  Future<Either<Failure, Transaction>> getTransactionById(String id);

  Future<Either<Failure, Transaction>> createTransaction({
    required String type,
    required String shortName,
    String? description,
    required double amount,
    required String currency,
    required DateTime transactionDate,
    String? categoryId,
    List<String>? tagIds,
  });

  Future<Either<Failure, Transaction>> updateTransaction({
    required String id,
    String? type,
    String? shortName,
    String? description,
    double? amount,
    String? currency,
    DateTime? transactionDate,
    String? categoryId,
    List<String>? tagIds,
  });

  Future<Either<Failure, void>> deleteTransaction(String id);
}

abstract class CategoryRepository {
  Future<Either<Failure, List<Category>>> getCategories();
  Future<Either<Failure, List<Category>>> getMostUsedCategories();
}
