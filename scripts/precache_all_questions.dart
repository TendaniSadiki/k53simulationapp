import 'package:k53app/src/core/services/offline_database_service.dart';

void main() async {
  print('🔧 Pre-caching all questions for offline use...');
  
  try {
    // Initialize offline database
    await OfflineDatabaseService.initialize();
    print('✓ Offline database initialized');
    
    // Pre-cache all categories
    await OfflineDatabaseService.preCacheAllCategories();
    print('✓ All categories pre-cached');
    
    // Show cache statistics
    final stats = await OfflineDatabaseService.getLocalStats();
    print('📊 Cache Statistics:');
    print('  - Questions: ${stats['questions']}');
    print('  - Answers: ${stats['answers']}');
    print('  - Pending Sync: ${stats['pending_sync']}');
    
    print('\n✅ Pre-caching completed successfully!');
    print('The offline database now contains a comprehensive set of questions for all categories.');
    
  } catch (e) {
    print('❌ Error during pre-caching: $e');
    print('Make sure the app is properly configured with Supabase credentials.');
  }
}