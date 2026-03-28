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
      type: json['type']?.toString() ?? 'EXPENSE',
      shortName:
          json['shortName']?.toString() ?? json['short_name']?.toString() ?? '',
      description: json['description']?.toString(),
      amount: (json['amount'] is String)
          ? double.tryParse(json['amount'].toString()) ?? 0.0
          : (json['amount'] is num)
              ? json['amount'].toDouble()
              : 0.0,
      currency: json['currency']?.toString() ?? 'UYU',
      transactionDate:
          json['transactionDate'] != null || json['transaction_date'] != null
              ? DateTime.tryParse(json['transactionDate']?.toString() ??
                      json['transaction_date']?.toString() ??
                      '') ??
                  DateTime.now()
              : DateTime.now(),
      categoryId:
          json['categoryId']?.toString() ?? json['category_id']?.toString(),
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      tags: json['tags'] != null
          ? (json['tags'] as List)
              .map((t) => TagModel.fromJson(t as Map<String, dynamic>))
              .toList()
          : null,
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.tryParse(json['createdAt']?.toString() ??
              json['created_at']?.toString() ??
              '')
          : null,
      lastModifiedAt:
          json['lastModifiedAt'] != null || json['last_modified_at'] != null
              ? DateTime.tryParse(json['lastModifiedAt']?.toString() ??
                  json['last_modified_at']?.toString() ??
                  '')
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
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'EXPENSE',
      icon: json['icon']?.toString(),
      color: json['color']?.toString(),
      parentId: json['parentId']?.toString() ?? json['parent_id']?.toString(),
      isHidden:
          json['isHidden'] as bool? ?? json['is_hidden'] as bool? ?? false,
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
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
