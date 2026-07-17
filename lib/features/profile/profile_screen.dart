import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'category_management_screen.dart';
import 'account_management_screen.dart';
import 'export_screen.dart';
import 'faq_screen.dart';
import 'about_screen.dart';
import '../insight/insight_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _go(BuildContext context, Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: context.appBarColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: context.appShadow,
        title: Text(
          'Pengaturan',
          style: TextStyle(
              color: context.appText,
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        children: [
          _buildSectionLabel(context, 'Kelola Data'),
          const SizedBox(height: 8),
          _buildGroup(context, [
            _Item(
              icon: Icons.pie_chart_rounded,
              label: 'Insight',
              subtitle: 'Analisis pengeluaran & pemasukan',
              color: AppColors.primary,
              onTap: () => _go(context, const InsightScreen()),
            ),
            _Item(
              icon: Icons.category_rounded,
              label: 'Kategori',
              subtitle: 'Kelola kategori transaksi',
              color: AppColors.warning,
              onTap: () => _go(context, const CategoryManagementScreen()),
            ),
            _Item(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Akun & Dompet',
              subtitle: 'Kelola akun dan saldo',
              color: AppColors.success,
              onTap: () => _go(context, const AccountManagementScreen()),
            ),
            _Item(
              icon: Icons.ios_share_rounded,
              label: 'Export Data',
              subtitle: 'Ekspor transaksi ke CSV',
              color: AppColors.accent,
              onTap: () => _go(context, const ExportScreen()),
            ),
          ]),
          const SizedBox(height: 20),
          _buildSectionLabel(context, 'Lainnya'),
          const SizedBox(height: 8),
          _buildGroup(context, [
            _Item(
              icon: Icons.help_center_rounded,
              label: 'Bantuan & FAQ',
              subtitle: 'Pertanyaan yang sering ditanya',
              color: AppColors.primary,
              onTap: () => _go(context, const FaqScreen()),
            ),
            _Item(
              icon: Icons.verified_rounded,
              label: 'Tentang Savery',
              subtitle: 'Versi dan informasi aplikasi',
              color: const Color(0xFF8B5CF6),
              onTap: () => _go(context, const AboutScreen()),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: context.appSubtext,
          letterSpacing: 0.4),
    );
  }

  Widget _buildGroup(BuildContext context, List<_Item> items) {
    return Container(
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appLine),
        boxShadow: [BoxShadow(color: context.appShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          final isLast = i == items.length - 1;
          return Column(
            children: [
              InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.vertical(
                  top: i == 0 ? const Radius.circular(16) : Radius.zero,
                  bottom: isLast ? const Radius.circular(16) : Radius.zero,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon, color: item.color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.label,
                                style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    color: context.appText)),
                            const SizedBox(height: 1),
                            Text(item.subtitle,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: context.appSubtext)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          size: 18, color: AppColors.grayText),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(height: 1, indent: 66, color: context.appLine),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _Item {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _Item({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}
