import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/offline_database_service.dart';

// Provider for offline database service
final offlineDatabaseProvider = Provider<OfflineDatabaseService>((ref) {
  return OfflineDatabaseService();
});

// Provider to initialize offline database
final offlineDatabaseInitializerProvider = FutureProvider<void>((ref) async {
  await OfflineDatabaseService.initialize();
});

// Provider for connectivity status
final connectivityProvider = StreamProvider<bool>((ref) async* {
  yield await OfflineDatabaseService.isConnected();
  
  // Listen for connectivity changes
  final connectivity = Connectivity();
  await for (final result in connectivity.onConnectivityChanged) {
    yield result != ConnectivityResult.none;
  }
});

// Provider for local database statistics
final localStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  return await OfflineDatabaseService.getLocalStats();
});

// Provider to trigger sync operations
final syncProvider = FutureProvider<void>((ref) async {
  await OfflineDatabaseService.syncPendingOperations();
});