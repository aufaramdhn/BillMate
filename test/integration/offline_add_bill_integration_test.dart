import 'dart:io';

import 'package:billmate/data/repositories/in_memory_bills_repository.dart';
import 'package:billmate/data/services/offline_bills_cache_service.dart';
import 'package:billmate/data/services/notification_service.dart';
import 'package:billmate/domain/entities/bill_entity.dart';
import 'package:billmate/presentation/blocs/bills/bills_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Offline add bill integration', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('billmate_test_hive_');
      Hive.init(tempDir.path);
      await Hive.openBox<Map<dynamic, dynamic>>('offline_bills_cache');
      await Hive.openBox<Map<dynamic, dynamic>>('offline_bills_queue');
      await OfflineBillsCacheService.clearAll();
    });

    tearDown(() async {
      await Hive.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('queues create operation when app is offline', () async {
      final bloc = BillsBloc(
        InMemoryBillsRepository(),
        isOnline: () => false,
        scheduleReminders: (bill) async => <BillReminderSchedule>[],
        rescheduleReminders: (bill) async => <BillReminderSchedule>[],
        cancelReminders: (billId) async {},
      );

      await bloc.addBill(
        userId: 'offline-user',
        title: 'Internet Kos',
        amount: 300000,
        category: BillCategory.internet,
        dueDate: DateTime(2026, 5, 1),
        isRecurring: true,
        recurrenceInterval: RecurrenceInterval.monthly,
      );

      final queue = await OfflineBillsCacheService.getQueuedOperations();
      expect(queue.length, 1);
      expect(queue.first.type, OfflineOperationType.create);
      expect(queue.first.billId, isNotEmpty);
    });
  });
}
