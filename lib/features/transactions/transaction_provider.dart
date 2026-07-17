import 'package:flutter/foundation.dart' hide Category;
import '../../data/models/transaction.dart';
import '../../data/models/category.dart';
import '../../data/models/account.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/account_repository.dart';

class TransactionProvider extends ChangeNotifier {
  final _txRepo = TransactionRepository();
  final _catRepo = CategoryRepository();
  final _accRepo = AccountRepository();

  List<Transaction> transactions = [];
  List<Category> categories = [];
  List<Account> accounts = [];

  String filterType = 'all';       // all | income | expense
  String filterPeriod = 'all';     // all | week | month | custom
  String? filterMonth;              // yyyy-MM, used when filterPeriod == custom
  int? filterCategoryId;
  String searchQuery = '';

  bool isLoading = false;

  bool get hasActiveFilters =>
      filterPeriod != 'all' || filterCategoryId != null;

  List<Transaction> get filteredTransactions {
    if (searchQuery.trim().isEmpty) return transactions;
    final q = searchQuery.trim().toLowerCase();
    return transactions.where((tx) {
      return tx.title.toLowerCase().contains(q) ||
          (tx.categoryName?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
  String _fmtMonth(DateTime d) => '${d.year}-${_pad(d.month)}';
  String _fmtDate(DateTime d) => '${d.year}-${_pad(d.month)}-${_pad(d.day)}';

  Future<void> load() async {
    isLoading = true;
    notifyListeners();

    String? month;
    String? dateFrom;
    String? dateTo;
    final now = DateTime.now();

    if (filterPeriod == 'week') {
      dateFrom = _fmtDate(now.subtract(const Duration(days: 6)));
      dateTo = _fmtDate(now);
    } else if (filterPeriod == 'month') {
      month = _fmtMonth(now);
    } else if (filterPeriod == 'custom' && filterMonth != null) {
      month = filterMonth;
    }

    transactions = await _txRepo.getAll(
      type: filterType == 'all' ? null : filterType,
      month: month,
      categoryId: filterCategoryId,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
    categories = await _catRepo.getAll();
    accounts = await _accRepo.getAll();
    isLoading = false;
    notifyListeners();
  }

  void setFilter(String type) {
    filterType = type;
    load();
  }

  void applyFilters({
    required String period,
    String? month,
    int? categoryId,
  }) {
    filterPeriod = period;
    filterMonth = month;
    filterCategoryId = categoryId;
    load();
  }

  void clearExtraFilters() {
    filterPeriod = 'all';
    filterMonth = null;
    filterCategoryId = null;
    load();
  }

  Future<void> addTransaction(Transaction tx) async {
    await _txRepo.insert(tx);
    final delta = tx.type == 'income' ? tx.amount : -tx.amount;
    await _accRepo.adjustBalance(tx.accountId, delta);
    await load();
  }

  Future<void> deleteTransaction(Transaction tx) async {
    await _txRepo.delete(tx.id!);
    final delta = tx.type == 'income' ? -tx.amount : tx.amount;
    await _accRepo.adjustBalance(tx.accountId, delta);
    await load();
  }

  Map<String, List<Transaction>> get groupedByDate {
    final map = <String, List<Transaction>>{};
    for (final tx in filteredTransactions) {
      map.putIfAbsent(tx.date, () => []).add(tx);
    }
    return map;
  }
}
