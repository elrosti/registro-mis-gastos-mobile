class MonthlySummary {
  final String period;
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final List<CategorySummary> incomeByCategory;
  final List<CategorySummary> expensesByCategory;

  const MonthlySummary({
    required this.period,
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    this.incomeByCategory = const [],
    this.expensesByCategory = const [],
  });

  factory MonthlySummary.fromJson(Map<String, dynamic> json) {
    return MonthlySummary(
      period: json['period'] as String? ?? '',
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0.0,
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0.0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      incomeByCategory: (json['incomeByCategory'] as List<dynamic>?)
              ?.map((e) => CategorySummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      expensesByCategory: (json['expensesByCategory'] as List<dynamic>?)
              ?.map((e) => CategorySummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CategorySummary {
  final String? categoryId;
  final String categoryName;
  final String type;
  final String currency;
  final double total;
  final int transactionCount;
  final double percentage;

  const CategorySummary({
    this.categoryId,
    required this.categoryName,
    required this.type,
    required this.currency,
    required this.total,
    required this.transactionCount,
    required this.percentage,
  });

  factory CategorySummary.fromJson(Map<String, dynamic> json) {
    return CategorySummary(
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String? ?? '',
      type: json['type'] as String? ?? '',
      currency: json['currency'] as String? ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      transactionCount: json['transactionCount'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
