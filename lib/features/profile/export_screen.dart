import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_icons.dart';
import '../../core/utils/formatter.dart';
import '../../data/repositories/transaction_repository.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final _txRepo = TransactionRepository();
  bool _exporting = false;
  String? _lastExportPath;

  String _selectedMonth = Formatter.currentMonth();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBg,
      appBar: AppBar(backgroundColor: AppColors.primary, title: const Text('Export Data')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Export Transaksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: context.appText)),
            const SizedBox(height: 4),
            Text('Export data transaksi ke file CSV yang bisa dibuka di Excel/Google Sheets.',
                style: TextStyle(color: context.appSubtext, fontSize: 13)),
            const SizedBox(height: 24),
            _buildCard(
              context: context,
              icon: AppIcons.caretLeft,
              title: 'Pilih Bulan',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(AppIcons.caretLeft),
                    onPressed: () => setState(() => _selectedMonth = Formatter.prevMonth(_selectedMonth)),
                  ),
                  Text(Formatter.month(_selectedMonth),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  IconButton(
                    icon: const Icon(AppIcons.caretRight),
                    onPressed: () => setState(() => _selectedMonth = Formatter.nextMonth(_selectedMonth)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildCard(
              context: context,
              icon: AppIcons.export_,
              title: 'Format',
              child: Row(
                children: [
                  const Icon(Icons.table_chart_outlined, color: AppColors.success, size: 32),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CSV (Excel / Google Sheets)', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('Format spreadsheet universal', style: TextStyle(fontSize: 12, color: context.appSubtext)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_lastExportPath != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('File berhasil dibuat!',
                              style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(_lastExportPath!, style: TextStyle(fontSize: 11, color: context.appSubtext)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _exporting ? null : _exportCsv,
                icon: _exporting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(AppIcons.export_),
                label: Text(_exporting ? 'Mengexport...' : 'Export CSV'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required BuildContext context, required IconData icon, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: context.appShadow, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: context.appSubtext, fontSize: 12)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Future<void> _exportCsv() async {
    setState(() { _exporting = true; _lastExportPath = null; });
    try {
      final transactions = await _txRepo.getAll(month: _selectedMonth);
      if (transactions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tidak ada transaksi di ${Formatter.month(_selectedMonth)}')),
          );
        }
        setState(() => _exporting = false);
        return;
      }

      final rows = <List<dynamic>>[
        ['Tanggal', 'Keterangan', 'Kategori', 'Tipe', 'Nominal', 'Akun', 'Catatan'],
      ];
      for (final tx in transactions) {
        rows.add([
          tx.date,
          tx.title,
          tx.categoryName ?? '',
          tx.type == 'income' ? 'Pemasukan' : 'Pengeluaran',
          tx.amount.toStringAsFixed(0),
          tx.accountName ?? '',
          tx.note ?? '',
        ]);
      }

      final csv = const ListToCsvConverter().convert(rows);
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'savery_$_selectedMonth.csv';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(csv);

      if (mounted) {
        setState(() { _lastExportPath = file.path; _exporting = false; });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal export: $e')));
        setState(() => _exporting = false);
      }
    }
  }
}
