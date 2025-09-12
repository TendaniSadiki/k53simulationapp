# K53 App Road Sign Issues - Resolution Plan

## Current Issues Identified

### 1. Single Question in Road Sign Mock Exams
- **Problem**: Only one road sign question appears when selecting "Road Signs" category
- **Root Cause**: The offline database may not have sufficient road sign questions cached
- **Evidence**: `k53_question_database.dart` shows only 3 road sign questions, but `complete_k53_seed.dart` mentions 52 questions

### 2. Missing Image Display in Exam Screen
- **Problem**: Questions with `image_url` don't display images during exams
- **Root Cause**: [`exam_screen.dart`](lib/src/features/exam/presentation/screens/exam_screen.dart:284-364) UI doesn't render images
- **Evidence**: Question model supports `image_url` field but UI doesn't utilize it

## Solution Plan

### Phase 1: Database Investigation & Repair

1. **Check Current Cache State**
   - Use `OfflineDatabaseService.debugCacheState()` to see current question counts
   - Verify road sign questions are properly cached

2. **Rebuild Database Cache**
   - If insufficient questions, run `OfflineDatabaseService.rebuildEntireCache()`
   - Ensure all 52 road sign questions are loaded

3. **Verify Seeding**
   - Check if `complete_k53_seed.dart` was executed successfully
   - Ensure Supabase database has all road sign questions

### Phase 2: Image Display Implementation

1. **Modify Exam Screen UI**
   - Update `_buildExamInProgress` method in [`exam_screen.dart`](lib/src/features/exam/presentation/screens/exam_screen.dart)
   - Add image display when `question.imageUrl != null`

2. **Image Widget Implementation**
   - Use `Image.asset()` for local assets
   - Handle proper sizing and layout
   - Add error handling for missing images

### Phase 3: Testing & Validation

1. **Test Road Sign Mock Exams**
   - Verify multiple questions appear (not just one)
   - Confirm images display correctly for questions with `image_url`

2. **Cross-Category Testing**
   - Test other categories to ensure no regression
   - Verify non-image questions work normally

## Technical Implementation Details

### Image Display Code (to be added to exam_screen.dart)

```dart
// In _buildExamInProgress method, after question text:
if (state.currentQuestion!.imageUrl != null) {
  const SizedBox(height: 16),
  Image.asset(
    state.currentQuestion!.imageUrl!,
    height: 150,
    fit: BoxFit.contain,
    errorBuilder: (context, error, stackTrace) {
      return Container(
        height: 150,
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported, size: 48),
      );
    },
  ),
  const SizedBox(height: 16),
}
```

### Database Debug Commands

```dart
// To check current state:
await OfflineDatabaseService.debugCacheState();

// To rebuild cache:
await OfflineDatabaseService.rebuildEntireCache();

// To check specific category:
final roadSignQuestions = await OfflineDatabaseService.getQuestions(
  category: 'road_signs',
  limit: 100
);
```

## Success Criteria

- [ ] Road sign mock exams show multiple questions (not just one)
- [ ] Questions with `image_url` display images correctly
- [ ] No regression in other exam categories
- [ ] All existing functionality remains intact

## Timeline

1. **Immediate**: Database investigation and cache rebuild
2. **Next**: Image display implementation
3. **Final**: Comprehensive testing and validation

## Risk Mitigation

- Backup current database state before rebuild
- Test changes on development environment first
- Implement proper error handling for image loading