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
      final authNotifier = ref.read(authProvider.notifier);
      try {
        await authNotifier.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } catch (e) {
        // Error is handled by the auth provider state
      }
    }
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      final authNotifier = ref.read(authProvider.notifier);
      try {
        await authNotifier.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
        );
        
        // Show success message for email verification
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please check your email for verification link'),
            ),
          );
        }
      } catch (e) {
        // Error is handled by the auth provider state
      }
    }
  }

  // Note: The _createUserProfile method is no longer needed as profile creation
  // is now handled by the AuthProvider during signup

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final error = authState.error;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('K53 Learner\'s License'),
        ),
        body: SingleChildScrollView(
          child: Padding(
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
      ),
    );
  }
}