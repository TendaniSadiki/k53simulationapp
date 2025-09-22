import 'dart:io';

void main() {
  print('🔄 Fixing image paths in SQL files...');
  
  // Define the path mapping from old flat structure to new organized structure
  final pathMapping = {
    'Maximum speed limit allowed.png': 'SELECTIVE RESTRICTION SIGNS/Maximum of 15 vehicles.png',
    'No stopping to ensure traffic flow and prevent dri.png': 'CONTROL SIGNS/Stop in line with the Stop sign or before the line.png',
    'Parking only if you pay the parking fee.png': 'SELECTIVE RESTRICTION SIGNS/Parking only if you pay the parking fee.png',
    'Parking_30min_Week_09-16_Sat_08-13.png.png': 'SELECTIVE RESTRICTION SIGNS/Parking_30min_Week_09-16_Sat_08-13.png.png',
    'Parking here is reserved for a vehicle carrying people with disabilities.png': 'RESERVATION SIGNS/Parking here is reserved for a vehicle carrying people with disabilities.png',
    'Over taking vehicles is prohibited for the next 500m.png': 'SELECTIVE RESTRICTION SIGNS/Overtaking prohibited for the next 2km.png',
    'Overtaking prohibited for the next 2km.png': 'SELECTIVE RESTRICTION SIGNS/Overtaking prohibited for the next 2km.png',
    'No over taking vehicles by goods vehicles for the next 500m.png': 'SELECTIVE RESTRICTION SIGNS/No right turn by buses allowed at the next junction.png',
    'No vehicles may enter this road at any time.png': 'CONTROL SIGNS/No vehicles may enter this road at any time.png',
    'Applies only to mini-buses.png': 'SELECTIVE RESTRICTION SIGNS/Applies only to mini-buses.png',
    'Come to a complete halt in line with the stop sign.png': 'CONTROL SIGNS/Come to a complete halt in line with the stop sign.png',
    'To indicate that you must move in a clockwise direction at the junction.png': 'CONTROL SIGNS/This is to indicate that there is a one-way carria.png',
    'Indicates that you must yield to other traffic. Gi.png': 'CONTROL SIGNS/Indicates that you must yield to other traffic. Gi.png',
    'Traffic circle ahead ( mini circle or round about)..png': 'CONTROL SIGNS/Traffic circle ahead ( mini circle or round about)..png',
    'Give way to any pedestrians on or about to enter t.png': 'CONTROL SIGNS/Give way to any pedestrians on or about to enter t.png',
    'Dual-carriage freeway begins The following rules apply to all freeways.png': 'COMPREHENSIVE SIGNS/Dual-carriage freeway begins The following rules apply to all freeways.png',
    'End of dual carriage freeway and freeway rules no longer apply.png': 'DE-RESTRICTION SIGNS/End of dual carriage freeway and freeway rules no longer apply.png',
    'Residential area.png': 'COMPREHENSIVE SIGNS/Residential area.png',
    'Gross vehicle mass limit allowed.png': 'SELECTIVE RESTRICTION SIGNS/Goods vehicles must travel at 50km per hour or faster.png',
  };

  // Read the SQL files
  final roadSignSql = File('scripts/road_sign_questions_output.sql').readAsStringSync();
  final rulesSql = File('scripts/seed_evolve_questions_with_images_updated.sql').readAsStringSync();
  
  String updatedRoadSignSql = roadSignSql;
  String updatedRulesSql = rulesSql;
  
  // Replace paths in both SQL files
  pathMapping.forEach((oldPath, newPath) {
    final oldFullPath = 'assets/individual_signs/$oldPath';
    final newFullPath = 'assets/individual_signs/$newPath';
    
    updatedRoadSignSql = updatedRoadSignSql.replaceAll(oldFullPath, newFullPath);
    updatedRulesSql = updatedRulesSql.replaceAll(oldFullPath, newFullPath);
  });
  
  // Write the updated files
  File('scripts/road_sign_questions_output_fixed.sql').writeAsStringSync(updatedRoadSignSql);
  File('scripts/seed_evolve_questions_with_images_updated_fixed.sql').writeAsStringSync(updatedRulesSql);
  
  print('✅ Created fixed SQL files:');
  print('   - scripts/road_sign_questions_output_fixed.sql');
  print('   - scripts/seed_evolve_questions_with_images_updated_fixed.sql');
  print('\n📋 Next steps:');
  print('   1. Review the fixed SQL files');
  print('   2. Run the verification script again: dart scripts/verify_sql_image_paths.dart');
  print('   3. Execute the SQL files in Supabase dashboard');
}