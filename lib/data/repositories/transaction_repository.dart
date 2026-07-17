import '../db/database_helper.dart';
import '../models/transaction.dart';

class TransactionRepository {
  final _db = DatabaseHelper();

  static const _joinedQuery = '''
    SELECT t.*, c.name as category_name, c.icon_key, c.color_hex, a.name as account_name
    FROM transactions t
    LEFT JOIN categories c ON t.category_id = c.id
    LEFT JOIN accounts a ON t.account_id = a.id
  ''';

  Future<List<Transaction>> getAll({
    String? type,
    String? month,
    int? categoryId,
    String? dateFrom,
    String? dateTo,
  }) async {
    final db = await _db.database;
    String query = _joinedQuery;
    final args = <dynamic>[];
    final conditions = <String>[];

    if (type != null && type != 'all') {
      conditions.add('t.type = ?');
      args.add(type);
    }
    if (month != null) {
      conditions.add("strftime('%Y-%m', t.date) = ?");
      args.add(month);
    }
    if (dateFrom != null) {
      conditions.add('t.date >= ?');
      args.add(dateFrom);
    }
    if (dateTo != null) {
      conditions.add('t.date <= ?');
      args.add(dateTo);
    }
    if (categoryId != null) {
      conditions.add('t.category_id = ?');
      args.add(categoryId);
    }
    if (conditions.isNotEmpty) {
      query += ' WHERE ${conditions.join(' AND ')}';
    }
    query += ' ORDER BY t.date DESC, t.created_at DESC';

    final maps = await db.rawQuery(query, args);
    return maps.map(Transaction.fromMap).toList();
  }

  Future<double> getTotalByTypeAndMonth(String type, String month) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      "SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE type = ? AND strftime('%Y-%m', date) = ?",
      [type, month],
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<Map<int, double>> getSpentByCategoryForMonth(String month) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      "SELECT category_id, SUM(amount) as total FROM transactions WHERE type = 'expense' AND strftime('%Y-%m', date) = ? GROUP BY category_id",
      [month],
    );
    return {for (final r in result) r['category_id'] as int: (r['total'] as num).toDouble()};
  }

  Future<int> insert(Transaction tx) async {
    final db = await _db.database;
    return db.insert('transactions', tx.toMap());
  }

  Future<int> update(Transaction tx) async {
    final db = await _db.database;
    return db.update('transactions', tx.toMap(), where: 'id = ?', whereArgs: [tx.id]);
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getCategoryTotalsForMonth(String type, String month) async {
    final db = await _db.database;
    return db.rawQuery('''
      SELECT c.name, c.color_hex, c.icon_key, SUM(t.amount) as total
      FROM transactions t
      LEFT JOIN categories c ON t.category_id = c.id
      WHERE t.type = ? AND strftime('%Y-%m', t.date) = ?
      GROUP BY t.category_id
      ORDER BY total DESC
    ''', [type, month]);
  }
}
