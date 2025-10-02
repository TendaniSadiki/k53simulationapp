import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/progress_tracking_service.dart';
import '../../../../core/models/progress_tracking.dart';
import '../../../../shared/widgets/connectivity_indicator.dart';

class ComprehensiveProgressDashboard extends ConsumerStatefulWidget {
  const ComprehensiveProgressDashboard({super.key});

  @override
  ConsumerState<ComprehensiveProgressDashboard> createState() => _ComprehensiveProgressDashboardState();
}

class _ComprehensiveProgressDashboardState extends ConsumerState<ComprehensiveProgressDashboard> {
  final ProgressTrackingService _progressService = ProgressTrackingService();
  List<LearningGoal> _goals = [];
  ProgressAnalytics? _analytics;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProgressData();
    });
  }

  Future<void> _loadProgressData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final goals = await _progressService.getUserLearningGoals();
      final analytics = await _progressService.getProgressAnalytics();
      
      setState(() {
        _goals = goals;
        _analytics = analytics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load progress data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _createSampleGoal() async {
    try {
      final goal = await _progressService.generateK53LearningGoal();
      await _progressService.createLearningGoal(
        title: goal.title,
        description: goal.description,
        targetDate: goal.targetDate,
        milestones: goal.milestones,
        dailyTasks: goal.dailyTasks,
      );
      await _loadProgressData();
    } catch (e) {
      print('Error creating sample goal: $e');
    }
  }

  Widget _buildGoalOverview() {
    if (_goals.isEmpty) {
      return Card(
        elevation: 4,
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.flag, size: 64, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'No Learning Goals Yet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Create your first learning goal to start tracking your progress',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _createSampleGoal,
                child: Text('Create K53 Preparation Goal'),
              ),
            ],
          ),
        ),
      );
    }

    final primaryGoal = _goals.first;
    return Card(
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
                  primaryGoal.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryGoal.isOnTrack ? Colors.green[100] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    primaryGoal.isOnTrack ? 'On Track' : 'Needs Attention',
                    style: TextStyle(
                      color: primaryGoal.isOnTrack ? Colors.green[800] : Colors.orange[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              primaryGoal.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            
            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overall Progress',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(primaryGoal.overallProgress * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: primaryGoal.overallProgress,
                  backgroundColor: Colors.grey[300],
                  color: Colors.blue,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${primaryGoal.daysRemaining} days remaining',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${primaryGoal.milestones.where((m) => m.isCompleted).length}/${primaryGoal.milestones.length} milestones',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneMap() {
    if (_goals.isEmpty) return SizedBox();

    final milestones = _goals.expand((goal) => goal.milestones).toList();
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Milestone Journey',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ...milestones.asMap().entries.map((entry) {
              final index = entry.key;
              final milestone = entry.value;
              final isLast = index == milestones.length - 1;
              
              return Column(
                children: [
                  Row(
                    children: [
                      // Milestone Icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: milestone.isCompleted 
                              ? milestone.typeColor 
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          milestone.isCompleted ? Icons.check : Icons.flag,
                          color: milestone.isCompleted ? Colors.white : Colors.grey[600],
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      
                      // Milestone Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              milestone.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: milestone.isCompleted ? milestone.typeColor : Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              milestone.description,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (milestone.targetDate.isAfter(DateTime.now()))
                              Text(
                                'Due: ${_formatDate(milestone.targetDate)}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.orange[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Connection Line (except for last milestone)
                  if (!isLast)
                    Container(
                      margin: EdgeInsets.only(left: 20, top: 8, bottom: 8),
                      width: 2,
                      height: 20,
                      color: Colors.grey[300],
                    ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsOverview() {
    if (_analytics == null) return SizedBox();

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learning Analytics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            // Key Metrics
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildMetricCard(
                  'Study Sessions',
                  '${_analytics!.totalStudySessions}',
                  Icons.school,
                  Colors.blue,
                ),
                _buildMetricCard(
                  'Practice Sessions',
                  '${_analytics!.totalPracticeSessions}',
                  Icons.videogame_asset,
                  Colors.green,
                ),
                _buildMetricCard(
                  'Questions Answered',
                  '${_analytics!.totalQuestionsAnswered}',
                  Icons.quiz,
                  Colors.orange,
                ),
                _buildMetricCard(
                  'Accuracy',
                  '${_analytics!.accuracyPercentage.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.purple,
                ),
                _buildMetricCard(
                  'Study Minutes',
                  '${_analytics!.totalStudyMinutes}',
                  Icons.timer,
                  Colors.red,
                ),
                _buildMetricCard(
                  'Current Streak',
                  '${_analytics!.streakDays} days',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: color),
          SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDailyHabitTracker() {
    if (_analytics == null) return SizedBox();

    final last7Days = _analytics!.dailyProgress.take(7).toList();
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '7-Day Habit Tracker',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: last7Days.asMap().entries.map((entry) {
                final day = entry.value;
                final dayName = _getDayName(day.date.weekday);
                
                return Column(
                  children: [
                    Text(
                      dayName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: day.hasActivity ? Colors.green : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: day.hasActivity ? Colors.green[800]! : Colors.grey[400]!,
                        ),
                      ),
                      child: day.hasActivity 
                          ? Icon(Icons.check, size: 18, color: Colors.white)
                          : Icon(Icons.close, size: 18, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${day.totalMinutes}m',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: day.hasActivity ? Colors.green[800] : Colors.grey[600],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryProgress() {
    if (_analytics == null || _analytics!.categoryAccuracy.isEmpty) return SizedBox();

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Performance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            ..._analytics!.categoryAccuracy.entries.map((entry) {
              final category = entry.key;
              final accuracy = entry.value;
              
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _formatCategoryName(category),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${(accuracy * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getAccuracyColor(accuracy),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: accuracy,
                    backgroundColor: Colors.grey[300],
                    color: _getAccuracyColor(accuracy),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  SizedBox(height: 16),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Dashboard'),
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
                        onPressed: _loadProgressData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadProgressData,
                  child: ListView(
                    padding: EdgeInsets.all(16),
                    children: [
                      _buildGoalOverview(),
                      SizedBox(height: 16),
                      _buildMilestoneMap(),
                      SizedBox(height: 16),
                      _buildAnalyticsOverview(),
                      SizedBox(height: 16),
                      _buildDailyHabitTracker(),
                      SizedBox(height: 16),
                      _buildCategoryProgress(),
                      SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  String _formatCategoryName(String category) {
    return category.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 0.8) return Colors.green;
    if (accuracy >= 0.6) return Colors.orange;
    return Colors.red;
  }
}