/// Utility class for safely parsing dates from backend responses
/// Handles both array format [year, month, day] and ISO8601 string format
class DateParser {
  /// Parse a date that could be in array format [year, month, day] or ISO8601 string
  static DateTime? parseDate(dynamic date) {
    if (date == null) return null;

    try {
      if (date is DateTime) {
        return date;
      } else if (date is List && date.length >= 3) {
        // Array format: [year, month, day]
        return DateTime(date[0] as int, date[1] as int, date[2] as int);
      } else if (date is String && date.isNotEmpty) {
        // ISO8601 string format
        return DateTime.parse(date);
      }
    } catch (e) {
      print('⚠️ Could not parse date "$date": $e');
    }

    return null;
  }

  /// Convert date to ISO8601 string for API requests
  static String? toIso8601(dynamic date) {
    final parsed = parseDate(date);
    return parsed?.toIso8601String();
  }
}
