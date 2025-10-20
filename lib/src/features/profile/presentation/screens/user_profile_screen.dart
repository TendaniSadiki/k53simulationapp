import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/progress_tracking_service.dart';
import '../../../../core/services/progress_tracking_service.dart';
import '../widgets/progress_chart_widget.dart';
import '../widgets/profile_info_widget.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  Map<String, dynamic>? _userProfile;
  ProgressStats? _userProgress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authState = ref.read(authProvider);
      if (authState.user != null) {
        // Load user profile
        final profile = await DatabaseService.getUserProfile(authState.user!.id);
        
        // Load user progress
        final progress = await ProgressTrackingService.getUserProgress(authState.user!.id);

        setState(() {
          _userProfile = profile;
          _userProgress = progress;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Profile Information
                    ProfileInfoWidget(
                      user: authState.user,
                      profile: _userProfile,
                      onProfileUpdated: _refreshData,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Progress Overview
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Progress Overview',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ProgressChartWidget(progress: _userProgress),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Learning Insights
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Learning Insights',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildLearningInsights(),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Gamification Stats
                    if (_userProfile != null) _buildGamificationStats(),
                    
                    const SizedBox(height: 24),
                    
                    // Quick Actions
                    _buildQuickActions(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildGamificationStats() {
    final totalPoints = _userProfile?['total_points'] ?? 0;
    final level = _userProfile?['level'] ?? 1;
    final loginStreak = _userProfile?['login_streak'] ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gamification Stats',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Level',
                level.toString(),
                Icons.star,
              ),
              _buildStatItem(
                'Points',
                totalPoints.toString(),
                Icons.emoji_events,
              ),
              _buildStatItem(
                'Streak',
                '$loginStreak days',
                Icons.local_fire_department,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildActionButton(
                'Edit Profile',
                Icons.edit,
                () => _showEditProfileDialog(),
              ),
              _buildActionButton(
                'Study History',
                Icons.history,
                () => _showStudyHistory(),
              ),
              _buildActionButton(
                'Achievements',
                Icons.emoji_events,
                () => _showAchievements(),
              ),
              _buildActionButton(
                'Settings',
                Icons.settings,
                () => _showSettings(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    // TODO: Implement edit profile dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit profile functionality coming soon!')),
    );
  }

  void _showStudyHistory() {
    // TODO: Implement study history screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Study history functionality coming soon!')),
    );
  }

  void _showAchievements() {
    // TODO: Implement achievements screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Achievements functionality coming soon!')),
    );
  }

  void _showSettings() {
    // TODO: Implement settings screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings functionality coming soon!')),
    );
  }

  Widget _buildLearningInsights() {
    if (_userProgress == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'Complete some questions to see learning insights',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final progress = _userProgress!;
    final totalQuestions = progress.totalQuestions;
    final accuracy = progress.accuracy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Study Streak
        _buildInsightCard(
          'Study Streak',
          '${_userProfile?['login_streak'] ?? 0} days',
          Icons.local_fire_department,
          Colors.orange,
          'Keep going! Maintain your streak for better learning retention.',
        ),
        
        const SizedBox(height: 12),
        
        // Current Level
        _buildInsightCard(
          'Current Level',
          'Level ${_userProfile?['level'] ?? 1}',
          Icons.star,
          Colors.amber,
          'Level up by answering more questions correctly!',
        ),
        
        const SizedBox(height: 12),
        
        // Performance Insights
        if (totalQuestions > 0) ...[
          _buildInsightCard(
            'Performance',
            accuracy >= 0.8 ? 'Excellent' : accuracy >= 0.6 ? 'Good' : 'Needs Practice',
            accuracy >= 0.8 ? Icons.emoji_events : accuracy >= 0.6 ? Icons.thumb_up : Icons.school,
            accuracy >= 0.8 ? Colors.green : accuracy >= 0.6 ? Colors.blue : Colors.orange,
            accuracy >= 0.8
                ? 'Great work! You\'re mastering the material.'
                : accuracy >= 0.6
                    ? 'Good progress. Keep practicing!'
                    : 'Focus on areas where you need improvement.',
          ),
          
          const SizedBox(height: 12),
        ],
        
        // Study Recommendations
        _buildInsightCard(
          'Recommendations',
          'Study Tips',
          Icons.lightbulb,
          Colors.purple,
          totalQuestions == 0
              ? 'Start with basic questions to build your foundation.'
              : accuracy < 0.6
                  ? 'Review incorrect answers and focus on weak areas.'
                  : 'Try more challenging questions to advance your skills.',
        ),
      ],
    );
  }

  Widget _buildInsightCard(String title, String value, IconData icon, Color color, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}