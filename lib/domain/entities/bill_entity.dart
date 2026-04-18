enum BillCategory {
  listrik,
  air,
  internet,
  cicilan,
  streaming,
  lainnya,
}

enum RecurrenceInterval {
  monthly,
  yearly,
}

class BillEntity {
  const BillEntity({
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

  BillEntity copyWith({
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
    return BillEntity(
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is BillEntity &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.amount == amount &&
        other.category == category &&
        other.dueDate == dueDate &&
        other.isPaid == isPaid &&
        other.isRecurring == isRecurring &&
        other.recurrenceInterval == recurrenceInterval &&
        other.notes == notes &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      title,
      amount,
      category,
      dueDate,
      isPaid,
      isRecurring,
      recurrenceInterval,
      notes,
      createdAt,
      updatedAt,
    );
  }
}

BillCategory billCategoryFromString(String rawValue) {
  final value = rawValue.trim().toLowerCase();
  return BillCategory.values.firstWhere(
    (category) => category.name == value,
    orElse: () => throw FormatException('Unsupported bill category: $rawValue'),
  );
}

RecurrenceInterval recurrenceIntervalFromString(String rawValue) {
  final value = rawValue.trim().toLowerCase();
  return RecurrenceInterval.values.firstWhere(
    (interval) => interval.name == value,
    orElse: () => throw FormatException('Unsupported recurrence interval: $rawValue'),
  );
}
