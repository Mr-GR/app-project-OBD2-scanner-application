// Utility functions for date/time operations
class DateTimeUtil {
  static DateTime? fromTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is DateTime) return timestamp;
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static int? toTimestamp(DateTime? dateTime) {
    if (dateTime == null) return null;
    return dateTime.millisecondsSinceEpoch;
  }

  static String formatDateTime(DateTime? dateTime, String format) {
    if (dateTime == null) return '';
    // Simple formatting - in a real app you'd use intl package
    return dateTime.toIso8601String();
  }
}
