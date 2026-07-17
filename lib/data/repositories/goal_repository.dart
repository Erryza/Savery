import '../db/database_helper.dart';
import '../models/goal.dart';
import '../models/goal_contribution.dart';

class GoalRepository {
  final _db = DatabaseHelper();

  Future<List<Goal>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('goals', orderBy: 'status ASC, id DESC');
    return maps.map(Goal.fromMap).toList();
  }

  Future<int> insert(Goal goal) async {
    final db = await _db.database;
    return db.insert('goals', goal.toMap());
  }

  Future<int> update(Goal goal) async {
    final db = await _db.database;
    return db.update('goals', goal.toMap(), where: 'id = ?', whereArgs: [goal.id]);
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addFunds(int id, double amount) async {
    final db = await _db.database;
    await db.rawUpdate(
      'UPDATE goals SET collected_amount = collected_amount + ?, status = CASE WHEN collected_amount + ? >= target_amount THEN "achieved" ELSE status END WHERE id = ?',
      [amount, amount, id],
    );
    await db.insert('goal_contributions', GoalContribution(
      goalId: id,
      amount: amount,
      date: DateTime.now().toIso8601String(),
    ).toMap());
  }

  Future<List<GoalContribution>> getContributions(int goalId, {int limit = 10}) async {
    final db = await _db.database;
    final maps = await db.query(
      'goal_contributions',
      where: 'goal_id = ?',
      whereArgs: [goalId],
      orderBy: 'date DESC, id DESC',
      limit: limit,
    );
    return maps.map(GoalContribution.fromMap).toList();
  }
}
