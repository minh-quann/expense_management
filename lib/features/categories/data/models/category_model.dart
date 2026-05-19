import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_management/features/categories/domain/entities/category.dart';

class CategoryModel extends AppCategory {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.color,
    required super.type,
    super.parentId,
    required super.isSystem,
    required super.isActive,
    required super.order,
    required super.createdAt,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] as String,
      icon: data['icon'] as String,
      color: data['color'] as String,
      type: data['type'] as String,
      parentId: data['parentId'] as String?,
      isSystem: data['isSystem'] as bool? ?? false,
      isActive: data['isActive'] as bool? ?? true,
      order: data['order'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'icon': icon,
      'color': color,
      'type': type,
      'parentId': parentId,
      'isSystem': isSystem,
      'isActive': isActive,
      'order': order,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory CategoryModel.fromEntity(AppCategory entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      icon: entity.icon,
      color: entity.color,
      type: entity.type,
      parentId: entity.parentId,
      isSystem: entity.isSystem,
      isActive: entity.isActive,
      order: entity.order,
      createdAt: entity.createdAt,
    );
  }
}
