import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/database_service.dart';

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
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      if (response.user != null) {
        // Create user profile
        await _createUserProfile(response.user!, fullName: fullName);

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

        // Update last login time
        await _updateLastLogin(response.user!.id);
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
  Future<void> _createUserProfile(User user, {String? fullName}) async {
    try {
      await DatabaseService.updateUserProfile({
        'id': user.id,
        'email': user.email,
        'full_name': fullName ?? user.email?.split('@').first,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'total_points': 0,
        'level': 1,
        'streak_days': 0,
        'last_activity': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to create user profile: $e');
    }
  }

  Future<void> _updateLastLogin(String userId) async {
    try {
      await DatabaseService.updateUserProfile({
        'id': userId,
        'last_login': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to update last login: $e');
    }
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

    return DateTime.now().isBefore(expiresAt);
  }

  // Get session expiry time
  DateTime? get sessionExpiry {
    return state.session?.expiresAt;
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