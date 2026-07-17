# Savery

Aplikasi pencatatan keuangan pribadi berbasis Flutter — catat transaksi, atur budget bulanan per kategori, dan capai tujuan tabunganmu lewat Goals.

## Fitur

- Pencatatan transaksi pemasukan & pengeluaran, dengan pencarian dan filter (periode, kategori, tipe)
- Scan struk otomatis (OCR) untuk mengisi nominal transaksi
- Budget bulanan per kategori dengan indikator progress
- Goals tabungan dengan pelacakan kontribusi
- Insight/analisis visual pengeluaran & pemasukan
- Export data transaksi ke CSV
- Mode terang, dukungan multi-akun/dompet

## Cara download & menjalankan project ini

### Prasyarat

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (lihat versi minimum di `pubspec.yaml` — `sdk: ^3.12.2`)
- Android Studio (untuk emulator/SDK Android) dan/atau Xcode (khusus macOS, untuk iOS)
- Git

Cek instalasi Flutter sudah beres dengan:

```bash
flutter doctor
```

### 1. Clone repository

```bash
git clone https://github.com/Erryza/Savery.git
cd Savery
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Jalankan aplikasi

Sambungkan HP Android (aktifkan USB debugging) atau jalankan emulator/simulator, lalu:

```bash
flutter devices        # cek device/emulator yang terdeteksi
flutter run             # jalankan dalam mode debug
```

### 4. Build APK untuk instalasi manual (tanpa Play Store)

```bash
flutter build apk --release
```

File hasil build ada di `build/app/outputs/flutter-apk/app-release.apk`, tinggal disalin ke HP Android dan diinstal langsung (aktifkan izin "Install from unknown sources" saat diminta).

## Tech stack

- **Flutter** + **Dart**
- **Provider** — state management
- **sqflite** — database lokal (SQLite)
- **fl_chart** — grafik & visualisasi
- **google_mlkit_text_recognition** — OCR scan struk
- **shared_preferences** — penyimpanan preferensi lokal
