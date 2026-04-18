import '../../domain/entities/bill_entity.dart';
import '../../domain/repositories/bills_repository.dart';

class InMemoryBillsRepository implements BillsRepository {
  final List<BillEntity> _items = <BillEntity>[];

  @override
  Future<List<BillEntity>> getBills() async {
    return List<BillEntity>.unmodifiable(_items);
  }

  @override
  Future<BillEntity> createBill(BillEntity bill) async {
    _items.add(bill);
    return bill;
  }

  @override
  Future<BillEntity> updateBill(BillEntity bill) async {
    final index = _items.indexWhere((item) => item.id == bill.id);
    if (index < 0) {
      throw StateError('Bill with id ${bill.id} was not found.');
    }
    _items[index] = bill;
    return bill;
  }

  @override
  Future<void> deleteBill(String billId) async {
    _items.removeWhere((item) => item.id == billId);
  }

  @override
  Future<BillEntity> markBillAsPaid(String billId, {DateTime? paidAt}) async {
    final index = _items.indexWhere((item) => item.id == billId);
    if (index < 0) {
      throw StateError('Bill with id $billId was not found.');
    }

    final now = paidAt ?? DateTime.now();
    final updated = _items[index].copyWith(
      isPaid: true,
      updatedAt: now,
    );
    _items[index] = updated;
    return updated;
  }
}
