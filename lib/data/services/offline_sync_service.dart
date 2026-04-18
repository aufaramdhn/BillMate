import '../../domain/repositories/bills_repository.dart';
import '../models/bill_model.dart';
import 'offline_bills_cache_service.dart';

class OfflineSyncService {
  const OfflineSyncService(this._repository);

  final BillsRepository _repository;

  Future<void> syncPendingOperations() async {
    final operations = await OfflineBillsCacheService.getQueuedOperations();

    for (final operation in operations) {
      switch (operation.type) {
        case OfflineOperationType.create:
          if (operation.payload == null) {
            continue;
          }
          await _repository.createBill(
            BillModel.fromJson(operation.payload!).toEntity(),
          );
        case OfflineOperationType.update:
          if (operation.payload == null) {
            continue;
          }
          await _repository.updateBill(
            BillModel.fromJson(operation.payload!).toEntity(),
          );
        case OfflineOperationType.delete:
          await _repository.deleteBill(operation.billId);
        case OfflineOperationType.markPaid:
          await _repository.markBillAsPaid(operation.billId);
      }
    }

    await OfflineBillsCacheService.clearQueue();
  }
}
