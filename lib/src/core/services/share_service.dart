import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './supabase_service.dart';

class ShareService {
  static const String _referralLink = 'https://k53app.com/referral';
  
  Future<void> shareReferralLink() async {
    final user = SupabaseService.auth.currentUser;
    final referralCode = user?.id.substring(0, 8) ?? 'default';
    final shareText = '''
🚗 Get ready for your K53 Learner's License test!

Download the K53 Learner's License App and use my referral code: $referralCode

✅ Study all K53 road signs and rules
✅ Take unlimited mock exams
✅ Track your progress
✅ Learn at your own pace

Download now: $_referralLink

#K53 #LearnersLicense #DrivingTest #RoadSafety
''';

    await Share.share(shareText);
  }

  Future<Map<String, dynamic>> getReferralStats() async {
    final user = SupabaseService.auth.currentUser;
    if (user == null) {
      return {
        'totalReferrals': 0,
        'completedReferrals': 0,
        'totalPoints': 0,
      };
    }

    try {
      // Query referrals table for this user
      final response = await SupabaseService.client
          .from('referrals')
          .select('*')
          .eq('referrer_id', user.id);

      final referrals = response as List<dynamic>;
      final totalReferrals = referrals.length;
      final completedReferrals = referrals.where((r) => r['is_completed'] == true).length;
      final totalPoints = referrals.fold<int>(0, (sum, r) => sum + ((r['points_awarded'] as int?) ?? 0));

      return {
        'totalReferrals': totalReferrals,
        'completedReferrals': completedReferrals,
        'totalPoints': totalPoints,
      };
    } catch (e) {
      // If referrals table doesn't exist or there's an error, return default values
      return {
        'totalReferrals': 0,
        'completedReferrals': 0,
        'totalPoints': 0,
      };
    }
  }

  Future<void> trackReferral(String referralCode) async {
    final user = SupabaseService.auth.currentUser;
    if (user == null) return;

    try {
      // Record the referral in the database
      await SupabaseService.client
          .from('referrals')
          .insert({
            'referrer_id': referralCode, // The person who shared the code
            'referred_id': user.id,      // The person who used the code
            'created_at': DateTime.now().toIso8601String(),
            'is_completed': true,
            'points_awarded': 100, // Award 100 points for successful referral
          });
    } catch (e) {
      // Handle error silently - referral tracking is optional
      print('Error tracking referral: $e');
    }
  }

  Future<void> shareAchievement(String achievementName, int points) async {
    final shareText = '''
🎉 I just earned the "$achievementName" achievement in the K53 Learner's License App!

🏆 +$points points
🚗 Mastering K53 road signs and rules

Download the app and start your journey to getting your learner's license:
$_referralLink

#K53 #Achievement #DrivingTest #RoadSafety
''';

    await Share.share(shareText);
  }

  Future<void> shareExamResult(int score, int totalQuestions, bool passed) async {
    final resultText = passed ? 'PASSED' : 'NEEDS MORE PRACTICE';
    final emoji = passed ? '🎉' : '📚';
    
    final shareText = '''
$emoji K53 Mock Exam Result: $resultText

📊 Score: $score/$totalQuestions
🚗 Category: All Categories
📱 App: K53 Learner's License

${passed ? 'Ready for the real test!' : 'Time to study more!'}

Download the app and test your knowledge:
$_referralLink

#K53 #MockExam #DrivingTest #${passed ? 'Passed' : 'StudyMore'}
''';

    await Share.share(shareText);
  }

  Future<void> shareProgress(int totalQuestions, int correctAnswers, String category) async {
    final percentage = totalQuestions > 0 ? ((correctAnswers / totalQuestions) * 100).round() : 0;
    
    final shareText = '''
📈 My K53 Learning Progress

✅ Category: $category
🎯 Accuracy: $percentage% ($correctAnswers/$totalQuestions)
📱 App: K53 Learner's License

Making progress towards my learner's license! 🚗

Download the app and track your progress:
$_referralLink

#K53 #LearningProgress #DrivingTest #RoadSafety
''';

    await Share.share(shareText);
  }
}