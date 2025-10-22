import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:ui' as ui;
import './config/environment_config.dart';
import './services/supabase_service.dart';
import './services/offline_database_service.dart';
import './services/offline_data_preloader.dart';

class AppInitializer {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Load environment variables
    await EnvironmentConfig.initialize();

    // Initialize Supabase
    await SupabaseService.initialize();

    // Initialize offline database
    await OfflineDatabaseService.initialize();

    // Start connectivity listener for auto-sync
    OfflineDatabaseService.startConnectivityListener();

    // Preload basic questions for offline use
    await OfflineDataPreloader.preloadQuestions();

    // Additional initialization can be added here:
    // - Analytics
    // - Crash reporting
    // - Caching
    // - etc.
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