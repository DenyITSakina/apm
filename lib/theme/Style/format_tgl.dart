import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static const List<String> _months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "Mei",
    "Jun",
    "Jul",
    "Agu",
    "Sep",
    "Okt",
    "Nov",
    "Des",
  ];

  static const List<String> _dateFormats = [
    'yyyy-MM-dd',
    'yyyy-M-d',
    'dd-MM-yyyy',
    'd-M-yyyy',
    'dd/MM/yyyy',
    'd/M/yyyy',
    'yyyy/MM/dd',
    'yyyy/M/d',
    'dd MMM yyyy',
    'd MMM yyyy',
    'dd MMMM yyyy',
    'd MMMM yyyy',
  ];

  static String format(String? inputDate) {
    if (_isInvalid(inputDate)) return '-';

    try {
      final date = _parseDate(inputDate!);
      if (date == null) return inputDate;

      return "${date.day} ${_months[date.month - 1]} ${date.year}";
    } catch (e) {
      return inputDate ?? '-';
    }
  }

  static String formatTglBlnTahun(String inputDate) => format(inputDate);

  static bool _isInvalid(String? input) {
    return input == null ||
        input.isEmpty ||
        input == 'null' ||
        input == '-' ||
        input.trim().isEmpty;
  }

  static DateTime? _parseDate(String input) {
    input = input.trim();

    for (final format in _dateFormats) {
      try {
        return DateFormat(format, 'id').parseStrict(input);
      } catch (_) {}
    }

    return _manualParse(input);
  }

  static DateTime? _manualParse(String input) {
    try {
      final cleaned = input.replaceAll(RegExp(r'[^0-9\s\-/]'), '');
      final parts = cleaned.split(RegExp(r'[\s\-/]'));

      if (parts.length != 3) return null;

      final p1 = int.tryParse(parts[0]) ?? 0;
      final p2 = int.tryParse(parts[1]) ?? 0;
      final p3 = int.tryParse(parts[2]) ?? 0;

      if (p1 > 1000 && p2 >= 1 && p2 <= 12 && p3 >= 1 && p3 <= 31) {
        return DateTime(p1, p2, p3);
      }

      if (p3 > 1000 && p2 >= 1 && p2 <= 12 && p1 >= 1 && p1 <= 31) {
        return DateTime(p3, p2, p1);
      }

      if (p3 > 1000 && p1 >= 1 && p1 <= 12 && p2 >= 1 && p2 <= 31) {
        return DateTime(p3, p1, p2);
      }

      return null;
    } catch (_) {
      return null;
    }
  }
}

String formatTglBlnTahun(String inputDate) => DateFormatter.format(inputDate);
String safeFormatTglBlnTahun(String? inputDate) =>
    DateFormatter.format(inputDate);
