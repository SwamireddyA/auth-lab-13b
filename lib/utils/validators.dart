class Validators {
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter your email.';
    if (!_emailRegex.hasMatch(v)) return 'Enter a valid email, like name@example.com.';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Enter a password.';
    if (v.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }
}
