import 'package:billmate/domain/entities/bill_entity.dart';

class BillRecapMonth {
  const BillRecapMonth({
    required this.year,
    required this.month,
    required this.totalAmount,
    required this.totalBillCount,
    required this.paidAmount,
    required this.unpaidAmount,
    required this.paidCount,
    required this.unpaidCount,
    required this.categoryBreakdown,
  });

  final int year;
  final int month;
  final double totalAmount;
  final int totalBillCount;
  final double paidAmount;
  final double unpaidAmount;
  final int paidCount;
  final int unpaidCount;
  final Map<BillCategory, CategorySummary> categoryBreakdown;

  BillRecapMonth copyWith({
    int? year,
    int? month,
    double? totalAmount,
    int? totalBillCount,
    double? paidAmount,
    double? unpaidAmount,
    int? paidCount,
    int? unpaidCount,
    Map<BillCategory, CategorySummary>? categoryBreakdown,
  }) {
    return BillRecapMonth(
      year: year ?? this.year,
      month: month ?? this.month,
      totalAmount: totalAmount ?? this.totalAmount,
      totalBillCount: totalBillCount ?? this.totalBillCount,
      paidAmount: paidAmount ?? this.paidAmount,
      unpaidAmount: unpaidAmount ?? this.unpaidAmount,
      paidCount: paidCount ?? this.paidCount,
      unpaidCount: unpaidCount ?? this.unpaidCount,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is BillRecapMonth &&
        other.year == year &&
        other.month == month &&
        other.totalAmount == totalAmount &&
        other.totalBillCount == totalBillCount &&
        other.paidAmount == paidAmount &&
        other.unpaidAmount == unpaidAmount &&
        other.paidCount == paidCount &&
        other.unpaidCount == unpaidCount &&
        other.categoryBreakdown == categoryBreakdown;
  }

  @override
  int get hashCode {
    return Object.hash(
      year,
      month,
      totalAmount,
      totalBillCount,
      paidAmount,
      unpaidAmount,
      paidCount,
      unpaidCount,
      categoryBreakdown,
    );
  }
}

class CategorySummary {
  const CategorySummary({
    required this.category,
    required this.totalAmount,
    required this.count,
    required this.paidAmount,
    required this.unpaidAmount,
  });

  final BillCategory category;
  final double totalAmount;
  final int count;
  final double paidAmount;
  final double unpaidAmount;

  CategorySummary copyWith({
    BillCategory? category,
    double? totalAmount,
    int? count,
    double? paidAmount,
    double? unpaidAmount,
  }) {
    return CategorySummary(
      category: category ?? this.category,
      totalAmount: totalAmount ?? this.totalAmount,
      count: count ?? this.count,
      paidAmount: paidAmount ?? this.paidAmount,
      unpaidAmount: unpaidAmount ?? this.unpaidAmount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is CategorySummary &&
        other.category == category &&
        other.totalAmount == totalAmount &&
        other.count == count &&
        other.paidAmount == paidAmount &&
        other.unpaidAmount == unpaidAmount;
  }

  @override
  int get hashCode {
    return Object.hash(
      category,
      totalAmount,
      count,
      paidAmount,
      unpaidAmount,
    );
  }
}
