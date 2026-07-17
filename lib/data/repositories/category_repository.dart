import '../db/database_helper.dart';
import '../models/category.dart';

class CategoryRepository {
  final _db = DatabaseHelper();

  Future<List<Category>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('categories', orderBy: 'type DESC, name ASC');
    return maps.map(Category.fromMap).toList();
  }

  Future<List<Category>> getByType(String type) async {
    final db = await _db.database;
    final maps = await db.query('categories', where: 'type = ?', whereArgs: [type], orderBy: 'name ASC');
    return maps.map(Category.fromMap).toList();
  }

  Future<int> insert(Category cat) async {
    final db = await _db.database;
    return db.insert('categories', cat.toMap());
  }

  Future<int> update(Category cat) async {
    final db = await _db.database;
    return db.update('categories', cat.toMap(), where: 'id = ?', whereArgs: [cat.id]);
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
