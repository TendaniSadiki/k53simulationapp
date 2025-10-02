# Double-Tap Gesture Implementation Plan

## Current State Analysis

### Study Mode (`study_screen.dart`)
- **Question Display**: [`_buildQuestionCard()`](lib/src/features/study/presentation/screens/study_screen.dart:221) method
- **Current Structure**: Single `Card` widget with question text, options, explanation, and navigation
- **Missing**: No double-tap gesture detection
- **Opportunity**: Perfect for flashcard-style learning

### Exam Mode (`exam_screen.dart`) 
- **Question Display**: Inline in [`_buildExamInProgress()`](lib/src/features/exam/presentation/screens/exam_screen.dart:210) method
- **Current Structure**: Column layout with timer, score, question text, options
- **Missing**: No double-tap gesture detection
- **Challenge**: High-stakes context requires careful implementation

### Exam Review (`exam_review_screen.dart`)
- **Question Display**: [`_buildQuestionReviewCard()`](lib/src/features/exam/presentation/screens/exam_review_screen.dart:34) method
- **Current Structure**: Read-only review cards with correctness indicators
- **Missing**: No double-tap gesture detection
- **Opportunity**: Post-exam learning reinforcement

## Implementation Strategy

### Phase 1: Create Reusable Flashcard Widget
- Create a new `FlashcardWidget` that can be used across all modes
- Implement double-tap gesture with animation
- Support both front (question) and back (answer/explanation) content

### Phase 2: Integrate into Study Mode
- Replace current question card with flashcard widget
- Maintain existing functionality (answer selection, navigation)
- Add flip animation for explanation reveal

### Phase 3: Integrate into Exam Mode
- Add flashcard functionality to exam questions
- Ensure it doesn't interfere with timed exam flow
- Consider exam-specific restrictions

### Phase 4: Integrate into Review Mode
- Add flashcard functionality to review cards
- Enhance post-exam learning experience

## Technical Implementation Details

### Flashcard Widget Structure
```dart
class FlashcardWidget extends StatefulWidget {
  final Widget frontContent;  // Question view
  final Widget backContent;   // Answer/explanation view
  final bool enableDoubleTap;
  final FlashcardMode mode;
  
  const FlashcardWidget({
    required this.frontContent,
    required this.backContent,
    this.enableDoubleTap = true,
    required this.mode,
  });
}
```

### Gesture Detection Logic
- **Double-tap timeout**: 500ms
- **Maximum tap distance**: 20 logical pixels
- **Animation duration**: 300ms
- **Haptic feedback**: Light impact on supported devices

### Animation System
- Use `AnimationController` with `SingleTickerProviderStateMixin`
- 3D-style flip animation with perspective
- Hardware-accelerated transforms for performance

## Success Criteria
- [ ] Double-tap works consistently across all modes
- [ ] Visual feedback within 100ms of gesture recognition
- [ ] Smooth 300ms flip animation
- [ ] No interference with existing functionality
- [ ] Proper error handling for edge cases
- [ ] Accessibility support for screen readers