import 'package:supabase/supabase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  
  final supabaseUrl = dotenv.get('SUPABASE_URL');
  final supabaseKey = dotenv.get('SUPABASE_SERVICE_ROLE_KEY');
  
  final supabase = SupabaseClient(supabaseUrl, supabaseKey);
  
  try {
    // Check if image_url column exists
    final result = await supabase
        .from('questions')
        .select('id, question_text, image_url')
        .limit(1);
    
    print('✅ Database connection successful');
    print('✅ image_url column exists in questions table');
    
    // Check if any questions have image_url populated
    final questionsWithImages = await supabase
        .from('questions')
        .select('id, question_text, image_url')
        .neq('image_url', 'null');
    
    print('Questions with images: ${questionsWithImages.length}');
    
    for (final question in questionsWithImages) {
      print('  - ${question['question_text']}: ${question['image_url']}');
    }
    
  } catch (e) {
    if (e.toString().contains('image_url')) {
      print('❌ ERROR: image_url column does not exist in questions table');
      print('Please run the SQL migration from scripts/add_image_url_column.sql');
      print('in your Supabase dashboard SQL editor');
    } else {
      print('Error checking database: $e');
    }
  } finally {
    supabase.dispose();
  }
}