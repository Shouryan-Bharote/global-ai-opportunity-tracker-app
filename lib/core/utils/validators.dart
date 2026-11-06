import 'package:ai_nexus/core/security/input_sanitizer.dart';

/// Form-level validators compatible with Flutter's FormField.validator.
///
/// All validators return `null` when valid and a human-readable error string
/// when invalid.  They are pure functions with no side effects.
class Validators {
  Validators._();

  // ---------------------------------------------------------------------------
  // Generic
  // ---------------------------------------------------------------------------

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Email
  // ---------------------------------------------------------------------------

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (InputSanitizer.normaliseEmail(value) == null) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Password
  // ---------------------------------------------------------------------------

  /// Validates that the password meets minimum security requirements (NIST
  /// SP 800-63B aligned):
  /// - At least 8 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one digit
  /// - At least one special character
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return InputSanitizer.validatePasswordStrength(value);
  }

  /// Validator for a "confirm password" field that checks the value matches
  /// [originalPassword].
  static String? Function(String?) confirmPassword(String originalPassword) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Please confirm your password';
      }
      if (value != originalPassword) {
        return 'Passwords do not match';
      }
      return null;
    };
  }

  // ---------------------------------------------------------------------------
  // Display name / nickname
  // ---------------------------------------------------------------------------

  /// Validates a display name or nickname:
  /// - Required (non-empty after trimming)
  /// - 2–40 characters
  /// - No HTML/script tags
  static String? displayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (trimmed.length > 40) {
      return 'Name must be 40 characters or fewer';
    }
    if (InputSanitizer.stripHtml(trimmed) != trimmed) {
      return 'Name cannot contain HTML or special markup';
    }
    if (InputSanitizer.containsSqlInjection(trimmed)) {
      return 'Name contains invalid characters';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Search query
  // ---------------------------------------------------------------------------

  /// Sanitise a search query — only informational (does not block submission).
  static String sanitisedSearchQuery(String raw) {
    return InputSanitizer.sanitiseSearchQuery(raw);
  }
}
