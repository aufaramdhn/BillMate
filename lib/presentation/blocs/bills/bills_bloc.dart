import 'package:flutter/foundation.dart';

import '../../../data/models/bill_model.dart';
import '../../../data/services/notification_log_service.dart';
import '../../../data/services/notification_service.dart';
import '../../../data/services/offline_bills_cache_service.dart';
import '../../../data/services/offline_sync_service.dart';
import '../../../domain/entities/bill_entity.dart';
import '../../../domain/repositories/bills_repository.dart';

enum BillPaymentFilter { all, paid, unpaid }

enum BillSortOption { dueDateAsc, dueDateDesc, amountAsc, amountDesc }

@immutable
class BillsState {
  const BillsState({
    required this.allBills,
    required this.visibleBills,
    required this.isLoading,
    required this.paymentFilter,
    required this.sortOption,
    this.selectedCategory,
    this.errorMessage,
  });

  factory BillsState.initial() {
    return const BillsState(
      allBills: <BillEntity>[],
      visibleBills: <BillEntity>[],
      isLoading: false,
      paymentFilter: BillPaymentFilter.all,
      sortOption: BillSortOption.dueDateAsc,
    );
  }

  final List<BillEntity> allBills;
  final List<BillEntity> visibleBills;
  final bool isLoading;
  final BillCategory? selectedCategory;
  final BillPaymentFilter paymentFilter;
  final BillSortOption sortOption;
  final String? errorMessage;

