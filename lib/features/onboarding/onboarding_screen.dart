import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main_shell.dart';
import '../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  static const _pages = [
    _PageData(
      title: 'Catat transaksi\nharianmu dengan mudah',
      desc: 'Kelola pemasukan dan pengeluaran\nkapan saja, di mana saja.',
    ),
    _PageData(
      title: 'Atur budget bulanan\nsesuai kebutuhan',
      desc: 'Pantau budget setiap kategori dan\nhindari pengeluaran berlebih.',
    ),
    _PageData(
      title: 'Capai target tabunganmu\nlewat Goals',
      desc: 'Buat tujuan keuangan dan wujudkan\nlangkah demi langkah.',
    ),
  ];

  void _next() {
    if (_page < _pages.length - 1) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const MainShell()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 24, 0),
                  child: TextButton(
                    onPressed: _finish,
                    child: const Text('Lewati',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemCount: _pages.length,
                  itemBuilder: (_, i) => _buildPage(i, _pages[i]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
                child: Column(
                  children: [
                    _buildDots(),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Text(
                          _page == _pages.length - 1 ? 'Mulai' : 'Selanjutnya',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(int index, _PageData page) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 0),
      child: Column(
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: 260,
            child: _Illustration(index: index),
          ),
          const SizedBox(height: 12),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
                height: 1.35),
          ),
          const SizedBox(height: 10),
          Text(
            page.desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 12.5, color: AppColors.grayText, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == _page ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == _page ? AppColors.primary : const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _PageData {
  final String title;
  final String desc;

  const _PageData({required this.title, required this.desc});
}

class _Illustration extends StatelessWidget {
  final int index;
  const _Illustration({required this.index});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // soft blob background
        Container(
          width: 220,
          height: 220,
          decoration: const BoxDecoration(
            color: Color(0xFFEFF4FF),
            shape: BoxShape.circle,
          ),
        ),
        switch (index) {
          0 => const _ClipboardIllustration(),
          1 => const _WalletIllustration(),
          _ => const _TargetIllustration(),
        },
      ],
    );
  }
}

// Small gold coin used across illustrations
class _Coin extends StatelessWidget {
  final double size;
  const _Coin({this.size = 34});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFBBF24),
        border: Border.all(color: const Color(0xFFF59E0B), width: 2),
      ),
      child: Center(
        child: Container(
          width: size * 0.45,
          height: size * 0.45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  final Color color;
  final double size;
  const _Sparkle({required this.color, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.circle, size: size, color: color);
  }
}

// ── Page 1: Clipboard with checklist + coins ──────────────────────────
class _ClipboardIllustration extends StatelessWidget {
  const _ClipboardIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(
              top: 18, left: 24, child: _Sparkle(color: Color(0xFF34D399), size: 12)),
          const Positioned(
              top: 30, right: 30, child: _Sparkle(color: Color(0xFF93C5FD), size: 8)),

          // coin stack behind, bottom-left
          const Positioned(
            left: 22,
            bottom: 30,
            child: _CoinStack(),
          ),

          // clipboard body
          Positioned(
            child: Container(
              width: 112,
              height: 148,
              padding: const EdgeInsets.fromLTRB(14, 26, 14, 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(3, (i) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: i == 2 ? 0 : 14),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),

          // clip tab on top
          const Positioned(
            top: 26,
            child: _ClipTab(),
          ),

          // checkmark badge overlapping bottom-right
          Positioned(
            right: 24,
            bottom: 44,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(Icons.check, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClipTab extends StatelessWidget {
  const _ClipTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 16,
      decoration: BoxDecoration(
        color: const Color(0xFF1D4ED8),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _CoinStack extends StatelessWidget {
  const _CoinStack();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 66,
      child: Stack(
        children: const [
          Positioned(bottom: 0, child: _Coin(size: 38)),
          Positioned(bottom: 14, left: 4, child: _Coin(size: 34)),
          Positioned(bottom: 28, left: 8, child: _Coin(size: 30)),
        ],
      ),
    );
  }
}

// ── Page 2: Wallet with coins + floating chips ────────────────────────
class _WalletIllustration extends StatelessWidget {
  const _WalletIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // floating chip: chart
          Positioned(
            top: 20,
            left: 30,
            child: _Chip(
              color: const Color(0xFF2DD4BF),
              icon: Icons.bar_chart_rounded,
            ),
          ),
          // floating chip: tag/gem
          Positioned(
            top: 10,
            right: 26,
            child: _Chip(
              color: AppColors.accent,
              icon: Icons.diamond_outlined,
            ),
          ),

          // coins near wallet
          const Positioned(top: 66, right: 44, child: _Coin(size: 30)),
          const Positioned(top: 84, right: 66, child: _Coin(size: 24)),

          // wallet body
          Positioned(
            bottom: 30,
            child: Container(
              width: 150,
              height: 104,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 10)),
                ],
              ),
              child: Stack(
                children: [
                  // flap
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  // clasp
                  Positioned(
                    right: 4,
                    top: 6,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFBBF24),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final Color color;
  final IconData icon;
  const _Chip({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Icon(icon, size: 18, color: Colors.white),
    );
  }
}

// ── Page 3: Target with arrow + coins ─────────────────────────────────
class _TargetIllustration extends StatelessWidget {
  const _TargetIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(
              top: 22, left: 34, child: _Sparkle(color: Color(0xFF34D399), size: 12)),
          const Positioned(
              top: 40, right: 28, child: _Sparkle(color: Color(0xFF93C5FD), size: 8)),

          const Positioned(bottom: 26, left: 40, child: _Coin(size: 28)),
          const Positioned(bottom: 18, right: 42, child: _Coin(size: 24)),

          // target rings
          Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 104,
            height: 104,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),

          // arrow
          const CustomPaint(
            size: Size(160, 160),
            painter: _ArrowPainter(),
          ),
        ],
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final shaftPaint = Paint()
      ..color = const Color(0xFF1F2937)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final tip = Offset(size.width * 0.62, size.height * 0.38);
    final tail = Offset(size.width * 0.08, size.height * 0.92);

    canvas.drawLine(tail, tip, shaftPaint);

    // arrow head
    final dir = (tip - tail);
    final len = dir.distance;
    final unit = Offset(dir.dx / len, dir.dy / len);
    final normal = Offset(-unit.dy, unit.dx);
    const headLen = 14.0;
    const headWidth = 8.0;
    final headBase = tip - unit * headLen;
    final p1 = headBase + normal * headWidth;
    final p2 = headBase - normal * headWidth;

    final headPaint = Paint()
      ..color = const Color(0xFF1F2937)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();
    canvas.drawPath(path, headPaint);

    // fletching at tail
    final featherPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final f1 = tail + normal * 10 + unit * 14;
    final f2 = tail - normal * 10 + unit * 14;
    canvas.drawLine(tail, f1, featherPaint);
    canvas.drawLine(tail, f2, featherPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
