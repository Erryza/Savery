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

## Install ke iPhone sendiri (iOS)

Beda dengan Android, iOS **tidak bisa** di-sideload cuma dengan kirim file lewat WhatsApp/dsb. Apple mewajibkan proses build & install pertama lewat **Xcode di macOS** — tidak ada jalan lain di luar App Store.

### Yang wajib disiapkan

- **Mac** (milik sendiri, pinjam, atau sewa Mac cloud seperti [MacinCloud](https://www.macincloud.com/)) dengan Xcode terpasang
- **Apple ID** (akun gratis biasa sudah cukup untuk install ke device sendiri)
- Kabel USB untuk sambungkan iPhone ke Mac (atau opsi wireless debugging di Xcode setelah pairing pertama lewat USB)

### Langkah-langkah

1. Clone repo & install dependencies seperti langkah di atas (`git clone`, `flutter pub get`), dilakukan di Mac.
2. Buka folder iOS project di Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
3. Di Xcode: pilih target **Runner** → tab **Signing & Capabilities** → aktifkan **Automatically manage signing** → pilih **Team** (login pakai Apple ID kamu di Xcode kalau belum, lewat Xcode → Settings → Accounts).
4. Sambungkan iPhone via kabel USB, pilih iPhone kamu sebagai target device di toolbar Xcode.
5. Klik tombol **Run (▶)**. Build pertama biasanya butuh waktu beberapa menit.
6. Di iPhone, buka **Settings → General → VPN & Device Management**, cari profil developer dengan nama Apple ID kamu, lalu tap **Trust**.
7. Buka app Savery dari home screen iPhone.

### Catatan penting

- Dengan **Apple ID gratis**, app akan **expired setiap 7 hari** — ulangi langkah 4-5 (sambungkan & klik Run lagi) untuk memperpanjang.
- Kalau ingin app **tidak expired** dan lebih mudah update (tanpa perlu Mac tiap minggu), daftar **Apple Developer Program** ($99/tahun) dan distribusikan lewat **TestFlight** — install lebih mirip Android (tinggal buka app TestFlight, terima invite, install), dan build selanjutnya bisa otomatis lewat CI (GitHub Actions/Codemagic) tanpa perlu Mac fisik lagi.
- Tidak punya Mac sama sekali? Sewa Mac cloud per jam/bulan (mis. MacinCloud) hanya untuk proses build & install awal ini.

## Tech stack

- **Flutter** + **Dart**
- **Provider** — state management
- **sqflite** — database lokal (SQLite)
- **fl_chart** — grafik & visualisasi
- **google_mlkit_text_recognition** — OCR scan struk
- **shared_preferences** — penyimpanan preferensi lokal
