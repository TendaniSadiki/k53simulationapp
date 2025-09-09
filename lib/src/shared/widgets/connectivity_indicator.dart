import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/offline_database_provider.dart';

class ConnectivityIndicator extends ConsumerWidget {
  const ConnectivityIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityProvider);
    
    return connectivityAsync.when(
      data: (isConnected) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isConnected ? Colors.green : Colors.orange,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isConnected ? Icons.wifi : Icons.wifi_off,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                isConnected ? 'Online' : 'Offline',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (error, stack) => const Icon(
        Icons.error_outline,
        size: 16,
        color: Colors.red,
      ),
    );
  }
}

class OfflineStatsIndicator extends ConsumerWidget {
  const OfflineStatsIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(localStatsProvider);
    
    return statsAsync.when(
      data: (stats) {
        final questionCount = stats['questions'] ?? 0;
        final answerCount = stats['answers'] ?? 0;
        final pendingSync = stats['pending_sync'] ?? 0;
        
        if (questionCount == 0 && answerCount == 0 && pendingSync == 0) {
          return const SizedBox.shrink();
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.storage,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                '$questionCount Q • $answerCount A',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (pendingSync > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$pendingSync',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}