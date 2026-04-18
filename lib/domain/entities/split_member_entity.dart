enum PaymentStatus {
  unpaid,
  partial,
  paid,
}

class SplitMemberEntity {
  const SplitMemberEntity({
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

  SplitMemberEntity copyWith({
    String? id,
    String? groupId,
    String? userId,
    bool clearUserId = false,
    String? name,
    String? email,
    bool clearEmail = false,
    double? sharePercentage,
    bool? isPaid,
    DateTime? paidAt,
    bool clearPaidAt = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SplitMemberEntity(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      userId: clearUserId ? null : userId ?? this.userId,
      name: name ?? this.name,
      email: clearEmail ? null : email ?? this.email,
      sharePercentage: sharePercentage ?? this.sharePercentage,
      isPaid: isPaid ?? this.isPaid,
      paidAt: clearPaidAt ? null : paidAt ?? this.paidAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is SplitMemberEntity &&
        other.id == id &&
        other.groupId == groupId &&
        other.userId == userId &&
        other.name == name &&
        other.email == email &&
        other.sharePercentage == sharePercentage &&
        other.isPaid == isPaid &&
        other.paidAt == paidAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      groupId,
      userId,
      name,
      email,
      sharePercentage,
      isPaid,
      paidAt,
      createdAt,
      updatedAt,
    );
  }
}
