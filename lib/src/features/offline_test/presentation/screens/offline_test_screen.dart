import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/offline_database_provider.dart';
import '../../../../core/services/offline_database_service.dart';
import '../../../../shared/widgets/connectivity_indicator.dart';

class OfflineTestScreen extends ConsumerWidget {
  const OfflineTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider);
    final localStats = ref.watch(localStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Mode Test'),
        actions: const [
          ConnectivityIndicator(),
          SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connectivity Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Connectivity Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    connectivity.when(
                      data: (isConnected) => Row(
                        children: [
                          Icon(
                            isConnected ? Icons.wifi : Icons.wifi_off,
                            color: isConnected ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isConnected ? 'Online' : 'Offline',
                            style: TextStyle(
                              color: isConnected ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text('Error: $error'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Local Database Stats
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Local Database Statistics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    localStats.when(
                      data: (stats) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Questions: ${stats['questions'] ?? 0}'),
                          Text('Answers: ${stats['answers'] ?? 0}'),
                          Text('Pending Sync: ${stats['pending_sync'] ?? 0}'),
                        ],
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text('Error: $error'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test Buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              // Test getting questions offline
                              final questions = await OfflineDatabaseService.getRandomQuestions(
                                count: 5,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Loaded ${questions.length} questions from ${connectivity.value ?? false ? 'online' : 'offline'}',
                                  ),
                                ),
                              );
                            },
                            child: const Text('Load Questions'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              // Test recording an answer
                              await OfflineDatabaseService.recordAnswer(
                                sessionId: 'test-session-${DateTime.now().millisecondsSinceEpoch}',
                                questionId: 'test-question',
                                chosenIndex: 0,
                                isCorrect: true,
                                elapsedMs: 1000,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Answer recorded (will sync when online)'),
                                ),
                              );
                              ref.refresh(localStatsProvider);
                            },
                            child: const Text('Record Answer'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        // Force sync
                        await OfflineDatabaseService.syncPendingOperations();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sync attempted'),
                          ),
                        );
                        ref.refresh(localStatsProvider);
                      },
                      child: const Text('Force Sync'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        // Clear local data
                        await OfflineDatabaseService.clearAllData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Local data cleared'),
                          ),
                        );
                        ref.refresh(localStatsProvider);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Clear Local Data'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Instructions
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to Test Offline Mode:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('1. Turn off WiFi/mobile data'),
                    Text('2. Click "Load Questions" - should work from cache'),
                    Text('3. Click "Record Answer" - will queue for sync'),
                    Text('4. Turn on connectivity - auto-sync should happen'),
                    Text('5. Check "Force Sync" if needed'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}