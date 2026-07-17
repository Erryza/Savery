import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBg,
      appBar: AppBar(backgroundColor: AppColors.primary, title: const Text('Tentang Savery')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Center(
                child: Text('S', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Savery', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: context.appText)),
            Text('Versi 1.0.0', style: TextStyle(color: context.appSubtext, fontSize: 14)),
            const SizedBox(height: 32),
            _infoCard(context, 'Deskripsi',
                'Savery adalah aplikasi pencatatan keuangan pribadi yang dirancang untuk membantu Anda mengelola pemasukan, pengeluaran, anggaran, dan tabungan secara cerdas — sepenuhnya offline dan gratis.'),
            const SizedBox(height: 12),
            _infoCard(context, 'Versi', '1.0.0 (Build 1)'),
            const SizedBox(height: 12),
            _infoCard(context, 'Platform', 'Android (Flutter)'),
            const SizedBox(height: 12),
            _infoCard(context, 'Data', '100% tersimpan lokal di perangkat Anda. Tidak ada data yang dikirim ke server.'),
            const SizedBox(height: 32),
            Text('Dibuat dengan ❤️ menggunakan Flutter',
                style: TextStyle(color: context.appSubtext, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(BuildContext context, String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: context.appShadow, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: context.appSubtext, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: context.appText)),
        ],
      ),
    );
  }
}
