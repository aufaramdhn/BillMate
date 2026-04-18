import 'package:billmate/domain/entities/bill_entity.dart';
import 'package:billmate/domain/entities/bill_recap_entity.dart';
import 'package:billmate/domain/repositories/bill_recap_repository.dart';
import 'package:billmate/domain/repositories/bills_repository.dart';

class InMemoryBillRecapRepository implements BillRecapRepository {
  InMemoryBillRecapRepository(this._billsRepository);

  final BillsRepository _billsRepository;

  @override
  Future<BillRecapMonth> getMonthlyRecap(int year, int month) async {
    final allBills = await _billsRepository.getBills();
    return _calculateMonthlyRecap(allBills, year, month);
  }

  @override
  Future<List<BillRecapMonth>> getRecapRange({
    required int startYear,
    required int startMonth,
    required int endYear,
    required int endMonth,
  }) async {
    final allBills = await _billsRepository.getBills();
    final recaps = <BillRecapMonth>[];

    var currentYear = startYear;
    var currentMonth = startMonth;

    while (currentYear < endYear || (currentYear == endYear && currentMonth <= endMonth)) {
      final recap = _calculateMonthlyRecap(allBills, currentYear, currentMonth);
      recaps.add(recap);

      currentMonth++;
      if (currentMonth > 12) {
        currentMonth = 1;
        currentYear++;
      }
    }

    return recaps;
  }

  @override
  Future<BillRecapMonth> getCurrentMonthRecap() async {
    final now = DateTime.now();
    return getMonthlyRecap(now.year, now.month);
  }

  BillRecapMonth _calculateMonthlyRecap(
    List<BillEntity> allBills,
    int year,
    int month,
  ) {
    final billsInMonth = allBills.where((bill) {
      return bill.dueDate.year == year && bill.dueDate.month == month;
    }).toList();

    double totalAmount = 0;
    double paidAmount = 0;
    double unpaidAmount = 0;
    int paidCount = 0;
    int unpaidCount = 0;

    final categoryMap = <BillCategory, CategorySummary>{};

    for (final bill in billsInMonth) {
      totalAmount += bill.amount;

      if (bill.isPaid) {
        paidAmount += bill.amount;
        paidCount++;
      } else {
        unpaidAmount += bill.amount;
        unpaidCount++;
      }

      final category = bill.category;
      final existing = categoryMap[category];

      if (existing == null) {
        categoryMap[category] = CategorySummary(
          category: category,
          totalAmount: bill.amount,
          count: 1,
          paidAmount: bill.isPaid ? bill.amount : 0,
          unpaidAmount: bill.isPaid ? 0 : bill.amount,
        );
      } else {
        categoryMap[category] = existing.copyWith(
          totalAmount: existing.totalAmount + bill.amount,
          count: existing.count + 1,
          paidAmount: existing.paidAmount + (bill.isPaid ? bill.amount : 0),
          unpaidAmount: existing.unpaidAmount + (bill.isPaid ? 0 : bill.amount),
        );
      }
    }

    return BillRecapMonth(
      year: year,
      month: month,
      totalAmount: totalAmount,
      totalBillCount: billsInMonth.length,
      paidAmount: paidAmount,
      unpaidAmount: unpaidAmount,
      paidCount: paidCount,
      unpaidCount: unpaidCount,
      categoryBreakdown: categoryMap,
    );
  }
}
