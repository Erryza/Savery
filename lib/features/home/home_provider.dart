import 'package:flutter/foundation.dart';
import '../../data/models/account.dart';
import '../../data/models/budget.dart';
import '../../data/models/transaction.dart';
import '../../data/repositories/account_repository.dart';
import '../../data/repositories/budget_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../core/utils/formatter.dart';

class HomeProvider extends ChangeNotifier {
  final _accountRepo = AccountRepository();
  final _txRepo = TransactionRepository();
  final _budgetRepo = BudgetRepository();

  Account? mainAccount;
  double income = 0;
  double expense = 0;
  double prevIncome = 0;
  double prevExpense = 0;
  List<Budget> budgets = [];
  List<Transaction> recentTransactions = [];
  bool balanceVisible = true;
  bool isLoading = false;

  double get savings => income - expense;
  double get prevSavings => prevIncome - prevExpense;
  String get selectedMonth => Formatter.currentMonth();

  double get savingsChangePct {
    if (prevSavings == 0) return 0;
    return ((savings - prevSavings) / prevSavings.abs()) * 100;
  }

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    final month = Formatter.currentMonth();
    final prev = Formatter.prevMonth(month);
    mainAccount = await _accountRepo.getMain();
    income = await _txRepo.getTotalByTypeAndMonth('income', month);
    expense = await _txRepo.getTotalByTypeAndMonth('expense', month);
    prevIncome = await _txRepo.getTotalByTypeAndMonth('income', prev);
    prevExpense = await _txRepo.getTotalByTypeAndMonth('expense', prev);
    budgets = await _budgetRepo.getForMonth(month);
    final allTx = await _txRepo.getAll();
    recentTransactions = allTx.take(4).toList();
    isLoading = false;
    notifyListeners();
  }

  void toggleBalance() {
    balanceVisible = !balanceVisible;
    notifyListeners();
  }
}
