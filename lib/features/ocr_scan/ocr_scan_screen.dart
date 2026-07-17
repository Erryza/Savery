import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_icons.dart';
import '../../core/utils/formatter.dart';

class OcrResult {
  final double? amount;
  final String? title;
  final String imagePath;

  const OcrResult({this.amount, this.title, required this.imagePath});
}

class _OcrLine {
  final String text;
  final Rect? box;
  _OcrLine(this.text, this.box);
}

class OcrScanScreen extends StatefulWidget {
  const OcrScanScreen({super.key});

  @override
  State<OcrScanScreen> createState() => _OcrScanScreenState();
}

class _OcrScanScreenState extends State<OcrScanScreen> {
  File? _image;
  bool _processing = false;
  String? _rawText;
  double? _detectedAmount;
  String? _detectedTitle;
  String _status = 'Ambil foto atau pilih dari galeri';

  final _picker = ImagePicker();
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  void dispose() {
    _recognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Scan Struk'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _sourceButton(
                    icon: Icons.camera_alt_outlined,
                    label: 'Kamera',
                    color: AppColors.primary,
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _sourceButton(
                    icon: Icons.photo_library_outlined,
                    label: 'Galeri',
                    color: AppColors.accent,
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              height: 220,
              decoration: BoxDecoration(
                color: context.appSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.appLine),
              ),
              child: _image == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 56, color: context.appLine),
                        const SizedBox(height: 12),
                        Text(_status, style: TextStyle(color: context.appSubtext, fontSize: 13)),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(_image!, fit: BoxFit.cover, width: double.infinity),
                    ),
            ),

            if (_processing) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 8),
              Center(child: Text('Membaca teks struk...', style: TextStyle(color: context.appSubtext))),
            ],

            if (_image != null && !_processing) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.appSurface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: context.appShadow, blurRadius: 6)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hasil Deteksi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: context.appText)),
                    const SizedBox(height: 12),
                    _resultRow('Nominal', _detectedAmount != null
                        ? Formatter.rupiah(_detectedAmount!)
                        : 'Tidak terdeteksi — isi manual'),
                    const SizedBox(height: 8),
                    _resultRow('Keterangan', _detectedTitle ?? 'Tidak terdeteksi — isi manual'),
                    if (_rawText != null) ...[
                      Divider(height: 20, color: context.appLine),
                      Text('Teks yang terbaca:', style: TextStyle(fontSize: 12, color: context.appSubtext)),
                      const SizedBox(height: 6),
                      Text(_rawText!, style: TextStyle(fontSize: 11, color: context.appText)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, OcrResult(
                  amount: _detectedAmount,
                  title: _detectedTitle,
                  imagePath: _image!.path,
                )),
                icon: const Icon(AppIcons.caretRight),
                label: const Text('Gunakan Hasil Ini'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sourceButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 90, child: Text(label, style: TextStyle(color: context.appSubtext, fontSize: 13))),
        Text(': ', style: TextStyle(color: context.appSubtext)),
        Expanded(child: Text(value, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: context.appText))),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 90);
    if (picked == null) return;
    setState(() {
      _image = File(picked.path);
      _processing = true;
      _rawText = null;
      _detectedAmount = null;
      _detectedTitle = null;
      _status = 'Membaca struk...';
    });
    await _runOcr(picked.path);
  }

  Future<void> _runOcr(String path) async {
    try {
      final inputImage = InputImage.fromFilePath(path);
      final recognized = await _recognizer.processImage(inputImage);

      // Debug: print full OCR text and block structure
      debugPrint('=== OCR FULL TEXT ===\n${recognized.text}');
      for (int bi = 0; bi < recognized.blocks.length; bi++) {
        final b = recognized.blocks[bi];
        debugPrint('BLOCK[$bi] box=${b.boundingBox} text=${b.text.replaceAll('\n', '|')}');
      }

      setState(() {
        final full = recognized.text;
        _rawText = full; // show full text for debugging
        _detectedAmount = _extractAmount(recognized);
        _detectedTitle = _extractTitle(recognized);
        _processing = false;
        _status = 'Selesai';
      });
    } catch (e) {
      setState(() {
        _processing = false;
        _status = 'Gagal membaca: $e';
      });
    }
  }

  // Kumpulkan semua baris beserta bounding box dari seluruh blocks
  List<_OcrLine> _collectLines(RecognizedText recognized) {
    final lines = <_OcrLine>[];
    for (final block in recognized.blocks) {
      for (final line in block.lines) {
        lines.add(_OcrLine(line.text, line.boundingBox));
      }
    }
    return lines;
  }

  // Cari nominal total dari struk
  double? _extractAmount(RecognizedText recognized) {
    // --- 1. Spesifik Alfamart/Indomaret: Total Belanja = Total Item - Total Disc ---
    final totalBelanja = _amountForKeyword(recognized, RegExp(r'total\s*belanj', caseSensitive: false));
    final totalItem    = _amountForKeyword(recognized, RegExp(r'total\s*item', caseSensitive: false), minAmount: 100);
    final totalDisc    = _amountForKeyword(recognized, RegExp(r'total\s*dis', caseSensitive: false), minAmount: 0);

    if (totalItem != null && totalItem > 1000) {
      final calculated = totalItem - (totalDisc ?? 0);
      if (calculated > 100) {
        if (totalBelanja == null || (totalBelanja - calculated).abs() > calculated * 0.3) {
          return calculated;
        }
        return totalBelanja;
      }
    }
    if (totalBelanja != null) return totalBelanja;

    // --- 2. Grand Total / Total Bayar (berbagai format) ---
    final grandTotal = _amountForKeyword(recognized, RegExp(r'grand\s*total', caseSensitive: false));
    if (grandTotal != null) return grandTotal;

    final totalBayar = _amountForKeyword(recognized,
        RegExp(r'total\s*(?:bayar|payment|amount|due|tagihan)', caseSensitive: false));
    if (totalBayar != null) return totalBayar;

    // --- 3. Generic "Total" (bukan Sub Total / Total Item / Total Disc) ---
    // \btota menangkap OCR misread: "Tota)", "Tota1", "Totai", dll
    final genericTotal = _bottommostAmount(recognized,
        RegExp(r'\btota', caseSensitive: false),
        exclude: RegExp(r'sub|item|disc|belanj|bayar|payment|dasar|pengenaan', caseSensitive: false));
    if (genericTotal != null) return genericTotal;

    // --- 4. Cash - Kembali (lebih andal dari Sub Total untuk total akhir) ---
    final cashAmount = _amountForKeyword(recognized, RegExp(r'\bcash\b|\btunai\b', caseSensitive: false));
    // Kembali: ke.{0,2}bal menangkap "Kembali","Kenbali","Kebali","Keembali" dll
    final kembali    = _amountForKeyword(recognized,
        RegExp(r'ke.{0,2}bal|kembali|kembalian|change', caseSensitive: false), minAmount: 0);
    if (cashAmount != null && kembali != null) {
      final calc = cashAmount - kembali;
      if (calc > 100) return calc;
    }
    // Cash = Total HANYA jika tidak ada tanda kembalian di seluruh teks OCR
    final hasChangeText = RegExp(r'ke.{0,2}bal|kembali|kembalian|change', caseSensitive: false)
        .hasMatch(recognized.text);
    if (cashAmount != null && kembali == null && !hasChangeText) return cashAmount;

    // --- 5. Sub Total (harga sebelum pajak, last resort) ---
    final subTotal = _amountForKeyword(recognized, RegExp(r'sub\s*total', caseSensitive: false));
    if (subTotal != null) return subTotal;

    // --- 6. Fallback: angka terbesar >= 1000, kecuali angka Cash ---
    double? biggest;
    for (final block in recognized.blocks) {
      for (final n in _allValidAmounts(block.text)) {
        if (n >= 1000 && n != cashAmount && (biggest == null || n > biggest)) biggest = n;
      }
    }
    return biggest ?? cashAmount;
  }

  // Kumpulkan semua (TextLine, TextBlock) dari seluruh blocks
  List<({TextLine line, TextBlock block})> _allLines(RecognizedText recognized) {
    final result = <({TextLine line, TextBlock block})>[];
    for (final block in recognized.blocks) {
      for (final line in block.lines) {
        result.add((line: line, block: block));
      }
    }
    return result;
  }

  // Cari angka di baris paling bawah (Y terbesar) yang cocok keyword — cek per LINE
  double? _bottommostAmount(RecognizedText recognized, RegExp kw, {RegExp? exclude}) {
    double bestY = double.negativeInfinity;
    double? bestAmount;

    for (final entry in _allLines(recognized)) {
      final lineText = entry.line.text;
      if (!kw.hasMatch(lineText)) continue;
      if (exclude != null && exclude.hasMatch(lineText)) continue;

      final box = entry.line.boundingBox;
      final cy = box != null ? (box.top + box.bottom) / 2.0 : 0.0;
      if (cy <= bestY) continue;

      // Cek angka dalam baris itu sendiri
      final inLine = _largestInText(lineText);
      if (inLine != null) { bestY = cy; bestAmount = inLine; continue; }

      // Cek baris lain di Y yang sama (kolom kanan)
      if (box != null) {
        double? rowBest;
        for (final other in _allLines(recognized)) {
          final ob = other.line.boundingBox;
          if (ob == null || other.line == entry.line) continue;
          if (ob.top < box.bottom && ob.bottom > box.top) {
            final n = _largestInText(other.line.text);
            if (n != null && (rowBest == null || n > rowBest)) rowBest = n;
          }
        }
        if (rowBest != null) { bestY = cy; bestAmount = rowBest; }
      }
    }
    return bestAmount;
  }

  // Cari angka di baris yang sama dengan keyword — cek per LINE
  double? _amountForKeyword(RecognizedText recognized, RegExp kw, {double minAmount = 1000}) {
    for (final entry in _allLines(recognized)) {
      final lineText = entry.line.text;
      if (!kw.hasMatch(lineText)) continue;

      final inLine = _largestInText(lineText, minAmount: minAmount);
      if (inLine != null) return inLine;

      final box = entry.line.boundingBox;
      if (box != null) {
        double? rowBest;
        for (final other in _allLines(recognized)) {
          final ob = other.line.boundingBox;
          if (ob == null || other.line == entry.line) continue;
          if (ob.top < box.bottom && ob.bottom > box.top) {
            final n = _largestInText(other.line.text, minAmount: minAmount);
            if (n != null && (rowBest == null || n > rowBest)) rowBest = n;
          }
        }
        if (rowBest != null) return rowBest;
      }
    }
    return null;
  }

  double? _largestInText(String text, {double minAmount = 1000}) {
    final all = _allValidAmounts(text).where((n) => n >= minAmount).toList();
    if (all.isEmpty) return null;
    all.sort((a, b) => b.compareTo(a));
    return all.first;
  }

  // Semua angka valid sebagai harga dalam satu string
  List<double> _allValidAmounts(String text) {
    final results = <double>[];
    // Cocokkan: 11.000 / 11,000 / 10, 900 (koma+spasi) / 11000 (>= 3 digit)
    final rx = RegExp(r'\d{1,3}(?:[.,]\s*\d{3})+|\b\d{3,}\b');
    for (final m in rx.allMatches(text)) {
      final raw = m.group(0)!;
      // Skip jika langsung diikuti huruf (satuan: ML, PCS, KG)
      final end = m.end;
      if (end < text.length && RegExp(r'[a-zA-Z]').hasMatch(text[end])) continue;
      final n = _parseNumber(raw.replaceAll(RegExp(r'\s'), ''));
      if (n != null && n > 0) results.add(n);
    }
    return results;
  }

  double? _largestValidAmount(String text) {
    final all = _allValidAmounts(text).where((n) => n >= 100).toList();
    if (all.isEmpty) return null;
    all.sort((a, b) => b.compareTo(a));
    return all.first;
  }

  double? _parseNumber(String s) {
    // Hapus pemisah ribuan (titik/koma sebelum tepat 3 digit)
    String clean = s.replaceAll(RegExp(r'[.,](?=\d{3}(?:[.,]|$))'), '');
    clean = clean.replaceAll(',', '.');
    return double.tryParse(clean.replaceAll(RegExp(r'[^0-9.]'), ''));
  }

  // Ambil nama merchant/judul dari baris pertama yang bukan angka
  String? _extractTitle(RecognizedText recognized) {
    final lines = _collectLines(recognized);
    for (final line in lines.take(8)) {
      final t = line.text.trim();
      if (t.length > 3 &&
          !RegExp(r'^\d').hasMatch(t) &&
          !t.contains('www') &&
          !t.contains('@') &&
          !RegExp(r'^\W+$').hasMatch(t)) {
        return t.length > 30 ? t.substring(0, 30) : t;
      }
    }
    return null;
  }
}
