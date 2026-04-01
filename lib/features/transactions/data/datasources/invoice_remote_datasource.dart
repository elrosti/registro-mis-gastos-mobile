import 'dart:developer' as developer;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/transaction_model.dart';

class InvoiceProcessingResult {
  final bool success;
  final String? message;
  final TransactionModel? transaction;
  final String? error;
  final InvoiceAnalysisResult? analysis;

  InvoiceProcessingResult({
    required this.success,
    this.message,
    this.transaction,
    this.error,
    this.analysis,
  });

  factory InvoiceProcessingResult.fromJson(Map<String, dynamic> json) {
    final success = json['success'] as bool? ?? false;

    TransactionModel? transaction;
    if (json['transaction'] != null) {
      transaction = TransactionModel.fromJson(json['transaction']);
    }

    InvoiceAnalysisResult? analysis;
    if (json['analysis'] != null) {
      analysis = InvoiceAnalysisResult.fromJson(json['analysis']);
    }

    return InvoiceProcessingResult(
      success: success,
      message: json['message'] as String?,
      transaction: transaction,
      error: json['error'] as String?,
      analysis: analysis,
    );
  }
}

class InvoiceAnalysisResult {
  final String merchantName;
  final double totalAmount;
  final String currency;
  final String date;
  final String suggestedCategory;
  final double confidence;

  InvoiceAnalysisResult({
    required this.merchantName,
    required this.totalAmount,
    required this.currency,
    required this.date,
    required this.suggestedCategory,
    required this.confidence,
  });

  factory InvoiceAnalysisResult.fromJson(Map<String, dynamic> json) {
    return InvoiceAnalysisResult(
      merchantName: json['merchantName'] as String? ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'UYU',
      date: json['date'] as String? ?? '',
      suggestedCategory: json['suggestedCategory'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

abstract class InvoiceRemoteDataSource {
  Future<InvoiceProcessingResult> processInvoiceImage({
    required String filePath,
    required String fileName,
    void Function(int, int)? onSendProgress,
  });
}

class InvoiceRemoteDataSourceImpl implements InvoiceRemoteDataSource {
  final ApiClient _apiClient;

  InvoiceRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<InvoiceProcessingResult> processInvoiceImage({
    required String filePath,
    required String fileName,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final response = await _apiClient.uploadFile(
        ApiConstants.invoices,
        filePath: filePath,
        fileName: fileName,
        fieldName: 'file',
        onSendProgress: onSendProgress,
      );

      final data = response.data as Map<String, dynamic>;
      developer.log('processInvoiceImage response: $data',
          name: 'InvoiceRemoteDataSource');

      return InvoiceProcessingResult.fromJson(data);
    } on ServerException {
      rethrow;
    } catch (e) {
      developer.log(
          'Exception in processInvoiceImage: type=${e.runtimeType}, message=$e',
          name: 'InvoiceRemoteDataSource');
      throw ServerException(message: 'Failed to process invoice image: $e');
    }
  }
}
