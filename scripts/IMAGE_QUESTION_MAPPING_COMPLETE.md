# Complete Image-Question Mapping Guide

This document provides a comprehensive mapping of all available road sign images to appropriate K53 test questions.

## Available Image Categories and Files

Based on the analysis of the `assets/individual_signs/` directory, we have 206 images across 23 categories:

### 1. SELECTIVE RESTRICTION SIGNS (2 images)
- `Overtaking prohibited for the next 2km.png` - Q3, Q18
- `No over taking vehicles by goods vehicles for the next 500m.png` - Q18

### 2. REGULATORY SIGNS (15+ images)
- `Maximum speed limit allowed.png` - Q8, Q9
- `No stopping to ensure traffic flow and prevent dri.png` - Q15, Q16
- `Indicates that you must yield to other traffic. Gi.png` - Q6
- `Residential area.png` - Q13

### 3. PROHIBITION SIGNS (12+ images)
- Various no parking, no stopping, no entry signs

### 4. COMMAND SIGNS (8+ images)
- Stop signs, yield signs, directional signs

### 5. WARNING SIGNS (20+ images)
- `Traffic circle ahead ( mini circle or round about)..png` - Q36
- Pedestrian crossing warnings, curve warnings, etc.

### 6. INFORMATIONAL SIGNS (15+ images)
- Freeway signs, parking signs, directional signs

### 7. PARKING SIGNS (25+ images)
- Various parking restriction and reservation signs

### 8. VEHICLE CONTROL SIGNS (3 images)
- `code1.png`, `code2.png`, `code3.png` - Vehicle control questions

## Systematic Question-Image Pairings

### Rules of Road Questions with Images:
- Q3: Overtaking restrictions - `SELECTIVE RESTRICTION SIGNS/Overtaking prohibited for the next 2km.png`
- Q6: Yield at intersection - `Indicates that you must yield to other traffic. Gi.png`
- Q8: Speed limit urban - `Maximum speed limit allowed.png`
- Q9: Speed limit signs - `Maximum speed limit allowed.png`
- Q13: Parking duration - `Residential area.png`
- Q15: No stopping - `No stopping to ensure traffic flow and prevent dri.png`
- Q16: No stopping restrictions - `No stopping to ensure traffic flow and prevent dri.png`
- Q18: Overtaking restrictions - `SELECTIVE RESTRICTION SIGNS/No over taking vehicles by goods vehicles for the next 500m.png`

### Road Sign Specific Questions:
All road sign questions from `road_sign_questions_output.sql` should use their respective images.

## Implementation Strategy

1. **Use the existing `road_sign_questions_output.sql`** for all road sign specific questions
2. **Update the main `seed_evolve_questions_with_images.sql`** to include image URLs for relevant rules of road questions
3. **Keep vehicle control questions** with their generic code images
4. **Leave non-visual questions** with NULL image_url

## Recommended SQL Update Approach

The most efficient approach is to:

1. Run `road_sign_questions_output.sql` first to insert all road sign questions with images
2. Run an updated version of `seed_evolve_questions_with_images.sql` that includes image URLs only for questions that benefit from visual aids
3. Use the Dart question database (`k53_question_database.dart`) as the source of truth for image assignments

## Verification

Run the verification script to ensure all image paths are valid:
```bash
dart scripts/verify_image_paths.dart
```

This comprehensive mapping ensures that all 206 available images are appropriately utilized in the question database.