import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/login_streak_service.dart';

final authProvider = StateNotifierProvider<AuthProvider, AuthState>((ref) {
  return AuthProvider();
});

class AuthState {
  final User? user;
  final Session? session;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final AuthStatus status;

  AuthState({
    this.user,
    this.session,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.status = AuthStatus.initial,
  });

  AuthState copyWith({
    User? user,
    Session? session,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    AuthStatus? status,
  }) {
    return AuthState(
      user: user ?? this.user,
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      status: status ?? this.status,
    );
  }
}

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends StateNotifier<AuthState> {
  AuthProvider() : super(AuthState()) {
    _initializeAuth();
  }

  // Initialize authentication state
  Future<void> _initializeAuth() async {
    try {
      state = state.copyWith(isLoading: true, status: AuthStatus.loading);

      // Get current session from Supabase
      final currentSession = SupabaseService.client.auth.currentSession;
      final currentUser = SupabaseService.client.auth.currentUser;

      if (currentSession != null && currentUser != null) {
        state = state.copyWith(
          user: currentUser,
          session: currentSession,
          isAuthenticated: true,
          isLoading: false,
          status: AuthStatus.authenticated,
        );

        // Track user login
        await AnalyticsService.trackUserLogin(userId: currentUser.id);
      } else {
        state = state.copyWith(
          isLoading: false,
          status: AuthStatus.unauthenticated,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize authentication: $e',
        status: AuthStatus.error,
      );
    }
  }

  // Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'provider_type': 'email',
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      if (response.user != null) {
        print('✅ User created successfully: ${response.user!.id}');
        print('📧 Email: $email');
        print('📝 Full Name: $fullName');
        print('📱 Phone: $phone');
        print('🔐 Provider Type: email');
        
        // Create user profile with enhanced fields
        await _createUserProfile(
          response.user!,
          fullName: fullName,
          phone: phone,
        );

        state = state.copyWith(
          user: response.user,
          session: response.session,
          isAuthenticated: true,
          isLoading: false,
          status: AuthStatus.authenticated,
        );

        // Track user registration
        await AnalyticsService.trackUserRegistration(
          userId: response.user!.id,
          email: email,
        );

        // Track login
        await AnalyticsService.trackUserLogin(userId: response.user!.id);

        // Show email verification message
        _showEmailVerificationMessage();
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to create user account',
          status: AuthStatus.error,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Sign up failed: $e',
        status: AuthStatus.error,
      );
    }
  }

  // Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null && response.session != null) {
        state = state.copyWith(
          user: response.user,
          session: response.session,
          isAuthenticated: true,
          isLoading: false,
          status: AuthStatus.authenticated,
        );

        // Track user login
        await AnalyticsService.trackUserLogin(userId: response.user!.id);

        // Update login streak and last login
        await LoginStreakService.trackLogin(response.user!.id);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Invalid email or password',
          status: AuthStatus.error,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Sign in failed: $e',
        status: AuthStatus.error,
      );
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true);

      await SupabaseService.client.auth.signOut();

      state = state.copyWith(
        user: null,
        session: null,
        isAuthenticated: false,
        isLoading: false,
        status: AuthStatus.unauthenticated,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Sign out failed: $e',
        status: AuthStatus.error,
      );
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await SupabaseService.client.auth.resetPasswordForEmail(email);

      state = state.copyWith(
        isLoading: false,
        error: 'Password reset email sent',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to send password reset email: $e',
        status: AuthStatus.error,
      );
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      final user = state.user;
      if (user == null) return;

      state = state.copyWith(isLoading: true, error: null);

      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      await DatabaseService.updateUserProfile({
        'id': user.id,
        ...updates,
        'updated_at': DateTime.now().toIso8601String(),
      });

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update profile: $e',
        status: AuthStatus.error,
      );
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = state.user;
    if (user == null) return null;

    try {
      return await DatabaseService.getUserProfile(user.id);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load user profile: $e',
      );
      return null;
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => state.isAuthenticated;

  // Get current user ID
  String? get userId => state.user?.id;

  // Get current user email
  String? get userEmail => state.user?.email;

  // Get current user display name
  String? get displayName {
    final user = state.user;
    if (user == null) return null;

    final userMetadata = user.userMetadata;
    return userMetadata?['full_name'] as String? ?? user.email;
  }

  // Helper methods
  Future<void> _createUserProfile(User user, {String? fullName, String? phone}) async {
    try {
      // Create profile data that matches the FINAL database schema
      final profileData = {
        'id': user.id,
        'handle': 'user_${user.id.substring(0, 8)}', // Generate handle from user ID
        'learner_code': 1, // Default learner code
        'locale': 'en', // Default locale
        'email': user.email, // Include email field
        'full_name': fullName,
        'phone': phone,
        'total_points': 0,
        'level': 1,
        'login_streak': 0,
        'first_login': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      print('📋 Creating user profile with FINAL schema data:');
      print('   - User ID: ${user.id}');
      print('   - Handle: ${profileData['handle']}');
      print('   - Email: ${user.email}');
      print('   - Full Name: $fullName');
      print('   - Phone: $phone');
      print('   - Learner Code: 1');
      print('   - Locale: en');

      // Create the complete profile in the database
      await DatabaseService.updateUserProfile(profileData);
      print('✅ User profile created successfully for user: ${user.id}');
      print('📝 Profile data saved with all required fields');
      
      // Verify the profile was created
      final createdProfile = await DatabaseService.getUserProfile(user.id);
      if (createdProfile != null) {
        print('✅ Profile verification successful:');
        print('   - Profile exists: true');
        print('   - Handle: ${createdProfile['handle']}');
        print('   - Email: ${createdProfile['email']}');
        print('   - Full Name: ${createdProfile['full_name']}');
      } else {
        print('❌ Profile verification failed: Profile not found after creation');
      }
    } catch (e) {
      print('❌ Failed to create user profile: $e');
      print('💡 The profile may have been created by the database trigger automatically');
      
      // Even if profile creation fails, the user metadata is already set during signup
      if (fullName != null || phone != null) {
        print('✅ User metadata was set during signup process');
        print('   - Full Name: $fullName');
        print('   - Phone: $phone');
      }
    }
  }

  // Show email verification message after signup
  void _showEmailVerificationMessage() {
    // This would typically show a dialog or snackbar
    print('📧 Email verification sent! Please check your inbox.');
    print('💡 You can now sign in with your verified email address.');
  }

  // Check if user needs email verification
  bool _needsEmailVerification(User? user) {
    return user != null && user.email != null && !user.email!.contains('@example.com');
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Refresh session
  Future<void> refreshSession() async {
    try {
      final currentSession = SupabaseService.client.auth.currentSession;
      final currentUser = SupabaseService.client.auth.currentUser;

      if (currentSession != null && currentUser != null) {
        state = state.copyWith(
          user: currentUser,
          session: currentSession,
          isAuthenticated: true,
          status: AuthStatus.authenticated,
        );
      } else {
        state = state.copyWith(
          user: null,
          session: null,
          isAuthenticated: false,
          status: AuthStatus.unauthenticated,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to refresh session: $e',
        status: AuthStatus.error,
      );
    }
  }

  // Check if session is valid
  bool get isSessionValid {
    final session = state.session;
    if (session == null) return false;

    final expiresAt = session.expiresAt;
    if (expiresAt == null) return false;

    return DateTime.now().isBefore(DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000));
  }

  // Get session expiry time
  DateTime? get sessionExpiry {
    final expiresAt = state.session?.expiresAt;
    return expiresAt != null ? DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000) : null;
  }

  // Get time until session expiry
  Duration? get timeUntilExpiry {
    final expiry = sessionExpiry;
    if (expiry == null) return null;

    return expiry.difference(DateTime.now());
  }

  // Check if session is about to expire (within 5 minutes)
  bool get isSessionAboutToExpire {
    final timeUntil = timeUntilExpiry;
    if (timeUntil == null) return false;

    return timeUntil.inMinutes <= 5;
  }

  // Refresh token if needed
  Future<void> refreshTokenIfNeeded() async {
    if (isSessionAboutToExpire) {
      await refreshSession();
    }
  }
}