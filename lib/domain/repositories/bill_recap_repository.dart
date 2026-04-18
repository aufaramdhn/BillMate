import 'package:billmate/domain/entities/bill_recap_entity.dart';

abstract class BillRecapRepository {
  /// Get monthly recap for a specific year and month
  Future<BillRecapMonth> getMonthlyRecap(int year, int month);

  /// Get list of recaps for a range of months (e.g., last 12 months)
  Future<List<BillRecapMonth>> getRecapRange({
    required int startYear,
    required int startMonth,
    required int endYear,
    required int endMonth,
  });

  /// Get current month recap
  Future<BillRecapMonth> getCurrentMonthRecap();
}
