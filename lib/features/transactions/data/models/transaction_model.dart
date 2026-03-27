import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.type,
    required super.shortName,
    super.description,
    required super.amount,
    required super.currency,
    required super.transactionDate,
    super.categoryId,
    super.category,
    super.tags,
    super.createdAt,
    super.lastModifiedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? 'EXPENSE',
      shortName: json['shortName'] ?? json['short_name'] ?? '',
      description: json['description'],
      amount: (json['amount'] is String)
          ? double.parse(json['amount'])
          : (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'UYU',
      transactionDate: json['transactionDate'] != null ||
              json['transaction_date'] != null
          ? DateTime.parse(json['transactionDate'] ?? json['transaction_date'])
          : DateTime.now(),
      categoryId: json['categoryId']?.toString() ?? json['category_id']?.toString(),
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'])
          : null,
      tags: json['tags'] != null
          ? (json['tags'] as List)
              .map((t) => TagModel.fromJson(t))
              .toList()
          : null,
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.parse(json['createdAt'] ?? json['created_at'])
          : null,
      lastModifiedAt: json['lastModifiedAt'] != null ||
              json['last_modified_at'] != null
          ? DateTime.parse(json['lastModifiedAt'] ?? json['last_modified_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'shortName': shortName,
      'description': description,
      'amount': amount,
      'currency': currency,
      'transactionDate': transactionDate.toIso8601String(),
      'categoryId': categoryId,
      'tags': tags?.map((t) => {'id': t.id, 'name': t.name}).toList(),
    };
  }
}

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.type,
    super.icon,
    super.color,
    super.parentId,
    super.isHidden,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'EXPENSE',
      icon: json['icon'],
      color: json['color'],
      parentId: json['parentId']?.toString() ?? json['parent_id']?.toString(),
      isHidden: json['isHidden'] ?? json['is_hidden'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'parentId': parentId,
      'isHidden': isHidden,
    };
  }
}

class TagModel extends Tag {
  const TagModel({
    required super.id,
    required super.name,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
