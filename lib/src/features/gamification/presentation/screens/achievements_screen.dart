import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/gamification_service.dart';
import '../providers/gamification_provider.dart';
import '../../../../shared/widgets/connectivity_indicator.dart';
import '../../../../core/models/achievement.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  List<Map<String, dynamic>> _achievements = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAchievements();
    });
  }

  Future<void> _loadAchievements() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // For now, use sample achievements since database might not have real data
      _achievements = [
        {
          'id': '1',
          'name': 'First Steps',
          'description': 'Complete your first study session',
          'progress': 1,
          'target': 1,
          'unlocked': true,
        },
        {
          'id': '2',
          'name': 'Exam Master',
          'description': 'Pass 5 mock exams',
          'progress': 2,
          'target': 5,
          'unlocked': false,
        },
        {
          'id': '3',
          'name': 'Perfect Score',
          'description': 'Get 100% on a mock exam',
          'progress': 0,
          'target': 1,
          'unlocked': false,
        },
        {
          'id': '4',
          'name': 'Daily Learner',
          'description': 'Study for 7 consecutive days',
          'progress': 3,
          'target': 7,
          'unlocked': false,
        },
        {
          'id': '5',
          'name': 'Road Signs Expert',
          'description': 'Master all road signs questions',
          'progress': 15,
          'target': 25,
          'unlocked': false,
        },
      ];

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load achievements: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    final isUnlocked = achievement['unlocked'] ?? false;
    final progress = achievement['progress'] ?? 0;
    final target = achievement['target'] ?? 1;
    final progressPercentage = progress / target;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: isUnlocked ? Colors.green[50] : Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isUnlocked ? Icons.verified : Icons.lock,
              color: isUnlocked ? Colors.green : Colors.grey,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement['name'] ?? 'Achievement',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? Colors.green[800] : Colors.grey[700],
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement['description'] ?? 'Complete this achievement',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isUnlocked ? Colors.green[600] : Colors.grey[600],
                        ),
                  ),
                  if (!isUnlocked)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progressPercentage,
                          backgroundColor: Colors.grey[300],
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$progress/$target',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                ],
              ),
            ),
            if (isUnlocked)
              const Icon(Icons.emoji_events, color: Colors.orange),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gamificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: const [
          ConnectivityIndicator(),
          SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAchievements,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAchievements,
                  child: ListView(
                    children: [
                      // Header with stats
                      Card(
                        margin: const EdgeInsets.all(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                icon: Icons.emoji_events,
                                value: '${_achievements.where((a) => a['unlocked'] == true).length}',
                                label: 'Unlocked',
                                color: Colors.green,
                              ),
                              _buildStatItem(
                                icon: Icons.star,
                                value: '${state.points}',
                                label: 'Points',
                                color: Colors.blue,
                              ),
                              _buildStatItem(
                                icon: Icons.leaderboard,
                                value: 'Level ${state.level}',
                                label: 'Level',
                                color: Colors.orange,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Achievements list
                      ..._achievements.map((achievement) => _buildAchievementCard(achievement)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}