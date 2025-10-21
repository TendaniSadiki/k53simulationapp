import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/gamification_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/database_service.dart';
import '../providers/gamification_provider.dart';
import '../../../../shared/widgets/connectivity_indicator.dart';
import '../../../../core/models/user_profile.dart';

class UserProfileDashboard extends ConsumerStatefulWidget {
  const UserProfileDashboard({super.key});

  @override
  ConsumerState<UserProfileDashboard> createState() => _UserProfileDashboardState();
}

class _UserProfileDashboardState extends ConsumerState<UserProfileDashboard> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _userStats;
  List<Map<String, dynamic>> _userAchievements = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
    });
  }


  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = SupabaseService.currentUserId;
      if (userId != null) {
        // Load user profile
        final profileData = await DatabaseService.getUserProfile(userId);
        if (profileData != null) {
          _userProfile = UserProfile.fromSupabase(profileData);
        }

        // Load user stats
        try {
          _userStats = await GamificationService().getUserStats();
        } catch (e) {
          print('Error loading user stats: $e');
          _userStats = {'points': 0, 'level': 1, 'unlocked_achievements': 0};
        }

        // Load user achievements
        try {
          final achievements = await GamificationService().getUserAchievements();
          _userAchievements = achievements.map((achievement) => {
            'name': achievement.achievementId,
            'description': 'Complete tasks to unlock',
            'unlocked': achievement.unlocked,
            'unlocked_at': achievement.unlockedAt,
          }).toList();
        } catch (e) {
          print('Error loading achievements: $e');
          _userAchievements = [];
        }
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load profile: $e';
        _isLoading = false;
      });
    }
  }

  void _showEditProfileDialog() {
    if (_userProfile != null) {
      _nameController.text = _userProfile!.handle ?? '';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Display Name',
                hintText: 'Enter your display name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Note: Email cannot be changed here. Contact support for email changes.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _saveProfile,
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isEditing = true;
    });

    try {
      final userId = SupabaseService.currentUserId;
      if (userId != null && _userProfile != null) {
        // Get current user email from auth
        final currentUser = SupabaseService.client.auth.currentUser;
        final userEmail = currentUser?.email ?? '';
        
        // Create updated profile data
        final updatedProfile = {
          'id': userId,
          'handle': _nameController.text.isNotEmpty ? _nameController.text : null,
          'email': userEmail,
          'learner_code': _userProfile!.learnerCode,
          'locale': _userProfile!.locale,
          'study_goal_date': _userProfile!.studyGoalDate?.toIso8601String(),
          'daily_points': _userProfile!.dailyPoints,
          'gaming_points': _userProfile!.gamingPoints,
          'total_points': _userProfile!.totalPoints,
          'level': _userProfile!.level,
          'login_streak': _userProfile!.loginStreak,
          'last_login_date': _userProfile!.lastLoginDate?.toIso8601String(),
          'last_daily_points_date': _userProfile!.lastDailyPointsDate?.toIso8601String(),
          'created_at': _userProfile!.createdAt.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        await DatabaseService.updateUserProfile(updatedProfile);
        
        // Reload profile data
        await _loadUserProfile();
        
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    } finally {
      setState(() {
        _isEditing = false;
      });
    }
  }

  Future<void> _claimDailyPoints() async {
    try {
      await GamificationService().trackDailyLogin();
      await _loadUserProfile(); // Refresh profile data
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Daily points claimed successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to claim daily points: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildPointCard(String title, int points, Color color, IconData icon) {
    return Card(
      elevation: 4,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.3)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '$points',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              'Points',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gamificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
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
                        onPressed: _loadUserProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUserProfile,
                  child: ListView(
                    padding: EdgeInsets.all(16),
                    children: [
                      // User Header with Edit Button
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _userProfile?.handle ?? 'User',
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: _showEditProfileDialog,
                                          icon: Icon(Icons.edit, size: 20),
                                          tooltip: 'Edit Profile',
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      _getUserEmail(),
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      'Learner Code: ${_userProfile?.learnerCode ?? 0}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Daily Points Claim Section
                      if (_userProfile?.canClaimDailyPoints() ?? true)
                        Card(
                          elevation: 4,
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Colors.green[100]!, Colors.green[200]!],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.celebration, color: Colors.green[800], size: 32),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Daily Login Bonus!',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green[800],
                                            ),
                                          ),
                                          Text(
                                            'Claim your daily points and maintain your streak',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Colors.green[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _claimDailyPoints,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.star),
                                      SizedBox(width: 8),
                                      Text(
                                        'Claim ${_calculateDailyPoints(_userProfile?.loginStreak ?? 0)} Points',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Card(
                          elevation: 4,
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 32),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Daily Points Claimed',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      Text(
                                        'Come back tomorrow for more points!',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      SizedBox(height: 16),

                      // Progress Overview with Points
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Progress Overview',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.star, size: 16, color: Colors.blue[800]),
                                        SizedBox(width: 4),
                                        Text(
                                          'Level ${_userProfile?.level ?? 1}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              
                              // Points Summary
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildProgressStat('Total Points', _userProfile?.totalPoints ?? 0, Icons.star, Colors.orange),
                                  _buildProgressStat('Daily Points', _userProfile?.dailyPoints ?? 0, Icons.calendar_today, Colors.green),
                                  _buildProgressStat('Gaming Points', _userProfile?.gamingPoints ?? 0, Icons.videogame_asset, Colors.blue),
                                ],
                              ),
                              SizedBox(height: 16),
                              
                              // Level Progress
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Level Progress',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${_userProfile?.totalPoints ?? 0} / ${_calculateNextLevelPoints(_userProfile?.level ?? 1)}',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: _calculateLevelProgress(_userProfile?.totalPoints ?? 0, _userProfile?.level ?? 1),
                                    backgroundColor: Colors.grey[300],
                                    color: Colors.blue,
                                    minHeight: 8,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${_calculatePointsToNextLevel(_userProfile?.totalPoints ?? 0, _userProfile?.level ?? 1)} points to next level',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Achievements Preview
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Recent Achievements',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => context.go('/achievements'),
                                    child: Text('View All'),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              
                              // Achievement preview cards
                              _buildAchievementPreview(),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 24),

                      // Statistics
                      Text(
                        'Statistics',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),

                      Column(
                        children: [
                          _buildStatCard(
                            'Login Streak',
                            '${_userProfile?.loginStreak ?? 0} days',
                            Icons.local_fire_department,
                            Colors.red,
                          ),
                          SizedBox(height: 8),
                          _buildStatCard(
                            'Last Login',
                            _userProfile?.lastLoginDate != null
                                ? _formatDate(_userProfile!.lastLoginDate!)
                                : 'Never',
                            Icons.calendar_today,
                            Colors.blue,
                          ),
                          SizedBox(height: 8),
                          _buildStatCard(
                            'Study Goal',
                            _userProfile?.studyGoalDate != null
                                ? _formatDate(_userProfile!.studyGoalDate!)
                                : 'Not set',
                            Icons.flag,
                            Colors.green,
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Quick Actions
                      Text(
                        'Quick Actions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),

                      GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: [
                          _buildActionCard(
                            'Achievements',
                            Icons.emoji_events,
                            Colors.orange,
                            () => context.go('/achievements'),
                          ),
                          _buildActionCard(
                            'Progress',
                            Icons.timeline,
                            Colors.blue,
                            () => context.go('/progress'),
                          ),
                          _buildActionCard(
                            'Study',
                            Icons.school,
                            Colors.green,
                            () => context.go('/study'),
                          ),
                          _buildActionCard(
                            'Settings',
                            Icons.settings,
                            Colors.grey,
                            () => context.go('/settings'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateDailyPoints(int streak) {
    if (streak >= 30) return 5;
    if (streak >= 14) return 4;
    if (streak >= 7) return 3;
    if (streak >= 3) return 2;
    return 1;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // New methods for progress overview
  Widget _buildProgressStat(String title, int value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        SizedBox(height: 4),
        Text(
          '$value',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  int _calculateNextLevelPoints(int currentLevel) {
    return currentLevel * (currentLevel + 1) * 50;
  }

  double _calculateLevelProgress(int totalPoints, int currentLevel) {
    final currentLevelPoints = _calculateNextLevelPoints(currentLevel - 1);
    final nextLevelPoints = _calculateNextLevelPoints(currentLevel);
    final pointsInCurrentLevel = totalPoints - currentLevelPoints;
    final pointsNeededForNextLevel = nextLevelPoints - currentLevelPoints;
    
    return pointsInCurrentLevel / pointsNeededForNextLevel;
  }

  int _calculatePointsToNextLevel(int totalPoints, int currentLevel) {
    final nextLevelPoints = _calculateNextLevelPoints(currentLevel);
    return nextLevelPoints - totalPoints;
  }

  Widget _buildAchievementPreview() {
    // For now, show a placeholder for achievements
    // In a real implementation, this would fetch actual achievements
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.orange, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'First Steps',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                      ),
                    ),
                    Text(
                      'Complete your first study session',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+10 pts',
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.green, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Learner',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    Text(
                      'Study for 3 consecutive days',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+20 pts',
                  style: TextStyle(
                    color: Colors.green[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(
          'And ${_userProfile?.totalPoints != null ? (_userProfile!.totalPoints ~/ 10) : 0} more achievements...',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  String _getUserEmail() {
    try {
      final currentUser = SupabaseService.client.auth.currentUser;
      return currentUser?.email ?? 'user@example.com';
    } catch (e) {
      return 'user@example.com';
    }
  }
}