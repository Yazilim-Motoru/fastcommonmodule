/// FastValidator provides static validation utilities for common form fields.
class FastValidator {
  /// Validates an email address.
  static bool isEmail(String? value) {
    if (value == null || value.isEmpty) return false;
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(value);
  }

  /// Validates a password (min 8 chars, at least 1 letter and 1 number).
  static bool isPassword(String? value) {
    if (value == null || value.length < 8) return false;
    final pwRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    return pwRegex.hasMatch(value);
  }

  /// Validates a phone number (simple international format, e.g. +905551112233).
  static bool isPhone(String? value) {
    if (value == null || value.isEmpty) return false;
    final phoneRegex = RegExp(r'^\+?[1-9]\d{7,14}$');
    return phoneRegex.hasMatch(value);
  }

  /// Validates that a field is not empty.
  static bool isNotEmpty(String? value) =>
      value != null && value.trim().isNotEmpty;

  /// Validates a username (alphanumeric, 3-32 chars).
  static bool isUsername(String? value) {
    if (value == null) return false;
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,32}$');
    return usernameRegex.hasMatch(value);
  }

  /// Validates a name (letters and spaces, 2-50 chars).
  static bool isName(String? value) {
    if (value == null) return false;
    final nameRegex = RegExp(r'^[a-zA-ZğüşöçıİĞÜŞÖÇ\s]{2,50} $');
    return nameRegex.hasMatch(value.trim());
  }

  /// Validates if the value contains only digits.
  static bool isNumeric(String? value) {
    if (value == null) return false;
    final numericRegex = RegExp(r'^\d+$');
    return numericRegex.hasMatch(value);
  }

  /// Validates Turkish T.C. identity number (11 digits, algorithmic check).
  static bool isTCIdentity(String? value) {
    if (value == null ||
        value.length != 11 ||
        !RegExp(r'^\d{11}$').hasMatch(value)) {
      return false;
    }
    final digits = value.split('').map(int.parse).toList();
    if (digits[0] == 0) {
      return false;
    }
    int sumOdd = digits[0] + digits[2] + digits[4] + digits[6] + digits[8];
    int sumEven = digits[1] + digits[3] + digits[5] + digits[7];
    int digit10 = ((sumOdd * 7) - sumEven) % 10;
    int digit11 = (digits.sublist(0, 10).reduce((a, b) => a + b)) % 10;
    return digits[9] == digit10 && digits[10] == digit11;
  }

  /// Validates a URL (basic check).
  static bool isUrl(String? value) {
    if (value == null) return false;
    final urlRegex = RegExp(
        r'^(https?:\/\/)?([\w\-]+\.)+[\w\-]+(\/[\w\-\._~:\/?#\[\]@!\$&\(\)\*\+,;=]*)? $');
    return urlRegex.hasMatch(value);
  }

  /// Validates if the value's length is between min and max (inclusive).
  static bool isLengthBetween(String? value, int min, int max) {
    if (value == null) return false;
    return value.length >= min && value.length <= max;
  }

  /// Validates if the value matches the given regex pattern.
  static bool isMatch(String? value, String pattern) {
    if (value == null) return false;
    final regex = RegExp(pattern);
    return regex.hasMatch(value);
  }
}
