import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/bill_entity.dart';

enum NotificationTriggerType { h3, h1, h0 }

class BillReminderSchedule {
  const BillReminderSchedule({
    required this.triggerType,
    required this.notificationId,
    required this.scheduleTime,
    required this.title,
    required this.body,
  });

  final NotificationTriggerType triggerType;
  final int notificationId;
  final tz.TZDateTime scheduleTime;
  final String title;
  final String body;
}

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static bool _tzInitialized = false;

  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _ensureTimeZoneReady();
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      // Fallback to UTC when local timezone cannot be resolved.
      tz.setLocalLocation(tz.UTC);
    }

    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsDarwin = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await _plugin.initialize(initializationSettings);
    _initialized = true;
  }

  static List<BillReminderSchedule> buildReminderSchedules(
    BillEntity bill, {
    DateTime? now,
  }) {
    _ensureTimeZoneReady();
    final reference = now ?? DateTime.now();
    final dueAtNineAm = DateTime(
      bill.dueDate.year,
      bill.dueDate.month,
      bill.dueDate.day,
      9,
    );

    final scheduleCandidates = <BillReminderSchedule>[
      _buildSchedule(bill, NotificationTriggerType.h3, dueAtNineAm.subtract(const Duration(days: 3))),
      _buildSchedule(bill, NotificationTriggerType.h1, dueAtNineAm.subtract(const Duration(days: 1))),
      _buildSchedule(bill, NotificationTriggerType.h0, dueAtNineAm),
    ];

    return scheduleCandidates
        .where((item) => item.scheduleTime.isAfter(tz.TZDateTime.from(reference, tz.local)))
        .toList();
  }

  static Future<List<BillReminderSchedule>> scheduleBillReminders(
    BillEntity bill, {
    DateTime? now,
  }) async {
    await initialize();
    final schedules = buildReminderSchedules(bill, now: now);

    for (final schedule in schedules) {
      await _plugin.zonedSchedule(
        schedule.notificationId,
        schedule.title,
        schedule.body,
        schedule.scheduleTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'bill_due_reminders',
            'Bill Due Reminders',
            channelDescription: 'Pengingat jatuh tempo tagihan H-3, H-1, H-0',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    return schedules;
  }

  static Future<List<BillReminderSchedule>> rescheduleBillReminders(
    BillEntity bill, {
    DateTime? now,
  }) async {
    await cancelBillReminders(bill.id);
    return scheduleBillReminders(bill, now: now);
  }

  static Future<void> cancelBillReminders(String billId) async {
    for (final trigger in NotificationTriggerType.values) {
      await _plugin.cancel(notificationIdFor(billId, trigger));
    }
  }

  static int notificationIdFor(String billId, NotificationTriggerType triggerType) {
    final seed = '$billId-${triggerType.name}';
    return seed.hashCode & 0x7fffffff;
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static BillReminderSchedule _buildSchedule(
    BillEntity bill,
    NotificationTriggerType triggerType,
    DateTime scheduleDateTime,
  ) {
    final scheduleTime = tz.TZDateTime.from(scheduleDateTime, tz.local);
    final triggerLabel = switch (triggerType) {
      NotificationTriggerType.h3 => 'H-3',
      NotificationTriggerType.h1 => 'H-1',
      NotificationTriggerType.h0 => 'H-0',
    };

    return BillReminderSchedule(
      triggerType: triggerType,
      notificationId: notificationIdFor(bill.id, triggerType),
      scheduleTime: scheduleTime,
      title: 'Pengingat Tagihan $triggerLabel',
      body: '${bill.title} jatuh tempo pada ${bill.dueDate.toLocal().toIso8601String().split('T').first}.',
    );
  }

  static void _ensureTimeZoneReady() {
    if (_tzInitialized) {
      return;
    }
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.UTC);
    _tzInitialized = true;
  }
}
