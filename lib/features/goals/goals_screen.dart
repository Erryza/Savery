import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatter.dart';
import '../../core/constants/app_icons.dart';
import '../../data/models/goal.dart';
import 'goal_provider.dart';
import 'goal_detail_screen.dart';

const _goalGradient = LinearGradient(
  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

bool goalHasImage(Goal goal) {
  final path = goal.iconOrImagePath;
  return path != null && path.isNotEmpty && File(path).existsSync();
}

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  bool _showAchieved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<GoalProvider>();
    final goals = _showAchieved ? p.achieved : p.ongoing;

    return Scaffold(
      backgroundColor: context.appBg,
      appBar: AppBar(
        backgroundColor: context.appBarColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: context.appShadow,
        automaticallyImplyLeading: false,
        title: Text('Goals',
            style: TextStyle(
                color: context.appText,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.plus, color: AppColors.primary),
            onPressed: () => _showAddGoalDialog(context, p),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(child: _buildGoalList(goals, p)),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final tabs = [
      ('Semua Goal', !_showAchieved, () => setState(() => _showAchieved = false)),
      ('Tercapai', _showAchieved, () => setState(() => _showAchieved = true)),
    ];
    return Container(
      color: context.appBarColor,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final i = entry.key;
          final t = entry.value;
          final active = t.$2;
          return Expanded(
            child: GestureDetector(
              onTap: t.$3,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: EdgeInsets.only(right: i < tabs.length - 1 ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : context.appLine,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  t.$1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: active ? Colors.white : context.appSubtext,
                    fontSize: 10.5,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGoalList(List<Goal> goals, GoalProvider p) {
    if (p.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: context.appPrimaryLight,
                  borderRadius: BorderRadius.circular(20)),
              child:
                  const Icon(Icons.favorite_border, size: 38, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              _showAchieved ? 'Belum ada goal yang tercapai' : 'Belum ada goal',
              style: TextStyle(
                  color: context.appText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            if (!_showAchieved)
              Text('Tekan + untuk membuat goal pertamamu',
                  style: TextStyle(color: context.appSubtext, fontSize: 13)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: goals.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildGoalCard(goals[i], i, p),
      ),
    );
  }

  Widget _buildGoalCard(Goal goal, int index, GoalProvider p) {
    final pct = goal.percentage;
    final barColor = pct >= 1.0 ? AppColors.success : AppColors.primary;
    final hasImage = goalHasImage(goal);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GoalDetailScreen(goalId: goal.id!, index: index),
        ),
      ),
      child: Container(
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appLine),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: hasImage ? null : _goalGradient,
              image: hasImage
                  ? DecorationImage(
                      image: FileImage(File(goal.iconOrImagePath!)),
                      fit: BoxFit.cover)
                  : null,
              borderRadius: BorderRadius.circular(16),
            ),
            child: hasImage
                ? null
                : const Icon(Icons.savings_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(goal.title,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: context.appText),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    if (goal.isAchieved)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(10)),
                        child: const Text('Tercapai!',
                            style: TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                                fontSize: 11)),
                      )
                    else
                      GestureDetector(
                        onTap: () => _showMenu(context, goal, p),
                        child: Icon(AppIcons.dotsThreeVertical,
                            color: context.appSubtext, size: 18),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: Formatter.rupiah(goal.collectedAmount),
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: context.appText),
                      ),
                      TextSpan(
                        text: ' / ${Formatter.rupiah(goal.targetAmount)}',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: context.appSubtext),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct.clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: context.appLine,
                          valueColor: AlwaysStoppedAnimation(barColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('${(pct * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: barColor)),
                  ],
                ),
                if (goal.deadline != null) ...[
                  const SizedBox(height: 6),
                  Text('Target: ${Formatter.date(goal.deadline!)}',
                      style: TextStyle(
                          color: context.appSubtext, fontSize: 11.5)),
                ],
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  void _showMenu(BuildContext context, Goal goal, GoalProvider p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.appSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: context.appLine,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.add_circle_outline_rounded,
                  color: AppColors.primary),
              title: const Text('Tambah Dana'),
              onTap: () {
                Navigator.pop(context);
                _showAddFundsDialog(context, goal, p);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
              title: const Text('Hapus Goal',
                  style: TextStyle(color: AppColors.danger)),
              onTap: () {
                Navigator.pop(context);
                p.deleteGoal(goal.id!);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddGoalDialog(BuildContext context, GoalProvider p) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddGoalSheet(
        onSave: (title, target, deadline, imagePath) => p.addGoal(Goal(
          title: title,
          targetAmount: target,
          deadline: deadline,
          iconOrImagePath: imagePath,
        )),
      ),
    );
  }

  Future<void> _showAddFundsDialog(
      BuildContext context, Goal goal, GoalProvider p) async {
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
}

// ── Add / Edit Goal Sheet ──────────────────────────────────────────────────────

enum _PhotoAction { camera, gallery, remove }

class AddGoalSheet extends StatefulWidget {
  final Goal? initial;
  final Future<void> Function(
      String title, double target, String? deadline, String? imagePath) onSave;

  const AddGoalSheet({super.key, this.initial, required this.onSave});

  @override
  State<AddGoalSheet> createState() => AddGoalSheetState();
}

class AddGoalSheetState extends State<AddGoalSheet> {
  late final _titleCtrl =
      TextEditingController(text: widget.initial?.title ?? '');
  late final _targetCtrl = TextEditingController(
      text: widget.initial == null
          ? ''
          : widget.initial!.targetAmount.toStringAsFixed(0));
  DateTime? _deadline;
  String? _imagePath;
  bool _saving = false;
  String? _titleError;
  String? _amountError;

  bool get _isEdit => widget.initial != null;
  bool get _hasImage => _imagePath != null && File(_imagePath!).existsSync();

  @override
  void initState() {
    super.initState();
    final d = widget.initial?.deadline;
    if (d != null) _deadline = DateTime.tryParse(d);
    _imagePath = widget.initial?.iconOrImagePath;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final action = await showModalBottomSheet<_PhotoAction>(
      context: context,
      backgroundColor: context.appSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: context.appLine, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded, color: AppColors.primary),
              title: const Text('Ambil Foto'),
              onTap: () => Navigator.pop(ctx, _PhotoAction.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(ctx, _PhotoAction.gallery),
            ),
            if (_hasImage)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                title: const Text('Hapus Foto', style: TextStyle(color: AppColors.danger)),
                onTap: () => Navigator.pop(ctx, _PhotoAction.remove),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (action == null) return;
    if (action == _PhotoAction.remove) {
      setState(() => _imagePath = null);
      return;
    }
    final picked = await ImagePicker().pickImage(
      source: action == _PhotoAction.camera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1280,
    );
    if (picked != null) setState(() => _imagePath = picked.path);
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final initial = _deadline != null && _deadline!.isAfter(now)
        ? _deadline!
        : now.add(const Duration(days: 30));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _submit() async {
    setState(() {
      _titleError = null;
      _amountError = null;
    });

    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _titleError = 'Masukkan nama goal terlebih dahulu');
      return;
    }
    final target = double.tryParse(
            _targetCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
        0;
    if (target <= 0) {
      setState(() => _amountError = 'Masukkan target yang valid');
      return;
    }

    setState(() => _saving = true);
    await widget.onSave(
      _titleCtrl.text.trim(),
      target,
      _deadline?.toIso8601String().substring(0, 10),
      _imagePath,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
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
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: context.appPrimaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(AppIcons.target,
                        size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_isEdit ? 'Edit Goal' : 'Buat Goal Baru',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: context.appText)),
                        Text(
                            _isEdit
                                ? 'Perbarui target tabunganmu'
                                : 'Tetapkan target tabunganmu',
                            style: TextStyle(
                                fontSize: 11, color: context.appSubtext)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(AppIcons.x, size: 20, color: context.appSubtext),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: context.appLine),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Foto Goal (Opsional)', Icons.image_outlined),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 130,
                      decoration: BoxDecoration(
                        color: context.appSurfaceAlt,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.appLine),
                        image: _hasImage
                            ? DecorationImage(
                                image: FileImage(File(_imagePath!)),
                                fit: BoxFit.cover)
                            : null,
                      ),
                      child: !_hasImage
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_rounded,
                                    size: 26, color: context.appSubtext),
                                const SizedBox(height: 6),
                                Text('Tambah foto',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 11.5, color: context.appSubtext)),
                              ],
                            )
                          : Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.45),
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.edit_rounded,
                                      size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _fieldLabel('Nama Goal', AppIcons.target),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _titleCtrl,
                    onChanged: (_) => setState(() => _titleError = null),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: 'Misal: Liburan ke Bali',
                      errorText: _titleError,
                      filled: true,
                      fillColor: context.appSurfaceAlt,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.appLine),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.appLine),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.danger),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _fieldLabel('Target Dana', AppIcons.wallet),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _targetCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() => _amountError = null),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: '0',
                      prefixText: 'Rp  ',
                      prefixStyle: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600, color: context.appSubtext),
                      errorText: _amountError,
                      filled: true,
                      fillColor: context.appSurfaceAlt,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.appLine),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.appLine),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.danger),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _fieldLabel('Target Tanggal', AppIcons.calendar),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: _pickDeadline,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: context.appSurfaceAlt,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.appLine),
                      ),
                      child: Row(
                        children: [
                          Icon(AppIcons.calendar, size: 16, color: context.appSubtext),
                          const SizedBox(width: 10),
                          Text(
                            _deadline != null
                                ? Formatter.date(_deadline!.toIso8601String())
                                : 'Opsional',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _deadline != null
                                    ? context.appText
                                    : context.appSubtext),
                          ),
                          const Spacer(),
                          if (_deadline != null)
                            GestureDetector(
                              onTap: () => setState(() => _deadline = null),
                              child: Icon(AppIcons.x, size: 16, color: context.appSubtext),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: context.appLine)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: context.appLine),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        foregroundColor: context.appSubtext,
                      ),
                      child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(_isEdit ? 'Simpan Perubahan' : 'Buat Goal',
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.appText)),
      ],
    );
  }
}

