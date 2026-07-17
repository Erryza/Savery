import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatter.dart';
import '../../core/constants/app_icons.dart';
import '../../data/models/transaction.dart';
import '../../data/models/category.dart' as cat_model;
import '../../widgets/category_badge.dart';
import 'transaction_provider.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        context.read<TransactionProvider>().setSearchQuery('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TransactionProvider>();
    final grouped = p.groupedByDate;
    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: context.appBg,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: context.appText, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Cari transaksi...',
                  hintStyle: TextStyle(color: context.appSubtext, fontSize: 14),
                  border: InputBorder.none,
                ),
                onChanged: (v) =>
                    context.read<TransactionProvider>().setSearchQuery(v),
              )
            : Text('Transaksi',
                style: TextStyle(
                    color: context.appText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
        backgroundColor: context.appBarColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: context.appShadow,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? AppIcons.x : AppIcons.search,
                color: context.appSubtext),
            onPressed: _toggleSearch,
          ),
          if (!_isSearching)
            IconButton(
              icon: Icon(AppIcons.filterAlt,
                  color: context.watch<TransactionProvider>().hasActiveFilters
                      ? AppColors.primary
                      : context.appSubtext),
              onPressed: () =>
                  _showFilterSheet(context.read<TransactionProvider>()),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(p),
          Expanded(
            child: p.isLoading
                ? const Center(child: CircularProgressIndicator())
                : p.filteredTransactions.isEmpty
                    ? _buildEmpty(p.searchQuery.trim().isNotEmpty)
                    : RefreshIndicator(
                        onRefresh: () => p.load(),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                          itemCount: dates.length,
                          itemBuilder: (_, i) =>
                              _buildDateGroup(dates[i], grouped[dates[i]]!),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(AppIcons.plus, color: Colors.white),
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
          if (added == true && context.mounted) {
            context.read<TransactionProvider>().load();
          }
        },
      ),
    );
  }

  Widget _buildFilterChips(TransactionProvider p) {
    const filters = [
      ('all', 'Semua'),
      ('income', 'Masuk'),
      ('expense', 'Keluar'),
    ];
    return Container(
      color: context.appBarColor,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: filters.asMap().entries.map((entry) {
          final i = entry.key;
          final f = entry.value;
          final active = p.filterType == f.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => p.setFilter(f.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: EdgeInsets.only(right: i < filters.length - 1 ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : context.appLine,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  f.$2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: active ? Colors.white : context.appSubtext,
                    fontSize: 10.5,
                    fontWeight:
                        active ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateGroup(String date, List<Transaction> txs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: Text(Formatter.relativeDate(date),
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: context.appSubtext,
                  fontSize: 12)),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.appSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.appLine),
          ),
          child: Column(
            children: txs
                .asMap()
                .entries
                .map((e) => _buildTxItem(e.value, e.key == txs.length - 1))
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildTxItem(Transaction tx, bool isLast) {
    final isIncome = tx.type == 'income';
    final color = CategoryBadge.colorFromHex(tx.categoryColorHex ?? '#6B7280');
    return GestureDetector(
      onLongPress: () => _showDeleteDialog(tx),
      child: Padding(
        padding: EdgeInsets.fromLTRB(14, 12, 14, isLast ? 12 : 0),
        child: Column(
          children: [
            Row(
              children: [
                CategoryBadge(
                    iconKey: tx.categoryIconKey ?? 'tag',
                    color: color,
                    size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tx.title,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: context.appText)),
                      const SizedBox(height: 1),
                      Text(tx.categoryName ?? '',
                          style: TextStyle(
                              color: context.appSubtext, fontSize: 12)),
                    ],
                  ),
                ),
                Text(
                  '${isIncome ? '+' : '-'}${Formatter.rupiah(tx.amount)}',
                  style: TextStyle(
                    color: isIncome ? AppColors.success : AppColors.danger,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (!isLast)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Divider(height: 1, color: context.appLine),
              ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(TransactionProvider p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(provider: p),
    );
  }

  Widget _buildEmpty(bool isSearchResult) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
                color: context.appPrimaryLight,
                borderRadius: BorderRadius.circular(20)),
            child: Icon(isSearchResult ? AppIcons.search : AppIcons.receipt,
                size: 38, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
              isSearchResult
                  ? 'Transaksi tidak ditemukan'
                  : 'Belum ada transaksi',
              style: TextStyle(
                  color: context.appText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
              isSearchResult
                  ? 'Coba kata kunci lain'
                  : 'Tekan + untuk mencatat transaksi pertamamu',
              style: TextStyle(color: context.appSubtext, fontSize: 13)),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(Transaction tx) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Transaksi'),
        content: Text('Hapus "${tx.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Hapus', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<TransactionProvider>().deleteTransaction(tx);
    }
  }
}

class _FilterSheet extends StatefulWidget {
  final TransactionProvider provider;
  const _FilterSheet({required this.provider});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String _period;
  late String? _month;
  late int? _categoryId;

  @override
  void initState() {
    super.initState();
    _period = widget.provider.filterPeriod;
    _month = widget.provider.filterMonth;
    _categoryId = widget.provider.filterCategoryId;
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  String _currentYM() {
    final now = DateTime.now();
    return '${now.year}-${_pad(now.month)}';
  }

  String _monthLabel(String ym) {
    final parts = ym.split('-');
    const months = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return '${months[int.parse(parts[1])]} ${parts[0]}';
  }

  void _prevMonth() {
    final base = _month ?? _currentYM();
    final parts = base.split('-');
    var y = int.parse(parts[0]);
    var m = int.parse(parts[1]) - 1;
    if (m < 1) { m = 12; y--; }
    setState(() => _month = '$y-${_pad(m)}');
  }

  void _nextMonth() {
    final base = _month ?? _currentYM();
    final parts = base.split('-');
    var y = int.parse(parts[0]);
    var m = int.parse(parts[1]) + 1;
    if (m > 12) { m = 1; y++; }
    setState(() => _month = '$y-${_pad(m)}');
  }

  @override
  Widget build(BuildContext context) {
    final cats = widget.provider.categories;

    return Container(
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 4),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 8, 12),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: context.appPrimaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(AppIcons.filterAlt, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Filter Transaksi',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.appText)),
                ),
                IconButton(
                  icon: Icon(AppIcons.x, size: 20, color: context.appSubtext),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Periode ──
                  _sectionLabel('Periode', Icons.calendar_today_outlined),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 3.0,
                    children: [
                      _periodOption('all', 'Semua', Icons.apps_rounded),
                      _periodOption('week', 'Minggu Ini', Icons.date_range_outlined),
                      _periodOption('month', 'Bulan Ini', Icons.calendar_month_outlined),
                      _periodOption('custom', 'Pilih Bulan', Icons.edit_calendar_outlined),
                    ],
                  ),

                  // Month navigator (appears when custom selected)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: _period == 'custom'
                        ? Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: context.appSurfaceAlt,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: context.appLine),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(AppIcons.caretLeft, color: AppColors.primary),
                                    onPressed: _prevMonth,
                                  ),
                                  Expanded(
                                    child: Text(
                                      _monthLabel(_month ?? _currentYM()),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: context.appText),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(AppIcons.caretRight, color: AppColors.primary),
                                    onPressed: _nextMonth,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 24),

                  // ── Kategori ──
                  _sectionLabel('Kategori', Icons.label_outline),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _catChip(null, 'Semua', null),
                      ...cats.map((c) => _catChip(c.id, c.name, c)),
                    ],
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),

          // Bottom buttons
          Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
            decoration: BoxDecoration(
              color: context.appSurface,
              border: Border(top: BorderSide(color: context.appLine)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() { _period = 'all'; _month = null; _categoryId = null; });
                      widget.provider.clearExtraFilters();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Text('Reset', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.provider.applyFilters(
                        period: _period,
                        month: _period == 'custom' ? (_month ?? _currentYM()) : null,
                        categoryId: _categoryId,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Terapkan Filter', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label, IconData icon) {
    return Row(
      children: [
        Container(
          width: 3, height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: context.appText)),
      ],
    );
  }

  Widget _periodOption(String value, String label, IconData icon) {
    final active = _period == value;
    return GestureDetector(
      onTap: () => setState(() {
        _period = value;
        if (value == 'custom') _month ??= _currentYM();
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : context.appSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? AppColors.primary : context.appLine,
            width: active ? 1.5 : 1,
          ),
          boxShadow: active
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 16, color: active ? Colors.white : AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : context.appText)),
            ),
            if (active)
              const Icon(Icons.check_circle_rounded, size: 14, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _catChip(int? id, String label, cat_model.Category? cat) {
    final active = _categoryId == id;
    final catColor = cat != null ? CategoryBadge.colorFromHex(cat.colorHex) : null;
    return GestureDetector(
      onTap: () => setState(() => _categoryId = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : context.appSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.primary : context.appLine,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (catColor != null) ...[
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  color: active ? Colors.white.withValues(alpha: 0.8) : catColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: active ? Colors.white : context.appText)),
          ],
        ),
      ),
    );
  }
}
