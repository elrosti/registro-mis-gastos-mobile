import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api';

  // Auth endpoints
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authMe = '/auth/me';
  static const String authOAuthUrl = '/auth/oauth/url';
  static const String authOAuthToken = '/auth/oauth/token';

  // Transaction endpoints
  static const String transactions = '/transactions';
  static String transactionById(String id) => '/transactions/$id';

  // Category endpoints
  static const String categories = '/categories';
  static const String categoriesMostUsed = '/categories/most-used';

  // Report endpoints
  static const String reportsMonthly = '/reports/monthly';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;
}
