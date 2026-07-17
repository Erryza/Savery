import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatter.dart';
import '../../data/models/transaction.dart';
import '../../data/models/category.dart' as cat_model;
import '../../data/models/account.dart';
import '../../widgets/category_badge.dart';
import '../ocr_scan/ocr_scan_screen.dart';
import 'transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final String initialType;
  const AddTransactionScreen({super.key, this.initialType = 'expense'});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  late String _type;
  cat_model.Category? _selectedCategory;
  Account? _selectedAccount;
  DateTime _selectedDate = DateTime.now();
  String? _receiptImagePath;
  bool _categoryError = false;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<TransactionProvider>();
      if (p.accounts.isEmpty || p.categories.isEmpty) p.load();
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  bool get _isIncome => _type == 'income';
  Color get _typeColor => _isIncome ? AppColors.success : AppColors.danger;
  Color get _typeColorDark =>
      _isIncome ? const Color(0xFF059669) : const Color(0xFFB91C1C);

  void _setType(String t) {
    if (_type == t) return;
    setState(() {
      _type = t;
      _selectedCategory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TransactionProvider>();
    final cats = p.categories.where((c) => c.type == _type).toList();
    if (_selectedAccount == null && p.accounts.isNotEmpty) {
      _selectedAccount = p.accounts.first;
    }

    return Scaffold(
      backgroundColor: context.appBg,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                children: [
                  _buildFormCard(cats, p),
                  const SizedBox(height: 16),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_typeColor, _typeColorDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 10,
        16,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Tambah Transaksi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(3),
            child: Row(
              children: [
                _typeTab('expense', 'Pengeluaran'),
                _typeTab('income', 'Pemasukan'),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Jumlah',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
            decoration: const InputDecoration(
              prefixText: 'Rp ',
              prefixStyle: TextStyle(
                color: Colors.white70,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
              border: InputBorder.none,
              hintText: '0',
              hintStyle: TextStyle(
                color: Colors.white38,
                fontSize: 34,
                fontWeight: FontWeight.w700,
              ),
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Masukkan jumlah' : null,
          ),
        ],
      ),
    );
  }

  Widget _typeTab(String type, String label) {
    final active = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => _setType(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? _typeColor : Colors.white70,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(List<cat_model.Category> cats, TransactionProvider p) {
    return Column(
      children: [
        _fieldCard(
          icon: Icons.edit_note_rounded,
          iconColor: AppColors.primary,
          label: 'Keterangan',
          child: TextFormField(
            controller: _titleCtrl,
            decoration: _inputDeco('Tulis keterangan transaksi'),
            validator: (v) => (v == null || v.isEmpty) ? 'Masukkan keterangan' : null,
          ),
        ),
        const SizedBox(height: 12),
        _fieldCard(
          icon: Icons.label_rounded,
          iconColor: AppColors.warning,
          label: 'Kategori',
          child: _selectorField(
            onTap: () => _showCategoryPicker(cats),
            hint: 'Pilih kategori',
            hasError: _categoryError,
            child: _selectedCategory == null
                ? null
                : Row(
                    children: [
                      CategoryBadge(
                        iconKey: _selectedCategory!.iconKey,
                        color: CategoryBadge.colorFromHex(_selectedCategory!.colorHex),
                        size: 26,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_selectedCategory!.name,
                            style: TextStyle(fontSize: 14, color: context.appText),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        _fieldCard(
          icon: Icons.account_balance_wallet_rounded,
          iconColor: AppColors.success,
          label: 'Akun',
          child: _selectorField(
            onTap: () => _showAccountPicker(p.accounts),
            hint: 'Pilih akun',
            child: _selectedAccount == null
                ? null
                : Text(_selectedAccount!.name,
                    style: TextStyle(fontSize: 14, color: context.appText)),
          ),
        ),
        const SizedBox(height: 12),
        _fieldCard(
          icon: Icons.calendar_today_rounded,
          iconColor: AppColors.accent,
          label: 'Tanggal',
          child: _selectorField(
            onTap: _pickDate,
            hint: 'Pilih tanggal',
            child: Text(
              Formatter.date(_selectedDate.toIso8601String()),
              style: TextStyle(fontSize: 14, color: context.appText),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _fieldCard(
          icon: Icons.sticky_note_2_rounded,
          iconColor: const Color(0xFF8B5CF6),
          label: 'Catatan (Opsional)',
          child: TextFormField(
            controller: _noteCtrl,
            maxLines: 2,
            decoration: _inputDeco('Tulis catatan...'),
          ),
        ),
        if (!_isIncome) ...[
          const SizedBox(height: 12),
          _scanCard(),
        ],
      ],
    );
  }

  Widget _fieldCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appLine),
        boxShadow: [
          BoxShadow(
              color: context.appShadow, blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.appSubtext,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectorField({
    required VoidCallback onTap,
    required String hint,
    Widget? child,
    bool hasError = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: context.appSurfaceAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: hasError ? AppColors.danger : context.appLine),
        ),
        child: Row(
          children: [
            Expanded(
              child: child ??
                  Text(hint,
                      style: TextStyle(color: context.appSubtext, fontSize: 13.5)),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: context.appSubtext, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _showCategoryPicker(List<cat_model.Category> cats) async {
    final selected = await showModalBottomSheet<cat_model.Category>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet(
        title: 'Pilih Kategori',
        itemCount: cats.length,
        itemBuilder: (ctx, i) {
          final c = cats[i];
          final active = c.id == _selectedCategory?.id;
          return _pickerTile(
            active: active,
            onTap: () => Navigator.pop(ctx, c),
            leading: CategoryBadge(
              iconKey: c.iconKey,
              color: CategoryBadge.colorFromHex(c.colorHex),
              size: 32,
            ),
            label: c.name,
          );
        },
      ),
    );
    if (selected != null) {
      setState(() {
        _selectedCategory = selected;
        _categoryError = false;
      });
    }
  }

  Future<void> _showAccountPicker(List<Account> accounts) async {
    final selected = await showModalBottomSheet<Account>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet(
        title: 'Pilih Akun',
        itemCount: accounts.length,
        itemBuilder: (ctx, i) {
          final a = accounts[i];
          final active = a.id == _selectedAccount?.id;
          return _pickerTile(
            active: active,
            onTap: () => Navigator.pop(ctx, a),
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: context.appPrimaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded,
                  size: 16, color: AppColors.primary),
            ),
            label: a.name,
          );
        },
      ),
    );
    if (selected != null) setState(() => _selectedAccount = selected);
  }

  Widget _pickerTile({
    required bool active,
    required VoidCallback onTap,
    required Widget leading,
    required String label,
  }) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: active ? AppColors.primary.withValues(alpha: 0.06) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      color: active ? AppColors.primary : context.appText)),
            ),
            if (active)
              const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _scanCard() {
    final attached = _receiptImagePath != null;
    final color = attached ? AppColors.success : AppColors.primary;
    return InkWell(
      onTap: _openOcrScan,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appLine),
          boxShadow: [
            BoxShadow(
                color: context.appShadow, blurRadius: 10, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.document_scanner_rounded, size: 16, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scan Struk',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.appSubtext,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    attached ? 'Struk terlampir ✓' : 'Tap untuk scan struk belanja',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: context.appSubtext),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: context.appSubtext, fontSize: 13.5),
        filled: true,
        fillColor: context.appSurfaceAlt,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.appLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.appLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        errorStyle: const TextStyle(fontSize: 11),
      );

  Widget _buildSubmitButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _typeColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        icon: const Icon(Icons.check_circle_rounded, size: 20),
        label: Text(
          'Simpan ${_isIncome ? 'Pemasukan' : 'Pengeluaran'}',
          style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _openOcrScan() async {
    final result = await Navigator.push<OcrResult>(
        context, MaterialPageRoute(builder: (_) => const OcrScanScreen()));
    if (result == null) return;
    setState(() {
      _receiptImagePath = result.imagePath;
      if (result.amount != null)
        _amountCtrl.text = result.amount!.toStringAsFixed(0);
      if (result.title != null && _titleCtrl.text.isEmpty)
        _titleCtrl.text = result.title!;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _categoryError = _selectedCategory == null);
    final account = _selectedAccount;
    final category = _selectedCategory;
    if (account == null || category == null) return;

    final amount =
        double.tryParse(_amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
            0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jumlah harus lebih dari 0')));
      return;
    }

    final tx = Transaction(
      accountId: account.id!,
      categoryId: category.id!,
      type: _type,
      amount: amount,
      title: _titleCtrl.text.trim(),
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      date: _selectedDate.toIso8601String().substring(0, 10),
      receiptImagePath: _receiptImagePath,
      createdAt: DateTime.now().toIso8601String(),
    );

    await context.read<TransactionProvider>().addTransaction(tx);
    if (mounted) Navigator.pop(context, true);
  }
}

// ── Picker Sheet ──────────────────────────────────────────────────────────────

class _PickerSheet extends StatelessWidget {
  final String title;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  const _PickerSheet({
    required this.title,
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
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
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: context.appLine, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.appText)),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 20, color: context.appSubtext),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.appLine),
          Flexible(
            child: itemCount == 0
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Tidak ada data',
                        style: TextStyle(color: context.appSubtext, fontSize: 13)),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom + 12),
                    itemCount: itemCount,
                    separatorBuilder: (_, __) => Divider(
                        height: 1, indent: 20, endIndent: 20, color: context.appLine),
                    itemBuilder: itemBuilder,
                  ),
          ),
        ],
      ),
    );
  }
}
