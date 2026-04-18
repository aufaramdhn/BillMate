import '../../domain/entities/bill_entity.dart';

class BillModel {
  const BillModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.category,
    required this.dueDate,
    required this.isPaid,
    required this.isRecurring,
    required this.createdAt,
    required this.updatedAt,
    this.recurrenceInterval,
    this.notes,
  });

  final String id;
  final String userId;
  final String title;
  final double amount;
  final BillCategory category;
  final DateTime dueDate;
  final bool isPaid;
  final bool isRecurring;
  final RecurrenceInterval? recurrenceInterval;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      amount: _toDouble(json['amount']),
      category: billCategoryFromString(json['category'] as String),
      dueDate: _parseDate(json['due_date']),
      isPaid: json['is_paid'] as bool? ?? false,
      isRecurring: json['is_recurring'] as bool? ?? false,
      recurrenceInterval: (json['recurrence_interval'] as String?) == null
          ? null
          : recurrenceIntervalFromString(json['recurrence_interval'] as String),
      notes: json['notes'] as String?,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  factory BillModel.fromEntity(BillEntity entity) {
    return BillModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      amount: entity.amount,
      category: entity.category,
      dueDate: entity.dueDate,
      isPaid: entity.isPaid,
      isRecurring: entity.isRecurring,
      recurrenceInterval: entity.recurrenceInterval,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  BillEntity toEntity() {
    return BillEntity(
      id: id,
      userId: userId,
      title: title,
      amount: amount,
      category: category,
      dueDate: dueDate,
      isPaid: isPaid,
      isRecurring: isRecurring,
      recurrenceInterval: recurrenceInterval,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'user_id': userId,
      'title': title,
      'amount': amount,
      'category': category.name,
      'due_date': _formatDateOnly(dueDate),
      'is_paid': isPaid,
      'is_recurring': isRecurring,
      'recurrence_interval': recurrenceInterval?.name,
      'notes': notes,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }

  BillModel copyWith({
    String? id,
    String? userId,
    String? title,
    double? amount,
    BillCategory? category,
    DateTime? dueDate,
    bool? isPaid,
    bool? isRecurring,
    RecurrenceInterval? recurrenceInterval,
    bool clearRecurrenceInterval = false,
    String? notes,
    bool clearNotes = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BillModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      isPaid: isPaid ?? this.isPaid,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceInterval: clearRecurrenceInterval
          ? null
          : recurrenceInterval ?? this.recurrenceInterval,
      notes: clearNotes ? null : notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.parse(value);
    }
    throw FormatException('Unsupported numeric value: $value');
  }

  static DateTime _parseDate(dynamic rawValue) {
    if (rawValue is DateTime) {
      return rawValue;
    }
    if (rawValue is String) {
      return DateTime.parse(rawValue);
    }
    throw FormatException('Unsupported date value: $rawValue');
  }

  static String _formatDateOnly(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
