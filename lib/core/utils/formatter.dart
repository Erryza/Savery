import 'package:intl/intl.dart';

class Formatter {
  static final _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String rupiah(double amount) => _currency.format(amount);

  static String rupiahShort(double amount) {
    if (amount >= 1000000000) {
      return 'Rp ${(amount / 1000000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}rb';
    }
    return rupiah(amount);
  }

  static String date(String isoDate) {
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return isoDate;
    return DateFormat('dd MMM yyyy', 'id_ID').format(dt);
  }

  static String dateShort(String isoDate) {
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return isoDate;
    return DateFormat('dd MMM', 'id_ID').format(dt);
  }

  static String month(String yyyyMM) {
    final parts = yyyyMM.split('-');
    if (parts.length != 2) return yyyyMM;
    final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    return DateFormat('MMMM yyyy', 'id_ID').format(dt);
  }

  static String relativeDate(String isoDate) {
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return isoDate;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(day).inDays;
    final full = DateFormat('dd MMMM yyyy', 'id_ID').format(dt);
    if (diff == 0) return 'Hari ini, $full';
    if (diff == 1) return 'Kemarin, $full';
    return full;
  }

  static String relativeDateTime(String isoDateTime) {
    final dt = DateTime.tryParse(isoDateTime);
    if (dt == null) return isoDateTime;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(day).inDays;
    final time = DateFormat('HH:mm').format(dt);
    if (diff == 0) return 'Hari ini, $time';
    if (diff == 1) return 'Kemarin, $time';
    return '${DateFormat('dd MMM', 'id_ID').format(dt)}, $time';
  }

  static String currentMonth() => DateFormat('yyyy-MM').format(DateTime.now());

  static String prevMonth(String yyyyMM) {
    final parts = yyyyMM.split('-');
    final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]) - 1);
    return DateFormat('yyyy-MM').format(dt);
  }

  static String nextMonth(String yyyyMM) {
    final parts = yyyyMM.split('-');
    final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]) + 1);
    return DateFormat('yyyy-MM').format(dt);
  }
}
