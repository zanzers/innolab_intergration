class CurrentUser {
  static final CurrentUser _instance = CurrentUser._internal();
  
  // This is the factory constructor that lets you call CurrentUser()
  factory CurrentUser() => _instance;

  CurrentUser._internal();

  // Variables to hold the data globally
  String uid = '';
  String email = '';
  String fullName = '';
  int level = 1;
  String role = 'client';

  // Helper to clear data on logout
  void clear() {
    uid = '';
    email = '';
    fullName = '';
    level = 1;
    role = 'client';
  }
}