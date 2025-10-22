class EnvironmentConfig {
  // No initialization needed - values are compiled in at build time
  static Future<void> initialize() async {
    // No-op - values are compiled in via --dart-define
  }

  static String get supabaseUrl =>
      const String.fromEnvironment('SUPABASE_URL', defaultValue: '');

  static String get supabaseAnonKey =>
      const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  static String get environment =>
      const String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');

  static bool get enableAnalytics =>
      const String.fromEnvironment('ENABLE_ANALYTICS', defaultValue: 'true') == 'true';

  static String get appName =>
      const String.fromEnvironment('APP_NAME', defaultValue: 'K53 Learner\'s License');

  static String get appVersion =>
      const String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');

  static bool get enableGamification =>
      const String.fromEnvironment('ENABLE_GAMIFICATION', defaultValue: 'true') == 'true';

  static bool get enableSharing =>
      const String.fromEnvironment('ENABLE_SHARING', defaultValue: 'true') == 'true';

  static bool get enableOfflineMode =>
      const String.fromEnvironment('ENABLE_OFFLINE_MODE', defaultValue: 'true') == 'true';

  static String get apiBaseUrl =>
      const String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';

  // Validate configuration
  static void validate() {
    if (supabaseUrl.isEmpty) {
      throw Exception('SUPABASE_URL is not configured. Use --dart-define=SUPABASE_URL=your_url');
    }
    if (supabaseAnonKey.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY is not configured. Use --dart-define=SUPABASE_ANON_KEY=your_key');
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