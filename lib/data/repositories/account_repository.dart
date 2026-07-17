import '../db/database_helper.dart';
import '../models/account.dart';

class AccountRepository {
  final _db = DatabaseHelper();

  Future<List<Account>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('accounts', orderBy: 'is_main DESC, name ASC');
    return maps.map(Account.fromMap).toList();
  }

  Future<Account?> getMain() async {
    final db = await _db.database;
    final maps = await db.query('accounts', where: 'is_main = 1', limit: 1);
    if (maps.isEmpty) return null;
    return Account.fromMap(maps.first);
  }

  Future<int> insert(Account account) async {
    final db = await _db.database;
    return db.insert('accounts', account.toMap());
  }

  Future<int> update(Account account) async {
    final db = await _db.database;
    return db.update('accounts', account.toMap(), where: 'id = ?', whereArgs: [account.id]);
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> adjustBalance(int accountId, double delta) async {
    final db = await _db.database;
    await db.rawUpdate(
      'UPDATE accounts SET balance = balance + ? WHERE id = ?',
      [delta, accountId],
    );
  }
}
