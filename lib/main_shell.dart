import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_provider.dart';
import 'features/home/home_screen.dart';
import 'features/transactions/transaction_provider.dart';
import 'features/transactions/transactions_screen.dart';
import 'features/budget/budget_provider.dart';
import 'features/budget/budget_screen.dart';
import 'features/goals/goal_provider.dart';
import 'features/goals/goals_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  List<Widget> get _screens => [
        HomeScreen(onSeeAllTransactions: () => _onTabTap(1)),
        const TransactionsScreen(),
        const BudgetScreen(),
        const GoalsScreen(),
      ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..value = 1.0;
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.96, end: 1.0)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _onTabTap(int i) async {
    if (i == _currentIndex) return;
    await _animCtrl.reverse();
    setState(() => _currentIndex = i);
    _refreshTab(i);
    _animCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: IndexedStack(index: _currentIndex, children: _screens),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: _onTabTap,
        items: [
          _navItem(Icons.home_rounded, 'Beranda'),
          _navItem(Icons.receipt_long_rounded, 'Transaksi'),
          _navItem(Icons.account_balance_wallet_rounded, 'Budget'),
          _navItem(Icons.track_changes_rounded, 'Goals'),
        ],
      ),
    );
  }

  BottomNavigationBarItem _navItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon, color: context.appSubtext),
      activeIcon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: context.appPrimaryLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      label: label,
    );
  }

  void _refreshTab(int i) {
    switch (i) {
      case 0:
        context.read<HomeProvider>().load();
      case 1:
        context.read<TransactionProvider>().load();
      case 2:
        context.read<BudgetProvider>().load();
      case 3:
        context.read<GoalProvider>().load();
    }
  }
}
