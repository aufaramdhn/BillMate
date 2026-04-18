import '../entities/bill_entity.dart';

abstract class BillsRepository {
  Future<List<BillEntity>> getBills();

  Future<BillEntity> createBill(BillEntity bill);

  Future<BillEntity> updateBill(BillEntity bill);

  Future<void> deleteBill(String billId);

  Future<BillEntity> markBillAsPaid(String billId, {DateTime? paidAt});
}
