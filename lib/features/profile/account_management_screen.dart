import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_icons.dart';
import '../../core/utils/formatter.dart';
import '../../data/models/account.dart';
import '../../data/repositories/account_repository.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  final _repo = AccountRepository();
  List<Account> _accounts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final accounts = await _repo.getAll();
    if (mounted) setState(() { _accounts = accounts; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Akun Bank & E-Wallet'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.plus, color: Colors.white),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _accounts.isEmpty
              ? Center(child: Text('Belum ada akun', style: TextStyle(color: context.appSubtext)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _accounts.length,
                  itemBuilder: (_, i) => _buildAccountCard(_accounts[i]),
                ),
    );
  }

  Widget _buildAccountCard(Account a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: context.appShadow, blurRadius: 4)],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(AppIcons.wallet, color: AppColors.primary, size: 22),
          ),
          title: Row(
            children: [
              Text(a.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              if (a.isMain) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Utama', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
              ],
            ],
          ),
          subtitle: Text(Formatter.rupiah(a.balance),
              style: TextStyle(color: context.appSubtext, fontSize: 13)),
          trailing: PopupMenuButton(
            icon: const Icon(AppIcons.dotsThreeVertical, color: AppColors.grayText),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit Nama')),
              const PopupMenuItem(value: 'setMain', child: Text('Jadikan Utama')),
              const PopupMenuItem(value: 'delete', child: Text('Hapus')),
            ],
            onSelected: (v) {
              if (v == 'edit') _showEditDialog(a);
              if (v == 'setMain') _setMain(a);
              if (v == 'delete') _deleteAccount(a);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showAddDialog() async {
    final nameCtrl = TextEditingController();
    final balanceCtrl = TextEditingController(text: '0');
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Akun'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama Akun', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: balanceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Saldo Awal (Rp)', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              final balance = double.tryParse(balanceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
              await _repo.insert(Account(name: nameCtrl.text.trim(), balance: balance));
              await _load();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(Account a) async {
    final nameCtrl = TextEditingController(text: a.name);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Nama Akun'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Nama Akun', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              await _repo.update(a.copyWith(name: nameCtrl.text.trim()));
              await _load();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _setMain(Account a) async {
    for (final acc in _accounts) {
      await _repo.update(acc.copyWith(isMain: acc.id == a.id));
    }
    await _load();
  }

  Future<void> _deleteAccount(Account a) async {
    if (a.isMain) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akun utama tidak bisa dihapus')),
      );
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Akun'),
        content: Text('Hapus akun "${a.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _repo.delete(a.id!);
      await _load();
    }
  }
}
