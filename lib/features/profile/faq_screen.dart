import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const _faqs = [
    _Faq('Apakah Savery membutuhkan koneksi internet?',
        'Tidak. Savery berjalan 100% offline. Semua data tersimpan di perangkat Anda dan tidak membutuhkan internet sama sekali.'),
    _Faq('Apakah data saya aman?',
        'Ya. Data Anda tersimpan sepenuhnya di dalam perangkat (local database). Tidak ada data yang dikirim ke server manapun.'),
    _Faq('Bagaimana cara menambah transaksi?',
        'Tekan tombol "+ Pemasukan" atau "− Pengeluaran" di halaman Beranda, atau tekan tombol (+) di tab Transaksi.'),
    _Faq('Bagaimana cara membuat budget?',
        'Buka tab Budget → tekan ikon (+) di kanan atas → pilih kategori dan masukkan limit anggaran.'),
    _Faq('Bagaimana cara membuat Savery Goal?',
        'Buka tab Goals → tekan ikon (+) → isi nama goal dan target nominal. Anda bisa menambah dana ke goal kapan saja.'),
    _Faq('Bagaimana cara export data transaksi?',
        'Buka tab Lainnya → Export Data → pilih bulan → tekan "Export CSV". File CSV akan tersimpan di penyimpanan internal HP.'),
    _Faq('Apakah bisa menambah kategori sendiri?',
        'Ya! Buka tab Lainnya → Kategori → tekan (+) untuk menambah kategori baru sesuai kebutuhan Anda.'),
    _Faq('Bagaimana cara menghapus transaksi?',
        'Di tab Transaksi, tekan dan tahan (long press) item transaksi yang ingin dihapus, lalu konfirmasi penghapusan.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBg,
      appBar: AppBar(backgroundColor: AppColors.primary, title: const Text('Bantuan & FAQ')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _faqs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) => _buildFaqCard(ctx, _faqs[i]),
      ),
    );
  }

  Widget _buildFaqCard(BuildContext context, _Faq faq) {
    return Container(
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: context.appShadow, blurRadius: 4)],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(faq.question,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: context.appText)),
        children: [
          Text(faq.answer, style: TextStyle(fontSize: 13, color: context.appSubtext, height: 1.5)),
        ],
      ),
    );
  }
}

class _Faq {
  final String question;
  final String answer;
  // ignore: unused_element
  const _Faq(this.question, this.answer);
}
