# Image-Question Mapping Guide

This document outlines the strategy for mapping road sign images from the `assets/individual_signs/` directory to relevant K53 driving test questions.

## Image Naming Strategy

We use descriptive image names that avoid the `sign_page_` prefix as requested. The images are organized by their functional meaning rather than page numbers.

## Available Road Sign Images

The following road sign images are available in `assets/individual_signs/`:

### Regulatory Signs
- `Maximum speed limit allowed.png` - Speed limit signs
- `No stopping to ensure traffic flow and prevent dri.png` - No stopping signs
- `Overtaking prohibited for the next 2km.png` - Overtaking prohibition
- `No over taking vehicles by goods vehicles for the next 500m.png` - Goods vehicle overtaking restriction
- `Over taking vehicles is prohibited for the next 500m.png` - General overtaking prohibition
- `Indicates that you must yield to other traffic. Gi.png` - Yield signs

### Informational Signs
- `Residential area.png` - Residential zone signs
- `Parking only if you pay the parking fee.png` - Paid parking signs
- `Parking_30min_Week_09-16_Sat_08-13.png.png` - Time-restricted parking
- `Parking here is reserved for a vehicle carrying people with disabilities.png` - Disability parking

## Question-Image Mapping

### Rules of the Road Questions with Images

**Q3 - Overtaking Restrictions**
- **Question**: "When may you not overtake another vehicle?... When you ..."
- **Image**: `assets/individual_signs/SELECTIVE RESTRICTION SIGNS/Overtaking prohibited for the next 2km.png`
- **Reason**: Question deals with overtaking prohibitions

**Q6 - Yield at Intersections**
- **Question**: "At an intersection..."
- **Image**: `assets/individual_signs/Indicates that you must yield to other traffic. Gi.png`
- **Reason**: Question involves yielding right of way

**Q8 & Q9 - Speed Limits**
- **Questions**: Speed limit questions
- **Image**: `assets/individual_signs/Maximum speed limit allowed.png`
- **Reason**: Directly related to speed limit signs

**Q13 - Parking Duration**
- **Question**: "What is the longest period that a vehicle may be parked..."
- **Image**: `assets/individual_signs/Residential area.png`
- **Reason**: Parking regulations often indicated by residential area signs

**Q15 & Q16 - Stopping Restrictions**
- **Questions**: "You are not allowed to stop..."
- **Image**: `assets/individual_signs/No stopping to ensure traffic flow and prevent dri.png`
- **Reason**: Direct no-stopping regulation questions

**Q18 - Overtaking Permissions**
- **Question**: "You may overtake another vehicle on the left hand side..."
- **Image**: `assets/individual_signs/SELECTIVE RESTRICTION SIGNS/No over taking vehicles by goods vehicles for the next 500m.png`
- **Reason**: Overtaking regulations with specific restrictions

### General Mapping Rules

1. **Direct Relevance**: Use images that directly illustrate the road sign being discussed
2. **Avoid Page Numbers**: Use descriptive names instead of `sign_page_XXX.png` format
3. **Multiple Applications**: Some signs (like speed limits) apply to multiple questions
4. **Progressive Enhancement**: Start with most relevant questions, expand as needed

## Implementation Files

### 1. Database Schema Update
The `questions` table has been modified to include an `image_url` column:
```sql
ALTER TABLE questions ADD COLUMN image_url TEXT;
```

### 2. Update Script
Use `scripts/add_image_urls_to_questions.sql` to:
- Add the image_url column if not exists
- Update relevant questions with appropriate image paths
- Verify the updates were successful

### 3. Usage in Application
The Flutter application will check for `image_url` field and display images when available:
```dart
if (question.imageUrl != null && question.imageUrl!.isNotEmpty) {
  return Image.asset(question.imageUrl!);
}
```

## Verification

After running the update script, verify the mappings:

```sql
-- Check which questions have images
SELECT category, question_text, image_url 
FROM questions 
WHERE image_url IS NOT NULL
ORDER BY category, question_text;

-- Count images per category
SELECT category, COUNT(*) as image_count
FROM questions 
WHERE image_url IS NOT NULL
GROUP BY category;
```

## Future Enhancements

1. **Additional Image Types**: Consider adding images for:
   - Traffic signals and robots
   - Pedestrian crossings
   - Road markings
   - Warning signs

2. **Dynamic Loading**: Implement lazy loading for better performance
3. **Image Preloading**: Preload all road sign images during app initialization
4. **Accessibility**: Add alt text and descriptions for screen readers

## Maintenance

When adding new questions or images:
1. Update the mapping documentation
2. Run the update script for new questions
3. Verify image paths exist in the assets directory
4. Test image display in the application

## Image Requirements

All images should:
- Be in PNG format with transparent backgrounds
- Have descriptive filenames (not page numbers)
- Be properly sized for mobile display (recommended: 200x200px minimum)
- Maintain aspect ratio and clarity when scaled