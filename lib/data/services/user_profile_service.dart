import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'onesignal_service.dart';
import 'supabase_service.dart';

class UserProfileService {
  static Future<void> syncOneSignalPlayerId(String userId) async {
    final playerId = OneSignalService.currentPlayerId;
    if (playerId == null || playerId.isEmpty) {
      return;
    }

    try {
      await SupabaseService.client.from('users').upsert(
        {
          'id': userId,
          'onesignal_player_id': playerId,
        },
        onConflict: 'id',
      );
    } on PostgrestException catch (error) {
      debugPrint('OneSignal player id sync failed: ${error.message}');
    }
  }
}
