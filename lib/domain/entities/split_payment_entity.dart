class SplitPaymentEntity {
  const SplitPaymentEntity({
    required this.id,
    required this.billId,
    required this.memberId,
    required this.amountOwed,
    required this.createdAt,
    required this.updatedAt,
    this.amountPaid = 0,
    this.status = 'unpaid',
  });

  final String id;
  final String billId;
  final String memberId;
  final double amountOwed;
  final double amountPaid;
  final String status; // 'unpaid', 'partial', 'paid'
  final DateTime createdAt;
  final DateTime updatedAt;

  SplitPaymentEntity copyWith({
    String? id,
    String? billId,
    String? memberId,
    double? amountOwed,
    double? amountPaid,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SplitPaymentEntity(
      id: id ?? this.id,
      billId: billId ?? this.billId,
      memberId: memberId ?? this.memberId,
      amountOwed: amountOwed ?? this.amountOwed,
      amountPaid: amountPaid ?? this.amountPaid,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is SplitPaymentEntity &&
        other.id == id &&
        other.billId == billId &&
        other.memberId == memberId &&
        other.amountOwed == amountOwed &&
        other.amountPaid == amountPaid &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      billId,
      memberId,
      amountOwed,
      amountPaid,
      status,
      createdAt,
      updatedAt,
    );
  }
}
