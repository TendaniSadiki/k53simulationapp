import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  // Read environment variables from .env file
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('❌ .env file not found');
    exit(1);
  }

  final envLines = envFile.readAsLinesSync();
  final envVars = <String, String>{};

  for (final line in envLines) {
    if (line.contains('=') && !line.startsWith('#')) {
      final parts = line.split('=');
      if (parts.length >= 2) {
        envVars[parts[0]] = parts.sublist(1).join('=');
      }
    }
  }

  final supabaseUrl = envVars['SUPABASE_URL'];
  final supabaseKey = envVars['SUPABASE_SERVICE_ROLE_KEY'];
  
  if (supabaseUrl == null || supabaseKey == null) {
    print('❌ Environment variables not found in .env file');
    print('Please set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY');
    exit(1);
  }
  
  final supabase = SupabaseClient(supabaseUrl, supabaseKey);
  
  try {
    print('🔍 Checking database for image URLs...');
    
    // Check road sign questions with images
    final roadSignQuestions = await supabase
        .from('questions')
        .select('id, question_text, image_url, category')
        .eq('category', 'road_signs')
        .order('id');
    
    print('\n📊 Road Sign Questions (${roadSignQuestions.length} total):');
    
    int questionsWithImages = 0;
    int questionsWithoutImages = 0;
    
    for (final question in roadSignQuestions) {
      final hasImage = question['image_url'] != null;
      if (hasImage) {
        questionsWithImages++;
        print('✅ ${question['question_text']}');
        print('   Image: ${question['image_url']}');
      } else {
        questionsWithoutImages++;
        print('❌ ${question['question_text']}');
        print('   Image: NULL');
      }
      print('---');
    }
    
    print('\n📈 Summary:');
    print('Questions with images: $questionsWithImages');
    print('Questions without images: $questionsWithoutImages');
    
    if (questionsWithImages > 0) {
      print('\n🎉 SUCCESS: Image URLs are now populated in the database!');
      print('The app should now display images for road sign questions.');
    } else {
      print('\n❌ WARNING: No image URLs found in road sign questions');
      print('Check if the seeding script properly updated the image_url column');
    }
    
  } catch (e) {
    print('Error checking database: $e');
  } finally {
    supabase.dispose();
  }
}