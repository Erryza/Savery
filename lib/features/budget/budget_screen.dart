import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatter.dart';
import '../../core/constants/app_icons.dart';
import '../../data/models/budget.dart';
import '../../data/models/category.dart' as cat_model;
import '../../widgets/category_badge.dart';
import 'budget_provider.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<BudgetProvider>();
    return Scaffold(
      backgroundColor: context.appBg,
      appBar: AppBar(
        backgroundColor: context.appBarColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: context.appShadow,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text('Budget',
            style: TextStyle(
                color: context.appText,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const CircleBorder(),
        onPressed: () => _showAddBudgetDialog(context, p),
        child: const Icon(AppIcons.plus, color: Colors.white),
      ),
      body: p.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _buildMonthSelector(p),
                  ),
                ),
                if (p.budgets.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildSummaryCard(p),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildSectionHeader(),
                  ),
                  const SizedBox(height: 8),
                ],
                // Only this section scrolls
                Expanded(
                  child: p.budgets.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          onRefresh: () => p.load(),
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                            itemCount: p.budgets.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 18),
                            itemBuilder: (_, i) => _buildBudgetRow(p.budgets[i], p),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildMonthSelector(BudgetProvider p) {
    return GestureDetector(
      onTap: () => _showMonthPicker(p),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: context.appShadow, blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(Formatter.month(p.selectedMonth),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.appText)),
            const SizedBox(width: 8),
            Icon(AppIcons.calendar, size: 16, color: context.appSubtext),
          ],
        ),
      ),
    );
  }

  void _showMonthPicker(BudgetProvider p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.appSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Consumer<BudgetProvider>(
            builder: (context, bp, _) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    icon: const Icon(AppIcons.caretLeft), onPressed: bp.prevMonth),
                Text(Formatter.month(bp.selectedMonth),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: context.appText)),
                IconButton(
                    icon: const Icon(AppIcons.caretRight), onPressed: bp.nextMonth),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BudgetProvider p) {
    final remaining = (p.totalLimit - p.totalSpent).clamp(0.0, double.infinity);
    return Container(
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: context.appShadow, blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Budget',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text(Formatter.rupiah(p.totalLimit),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -10),
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: context.appSurface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _summaryStat('Terpakai', Formatter.rupiah(p.totalSpent)),
                    _summaryStat('Sisa', Formatter.rupiah(remaining), alignEnd: true),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: p.totalPercentage.clamp(0.0, 1.0),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(8),
                          backgroundColor: context.appLine,
                          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('${(p.totalPercentage * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: context.appText)),
                  ],
                ),
              ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryStat(String label, String value, {bool alignEnd = false}) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: context.appSubtext, fontSize: 11.5)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                color: context.appText, fontWeight: FontWeight.w700, fontSize: 14)),
      ],
    );
  }

  Widget _buildBudgetRow(Budget b, BudgetProvider p) {
    final color = CategoryBadge.colorFromHex(b.categoryColorHex ?? '#6B7280');
    final pct = b.percentage;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onLongPress: () => _showMenu(context, b, p),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CategoryBadge(
            iconKey: b.categoryIconKey ?? 'tag',
            color: color,
            size: 44,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.categoryName ?? '',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: context.appText)),
                const SizedBox(height: 2),
                Text(
                    '${Formatter.rupiah(b.spentAmount)} / ${Formatter.rupiah(b.limitAmount)}',
                    style: TextStyle(fontSize: 11.5, color: context.appSubtext)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: pct.clamp(0.0, 1.0),
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(3),
                    backgroundColor: context.appLine,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text('${(pct * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13, color: color)),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context, Budget b, BudgetProvider p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.appSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: context.appLine, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _showEditBudgetDialog(context, b, p);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
              title: const Text('Hapus', style: TextStyle(color: AppColors.danger)),
              onTap: () {
                Navigator.pop(context);
                p.deleteBudget(b.id!);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text('Budget per Kategori',
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: context.appText)),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: context.appPrimaryLight,
                  borderRadius: BorderRadius.circular(20)),
              child: const Icon(AppIcons.chartPie, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text('Belum ada budget',
                style: TextStyle(
                    color: context.appText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Tekan + di kanan bawah untuk menambah budget',
                style: TextStyle(color: context.appSubtext, fontSize: 13),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddBudgetDialog(BuildContext context, BudgetProvider p) async {
    final availableCats =
        p.categories.where((c) => !p.budgets.any((b) => b.categoryId == c.id)).toList();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddBudgetSheet(
        availableCategories: availableCats,
        month: p.selectedMonth,
        onSave: (cat, limit) async {
          await p.addBudget(Budget(
            categoryId: cat.id!,
            month: p.selectedMonth,
            limitAmount: limit,
          ));
        },
      ),
    );
  }

  Future<void> _showEditBudgetDialog(
      BuildContext context, Budget b, BudgetProvider p) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditBudgetSheet(
        budget: b,
        onSave: (limit) async {
          await p.updateBudget(b.copyWith(limitAmount: limit));
        },
      ),
    );
  }
}

// ── Add Budget Sheet ──────────────────────────────────────────────────────────

class _AddBudgetSheet extends StatefulWidget {
  final List<cat_model.Category> availableCategories;
  final String month;
  final Future<void> Function(cat_model.Category, double) onSave;

