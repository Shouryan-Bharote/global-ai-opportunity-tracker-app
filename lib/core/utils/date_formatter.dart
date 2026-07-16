class DateFormatter {
  DateFormatter._();

  // Simple formatting placeholders until intl package is added, if needed.
  static String formatShortDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
