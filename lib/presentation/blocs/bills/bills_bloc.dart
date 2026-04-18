import 'package:flutter/foundation.dart';

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
  BillsBloc(this._repository);

  final BillsRepository _repository;

  BillsState _state = BillsState.initial();
  BillsState get state => _state;

  Future<void> loadBills() async {
    _setState(_state.copyWith(isLoading: true, clearErrorMessage: true));
    try {
      final bills = await _repository.getBills();
      _setState(
        _state.copyWith(
          allBills: bills,
          isLoading: false,
          clearErrorMessage: true,
        ),
      );
      _applyView();
    } catch (error) {
      _setState(
        _state.copyWith(
          isLoading: false,
          errorMessage: 'Gagal memuat tagihan: $error',
        ),
      );
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
      await loadBills();
    } catch (error) {
      _setState(_state.copyWith(errorMessage: 'Gagal menambah tagihan: $error'));
    }
  }

  Future<void> updateBill(BillEntity bill) async {
    try {
      await _repository.updateBill(
        bill.copyWith(updatedAt: DateTime.now()),
      );
      await loadBills();
    } catch (error) {
      _setState(_state.copyWith(errorMessage: 'Gagal mengubah tagihan: $error'));
    }
  }

  Future<void> deleteBill(String billId) async {
    try {
      await _repository.deleteBill(billId);
      await loadBills();
    } catch (error) {
      _setState(_state.copyWith(errorMessage: 'Gagal menghapus tagihan: $error'));
    }
  }

  Future<void> markAsPaid(String billId) async {
    try {
      await _repository.markBillAsPaid(billId);
      await loadBills();
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
