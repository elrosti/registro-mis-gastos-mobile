import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/monthly_summary_model.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_datasource.dart';
import '../datasources/category_remote_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;

  TransactionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions({
    int page = 0,
    int size = 20,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? type,
  }) async {
    try {
      final result = await remoteDataSource.getTransactions(
        page: page,
        size: size,
        startDate: startDate,
        endDate: endDate,
        categoryId: categoryId,
        type: type,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> getTransactionById(String id) async {
    try {
      final result = await remoteDataSource.getTransactionById(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MonthlySummary>> getMonthlySummary(
      {int? year, int? month, DateTime? startDate, DateTime? endDate}) async {
    try {
      final result = await remoteDataSource.getMonthlySummary(
          year: year, month: month, startDate: startDate, endDate: endDate);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> createTransaction({
    required String type,
    required String shortName,
    String? description,
    required double amount,
    required String currency,
    required DateTime transactionDate,
    String? categoryId,
    List<String>? tagIds,
  }) async {
    try {
      final result = await remoteDataSource.createTransaction(
        type: type,
        shortName: shortName,
        description: description,
        amount: amount,
        currency: currency,
        transactionDate: transactionDate,
        categoryId: categoryId,
        tagIds: tagIds,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final result = await remoteDataSource.updateTransaction(
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
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    try {
      await remoteDataSource.deleteTransaction(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final result = await remoteDataSource.getCategories();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getMostUsedCategories() async {
    try {
      final result = await remoteDataSource.getMostUsedCategories();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
