import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tzdata.initializeTimeZones();
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

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

  static tz.TZDateTime nextNotificationDateTime(
    DateTime dateTime,
  ) {
    final localDateTime = tz.TZDateTime.from(dateTime, tz.local);
    return localDateTime;
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
