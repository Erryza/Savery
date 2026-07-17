import '../db/database_helper.dart';
import '../models/budget.dart';

class BudgetRepository {
  final _db = DatabaseHelper();

  Future<List<Budget>> getForMonth(String month) async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT b.*, c.name as category_name, c.icon_key, c.color_hex,
        (SELECT COALESCE(SUM(amount), 0) FROM transactions t
         WHERE t.category_id = b.category_id AND t.type = 'expense'
         AND strftime('%Y-%m', t.date) = b.month) as spent
      FROM budgets b
      LEFT JOIN categories c ON b.category_id = c.id
      WHERE b.month = ?
      ORDER BY c.name ASC
    ''', [month]);
    return maps.map(Budget.fromMap).toList();
  }

  Future<int> insert(Budget budget) async {
    final db = await _db.database;
    return db.insert('budgets', budget.toMap());
  }

  Future<int> update(Budget budget) async {
    final db = await _db.database;
    return db.update('budgets', budget.toMap(), where: 'id = ?', whereArgs: [budget.id]);
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }
}
