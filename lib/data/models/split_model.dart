import 'package:billmate/domain/entities/split_group_entity.dart';
import 'package:billmate/domain/entities/split_member_entity.dart';

class SplitGroupModel {
  SplitGroupModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  final String id;
  final String userId;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory SplitGroupModel.fromJson(Map<String, dynamic> json) {
    return SplitGroupModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  SplitGroupEntity toEntity() {
    return SplitGroupEntity(
      id: id,
      userId: userId,
      name: name,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory SplitGroupModel.fromEntity(SplitGroupEntity entity) {
    return SplitGroupModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      description: entity.description,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

class SplitMemberModel {
  SplitMemberModel({
    required this.id,
    required this.groupId,
    required this.name,
    required this.sharePercentage,
    required this.createdAt,
    required this.updatedAt,
    this.userId,
    this.email,
    this.isPaid = false,
    this.paidAt,
  });

  final String id;
  final String groupId;
  final String? userId;
  final String name;
  final String? email;
  final double sharePercentage;
  final bool isPaid;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory SplitMemberModel.fromJson(Map<String, dynamic> json) {
    return SplitMemberModel(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      userId: json['user_id'] as String?,
      name: json['name'] as String,
      email: json['email'] as String?,
      sharePercentage: (json['share_percentage'] as num).toDouble(),
      isPaid: json['is_paid'] as bool? ?? false,
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'user_id': userId,
      'name': name,
      'email': email,
      'share_percentage': sharePercentage,
      'is_paid': isPaid,
      'paid_at': paidAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  SplitMemberEntity toEntity() {
    return SplitMemberEntity(
      id: id,
      groupId: groupId,
      userId: userId,
      name: name,
      email: email,
      sharePercentage: sharePercentage,
      isPaid: isPaid,
      paidAt: paidAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory SplitMemberModel.fromEntity(SplitMemberEntity entity) {
    return SplitMemberModel(
      id: entity.id,
      groupId: entity.groupId,
      userId: entity.userId,
      name: entity.name,
      email: entity.email,
      sharePercentage: entity.sharePercentage,
      isPaid: entity.isPaid,
      paidAt: entity.paidAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
