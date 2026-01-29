class Session {
  // Stores the logged-in user's role: "admin" or "employee"
  static String? userRole;

  // Stores the logged-in user's employee ID (used in attendance)
  static String? empId;

  /// Sets the logged-in user info
  static void setSession({required String role, required String id}) {
    userRole = role;
    empId = id;
  }

  /// Clears session on logout
  static void clear() {
    userRole = null;
    empId = null;
  }

  /// Helper getters
  static bool get isAdmin => userRole == "admin";
  static bool get isEmployee => userRole == "employee";
}
