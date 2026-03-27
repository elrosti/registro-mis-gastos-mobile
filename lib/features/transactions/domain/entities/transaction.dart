import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String id;
  final String type;
  final String shortName;
  final String? description;
  final double amount;
  final String currency;
  final DateTime transactionDate;
  final String? categoryId;
  final Category? category;
  final List<Tag>? tags;
  final DateTime? createdAt;
  final DateTime? lastModifiedAt;

  const Transaction({
    required this.id,
    required this.type,
    required this.shortName,
    this.description,
    required this.amount,
    required this.currency,
    required this.transactionDate,
    this.categoryId,
    this.category,
    this.tags,
    this.createdAt,
    this.lastModifiedAt,
  });

  bool get isIncome => type == 'INCOME';
  bool get isExpense => type == 'EXPENSE';

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
        category,
        tags,
        createdAt,
        lastModifiedAt,
      ];
}

class Category extends Equatable {
  final String id;
  final String name;
  final String type;
  final String? icon;
  final String? color;
  final String? parentId;
  final bool isHidden;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    this.color,
    this.parentId,
    this.isHidden = false,
  });

  @override
  List<Object?> get props => [id, name, type, icon, color, parentId, isHidden];
}

class Tag extends Equatable {
  final String id;
  final String name;

  const Tag({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}
