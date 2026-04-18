import 'package:flutter/foundation.dart';

import '../../domain/entities/bill_recap_entity.dart';

class BillsRecapState with ChangeNotifier {
  BillRecapMonth? currentMonthRecap;
  List<BillRecapMonth> recapHistory = [];
  bool isLoading = false;
  String? error;

  void setCurrentMonthRecap(BillRecapMonth recap) {
    currentMonthRecap = recap;
    notifyListeners();
  }

  void setRecapHistory(List<BillRecapMonth> history) {
    recapHistory = history;
    notifyListeners();
  }

  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }

  void setError(String? errorMsg) {
    error = errorMsg;
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}
