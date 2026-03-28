import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/transaction_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<List<CategoryModel>> getMostUsedCategories();
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiClient _apiClient;

  CategoryRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiClient.get(ApiConstants.categories);
      final data = response.data;
      
      if (data is List) {
        return data.map((json) => CategoryModel.fromJson(json)).toList();
      }
      
      return [];
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch categories: $e');
    }
  }

  @override
  Future<List<CategoryModel>> getMostUsedCategories() async {
    try {
      final response = await _apiClient.get(ApiConstants.categoriesMostUsed);
      final data = response.data;
      
      if (data is List) {
        return data.map((json) => CategoryModel.fromJson(json)).toList();
      }
      
      return [];
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch most used categories: $e');
    }
  }
}
