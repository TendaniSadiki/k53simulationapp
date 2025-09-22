# Expected Question Statistics After Running SQL File

## Total Questions to be Added
- **72 Rules of the Road questions** (applies to all learner codes 1, 2, 3)
- **7 Motorcycle (Code 1) Vehicle Controls questions** (Q192-Q198)
- **7 Light Motor Vehicle (Code 2) Controls questions** (Q212-Q218)  
- **7 Heavy Motor Vehicle (Code 3) Controls questions** (Q230-Q236)

**Total: 93 questions**

## Questions with Images
The following questions will have image assignments:

### Rules of the Road Questions with Images:
- **Q3**: Overtaking prohibition - `assets/individual_signs/SELECTIVE RESTRICTION SIGNS/Overtaking prohibited for the next 2km.png`
- **Q6**: Yield sign - `assets/individual_signs/REGULATORY SIGNS/Yield sign.png`
- **Q8**: Speed limit sign - `assets/individual_signs/LIMIT PROHIBITION SIGNS/Maximum speed limit allowed.png`
- **Q9**: Speed limit sign - `assets/individual_signs/LIMIT PROHIBITION SIGNS/Maximum speed limit allowed.png`
- **Q13**: Residential area - `assets/individual_signs/REGULATORY SIGNS/Residential area.png`
- **Q15**: No stopping sign - `assets/individual_signs/REGULATORY SIGNS/No stopping to ensure traffic flow and prevent dri.png`
- **Q16**: No stopping sign - `assets/individual_signs/REGULATORY SIGNS/No stopping to ensure traffic flow and prevent dri.png`
- **Q18**: No overtaking for goods vehicles - `assets/individual_signs/SELECTIVE RESTRICTION SIGNS/No over taking vehicles by goods vehicles for the next 500m.png`

### Vehicle Controls Questions:
- All vehicle controls questions currently have `NULL` image_url as they don't require road sign images

## Summary
- **Total questions**: 93
- **Questions with images**: 8 (all in Rules of the Road category)
- **Questions without images**: 85
- **Image coverage**: 8.6% of questions will have images

## Execution Order
1. First run: `scripts/check_and_create_tables.sql` (if tables don't exist)
2. Then run: `scripts/seed_evolve_questions_with_images_final.sql`
3. Verify with: `scripts/check_question_stats.sql`

## Notes
- The image assignments focus on road sign questions where visual identification is crucial
- Vehicle controls questions use text-based number references rather than images
- All image paths use the organized subfolder structure for better maintenance