# K53 App - Image Requirements Guide

## Overview
This document explains how to identify which questions in the K53 exam preparation app need images and how the logging system works.

## Current Image Requirements

Based on the code analysis, the following questions currently reference images:

### Road Signs Category
1. **Parking Sign Question** - [`assets/individual_signs/parking.png`](scripts/k53_question_database.dart:105)
   - Question: "What does a blue rectangular sign with a white "P" indicate?"
   - Location: [`scripts/k53_question_database.dart`](scripts/k53_question_database.dart:105)

2. **Stop Ahead Sign Question** - [`assets/individual_signs/stop_ahead.png`](scripts/complete_k53_seed.dart:210)
   - Question: "What does this sign indicate?" (referring to a stop ahead sign)
   - Location: [`scripts/complete_k53_seed.dart`](scripts/complete_k53_seed.dart:210)

## How to Identify Questions Needing Images

### 1. Run a Mock Exam
The app now includes automatic image requirement logging. To see which questions need images:

1. **Start a mock exam** through the app interface
2. **Check the console output** - the app will log all questions that reference images
3. **Look for log messages** with the pattern: `Analytics: Image requirement -`

### 2. Console Output Format
When you run a mock exam, you'll see log messages like:

```
Analytics: Image requirement - Question ID: [id], Question: "[text]", Image URL: [url], Category: [category], Learner Code: [code]
```

### 3. Example Output
```
Analytics: Image requirement - Question ID: abc123, Question: "What does this road sign indicate?", Image URL: assets/individual_signs/stop_ahead.png, Category: road_signs, Learner Code: 1
Analytics: Image requirement - Question ID: def456, Question: "What is the legal blood alcohol limit?", Image URL: null, Category: general_knowledge, Learner Code: 1
```

## Image File Structure
The expected image file structure is:
```
assets/
  images/
    signs/
      parking.png
      stop_ahead.png
      [other sign images]
```

## Adding New Images
When you identify new questions that need images:

1. **Add the image reference** to the question in the database
2. **Place the image file** in the appropriate `assets/images/` directory
3. **Update pubspec.yaml** to include the new asset paths
4. **Run a test exam** to verify the image loads correctly

## Technical Implementation

### Analytics Service
The [`AnalyticsService.trackImageRequirement()`](lib/src/core/services/analytics_service.dart:192) method logs image requirements with the following details:
- Question ID
- Question text
- Image URL (or null if no image)
- Category
- Learner code

### Exam Provider Integration
The [`ExamNotifier.loadExamQuestions()`](lib/src/features/exam/presentation/providers/exam_provider.dart:148) method automatically logs image requirements for all loaded questions.

## Next Steps
1. Run mock exams to generate complete list of image requirements
2. Source or create the required images
3. Add images to the assets directory
4. Update the pubspec.yaml with asset paths
5. Test image display functionality in the exam interface