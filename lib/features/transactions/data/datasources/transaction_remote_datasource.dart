import 'dart:developer' as developer;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/transaction_model.dart';
import '../models/monthly_summary_model.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getTransactions({
    int page = 0,
    int size = 20,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? type,
  });

  Future<MonthlySummary> getMonthlySummary(
      {int? year, int? month, DateTime? startDate, DateTime? endDate});

  Future<TransactionModel> getTransactionById(String id);

  Future<TransactionModel> createTransaction({
    required String type,
    required String shortName,
    String? description,
    required double amount,
    required String currency,
    required DateTime transactionDate,
    String? categoryId,
    List<String>? tagIds,
  });

  Future<TransactionModel> updateTransaction({
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

  Future<void> deleteTransaction(String id);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final ApiClient _apiClient;

  TransactionRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<TransactionModel>> getTransactions({
    int page = 0,
    int size = 20,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };

      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      }
      if (categoryId != null) {
        queryParams['categoryId'] = categoryId;
      }
      if (type != null) {
        queryParams['type'] = type;
      }

      final response = await _apiClient.get(
        ApiConstants.transactions,
        queryParameters: queryParams,
      );

      final data = response.data;
      List<dynamic>? content;

      if (data is List) {
        content = data;
      } else if (data is Map<String, dynamic>) {
        content = data['content'] as List<dynamic>?;
        content ??= data['data'] as List<dynamic>?;
      }

      if (content == null) {
        return [];
      }

      return content
          .map(
              (json) => TransactionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e, stackTrace) {
      developer.log(
          'Exception in getTransactions: type=${e.runtimeType}, message=$e, stack=$stackTrace',
          name: 'TransactionRemoteDataSource');
      throw ServerException(message: 'Failed to fetch transactions: $e');
    }
  }

  @override
  Future<MonthlySummary> getMonthlySummary(
      {int? year, int? month, DateTime? startDate, DateTime? endDate}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (year != null) queryParams['year'] = year;
      if (month != null) queryParams['month'] = month;
      if (startDate != null)
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      if (endDate != null)
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];

      final response = await _apiClient.get(
        ApiConstants.reportsMonthly,
        queryParameters: queryParams,
      );

      developer.log('getMonthlySummary response.data: ${response.data}',
          name: 'TransactionRemoteDataSource');
      developer.log(
          'getMonthlySummary response.data type: ${response.data.runtimeType}',
          name: 'TransactionRemoteDataSource');

      final data = response.data as Map<String, dynamic>;
      developer.log(
          'totalIncome: ${data['totalIncome']}, totalExpenses: ${data['totalExpenses']}, balance: ${data['balance']}',
          name: 'TransactionRemoteDataSource');

      return MonthlySummary.fromJson(data);
    } on ServerException {
      rethrow;
    } catch (e, stackTrace) {
      developer.log(
          'Exception in getMonthlySummary: type=${e.runtimeType}, message=$e, stack=$stackTrace',
          name: 'TransactionRemoteDataSource');
      throw ServerException(message: 'Failed to fetch monthly summary: $e');
    }
  }

  @override
  Future<TransactionModel> getTransactionById(String id) async {
    try {
      final response = await _apiClient.get(ApiConstants.transactionById(id));
      return TransactionModel.fromJson(response.data);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch transaction: $e');
    }
  }

  @override
  Future<TransactionModel> createTransaction({
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
      final response = await _apiClient.post(
        ApiConstants.transactions,
        data: {
          'type': type,
          'shortName': shortName,
          'description': description,
          'amount': amount,
          'currency': currency,
          'transactionDate': transactionDate.toIso8601String().split('T')[0],
          'categoryId': categoryId,
          'tagIds': tagIds,
        },
      );
      return TransactionModel.fromJson(response.data);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to create transaction: $e');
    }
  }

  @override
  Future<TransactionModel> updateTransaction({
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
      final data = <String, dynamic>{};
      if (type != null) data['type'] = type;
      if (shortName != null) data['shortName'] = shortName;
      if (description != null) data['description'] = description;
      if (amount != null) data['amount'] = amount;
      if (currency != null) data['currency'] = currency;
      if (transactionDate != null) {
        data['transactionDate'] =
            transactionDate.toIso8601String().split('T')[0];
      }
      if (categoryId != null) data['categoryId'] = categoryId;
      if (tagIds != null) data['tagIds'] = tagIds;

      final response = await _apiClient.put(
        ApiConstants.transactionById(id),
        data: data,
      );
      return TransactionModel.fromJson(response.data);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to update transaction: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await _apiClient.delete(ApiConstants.transactionById(id));
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to delete transaction: $e');
    }
  }
}
