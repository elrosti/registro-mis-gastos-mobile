import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, String currency) {
    final formatter = NumberFormat.currency(
      locale: currency == 'USD' ? 'en_US' : 'es_UY',
      symbol: currency == 'USD' ? '\$' : '\$U',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String formatCompact(double amount, String currency) {
    final symbol = currency == 'USD' ? '\$' : '\$U';
    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount, currency);
  }

  static String formatWithSign(double amount, String currency, bool isIncome) {
    final formatted = format(amount.abs(), currency);
    return isIncome ? '+$formatted' : '-$formatted';
  }
}

class DateFormatter {
  static String formatDate(DateTime date, {String pattern = 'dd/MM/yyyy'}) {
    return DateFormat(pattern).format(date);
  }

  static String formatMonthYear(DateTime date) {
    final months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hoy';
    } else if (dateOnly == yesterday) {
      return 'Ayer';
    } else if (now.difference(date).inDays < 7) {
      final weekdays = [
        'lunes',
        'martes',
        'miércoles',
        'jueves',
        'viernes',
        'sábado',
        'domingo'
      ];
      return weekdays[date.weekday - 1].capitalize();
    }
    return formatDate(date);
  }

  static String toApiFormat(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
