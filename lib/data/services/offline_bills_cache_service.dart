import 'package:hive_flutter/hive_flutter.dart';

import '../models/bill_model.dart';
import '../../domain/entities/bill_entity.dart';

enum OfflineOperationType { create, update, delete, markPaid }

class OfflineOperation {
  const OfflineOperation({
    required this.type,
    required this.billId,
    required this.createdAt,
    this.payload,
  });

  final OfflineOperationType type;
  final String billId;
  final DateTime createdAt;
  final Map<String, dynamic>? payload;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type.name,
      'bill_id': billId,
      'created_at': createdAt.toIso8601String(),
      'payload': payload,
    };
  }

  factory OfflineOperation.fromJson(Map<dynamic, dynamic> raw) {
    return OfflineOperation(
      type: OfflineOperationType.values.firstWhere(
        (item) => item.name == raw['type'],
      ),
      billId: raw['bill_id'] as String,
      createdAt: DateTime.parse(raw['created_at'] as String),
      payload: (raw['payload'] as Map?)?.cast<String, dynamic>(),
    );
  }
}

class OfflineBillsCacheService {
  OfflineBillsCacheService._();

  static const String _billsBoxName = 'offline_bills_cache';
  static const String _queueBoxName = 'offline_bills_queue';
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    try {
      await Hive.initFlutter();
    } catch (_) {
      // Ignore when Hive is already initialized manually in tests.
    }

    if (!Hive.isBoxOpen(_billsBoxName)) {
      await Hive.openBox<Map<dynamic, dynamic>>(_billsBoxName);
    }
    if (!Hive.isBoxOpen(_queueBoxName)) {
      await Hive.openBox<Map<dynamic, dynamic>>(_queueBoxName);
    }
    _initialized = true;
  }

  static Future<void> upsertCachedBill(BillEntity bill) async {
    await initialize();
    final box = Hive.box<Map<dynamic, dynamic>>(_billsBoxName);
    await box.put(bill.id, BillModel.fromEntity(bill).toJson());
  }

  static Future<void> removeCachedBill(String billId) async {
    await initialize();
    final box = Hive.box<Map<dynamic, dynamic>>(_billsBoxName);
    await box.delete(billId);
  }

  static Future<List<BillEntity>> getCachedBills() async {
    await initialize();
    final box = Hive.box<Map<dynamic, dynamic>>(_billsBoxName);
    return box.values
        .map((item) => BillModel.fromJson(item.cast<String, dynamic>()).toEntity())
        .toList();
  }

  static Future<void> enqueueOperation(OfflineOperation operation) async {
    await initialize();
    final box = Hive.box<Map<dynamic, dynamic>>(_queueBoxName);
    await box.add(operation.toJson());
  }

  static Future<List<OfflineOperation>> getQueuedOperations() async {
    await initialize();
    final box = Hive.box<Map<dynamic, dynamic>>(_queueBoxName);
    return box.values.map(OfflineOperation.fromJson).toList();
  }

  static Future<void> clearQueue() async {
    await initialize();
    final box = Hive.box<Map<dynamic, dynamic>>(_queueBoxName);
    await box.clear();
  }

  static Future<void> clearAll() async {
    await initialize();
    await Hive.box<Map<dynamic, dynamic>>(_billsBoxName).clear();
    await Hive.box<Map<dynamic, dynamic>>(_queueBoxName).clear();
  }
}
