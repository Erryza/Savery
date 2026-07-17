import 'package:flutter/foundation.dart';
import '../../data/models/goal.dart';
import '../../data/models/goal_contribution.dart';
import '../../data/repositories/goal_repository.dart';

class GoalProvider extends ChangeNotifier {
  final _repo = GoalRepository();

  List<Goal> goals = [];
  List<GoalContribution> contributions = [];
  bool isLoading = false;

  List<Goal> get ongoing => goals.where((g) => !g.isAchieved).toList();
  List<Goal> get achieved => goals.where((g) => g.isAchieved).toList();

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    goals = await _repo.getAll();
    isLoading = false;
    notifyListeners();
  }

  Future<void> addGoal(Goal goal) async {
    await _repo.insert(goal);
    await load();
  }

  Future<void> updateGoal(Goal goal) async {
    await _repo.update(goal);
    await load();
  }

  Future<void> deleteGoal(int id) async {
    await _repo.delete(id);
    await load();
  }

  Future<void> addFunds(int id, double amount) async {
    await _repo.addFunds(id, amount);
    await load();
    await loadContributions(id);
  }

  Future<void> loadContributions(int goalId) async {
    contributions = await _repo.getContributions(goalId);
    notifyListeners();
  }
}