// ── Add Funds Sheet ───────────────────────────────────────────────────────────

class AddFundsSheet extends StatefulWidget {
  final Goal goal;
  final Future<void> Function(double amount) onSave;

  const AddFundsSheet({super.key, required this.goal, required this.onSave});

  @override
  State<AddFundsSheet> createState() => _AddFundsSheetState();
}

class _AddFundsSheetState extends State<AddFundsSheet> {
  final _ctrl = TextEditingController();
  bool _saving = false;
  String? _amountError;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _amountError = null);
    final amount =
        double.tryParse(_ctrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (amount <= 0) {
      setState(() => _amountError = 'Masukkan nominal yang valid');
      return;
    }
    setState(() => _saving = true);
    await widget.onSave(amount);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
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
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: context.appPrimaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(AppIcons.piggyBank,
                        size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tambah Dana',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: context.appText)),
                        Text(goal.title,
                            style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(AppIcons.x, size: 20, color: context.appSubtext),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: context.appLine),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.appSurfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.appLine),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Terkumpul',
                                  style: TextStyle(fontSize: 11, color: context.appSubtext)),
                              const SizedBox(height: 2),
                              Text(Formatter.rupiah(goal.collectedAmount),
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: context.appText)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Target',
                                style: TextStyle(fontSize: 11, color: context.appSubtext)),
                            const SizedBox(height: 2),
                            Text(Formatter.rupiah(goal.targetAmount),
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(AppIcons.wallet, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text('Jumlah Dana',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600, color: context.appText)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _ctrl,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    onChanged: (_) => setState(() => _amountError = null),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: '0',
                      prefixText: 'Rp  ',
                      prefixStyle: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600, color: context.appSubtext),
                      errorText: _amountError,
                      filled: true,
                      fillColor: context.appSurfaceAlt,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.appLine),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.appLine),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.danger),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: context.appLine)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: context.appLine),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        foregroundColor: context.appSubtext,
                      ),
                      child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Tambah', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
