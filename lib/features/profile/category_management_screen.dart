import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_icons.dart';
import '../../data/models/category.dart';
import '../../data/repositories/category_repository.dart';
import '../../widgets/category_badge.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen>
    with SingleTickerProviderStateMixin {
  final _repo = CategoryRepository();
  late TabController _tabCtrl;
  List<Category> _income = [];
  List<Category> _expense = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final all = await _repo.getAll();
    if (mounted) {
      setState(() {
        _income = all.where((c) => c.type == 'income').toList();
        _expense = all.where((c) => c.type == 'expense').toList();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Kategori'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.plus, color: Colors.white),
            onPressed: () => _showAddDialog(),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [Tab(text: 'Pemasukan'), Tab(text: 'Pengeluaran')],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _buildList(_income),
                _buildList(_expense),
              ],
            ),
    );
  }

  Widget _buildList(List<Category> cats) {
    if (cats.isEmpty) {
      return Center(child: Text('Belum ada kategori', style: TextStyle(color: context.appSubtext)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cats.length,
      itemBuilder: (_, i) {
        final c = cats[i];
        final color = CategoryBadge.colorFromHex(c.colorHex);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: context.appSurface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: context.appShadow, blurRadius: 4)],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: ListTile(
              leading: CategoryBadge(iconKey: c.iconKey, color: color, size: 40),
              title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(c.type == 'income' ? 'Pemasukan' : 'Pengeluaran',
                  style: TextStyle(fontSize: 12, color: context.appSubtext)),
              trailing: PopupMenuButton(
                icon: const Icon(AppIcons.dotsThreeVertical, color: AppColors.grayText),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                ],
                onSelected: (v) {
                  if (v == 'edit') _showEditDialog(c);
                  if (v == 'delete') _deleteCategory(c);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddDialog() async {
    final nameCtrl = TextEditingController();
    String type = _tabCtrl.index == 0 ? 'income' : 'expense';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Tambah Kategori'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama Kategori', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Tipe', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'income', child: Text('Pemasukan')),
                  DropdownMenuItem(value: 'expense', child: Text('Pengeluaran')),
                ],
                onChanged: (v) => setS(() => type = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                await _repo.insert(Category(
                  name: nameCtrl.text.trim(),
                  type: type,
                  iconKey: type == 'income' ? 'briefcase' : 'tag',
                  colorHex: type == 'income' ? '#10B981' : '#6B7280',
                ));
                await _load();
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(Category c) async {
    final nameCtrl = TextEditingController(text: c.name);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Kategori'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Nama Kategori', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              await _repo.update(c.copyWith(name: nameCtrl.text.trim()));
              await _load();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(Category c) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Hapus kategori "${c.name}"?'),
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
      await _repo.delete(c.id!);
      await _load();
    }
  }
}
