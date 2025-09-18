# Offline Question Caching Guide

## Understanding the Question Caching System

The K53 app uses a two-tier question system:

### 1. Online Database (Supabase)
- Contains the complete Evolve Driving Academy question set (72+ questions)
- All categories: rules_of_road, road_signs, vehicle_controls, general_knowledge, etc.
- Accessed when online connectivity is available

### 2. Offline Cache (SQLite)
- Initially contains only 5 basic questions for immediate offline use
- Automatically caches questions as they are accessed online
- Progressive caching ensures frequently used questions are available offline

## Why Only 5 Questions Initially?

The app is designed this way for several reasons:
1. **Fast Startup**: Minimal initial cache for quick app loading
2. **Storage Efficiency**: Avoids downloading all questions if user never uses them
3. **Progressive Enhancement**: Questions are cached as needed during normal usage

## How to Ensure All Questions Are Available Offline

### Option 1: Automatic Pre-caching (Recommended)
The enhanced `OfflineDataPreloader` will now automatically:
- Check if online connectivity is available
- Pre-cache all categories from the online database
- Fall back to basic questions if offline
- Cache threshold increased to 50+ questions

### Option 2: Manual Pre-caching
Run the pre-caching script to manually populate the offline database:

```bash
# This will cache all questions from the online database
dart scripts/precache_all_questions.dart
```

### Option 3: Normal Usage Caching
As users navigate through the app:
- Questions accessed from online are automatically cached
- Frequently used questions remain in offline storage
- The cache grows organically with app usage

## Enhanced Preloading Logic

The updated system now:
1. **Checks for sufficient questions** (>50) before considering cache complete
2. **Attempts online pre-caching first** when connectivity is available
3. **Falls back to basic questions** only when offline
4. **Provides better feedback** about cache status

## Cache Management

### View Cache Statistics
The app includes debug functionality to check cache status:
```dart
await OfflineDatabaseService.debugCacheState();
```

### Force Cache Rebuild
To completely refresh the offline cache:
```dart
await OfflineDatabaseService.rebuildEntireCache();
```

### Category-Specific Refresh
To refresh questions for a specific category:
```dart
await OfflineDatabaseService.refreshCategoryCache('rules_of_road');
```

## Expected Behavior

After the enhancements:
- **Online Users**: Will automatically get all questions cached after first use
- **Offline Users**: Will have basic questions immediately, full set when online
- **Mixed Connectivity**: Progressive caching ensures optimal offline experience

## Troubleshooting

If questions aren't caching properly:
1. Check Supabase connectivity and credentials
2. Verify the online database has been seeded with questions
3. Ensure the app has proper network permissions
4. Check console logs for caching errors

The system is designed to be resilient - even if pre-caching fails, the app will still function with basic questions and cache questions as they are accessed.