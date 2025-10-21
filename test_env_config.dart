import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentConfig {
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
  }

  static String get supabaseUrl =>
      dotenv.get('SUPABASE_URL', fallback: '');

  static String get supabaseAnonKey =>
      dotenv.get('SUPABASE_ANON_KEY', fallback: '');

  static String get environment =>
      dotenv.get('ENVIRONMENT', fallback: 'development');

  static bool get enableAnalytics =>
      dotenv.get('ENABLE_ANALYTICS', fallback: 'true') == 'true';

  static String get appName =>
      dotenv.get('APP_NAME', fallback: 'K53 Learner\'s License');

  static String get appVersion =>
      dotenv.get('APP_VERSION', fallback: '1.0.0');

  static bool get enableGamification =>
      dotenv.get('ENABLE_GAMIFICATION', fallback: 'true') == 'true';

  static bool get enableSharing =>
      dotenv.get('ENABLE_SHARING', fallback: 'true') == 'true';

  static bool get enableOfflineMode =>
      dotenv.get('ENABLE_OFFLINE_MODE', fallback: 'true') == 'true';

  static String get apiBaseUrl =>
      dotenv.get('API_BASE_URL', fallback: '');

  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';

  // Validate configuration
  static void validate() {
    if (supabaseUrl.isEmpty) {
      throw Exception('SUPABASE_URL is not configured in .env file');
    }
    if (supabaseAnonKey.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY is not configured in .env file');
    }
  }

  // Print configuration for debugging
  static void printConfig() {
    print('=== Environment Configuration ===');
    print('Environment: $environment');
    print('App Name: $appName');
    print('App Version: $appVersion');
    print('Supabase URL: ${supabaseUrl.substring(0, 30)}...');
    print('Supabase Key: ${supabaseAnonKey.substring(0, 20)}...');
    print('Analytics Enabled: $enableAnalytics');
    print('Gamification Enabled: $enableGamification');
    print('Sharing Enabled: $enableSharing');
    print('Offline Mode Enabled: $enableOfflineMode');
    print('==================================');
  }
}

void main() async {
  print('Testing .env configuration...');
  
  try {
    await EnvironmentConfig.initialize();
    EnvironmentConfig.validate();
    EnvironmentConfig.printConfig();
    
    print('\n✅ .env configuration is working correctly!');
    print('✅ All required environment variables are present');
    print('✅ Configuration loaded successfully from .env file');
    
  } catch (e) {
    print('\n❌ Error: $e');
    print('❌ .env configuration failed');
  }
}