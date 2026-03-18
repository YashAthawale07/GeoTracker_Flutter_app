class Validators {
  static String? validateNotEmpty(String? value) {
    if (value == null || value.isEmpty) return "This field is required";
    return null;
  }

  static String? validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return "This field is required";
    // Simple email validation (good enough for basic form checks)
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(v)) return "Enter a valid email";
    return null;
  }

  static String? validatePhone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return "This field is required";
    // Accept 10-15 digits (optionally with +)
    final phoneRegex = RegExp(r'^\+?\d{10,15}$');
    if (!phoneRegex.hasMatch(v)) return "Enter a valid phone number";
    return null;
  }
}
