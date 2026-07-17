import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatter.dart';
import '../../core/constants/app_icons.dart';
import '../../widgets/savery_progress_bar.dart';
import '../../widgets/category_badge.dart';
import '../transactions/add_transaction_screen.dart';
import '../profile/profile_screen.dart';
import 'home_provider.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onSeeAllTransactions;

  const HomeScreen({super.key, this.onSeeAllTransactions});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<HomeProvider>();
    return Scaffold(
      backgroundColor: context.appBg,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => p.load(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 90),
            children: [
              _buildHeader(p),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                child: Column(
                  children: [
                    _buildBudgetSummary(p),
                    _buildSectionTitle('Transaksi Terbaru',
                        link: 'Lihat semua',
                        onLinkTap: widget.onSeeAllTransactions),
                    _buildRecentTransactions(p),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(AppIcons.plus, color: Colors.white),
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
          if (added == true && context.mounted) {
            context.read<HomeProvider>().load();
          }
        },
      ),
    );
  }

  Widget _buildHeader(HomeProvider p) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(18, 18, 18, 0),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B7DF6), Color(0xFF1D4ED8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, Savery',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Kelola keuanganmu hari ini ✨',
                          style: TextStyle(
                              color: Color(0xFFDBEAFE), fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    ),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(AppIcons.settings,
                          size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Saldo',
                      style:
                          TextStyle(color: Color(0xFFDBEAFE), fontSize: 11)),
                  GestureDetector(
                    onTap: p.toggleBalance,
                    child: Icon(
                      p.balanceVisible ? AppIcons.eye : AppIcons.eyeSlash,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                p.balanceVisible
                    ? Formatter.rupiah(p.mainAccount?.balance ?? 0)
                    : '••••••••••',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -22),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 26),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: context.appSurface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: context.appShadow,
                    blurRadius: 10,
                    offset: const Offset(0, 3)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _balanceStat(
                    'Pemasukan',
                    p.balanceVisible ? Formatter.rupiah(p.income) : '••••',
                    color: AppColors.success,
                  ),
                ),
                Container(width: 1, height: 30, color: context.appLine),
                Expanded(
                  child: _balanceStat(
                    'Pengeluaran',
                    p.balanceVisible ? Formatter.rupiah(p.expense) : '••••',
                    color: AppColors.danger,
                    alignEnd: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _balanceStat(String label, String value,
      {required Color color, bool alignEnd = false}) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(color: context.appSubtext, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 13.5, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildSectionTitle(String title,
      {String? link, VoidCallback? onLinkTap}) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: context.appText)),
          if (link != null)
            GestureDetector(
              onTap: onLinkTap,
              child: Text(link,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
            ),
        ],
      ),
    );
  }

  Widget _buildBudgetSummary(HomeProvider p) {
    final budgets = p.budgets;
    final totalSpent = budgets.fold(0.0, (sum, b) => sum + b.spentAmount);
    final totalLimit = budgets.fold(0.0, (sum, b) => sum + b.limitAmount);
    final pct =
        totalLimit > 0 ? (totalSpent / totalLimit).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.appLine),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4)),
        ],
      ),
      child: budgets.isEmpty
          ? Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.appPrimaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(AppIcons.chartPie,
                      size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Belum ada budget bulan ini',
                      style:
                          TextStyle(color: context.appSubtext, fontSize: 12)),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ringkasan Budget Bulan Ini',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: context.appText)),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${(pct * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: context.appText)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SaveryProgressBar(value: pct, height: 8),
                          const SizedBox(height: 10),
                          Text(
                              '${Formatter.rupiah(totalSpent)} / ${Formatter.rupiah(totalLimit)}',
                              style: TextStyle(
                                  fontSize: 11.5, color: context.appSubtext)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildRecentTransactions(HomeProvider p) {
    if (p.recentTransactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text('Belum ada transaksi',
              style: TextStyle(color: context.appSubtext, fontSize: 12)),
        ),
      );
    }
    return Column(
      children: p.recentTransactions.asMap().entries.map((e) {
        final tx = e.value;
        final isLast = e.key == p.recentTransactions.length - 1;
        final isIncome = tx.type == 'income';
        final color =
            CategoryBadge.colorFromHex(tx.categoryColorHex ?? '#6B7280');
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
          child: Row(
            children: [
              CategoryBadge(
                  iconKey: tx.categoryIconKey ?? 'tag', color: color, size: 38),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: context.appText)),
                    const SizedBox(height: 2),
                    Text(Formatter.relativeDateTime(tx.createdAt),
                        style: TextStyle(
                            fontSize: 10.5, color: context.appSubtext)),
                  ],
                ),
              ),
              Text(
                '${isIncome ? '+' : '-'}${Formatter.rupiah(tx.amount)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isIncome ? AppColors.success : AppColors.danger,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
