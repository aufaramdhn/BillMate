import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../config/app_config.dart';

class OneSignalService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized || AppConfig.oneSignalAppId.isEmpty) {
      return;
    }

    try {
      OneSignal.initialize(AppConfig.oneSignalAppId);
      await OneSignal.Notifications.requestPermission(false);
      _initialized = true;
    } catch (error) {
      debugPrint('OneSignal initialize skipped: $error');
    }
  }

  static String? get currentPlayerId {
    if (!_initialized) {
      return null;
    }

    return OneSignal.User.pushSubscription.id;
  }
}
