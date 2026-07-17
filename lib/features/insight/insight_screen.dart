import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatter.dart';
import '../../core/constants/app_icons.dart';
import 'insight_provider.dart';

class InsightScreen extends StatefulWidget {
  const InsightScreen({super.key});

  @override
  State<InsightScreen> createState() => _InsightScreenState();
}

class _InsightScreenState extends State<InsightScreen> {
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InsightProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<InsightProvider>();
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
        titleSpacing: 16,
        title: Text('Insight',
            style: TextStyle(
                color: context.appText,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      ),
      body: p.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildMonthSelector(p),
                ),
                const SizedBox(height: 20),
                Text('Pengeluaran per Kategori',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: context.appText)),
                const SizedBox(height: 12),
                _buildDonutCard(p),
                const SizedBox(height: 20),
                Text('Pemasukan vs Pengeluaran',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: context.appText)),
                const SizedBox(height: 12),
                _buildComparisonCard(p),
              ],
            ),
    );
  }

  Widget _buildMonthSelector(InsightProvider p) {
    return GestureDetector(
      onTap: () => _showMonthPicker(p),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: context.appShadow, blurRadius: 4, offset: const Offset(0, 1)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(Formatter.month(p.selectedMonth),
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: context.appText)),
            const SizedBox(width: 8),
            Icon(AppIcons.calendar, size: 16, color: context.appSubtext),
          ],
        ),
      ),
    );
  }

  void _showMonthPicker(InsightProvider p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.appSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Consumer<InsightProvider>(
            builder: (context, ip, _) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    icon: const Icon(AppIcons.caretLeft), onPressed: ip.prevMonth),
                Text(Formatter.month(ip.selectedMonth),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: context.appText)),
                IconButton(
                    icon: const Icon(AppIcons.caretRight), onPressed: ip.nextMonth),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDonutCard(InsightProvider p) {
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
      child: p.expenseCategoryTotals.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(AppIcons.chartDonut, size: 48, color: context.appLine),
                    const SizedBox(height: 12),
                    Text('Tidak ada data pengeluaran bulan ini',
                        style: TextStyle(color: context.appSubtext, fontSize: 12),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 130,
                  height: 130,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              setState(() {
                                _touchedIndex =
                                    response?.touchedSection?.touchedSectionIndex ??
                                        -1;
                              });
                            },
                          ),
                          sections: p.expenseCategoryTotals.asMap().entries.map((e) {
                            final i = e.key;
                            final total = (e.value['total'] as num).toDouble();
                            final isTouched = i == _touchedIndex;
                            return PieChartSectionData(
                              color: _colors(p.expenseCategoryTotals.length)[
                                  i % _colors(p.expenseCategoryTotals.length).length],
                              value: total,
                              showTitle: false,
                              radius: isTouched ? 26 : 22,
                            );
                          }).toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 42,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Total',
                              style: TextStyle(
                                  fontSize: 10.5, color: context.appSubtext)),
                          const SizedBox(height: 2),
                          Text(Formatter.rupiahShort(p.totalExpense),
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: context.appText)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: p.expenseCategoryTotals.asMap().entries.map((e) {
                      final i = e.key;
                      final item = e.value;
                      final total = (item['total'] as num).toDouble();
                      final pct =
                          p.totalExpense > 0 ? total / p.totalExpense * 100 : 0.0;
                      final color = _colors(p.expenseCategoryTotals.length)[
                          i % _colors(p.expenseCategoryTotals.length).length];
                      final isLast = i == p.expenseCategoryTotals.length - 1;
                      return Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(top: 2),
                              decoration:
                                  BoxDecoration(color: color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(item['name'] as String? ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: context.appText)),
                            ),
                            const SizedBox(width: 6),
                            Text('${pct.toStringAsFixed(0)}%',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: color)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildComparisonCard(InsightProvider p) {
    final maxOf = p.totalIncome > p.totalExpense ? p.totalIncome : p.totalExpense;
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
      child: Column(
        children: [
          _compareRow('Pemasukan', p.totalIncome, AppColors.success, maxOf),
          const SizedBox(height: 16),
          _compareRow('Pengeluaran', p.totalExpense, AppColors.danger, maxOf),
        ],
      ),
    );
  }

  Widget _compareRow(String label, double value, Color color, double maxOf) {
    final pct = maxOf > 0 ? (value / maxOf).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: context.appSubtext)),
            Text(Formatter.rupiah(value),
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: context.appText)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 10,
            backgroundColor: context.appLine,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  List<Color> _colors(int count) {
    const base = [
      AppColors.primary, AppColors.warning, AppColors.accent,
      AppColors.success, AppColors.danger, Color(0xFF06B6D4),
      Color(0xFFEC4899), Color(0xFF84CC16),
    ];
    return List.generate(count, (i) => base[i % base.length]);
  }
}
