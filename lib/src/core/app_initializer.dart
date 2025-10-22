import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;
import './config/environment_config.dart';
import './config/offline_config.dart';
import './services/supabase_service.dart';
import './services/local_auth_service.dart';
import './services/hybrid_question_service.dart';
import './services/offline_database_service.dart';
import './services/offline_data_preloader.dart';

class AppInitializer {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Validate offline configuration
    OfflineConfig.validate();
    
    // Print configuration for debugging
    if (EnvironmentConfig.isDevelopment) {
      EnvironmentConfig.printConfig();
      OfflineConfig.printConfig();
    }

    // Initialize offline database first (most critical)
    await OfflineDatabaseService.initialize();

    // Initialize local authentication
    await LocalAuthService.initialize();

    // Initialize hybrid question service
    await HybridQuestionService.initialize();

    // Try to initialize Supabase, but don't fail if it doesn't work
    try {
      EnvironmentConfig.validate();
      await SupabaseService.initialize();
      print('✅ Supabase initialized successfully');
    } catch (e) {
      print('⚠️ Supabase initialization failed: $e');
      print('🔄 Falling back to offline mode');
    }

    // Create default offline user if no user exists
    final isAuthenticated = await LocalAuthService.isAuthenticated();
    if (!isAuthenticated) {
      await LocalAuthService.createDefaultOfflineUser();
      print('✅ Default offline user created');
    }

    // Preload all questions for offline use
    await OfflineDataPreloader.preloadQuestions();

    // Start connectivity listener for optional auto-sync
    OfflineDatabaseService.startConnectivityListener();

    print('✅ App initialization complete - Ready for offline use');
  }

  static Future<void> preCacheAssets(BuildContext context) async {
    // Pre-cache any assets that need to be loaded immediately
    // This can be called from the main widget's build method
  }

  static void setupErrorHandling() {
    // Setup global error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      // Log to analytics/crash reporting
      if (EnvironmentConfig.isDevelopment) {
        debugPrint('Flutter error: ${details.exception}');
      }
    };

    // Setup platform error handling
    ui.PlatformDispatcher.instance.onError = (error, stack) {
      // Log to analytics/crash reporting
      if (EnvironmentConfig.isDevelopment) {
        debugPrint('Platform error: $error\n$stack');
      }
      return true;
    };
  }
}