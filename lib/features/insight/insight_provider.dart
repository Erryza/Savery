import 'package:flutter/foundation.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../core/utils/formatter.dart';

class InsightProvider extends ChangeNotifier {
  final _txRepo = TransactionRepository();

  String selectedMonth = Formatter.currentMonth();
  List<Map<String, dynamic>> expenseCategoryTotals = [];
  double totalExpense = 0;
  double totalIncome = 0;
  bool isLoading = false;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    expenseCategoryTotals =
        await _txRepo.getCategoryTotalsForMonth('expense', selectedMonth);
    totalExpense = await _txRepo.getTotalByTypeAndMonth('expense', selectedMonth);
    totalIncome = await _txRepo.getTotalByTypeAndMonth('income', selectedMonth);
    isLoading = false;
    notifyListeners();
  }

  void prevMonth() {
    selectedMonth = Formatter.prevMonth(selectedMonth);
    load();
  }

  void nextMonth() {
    selectedMonth = Formatter.nextMonth(selectedMonth);
    load();
  }
}
