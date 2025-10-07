import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../../core/services/supabase_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _currentBackPressTime;
  bool _isSignUpMode = false;

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_currentBackPressTime == null ||
        now.difference(_currentBackPressTime!) > const Duration(seconds: 2)) {
      _currentBackPressTime = now;
      
      // Show toast message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(20),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleSignUpMode() {
    setState(() {
      _isSignUpMode = !_isSignUpMode;
      // Clear form when switching modes
      if (!_isSignUpMode) {
        _fullNameController.clear();
        _phoneController.clear();
      }
    });
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      ref.read(authLoadingProvider.notifier).state = true;
      ref.read(authErrorProvider.notifier).state = null;

      try {
        await SupabaseService.executeWithErrorHandling(
          () => SupabaseService.auth.signInWithPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          ),
          errorMessage: 'Failed to sign in',
        );
      } catch (e) {
        ref.read(authErrorProvider.notifier).state = e.toString();
      } finally {
        ref.read(authLoadingProvider.notifier).state = false;
      }
    }
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      ref.read(authLoadingProvider.notifier).state = true;
      ref.read(authErrorProvider.notifier).state = null;

      try {
        final response = await SupabaseService.executeWithErrorHandling(
          () => SupabaseService.auth.signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          ),
          errorMessage: 'Failed to sign up',
        );

        // If user was created successfully, manually create profile with additional info
        if (response.user != null) {
          await _createUserProfile(
            response.user!.id,
            _fullNameController.text.trim(),
            _phoneController.text.trim(),
          );
        }
        
        // Show success message for email verification
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please check your email for verification link'),
            ),
          );
        }
      } catch (e) {
        ref.read(authErrorProvider.notifier).state = e.toString();
      } finally {
        ref.read(authLoadingProvider.notifier).state = false;
      }
    }
  }

  Future<void> _createUserProfile(String userId, String fullName, String phone) async {
    try {
      // Create user profile in profiles table with basic fields first
      // This handles the case where new columns might not exist yet
      final profileData = {
        'id': userId,
        'handle': 'user_${userId.substring(0, 8)}',
        'learner_code': 1,
        'locale': 'en',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Try to add new fields if they exist in the database schema
      try {
        // Attempt to insert with new fields
        await SupabaseService.client.from('profiles').upsert({
          ...profileData,
          'full_name': fullName.isNotEmpty ? fullName : null,
          'phone': phone.isNotEmpty ? phone : null,
          'first_login': true,
        });
        print('✅ User profile created with enhanced fields for user: $userId');
        print('📝 Profile data: full_name=$fullName, phone=$phone, first_login=true');
      } catch (e) {
        // If that fails, fall back to basic profile creation
        print('⚠️ Enhanced profile creation failed, using basic profile: $e');
        await SupabaseService.client.from('profiles').upsert(profileData);
        print('✅ Basic user profile created successfully for user: $userId');
        print('📝 Note: Run database migration to enable full_name, phone, and first_login fields');
      }

      // Create user settings
      await SupabaseService.client.from('user_settings').upsert({
        'id': userId,
      });

    } catch (e) {
      print('⚠️ Error creating user profile: $e');
      // Don't throw error here - profile creation is secondary to auth
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);
    final error = ref.watch(authErrorProvider);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
      appBar: AppBar(
        title: const Text('K53 Learner\'s License'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isSignUpMode ? 'Create Account' : 'Welcome',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 32),
              
              // Full Name Field (only for sign-up)
              if (_isSignUpMode) ...[
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    hintText: 'Enter your full name',
                  ),
                  validator: _isSignUpMode ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  } : null,
                ),
                const SizedBox(height: 16),
              ],
              
              // Phone Field (only for sign-up)
              if (_isSignUpMode) ...[
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    hintText: 'Enter your phone number',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: _isSignUpMode ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  } : null,
                ),
                const SizedBox(height: 16),
              ],
              
              // Email Field (always visible)
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Password Field (always visible)
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              
              // Error message
              if (error != null) ...[
                const SizedBox(height: 16),
                Text(
                  error,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Loading indicator or buttons
              if (isLoading)
                const CircularProgressIndicator()
              else
                Column(
                  children: [
                    // Sign In/Sign Up button based on mode
                    ElevatedButton(
                      onPressed: _isSignUpMode ? _signUp : _signIn,
                      child: Text(_isSignUpMode ? 'Create Account' : 'Sign In'),
                    ),
                    const SizedBox(height: 12),
                    
                    // Toggle between sign-in and sign-up
                    TextButton(
                      onPressed: _toggleSignUpMode,
                      child: Text(
                        _isSignUpMode
                          ? 'Already have an account? Sign In'
                          : 'Don\'t have an account? Sign Up',
                      ),
                    ),
                  ],
                ),
              
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/admin/login'),
                child: const Text('Admin Login →'),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}