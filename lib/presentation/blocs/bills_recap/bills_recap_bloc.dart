import 'package:flutter/foundation.dart';

import 'package:billmate/domain/entities/bill_recap_entity.dart';
import 'package:billmate/domain/repositories/bill_recap_repository.dart';
import 'bills_recap_state.dart';

class BillsRecapBloc extends ChangeNotifier {
  BillsRecapBloc(this._recapRepository) : state = BillsRecapState();

  final BillRecapRepository _recapRepository;
  final BillsRecapState state;

  Future<void> loadCurrentMonthRecap() async {
    state.setLoading(true);
    state.clearError();

    try {
      final recap = await _recapRepository.getCurrentMonthRecap();
      state.setCurrentMonthRecap(recap);
    } catch (e) {
      state.setError('Failed to load recap: ${e.toString()}');
    } finally {
      state.setLoading(false);
    }
  }

  Future<void> loadMonthlyRecap(int year, int month) async {
    state.setLoading(true);
    state.clearError();

    try {
      final recap = await _recapRepository.getMonthlyRecap(year, month);
      state.setCurrentMonthRecap(recap);
    } catch (e) {
      state.setError('Failed to load recap: ${e.toString()}');
    } finally {
      state.setLoading(false);
    }
  }

  Future<void> loadRecapHistory({
    required int startYear,
    required int startMonth,
    required int endYear,
    required int endMonth,
  }) async {
    state.setLoading(true);
    state.clearError();

    try {
      final recaps = await _recapRepository.getRecapRange(
        startYear: startYear,
        startMonth: startMonth,
        endYear: endYear,
        endMonth: endMonth,
      );
      state.setRecapHistory(recaps);
    } catch (e) {
      state.setError('Failed to load history: ${e.toString()}');
    } finally {
      state.setLoading(false);
    }
  }
}
