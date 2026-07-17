import 'package:flutter/foundation.dart' hide Category;
import '../../data/models/budget.dart';
import '../../data/models/category.dart';
import '../../data/repositories/budget_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../core/utils/formatter.dart';

class BudgetProvider extends ChangeNotifier {
  final _budgetRepo = BudgetRepository();
  final _catRepo = CategoryRepository();

  List<Budget> budgets = [];
  List<Category> categories = [];
  String selectedMonth = Formatter.currentMonth();
  bool isLoading = false;

  double get totalLimit => budgets.fold(0, (s, b) => s + b.limitAmount);
  double get totalSpent => budgets.fold(0, (s, b) => s + b.spentAmount);
  double get totalPercentage => totalLimit > 0 ? (totalSpent / totalLimit).clamp(0.0, 1.0) : 0;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    budgets = await _budgetRepo.getForMonth(selectedMonth);
    categories = await _catRepo.getByType('expense');
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

  Future<void> addBudget(Budget budget) async {
    await _budgetRepo.insert(budget);
    await load();
  }

  Future<void> updateBudget(Budget budget) async {
    await _budgetRepo.update(budget);
    await load();
  }

  Future<void> deleteBudget(int id) async {
    await _budgetRepo.delete(id);
    await load();
  }
}
