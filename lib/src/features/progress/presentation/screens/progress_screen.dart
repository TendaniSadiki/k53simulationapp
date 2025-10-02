import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/progress_tracking_service.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Replace with actual user ID from authentication
    const userId = 'current_user';
    final progressFuture = ProgressTrackingService.getUserProgress(userId);
    final insightsFuture = ProgressTrackingService.getLearningInsights(userId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracking'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
      ),
      body: FutureBuilder<ProgressStats>(
        future: progressFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading progress data',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          final progress = snapshot.data!;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Your Learning Progress',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Overall Stats Card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Questions Answered:'),
                            Text(
                              progress.totalQuestions.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Correct Answers:'),
                            Text(
                              progress.correctAnswers.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Accuracy:'),
                            Text(
                              '${(progress.accuracy * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: _getAccuracyColor(progress.accuracy),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Points:'),
                            Text(
                              progress.totalPoints.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Current Streak:'),
                            Text(
                              '${progress.currentStreak} days',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Category Progress
                const Text(
                  'Category Progress:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ..._buildCategoryProgress(progress.categoryStats),

                const SizedBox(height: 20),

                // Learning Insights
                FutureBuilder<Map<String, dynamic>>(
                  future: insightsFuture,
                  builder: (context, insightsSnapshot) {
                    if (insightsSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (insightsSnapshot.hasError || !insightsSnapshot.hasData) {
                      return Container(); // Hide insights if error or no data
                    }

                    final insights = insightsSnapshot.data!;
                    return _buildLearningInsights(insights);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildCategoryProgress(Map<String, CategoryProgress> categoryStats) {
    if (categoryStats.isEmpty) {
      return [
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No category data available yet. Start answering questions to see your progress!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ];
    }

    return categoryStats.entries.map((entry) {
      final category = entry.key;
      final stats = entry.value;
      final accuracy = stats.accuracy;

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          title: Text(category),
          subtitle: LinearProgressIndicator(
            value: accuracy,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(_getAccuracyColor(accuracy)),
          ),
          trailing: Text(
            '${(accuracy * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getAccuracyColor(accuracy),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildLearningInsights(Map<String, dynamic> insights) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Learning Insights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (insights['bestCategory'] != 'N/A')
              _buildInsightRow(
                '🏆 Best Category',
                '${insights['bestCategory']} (${(insights['bestCategoryAccuracy'] * 100).toStringAsFixed(1)}%)',
              ),
            if (insights['weakestCategory'] != 'N/A')
              _buildInsightRow(
                '📊 Needs Improvement',
                '${insights['weakestCategory']} (${(insights['weakestCategoryAccuracy'] * 100).toStringAsFixed(1)}%)',
              ),
            _buildInsightRow(
              '⏱️ Total Study Time',
              _formatDuration(insights['totalStudyTime']),
            ),
            _buildInsightRow(
              '📈 Average Accuracy',
              '${(insights['averageAccuracy'] * 100).toStringAsFixed(1)}%',
            ),
            _buildInsightRow(
              '🎯 Sessions Completed',
              insights['totalSessions'].toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 0.8) return Colors.green;
    if (accuracy >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}