  const _AddBudgetSheet({
    required this.availableCategories,
    required this.month,
    required this.onSave,
  });

  @override
  State<_AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends State<_AddBudgetSheet> {
  cat_model.Category? _selectedCat;
  final _ctrl = TextEditingController();
  bool _saving = false;
  String? _amountError;
  String? _catError;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() { _catError = null; _amountError = null; });

    if (_selectedCat == null) {
      setState(() => _catError = 'Pilih kategori terlebih dahulu');
      return;
    }
    final limit = double.tryParse(_ctrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (limit <= 0) {
      setState(() => _amountError = 'Masukkan nominal yang valid');
      return;
    }

    setState(() => _saving = true);
    await widget.onSave(_selectedCat!, limit);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(color: context.appLine, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
              child: Row(
                children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: context.appPrimaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(AppIcons.chartPie, size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tambah Budget',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.appText)),
                        Text('Atur limit pengeluaran per kategori',
                            style: TextStyle(fontSize: 11, color: context.appSubtext)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(AppIcons.x, size: 20, color: context.appSubtext),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: context.appLine),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Kategori ──
                  _fieldLabel('Kategori', AppIcons.tag),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: context.appSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _catError != null ? AppColors.danger : context.appLine,
                      ),
                    ),
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: widget.availableCategories.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Text('Semua kategori sudah memiliki budget',
                                  style: TextStyle(color: context.appSubtext, fontSize: 13),
                                  textAlign: TextAlign.center),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: widget.availableCategories.length,
                              separatorBuilder: (_, __) =>
                                  Divider(height: 1, indent: 16, endIndent: 16, color: context.appLine),
                              itemBuilder: (_, i) {
                                final c = widget.availableCategories[i];
                                final active = _selectedCat?.id == c.id;
                                final color = CategoryBadge.colorFromHex(c.colorHex);
                                return InkWell(
                                  onTap: () => setState(() { _selectedCat = c; _catError = null; }),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    color: active ? AppColors.primary.withValues(alpha: 0.06) : context.appSurface,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 10, height: 10,
                                          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(c.name,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                                                  color: active ? AppColors.primary : context.appText)),
                                        ),
                                        if (active)
                                          const Icon(Icons.check_circle_rounded,
                                              size: 18, color: AppColors.primary),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                  if (_catError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(_catError!,
                          style: const TextStyle(color: AppColors.danger, fontSize: 11)),
                    ),

                  const SizedBox(height: 20),

                  // ── Limit ──
                  _fieldLabel('Limit Budget', AppIcons.wallet),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _ctrl,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() => _amountError = null),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: '0',
                      prefixText: 'Rp  ',
                      prefixStyle: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600, color: context.appSubtext),
                      errorText: _amountError,
                      filled: true,
                      fillColor: context.appSurfaceAlt,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.appLine),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.appLine),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.danger),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Bottom buttons
            Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: context.appLine)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: context.appLine),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        foregroundColor: context.appSubtext,
                      ),
                      child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _saving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Simpan Budget', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.appText)),
      ],
    );
  }
}

// ── Edit Budget Sheet ─────────────────────────────────────────────────────────

class _EditBudgetSheet extends StatefulWidget {
  final Budget budget;
  final Future<void> Function(double) onSave;

  const _EditBudgetSheet({required this.budget, required this.onSave});

  @override
  State<_EditBudgetSheet> createState() => _EditBudgetSheetState();
}

class _EditBudgetSheetState extends State<_EditBudgetSheet> {
  late final TextEditingController _ctrl;
  bool _saving = false;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.budget.limitAmount.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _amountError = null);
    final limit = double.tryParse(_ctrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (limit <= 0) {
      setState(() => _amountError = 'Masukkan nominal yang valid');
      return;
    }
    setState(() => _saving = true);
    await widget.onSave(limit);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.budget;
    final color = CategoryBadge.colorFromHex(b.categoryColorHex ?? '#6B7280');

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(color: context.appLine, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
              child: Row(
                children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(AppIcons.chartPie, size: 18, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Edit Budget',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.appText)),
                        Text(b.categoryName ?? '',
                            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(AppIcons.x, size: 20, color: context.appSubtext),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: context.appLine),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current limit info
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.appSurfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.appLine),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Limit saat ini',
                                  style: TextStyle(fontSize: 11, color: context.appSubtext)),
                              const SizedBox(height: 2),
                              Text(Formatter.rupiah(b.limitAmount),
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.appText)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Terpakai',
                                style: TextStyle(fontSize: 11, color: context.appSubtext)),
                            const SizedBox(height: 2),
                            Text(Formatter.rupiah(b.spentAmount),
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Icon(AppIcons.wallet, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text('Limit Baru',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.appText)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _ctrl,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    onChanged: (_) => setState(() => _amountError = null),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: '0',
                      prefixText: 'Rp  ',
                      prefixStyle: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600, color: context.appSubtext),
                      errorText: _amountError,
                      filled: true,
                      fillColor: context.appSurfaceAlt,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.appLine),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.appLine),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.danger),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Bottom buttons
            Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: context.appLine)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: context.appLine),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        foregroundColor: context.appSubtext,
                      ),
                      child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _saving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
