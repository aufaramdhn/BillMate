import '../../domain/entities/bill_entity.dart';
import 'notification_service.dart';

enum NotificationLogStatus { scheduled, sent, cancelled }

class NotificationLogEntry {
  const NotificationLogEntry({
    required this.billId,
    required this.triggerType,
    required this.status,
    required this.timestamp,
  });

  final String billId;
  final NotificationTriggerType triggerType;
  final NotificationLogStatus status;
  final DateTime timestamp;
}

class NotificationLogService {
  NotificationLogService._();

  static final List<NotificationLogEntry> _entries = <NotificationLogEntry>[];

  static List<NotificationLogEntry> get entries =>
      List<NotificationLogEntry>.unmodifiable(_entries);

  static void recordScheduled(
    BillEntity bill,
    List<BillReminderSchedule> schedules,
  ) {
    final now = DateTime.now();
    for (final schedule in schedules) {
      _entries.add(
        NotificationLogEntry(
          billId: bill.id,
          triggerType: schedule.triggerType,
          status: NotificationLogStatus.scheduled,
          timestamp: now,
        ),
      );
    }
  }

  static void recordCancelled(String billId) {
    final now = DateTime.now();
    for (final trigger in NotificationTriggerType.values) {
      _entries.add(
        NotificationLogEntry(
          billId: billId,
          triggerType: trigger,
          status: NotificationLogStatus.cancelled,
          timestamp: now,
        ),
      );
    }
  }

  static void clear() {
    _entries.clear();
  }
}
