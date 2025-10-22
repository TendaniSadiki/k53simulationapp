import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'src/core/app_initializer.dart';
import 'src/core/app.dart';

void main() async {
  // Initialize Hive with path
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  
  await AppInitializer.initialize();
  AppInitializer.setupErrorHandling();
  
  runApp(
    const ProviderScope(
      child: K53App(),
    ),
  );
}
