# Evolve Driving Academy Questions - Image Mapping Guide

This document maps Evolve Driving Academy questions to appropriate road sign images from the `assets/individual_signs/` directory using only descriptive image names.

## Rules of the Road Questions (72 questions)

### Speed Limit Questions
- **Q8**: "Unless otherwise shown by a sign, the general speed limit in an urban area is ...km/h."
  - Image: `Maximum speed limit allowed.png` (general speed limit sign)
  
- **Q9**: "The legal speed limit which you may drive..."
  - Image: `Maximum speed limit allowed.png` (general speed limit sign)

### Stop and Yield Questions
- **Q6**: "At an intersection..." (mentions yield to oncoming traffic)
  - Image: `Indicates that you must yield to other traffic. Gi.png` (yield sign)

- **Q34**: "If you come across an emergency vehicle on the road sounding a siren..."
  - Image: `Give way to any pedestrians on or about to enter t.png` (yield/give way concept)

### Parking Questions
- **Q15**: "You are not allowed to stop..." (mentions pavement/parking)
  - Image: `Parking only if you pay the parking fee.png` (parking regulation sign)

- **Q16**: "You are not allowed to stop..." (parking restrictions)
  - Image: `No stopping to ensure traffic flow and prevent dri.png` (no stopping sign)

- **Q37**: "Where may you legally stop with your vehicle?"
  - Image: `Parking_30min_Week_09-16_Sat_08-13.png.png` (time-restricted parking)

- **Q43**: "In which case is it permitted to travel with only the parking lights..."
  - Image: `Applies at night only.png` or `Applies during day time only.png`

### Overtaking Questions
- **Q3**: "When may you not overtake another vehicle?"
  - Image: `Overtaking prohibited for the next 2km.png` (overtaking prohibition)

- **Q18**: "You may overtake another vehicle on the left hand side..."
  - Image: `No over taking vehicles by goods vehicles for the next 500m.png`

### Special Area Questions
- **Q13**: "What is the longest period that a vehicle may be parked..."
  - Image: `Residential area.png` (outside urban areas context)

- **Q44**: "The only instance where you may stop on a freeway..."
  - Image: `Dual-carriage freeway begins The following rules apply to all freeways.png`

- **Q60**: "The following vehicle may not be used on a freeway..."
  - Image: `End of dual carriage freeway and freeway rules no longer apply.png`

### Sign Type Questions
- **Q49**: "A Temporary sign...?"
  - Image: `Applies for the next 5km.png` (temporary/distance-based signs)

- **Q71**: "The use of a temporary sign implies that for some reason..."
  - Image: `Applies on the days and during the times shown.png` (conditional signs)

## Image Naming Conventions

The images follow descriptive naming patterns:
- `Maximum speed limit allowed.png`
- `No stopping to ensure traffic flow and prevent dri.png`
- `Parking only if you pay the parking fee.png`
- `Overtaking prohibited for the next 2km.png`
- `Residential area.png`

## Implementation Strategy

1. **Update the seed script** to include `image_url` field for relevant questions
2. **Use descriptive paths**: `assets/individual_signs/Maximum speed limit allowed.png`
3. **Prioritize questions** that directly reference signs or visual concepts

## Recommended Image Assignments

Here are the most critical image-question mappings:

1. **Speed limits**: Q8, Q9 → `Maximum speed limit allowed.png`
2. **Stop/Yield**: Q6, Q34 → `Give way to any pedestrians on or about to enter t.png`
3. **Parking**: Q15, Q16, Q37 → `Parking only if you pay the parking fee.png`, `No stopping to ensure traffic flow and prevent dri.png`
4. **Overtaking**: Q3, Q18 → `Overtaking prohibited for the next 2km.png`
5. **Freeways**: Q44, Q60 → Freeway-related signs
6. **Sign types**: Q49, Q71 → `Applies for the next 5km.png`, `Applies on the days and during the times shown.png`

## Next Steps

1. Update `scripts/seed_evolve_questions.sql` with image_url mappings
2. Verify all image paths exist in the assets directory
3. Test the integration with the offline database system
4. Ensure proper image loading in the exam interface