class AppConstants {
  AppConstants._();

  static const String appName = 'Registro Mis Gastos';
  static const String appVersion = '1.0.0';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String currencyKey = 'default_currency';
  static const String pendingActionsKey = 'pending_actions';

  // Currencies
  static const String currencyUyu = 'UYU';
  static const String currencyUsd = 'USD';

  // Transaction types
  static const String typeIncome = 'INCOME';
  static const String typeExpense = 'EXPENSE';

  // Date formats
  static const String dateFormatApi = 'yyyy-MM-dd';
  static const String dateFormatDisplay = 'dd/MM/yyyy';
  static const String dateFormatMonthYear = 'MMMM yyyy';
  static const String timeFormatDisplay = 'HH:mm';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxTransactionNameLength = 50;
  static const int maxAmountDigits = 12;
  static const int maxAmountDecimals = 2;

  // UI
  static const Duration snackBarDuration = Duration(seconds: 4);
  static const Duration undoDuration = Duration(seconds: 5);
  static const Duration animationDuration = Duration(milliseconds: 200);
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
}