  BillsState copyWith({
    List<BillEntity>? allBills,
    List<BillEntity>? visibleBills,
    bool? isLoading,
    BillCategory? selectedCategory,
    bool clearSelectedCategory = false,
    BillPaymentFilter? paymentFilter,
    BillSortOption? sortOption,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return BillsState(
      allBills: allBills ?? this.allBills,
      visibleBills: visibleBills ?? this.visibleBills,
      isLoading: isLoading ?? this.isLoading,
      selectedCategory: clearSelectedCategory
          ? null
          : selectedCategory ?? this.selectedCategory,
      paymentFilter: paymentFilter ?? this.paymentFilter,
      sortOption: sortOption ?? this.sortOption,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class BillsBloc extends ChangeNotifier {
  BillsBloc(
    this._repository, {
    bool Function()? isOnline,
    OfflineSyncService? offlineSyncService,
  Future<List<BillReminderSchedule>> Function(BillEntity bill)?
    scheduleReminders,
  Future<List<BillReminderSchedule>> Function(BillEntity bill)?
    rescheduleReminders,
  Future<void> Function(String billId)? cancelReminders,
  })  : _isOnline = isOnline ?? _alwaysOnline,
    _offlineSyncService = offlineSyncService ?? OfflineSyncService(_repository),
    _scheduleReminders = scheduleReminders ?? _defaultScheduleReminders,
    _rescheduleReminders =
      rescheduleReminders ?? _defaultRescheduleReminders,
    _cancelReminders = cancelReminders ?? _defaultCancelReminders;

  final BillsRepository _repository;
  final bool Function() _isOnline;
  final OfflineSyncService _offlineSyncService;
    final Future<List<BillReminderSchedule>> Function(BillEntity bill)
      _scheduleReminders;
    final Future<List<BillReminderSchedule>> Function(BillEntity bill)
      _rescheduleReminders;
    final Future<void> Function(String billId) _cancelReminders;

  BillsState _state = BillsState.initial();
  BillsState get state => _state;

  Future<void> loadBills() async {
    _setState(_state.copyWith(isLoading: true, clearErrorMessage: true));
    try {
      if (_isOnline()) {
        await _offlineSyncService.syncPendingOperations();
      }

      final bills = await _repository.getBills();
      _setState(
        _state.copyWith(
          allBills: bills,
          isLoading: false,
          clearErrorMessage: true,
        ),
      );
      for (final bill in bills) {
        await OfflineBillsCacheService.upsertCachedBill(bill);
      }
      _applyView();
    } catch (error) {
      final cachedBills = await OfflineBillsCacheService.getCachedBills();
      _setState(
        _state.copyWith(
          allBills: cachedBills,
          isLoading: false,
          errorMessage: 'Mode offline aktif. Menampilkan data cache.',
        ),
      );
      _applyView();
    }
  }

  Future<void> _scheduleNewBillReminders(BillEntity bill) async {
    final schedules = await _scheduleReminders(bill);
    NotificationLogService.recordScheduled(bill, schedules);
  }

  Future<void> _rescheduleBillReminders(BillEntity bill) async {
    final schedules = await _rescheduleReminders(bill);
    NotificationLogService.recordScheduled(bill, schedules);
  }

  Future<void> _cancelBillReminders(String billId) async {
    await _cancelReminders(billId);
    NotificationLogService.recordCancelled(billId);
  }

  Future<void> _enqueueOfflineCreate(BillEntity bill) async {
    await OfflineBillsCacheService.enqueueOperation(
      OfflineOperation(
        type: OfflineOperationType.create,
        billId: bill.id,
        createdAt: DateTime.now(),
        payload: BillModel.fromEntity(bill).toJson(),
      ),
    );
  }

  Future<void> _enqueueOfflineUpdate(BillEntity bill) async {
    await OfflineBillsCacheService.enqueueOperation(
      OfflineOperation(
        type: OfflineOperationType.update,
        billId: bill.id,
        createdAt: DateTime.now(),
        payload: BillModel.fromEntity(bill).toJson(),
      ),
    );
  }

  Future<void> _enqueueOfflineDelete(String billId) async {
    await OfflineBillsCacheService.enqueueOperation(
      OfflineOperation(
        type: OfflineOperationType.delete,
        billId: billId,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> _enqueueOfflineMarkPaid(String billId) async {
    await OfflineBillsCacheService.enqueueOperation(
      OfflineOperation(
        type: OfflineOperationType.markPaid,
        billId: billId,
        createdAt: DateTime.now(),
      ),
    );
  }

  static bool _alwaysOnline() {
    return true;
  }

  static Future<List<BillReminderSchedule>> _defaultScheduleReminders(
    BillEntity bill,
  ) {
    return NotificationService.scheduleBillReminders(bill);
  }

  static Future<List<BillReminderSchedule>> _defaultRescheduleReminders(
    BillEntity bill,
  ) {
    return NotificationService.rescheduleBillReminders(bill);
  }

  static Future<void> _defaultCancelReminders(String billId) {
    return NotificationService.cancelBillReminders(billId);
  }

  Future<void> _saveBillToLocalState(BillEntity bill) async {
    final nextBills = List<BillEntity>.from(_state.allBills)
      ..removeWhere((item) => item.id == bill.id)
      ..add(bill);
    _setState(_state.copyWith(allBills: nextBills));
    _applyView();
    await OfflineBillsCacheService.upsertCachedBill(bill);
  }

  Future<void> _removeBillFromLocalState(String billId) async {
    final nextBills = List<BillEntity>.from(_state.allBills)
      ..removeWhere((item) => item.id == billId);
    _setState(_state.copyWith(allBills: nextBills));
    _applyView();
    await OfflineBillsCacheService.removeCachedBill(billId);
  }

  Future<void> _replaceBillInLocalState(BillEntity bill) async {
    final nextBills = List<BillEntity>.from(_state.allBills);
    final index = nextBills.indexWhere((item) => item.id == bill.id);
    if (index >= 0) {
      nextBills[index] = bill;
    } else {
      nextBills.add(bill);
    }
    _setState(_state.copyWith(allBills: nextBills));
    _applyView();
    await OfflineBillsCacheService.upsertCachedBill(bill);
  }

  Future<void> _syncIfOnline() async {
    if (_isOnline()) {
      await _offlineSyncService.syncPendingOperations();
    }
  }

  Future<void> addBill({
    required String userId,
    required String title,
    required double amount,
    required BillCategory category,
    required DateTime dueDate,
    required bool isRecurring,
    RecurrenceInterval? recurrenceInterval,
    String? notes,
  }) async {
    final now = DateTime.now();
    final bill = BillEntity(
      id: _generateId(),
      userId: userId,
      title: title,
      amount: amount,
      category: category,
      dueDate: DateTime(dueDate.year, dueDate.month, dueDate.day),
      isPaid: false,
      isRecurring: isRecurring,
      recurrenceInterval: isRecurring ? recurrenceInterval : null,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _repository.createBill(bill);
      await _scheduleNewBillReminders(bill);
      await _saveBillToLocalState(bill);

      if (_isOnline()) {
        await _syncIfOnline();
        await loadBills();
      } else {
        await _enqueueOfflineCreate(bill);
      }
    } catch (error) {
      _setState(
        _state.copyWith(errorMessage: 'Gagal menambah tagihan: $error'),
      );
    }
  }

  Future<void> updateBill(BillEntity bill) async {
    final updatedBill = bill.copyWith(updatedAt: DateTime.now());
    try {
      await _repository.updateBill(updatedBill);
      await _rescheduleBillReminders(updatedBill);
      await _replaceBillInLocalState(updatedBill);

      if (_isOnline()) {
        await _syncIfOnline();
        await loadBills();
      } else {
        await _enqueueOfflineUpdate(updatedBill);
      }
    } catch (error) {
      _setState(_state.copyWith(errorMessage: 'Gagal mengubah tagihan: $error'));
    }
  }

  Future<void> deleteBill(String billId) async {
    try {
      await _repository.deleteBill(billId);
      await _cancelBillReminders(billId);
      await _removeBillFromLocalState(billId);

      if (_isOnline()) {
        await _syncIfOnline();
        await loadBills();
      } else {
        await _enqueueOfflineDelete(billId);
      }
    } catch (error) {
      _setState(_state.copyWith(errorMessage: 'Gagal menghapus tagihan: $error'));
    }
  }

  Future<void> markAsPaid(String billId) async {
    try {
      final updatedBill = await _repository.markBillAsPaid(billId);
      await _cancelBillReminders(billId);
      await _replaceBillInLocalState(updatedBill);

      if (_isOnline()) {
        await _syncIfOnline();
        await loadBills();
      } else {
        await _enqueueOfflineMarkPaid(billId);
      }
    } catch (error) {
      _setState(_state.copyWith(errorMessage: 'Gagal menandai lunas: $error'));
    }
  }

  void setCategoryFilter(BillCategory? category) {
    _setState(
      _state.copyWith(
        selectedCategory: category,
        clearSelectedCategory: category == null,
      ),
    );
    _applyView();
  }

  void setPaymentFilter(BillPaymentFilter paymentFilter) {
    _setState(_state.copyWith(paymentFilter: paymentFilter));
    _applyView();
  }

  void setSortOption(BillSortOption sortOption) {
    _setState(_state.copyWith(sortOption: sortOption));
    _applyView();
  }

  BillEntity? findById(String billId) {
    for (final bill in _state.allBills) {
      if (bill.id == billId) {
        return bill;
      }
    }
    return null;
  }

  void _applyView() {
    var filtered = List<BillEntity>.from(_state.allBills);

    final selectedCategory = _state.selectedCategory;
    if (selectedCategory != null) {
      filtered = filtered.where((bill) => bill.category == selectedCategory).toList();
    }

    switch (_state.paymentFilter) {
      case BillPaymentFilter.paid:
        filtered = filtered.where((bill) => bill.isPaid).toList();
      case BillPaymentFilter.unpaid:
        filtered = filtered.where((bill) => !bill.isPaid).toList();
      case BillPaymentFilter.all:
        break;
    }

    switch (_state.sortOption) {
      case BillSortOption.dueDateAsc:
        filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      case BillSortOption.dueDateDesc:
        filtered.sort((a, b) => b.dueDate.compareTo(a.dueDate));
      case BillSortOption.amountAsc:
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
      case BillSortOption.amountDesc:
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
    }

    _setState(_state.copyWith(visibleBills: filtered));
  }

  void _setState(BillsState newState) {
    _state = newState;
    notifyListeners();
  }

  String _generateId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    return 'bill_$now';
  }
}
