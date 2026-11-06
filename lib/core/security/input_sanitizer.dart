/// Input sanitisation utilities for user-supplied text.
///
/// All methods are static and pure (no side effects), making them safe to
/// call on any platform including in isolates or background processors.
///
/// ## When to use
/// - Strip dangerous HTML/script tags before displaying user-generated content.
/// - Validate passwords meet minimum complexity requirements.
/// - Trim and normalise names/usernames before persisting or sending to the API.
class InputSanitizer {
  InputSanitizer._();

  // ---------------------------------------------------------------------------
  // HTML / XSS
  // ---------------------------------------------------------------------------

  /// Removes all HTML tags from [input] to prevent stored-XSS attacks when
  /// displaying user-generated content in rich-text contexts.
  ///
  /// ```dart
  /// InputSanitizer.stripHtml('<script>alert(1)</script>Nice event!');
  /// // => 'Nice event!'
  /// ```
  static String stripHtml(String input) {
    return input.replaceAll(RegExp('<[^>]*>'), '');
  }

  /// Encodes dangerous HTML characters as their entity equivalents.
  ///
  /// Use this instead of [stripHtml] when the original text must be preserved
  /// verbatim (e.g. in a code block) but you still need it to be safe inside
  /// an HTML context.
  static String escapeHtml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }

  // ---------------------------------------------------------------------------
  // General normalisation
  // ---------------------------------------------------------------------------

  /// Trims leading/trailing whitespace and collapses internal runs of
  /// whitespace to a single space.
  static String normalise(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Removes any character that is not a Unicode letter, digit, space,
  /// hyphen, or apostrophe.  Used for display names / nicknames.
  static String sanitiseName(String input) {
    final trimmed = normalise(input);
    return trimmed.replaceAll(RegExp(r"[^\p{L}\p{N}\s\-']", unicode: true), '');
  }

  /// Removes characters that are not safe in a URL query-string value.
  /// Keeps letters, digits, spaces, hyphens, underscores, and dots.
  static String sanitiseSearchQuery(String input) {
    final trimmed = normalise(input);
    return trimmed.replaceAll(RegExp(r'[^\w\s\-.]'), '');
  }

  // ---------------------------------------------------------------------------
  // Password strength
  // ---------------------------------------------------------------------------

  /// Returns `null` when the password satisfies all requirements, or a
  /// human-readable error message explaining what is missing.
  ///
  /// Requirements (aligned with NIST SP 800-63B):
  /// - Minimum 8 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one digit
  /// - At least one special character
  static String? validatePasswordStrength(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    if (!password.contains(RegExp('[A-Z]'))) {
      return 'Password must contain at least one uppercase letter.';
    }
    if (!password.contains(RegExp('[a-z]'))) {
      return 'Password must contain at least one lowercase letter.';
    }
    if (!password.contains(RegExp('[0-9]'))) {
      return 'Password must contain at least one number.';
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/`~]'))) {
      return 'Password must contain at least one special character.';
    }
    return null;
  }

  /// Returns a score from 0 (very weak) to 4 (very strong) for UI meters.
  static int passwordStrengthScore(String password) {
    var score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.contains(RegExp('[A-Z]')) &&
        password.contains(RegExp('[a-z]'))) {
      score++;
    }
    if (password.contains(RegExp('[0-9]')) &&
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/`~]'))) {
      score++;
    }
    return score;
  }

  // ---------------------------------------------------------------------------
  // Email
  // ---------------------------------------------------------------------------

  /// Validates and normalises an email address.
  ///
  /// - Lowercases the address.
  /// - Trims whitespace.
  /// - Returns `null` if the email is invalid.
  static String? normaliseEmail(String input) {
    final lower = input.trim().toLowerCase();
    final regex = RegExp(r'^[\w\-.+]+@([\w-]+\.)+[\w-]{2,}$');
    return regex.hasMatch(lower) ? lower : null;
  }

  // ---------------------------------------------------------------------------
  // SQL / NoSQL injection prevention (belt-and-suspenders)
  // ---------------------------------------------------------------------------

  /// Returns `true` if [input] contains patterns commonly associated with
  /// SQL injection.  The API should also validate on the server side, but this
  /// provides early client feedback.
  static bool containsSqlInjection(String input) {
    final pattern = RegExp(
      r"('|(--)|;|(\b(SELECT|INSERT|UPDATE|DELETE|DROP|UNION|EXEC|"
      r'CREATE|ALTER|TRUNCATE)\b))',
      caseSensitive: false,
    );
    return pattern.hasMatch(input);
  }
}
