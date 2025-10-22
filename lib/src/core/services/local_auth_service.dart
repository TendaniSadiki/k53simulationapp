import 'package:hive/hive.dart';

class LocalAuthService {
  static const String _authBoxName = 'local_auth';
  static const String _currentUserKey = 'current_user';
  static const String _usersBoxName = 'local_users';

  static Future<void> initialize() async {
    // Initialize Hive - boxes will be opened on-demand when needed
    // Hive.init() is called automatically when opening boxes
  }

  // Check if user is authenticated locally
  static Future<bool> isAuthenticated() async {
    final box = await Hive.openBox(_authBoxName);
    final currentUser = box.get(_currentUserKey);
    return currentUser != null;
  }

  // Get current user ID
  static Future<String?> getCurrentUserId() async {
    final box = await Hive.openBox(_authBoxName);
    return box.get(_currentUserKey);
  }

  // Local user registration
  static Future<bool> registerLocalUser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final usersBox = await Hive.openBox(_usersBoxName);
      final authBox = await Hive.openBox(_authBoxName);
      
      // Check if user already exists
      if (usersBox.containsKey(email)) {
        return false; // User already exists
      }
      
      // Create local user
      final userData = {
        'id': 'local_${DateTime.now().millisecondsSinceEpoch}',
        'username': username,
        'email': email,
        'password': _hashPassword(password), // Simple hash for local storage
        'created_at': DateTime.now().toIso8601String(),
        'points': 0,
        'login_streak': 0,
        'last_login': DateTime.now().toIso8601String(),
      };
      
      // Save user and set as current
      await usersBox.put(email, userData);
      await authBox.put(_currentUserKey, userData['id']);
      
      return true;
    } catch (e) {
      print('Local registration error: $e');
      return false;
    }
  }

  // Local user login
  static Future<bool> loginLocalUser({
    required String email,
    required String password,
  }) async {
    try {
      final usersBox = await Hive.openBox(_usersBoxName);
      final authBox = await Hive.openBox(_authBoxName);
      
      final userData = usersBox.get(email);
      if (userData == null) {
        return false; // User not found
      }
      
      final storedPassword = userData['password'] as String;
      if (_hashPassword(password) != storedPassword) {
        return false; // Password incorrect
      }
      
      // Update last login
      userData['last_login'] = DateTime.now().toIso8601String();
      await usersBox.put(email, userData);
      
      // Set as current user
      await authBox.put(_currentUserKey, userData['id']);
      
      return true;
    } catch (e) {
      print('Local login error: $e');
      return false;
    }
  }

  // Logout
  static Future<void> logout() async {
    final box = await Hive.openBox(_authBoxName);
    await box.delete(_currentUserKey);
  }

  // Get current user data
  static Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final currentUserId = await getCurrentUserId();
      if (currentUserId == null) return null;
      
      final usersBox = await Hive.openBox(_usersBoxName);
      
      // Find user by ID
      for (final key in usersBox.keys) {
        final userData = usersBox.get(key) as Map<String, dynamic>?;
        if (userData != null && userData['id'] == currentUserId) {
          return userData;
        }
      }
      
      return null;
    } catch (e) {
      print('Get user data error: $e');
      return null;
    }
  }

  // Update user data
  static Future<bool> updateUserData(Map<String, dynamic> updates) async {
    try {
      final currentUserData = await getCurrentUserData();
      if (currentUserData == null) return false;
      
      final usersBox = await Hive.openBox(_usersBoxName);
      final email = currentUserData['email'] as String;
      
      // Merge updates
      final updatedData = {...currentUserData, ...updates};
      await usersBox.put(email, updatedData);
      
      return true;
    } catch (e) {
      print('Update user data error: $e');
      return false;
    }
  }

  // Simple password hashing for local storage
  static String _hashPassword(String password) {
    // Simple hash for local storage - not cryptographically secure
    // For production, consider using a proper hashing library
    return (password.hashCode % 1000000).toString();
  }

  // Create default offline user
  static Future<void> createDefaultOfflineUser() async {
    final exists = await isAuthenticated();
    if (!exists) {
      await registerLocalUser(
        username: 'K53 Learner',
        email: 'offline@k53app.com',
        password: 'k53learner',
      );
    }
  }
}