import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/gamification_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/database_service.dart';
import '../providers/gamification_provider.dart';
import '../../../../shared/widgets/connectivity_indicator.dart';
import '../../../../core/models/achievement.dart';
import '../../../../core/models/user_profile.dart';

class EnhancedAchievementsScreen extends ConsumerStatefulWidget {
  const EnhancedAchievementsScreen({super.key});

  @override
  ConsumerState<EnhancedAchievementsScreen> createState() => _EnhancedAchievementsScreenState();
}

class _EnhancedAchievementsScreenState extends ConsumerState<EnhancedAchievementsScreen> {
  List<Achievement> _achievements = [];
  List<UserAchievement> _userAchievements = [];
  UserProfile? _userProfile;
  bool _isLoading = true;
  String? _error;
  AchievementType? _selectedFilter;
  bool _showUnlockedOnly = false;

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
      final gamificationService = GamificationService();
      
      // Load achievements and user profile
      final achievements = await gamificationService.getAllAchievements();
      final userAchievements = await gamificationService.getUserAchievements();
      final userStats = await gamificationService.getUserStats();
      
      // Load user profile for point display
      final userId = SupabaseService.currentUserId;
      if (userId != null) {
        _userProfile = await DatabaseService.getUserProfile(userId);
      }

      setState(() {
        _achievements = achievements;
        _userAchievements = userAchievements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load achievements: $e';
        _isLoading = false;
      });
    }
  }

  void _showAchievementUnlockDialog(Achievement achievement) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.green[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.orange, size: 32),
            SizedBox(width: 12),
            Text(
              'Achievement Unlocked!',
              style: TextStyle(
                color: Colors.green[800],
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              achievement.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.green[700]),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.orange[800]),
                  SizedBox(width: 8),
                  Text(
                    '+${achievement.points} Points',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  List<Achievement> get _filteredAchievements {
    var filtered = _achievements;

    // Apply type filter
    if (_selectedFilter != null) {
      filtered = filtered.where((a) => a.type == _selectedFilter).toList();
    }

    // Apply unlocked filter
    if (_showUnlockedOnly) {
      filtered = filtered.where((a) {
        final userAchievement = _userAchievements.firstWhere(
          (ua) => ua.achievementId == a.id,
          orElse: () => UserAchievement(
            id: '',
            userId: '',
            achievementId: a.id,
            progress: 0,
            unlocked: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        return userAchievement.unlocked;
      }).toList();
    }

    return filtered;
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final userAchievement = _userAchievements.firstWhere(
      (ua) => ua.achievementId == achievement.id,
      orElse: () => UserAchievement(
        id: '',
        userId: '',
        achievementId: achievement.id,
        progress: 0,
        unlocked: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    final isUnlocked = userAchievement.unlocked;
    final progress = userAchievement.progress;
    final target = achievement.targetValue;
    final progressPercentage = target > 0 ? progress / target : 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: isUnlocked ? Colors.green[50] : Colors.grey[100],
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Achievement Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isUnlocked ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                isUnlocked ? Icons.emoji_events : Icons.lock,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            
            // Achievement Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        achievement.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isUnlocked ? Colors.green[800] : Colors.grey[700],
                            ),
                      ),
                      if (isUnlocked)
                        Icon(Icons.verified, color: Colors.green, size: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isUnlocked ? Colors.green[600] : Colors.grey[600],
                        ),
                  ),
                  
                  // Progress Bar for Locked Achievements
                  if (!isUnlocked)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progressPercentage.toDouble(),
                          backgroundColor: Colors.grey[300],
                          color: _getProgressColor(achievement.type),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$progress/$target',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '${(progressPercentage * 100).toStringAsFixed(0)}%',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  
                  // Points Awarded for Unlocked Achievements
                  if (isUnlocked)
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.orange[800]),
                          SizedBox(width: 4),
                          Text(
                            '+${achievement.points} Points',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(AchievementType type) {
    switch (type) {
      case AchievementType.streak:
        return Colors.green;
      case AchievementType.accuracy:
        return Colors.blue;
      case AchievementType.completion:
        return Colors.purple;
      case AchievementType.speed:
        return Colors.orange;
      case AchievementType.social:
        return Colors.pink;
      default:
        return Colors.blue;
    }
  }

  String _getAchievementTypeLabel(AchievementType type) {
    switch (type) {
      case AchievementType.streak:
        return 'Streak';
      case AchievementType.accuracy:
        return 'Accuracy';
      case AchievementType.completion:
        return 'Completion';
      case AchievementType.speed:
        return 'Speed';
      case AchievementType.social:
        return 'Social';
      default:
        return 'Other';
    }
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
                  child: Column(
                    children: [
                      // Header with Stats
                      Card(
                        margin: const EdgeInsets.all(16),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Dual Point System Display
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildPointItem(
                                    icon: Icons.calendar_today,
                                    value: '${_userProfile?.dailyPoints ?? 0}',
                                    label: 'Daily Points',
                                    color: Colors.green,
                                  ),
                                  _buildPointItem(
                                    icon: Icons.videogame_asset,
                                    value: '${_userProfile?.gamingPoints ?? 0}',
                                    label: 'Gaming Points',
                                    color: Colors.blue,
                                  ),
                                  _buildPointItem(
                                    icon: Icons.star,
                                    value: '${_userProfile?.totalPoints ?? 0}',
                                    label: 'Total Points',
                                    color: Colors.orange,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem(
                                    icon: Icons.emoji_events,
                                    value: '${_userAchievements.where((ua) => ua.unlocked).length}',
                                    label: 'Unlocked',
                                    color: Colors.green,
                                  ),
                                  _buildStatItem(
                                    icon: Icons.leaderboard,
                                    value: 'Level ${_userProfile?.level ?? 1}',
                                    label: 'Level',
                                    color: Colors.purple,
                                  ),
                                  _buildStatItem(
                                    icon: Icons.local_fire_department,
                                    value: '${_userProfile?.loginStreak ?? 0}',
                                    label: 'Day Streak',
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Filter Controls
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: DropdownButton<AchievementType>(
                                value: _selectedFilter,
                                hint: Text('Filter by Type'),
                                isExpanded: true,
                                items: [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text('All Types'),
                                  ),
                                  ...AchievementType.values.map((type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Text(_getAchievementTypeLabel(type)),
                                    );
                                  }).toList(),
                                ],
                                onChanged: (type) {
                                  setState(() {
                                    _selectedFilter = type;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            FilterChip(
                              label: Text('Unlocked Only'),
                              selected: _showUnlockedOnly,
                              onSelected: (selected) {
                                setState(() {
                                  _showUnlockedOnly = selected;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Achievements List
                      Expanded(
                        child: ListView(
                          children: [
                            ..._filteredAchievements.map((achievement) => _buildAchievementCard(achievement)),
                            if (_filteredAchievements.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  children: [
                                    Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No achievements found',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Try changing your filters',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPointItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        const SizedBox(height: 8),
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