import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatter.dart';
import '../../core/constants/app_icons.dart';
import '../../data/models/transaction.dart';
import '../../data/models/category.dart' as cat_model;
import '../../data/models/account.dart';
import '../../widgets/category_badge.dart';
import '../ocr_scan/ocr_scan_screen.dart';
import 'transaction_provider.dart';

class AddTransactionSheet extends StatefulWidget {
  final String initialType;
  const AddTransactionSheet({super.key, this.initialType = 'expense'});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  late String _type;
  cat_model.Category? _selectedCategory;
  Account? _selectedAccount;
  DateTime _selectedDate = DateTime.now();
  String? _receiptImagePath;

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

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TransactionProvider>();
    final cats = p.categories.where((c) => c.type == _type).toList();
    if (_selectedCategory != null && _selectedCategory!.type != _type) {
      _selectedCategory = null;
    }
    if (_selectedAccount == null && p.accounts.isNotEmpty) {
      _selectedAccount = p.accounts.first;
    }

    return Container(
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: context.appLine, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tambah Transaksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(AppIcons.x), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 12),
              _buildTypeToggle(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Nominal', prefixText: 'Rp ', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Masukkan nominal' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Keterangan', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Masukkan keterangan' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<cat_model.Category>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                items: cats.map((c) => DropdownMenuItem<cat_model.Category>(
                  value: c,
                  child: Row(
                    children: [
                      CategoryBadge(iconKey: c.iconKey, color: CategoryBadge.colorFromHex(c.colorHex), size: 28),
                      const SizedBox(width: 8),
                      Text(c.name, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                )).toList(),
                onChanged: (c) => setState(() => _selectedCategory = c),
                validator: (v) => v == null ? 'Pilih kategori' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Account>(
                initialValue: _selectedAccount,
                decoration: const InputDecoration(labelText: 'Akun', border: OutlineInputBorder()),
                items: p.accounts.map((a) => DropdownMenuItem<Account>(value: a, child: Text(a.name))).toList(),
                onChanged: (a) => setState(() => _selectedAccount = a),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                  child: Row(
                    children: [
                      const Icon(AppIcons.calendar, size: 18, color: AppColors.grayText),
                      const SizedBox(width: 8),
                      Text(Formatter.date(_selectedDate.toIso8601String()), style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(labelText: 'Catatan (opsional)', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              // Scan struk button (hanya untuk pengeluaran)
              if (_type == 'expense')
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _openOcrScan,
                    icon: const Icon(Icons.document_scanner_outlined),
                    label: Text(_receiptImagePath != null ? '✓ Struk terlampir' : 'Scan Struk (OCR)'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: _receiptImagePath != null ? AppColors.success : AppColors.primary,
                      side: BorderSide(color: _receiptImagePath != null ? AppColors.success : AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _type == 'income' ? AppColors.success : AppColors.danger,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Simpan ${_type == 'income' ? 'Pemasukan' : 'Pengeluaran'}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      decoration: BoxDecoration(color: context.appSurfaceAlt, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _typeTab('income', 'Pemasukan', AppColors.success),
          _typeTab('expense', 'Pengeluaran', AppColors.danger),
        ],
      ),
    );
  }

  Widget _typeTab(String type, String label, Color color) {
    final active = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(label, style: TextStyle(
              color: active ? Colors.white : context.appSubtext,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            )),
          ),
        ),
      ),
    );
  }

  Future<void> _openOcrScan() async {
    final result = await Navigator.push<OcrResult>(
      context,
      MaterialPageRoute(builder: (_) => const OcrScanScreen()),
    );
    if (result == null) return;
    setState(() {
      _receiptImagePath = result.imagePath;
      if (result.amount != null) {
        _amountCtrl.text = result.amount!.toStringAsFixed(0);
      }
      if (result.title != null && _titleCtrl.text.isEmpty) {
        _titleCtrl.text = result.title!;
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final account = _selectedAccount;
    final category = _selectedCategory;
    if (account == null || category == null) return;

    final amount = double.tryParse(_amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nominal harus lebih dari 0')));
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
    if (mounted) Navigator.pop(context);
  }
}
