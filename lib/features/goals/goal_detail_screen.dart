import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatter.dart';
import '../../core/constants/app_icons.dart';
import '../../data/models/goal.dart';
import 'goal_provider.dart';
import 'goals_screen.dart' show AddGoalSheet, AddFundsSheet, goalHasImage;

class GoalDetailScreen extends StatefulWidget {
  final int goalId;
  final int index;

  const GoalDetailScreen({super.key, required this.goalId, required this.index});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalProvider>().loadContributions(widget.goalId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<GoalProvider>();
    Goal? goal;
    for (final g in p.goals) {
      if (g.id == widget.goalId) {
        goal = g;
        break;
      }
    }

    if (goal == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) Navigator.pop(context);
      });
      return Scaffold(backgroundColor: context.appBg, body: const SizedBox());
    }

    final pct = goal.percentage;

    final deadline = goal.deadline;
    Color deadlineColor = context.appSubtext;
    if (deadline != null) {
      final dt = DateTime.tryParse(deadline);
      if (dt != null) {
        final now = DateTime.now();
        final days = DateTime(dt.year, dt.month, dt.day)
            .difference(DateTime(now.year, now.month, now.day))
            .inDays;
        if (goal.isAchieved) {
          deadlineColor = AppColors.success;
        } else if (days < 0) {
          deadlineColor = AppColors.danger;
        } else if (days == 0) {
          deadlineColor = AppColors.warning;
        }
      }
    }

    return Scaffold(
      backgroundColor: context.appBg,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildBanner(context, goal),
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.appSurface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(goal.title,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: context.appText),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                          ),
                          if (goal.isAchieved)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFD1FAE5),
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Text('Tercapai!',
                                  style: TextStyle(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: Formatter.rupiah(goal.collectedAmount),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: context.appText),
                                  ),
                                  TextSpan(
                                    text: ' / ${Formatter.rupiah(goal.targetAmount)}',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: context.appSubtext),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text('${(pct * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: pct >= 1.0
                                      ? AppColors.success
                                      : AppColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: pct.clamp(0.0, 1.0),
                          minHeight: 9,
                          backgroundColor: context.appLine,
                          valueColor: AlwaysStoppedAnimation(
                              pct >= 1.0 ? AppColors.success : AppColors.primary),
                        ),
                      ),
                      if (deadline != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Target: ${Formatter.date(deadline)}',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: deadlineColor),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Setoran Terakhir',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: context.appText)),
                      const SizedBox(height: 10),
                      _buildContributionsList(context, p),
                    ],
                  ),
                ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildBottomBar(context, goal, p),
        ],
      ),
    );
  }

  Widget _buildBanner(BuildContext context, Goal goal) {
    final hasImage = goalHasImage(goal);
    return Stack(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: hasImage
                ? null
                : const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            image: hasImage
                ? DecorationImage(
                    image: FileImage(File(goal.iconOrImagePath!)),
                    fit: BoxFit.cover)
                : null,
          ),
          child: hasImage
              ? null
              : const Center(
                  child: Icon(Icons.savings_rounded,
                      color: Colors.white70, size: 64),
                ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 16,
          child: PopupMenuButton<String>(
            icon: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(AppIcons.dotsThreeVertical,
                  color: Colors.white, size: 20),
            ),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Hapus')),
            ],
            onSelected: (v) {
              final p = context.read<GoalProvider>();
              if (v == 'edit') _showEdit(context, goal, p);
              if (v == 'delete') _confirmDelete(context, goal, p);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContributionsList(BuildContext context, GoalProvider p) {
    if (p.contributions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appLine),
        ),
        child: Center(
          child: Text('Belum ada setoran',
              style: TextStyle(color: context.appSubtext, fontSize: 12)),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appLine),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: p.contributions.asMap().entries.map((e) {
          final isLast = e.key == p.contributions.length - 1;
          final c = e.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(Formatter.date(c.date),
                        style: TextStyle(fontSize: 13, color: context.appText)),
                    Text('+${Formatter.rupiah(c.amount)}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success)),
                  ],
                ),
              ),
              if (!isLast) Divider(height: 1, color: context.appLine),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, Goal goal, GoalProvider p) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          18, 12, 18, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: context.appSurface,
        border: Border(top: BorderSide(color: context.appLine)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _showAddFunds(context, goal, p),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          icon: const Icon(AppIcons.plus, size: 20),
          label: const Text('Tambah Setoran',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Future<void> _showAddFunds(BuildContext context, Goal goal, GoalProvider p) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddFundsSheet(
        goal: goal,
        onSave: (amount) => p.addFunds(goal.id!, amount),
      ),
    );
  }

  Future<void> _showEdit(BuildContext context, Goal goal, GoalProvider p) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddGoalSheet(
        initial: goal,
        onSave: (title, target, deadline, imagePath) => p.updateGoal(Goal(
          id: goal.id,
          title: title,
          targetAmount: target,
          collectedAmount: goal.collectedAmount,
          iconOrImagePath: imagePath,
          status: goal.status,
          deadline: deadline,
        )),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Goal goal, GoalProvider p) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Goal'),
        content: Text('Yakin ingin menghapus goal "${goal.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await p.deleteGoal(goal.id!);
      if (context.mounted) Navigator.pop(context);
    }
  }
}
