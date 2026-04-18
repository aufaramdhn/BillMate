import 'package:billmate/data/services/notification_service.dart';
import 'package:billmate/domain/entities/bill_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationService', () {
    test('builds H-3, H-1, H-0 reminder schedules for future due date', () {
      final bill = BillEntity(
        id: 'bill-001',
        userId: 'user-001',
        title: 'Listrik Bulanan',
        amount: 250000,
        category: BillCategory.listrik,
        dueDate: DateTime(2026, 4, 30),
        isPaid: false,
        isRecurring: true,
        recurrenceInterval: RecurrenceInterval.monthly,
        notes: null,
        createdAt: DateTime(2026, 4, 1),
        updatedAt: DateTime(2026, 4, 1),
      );

      final reminders = NotificationService.buildReminderSchedules(
        bill,
        now: DateTime(2026, 4, 20, 8),
      );

      expect(reminders.length, 3);
      expect(reminders[0].triggerType, NotificationTriggerType.h3);
      expect(reminders[1].triggerType, NotificationTriggerType.h1);
      expect(reminders[2].triggerType, NotificationTriggerType.h0);
    });

    test('filters out reminder schedules that are already in the past', () {
      final bill = BillEntity(
        id: 'bill-002',
        userId: 'user-001',
        title: 'Air Bulanan',
        amount: 175000,
        category: BillCategory.air,
        dueDate: DateTime(2026, 4, 10),
        isPaid: false,
        isRecurring: false,
        recurrenceInterval: null,
        notes: null,
        createdAt: DateTime(2026, 4, 1),
        updatedAt: DateTime(2026, 4, 1),
      );

      final reminders = NotificationService.buildReminderSchedules(
        bill,
        now: DateTime(2026, 4, 12, 8),
      );

      expect(reminders, isEmpty);
    });
  });
}
