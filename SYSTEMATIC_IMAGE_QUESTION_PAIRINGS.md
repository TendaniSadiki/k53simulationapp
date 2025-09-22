# Systematic Image-Question Pairings

## Matching Strategy
This document provides specific pairings between K53 test questions and the available road sign images. The pairing follows these principles:

1. **Relevance**: Match images to questions that directly reference the sign type
2. **Category Alignment**: Road signs to road_sign questions, regulatory signs to rules_of_road
3. **Progressive Coverage**: Start with obvious matches, then expand to related concepts
4. **Avoid Duplication**: Ensure each image is used appropriately without unnecessary repetition

## Specific Question-Image Pairings

### 1. Speed Limit Signs
**Images:**
- `LIMIT PROHIBITION SIGNS/Maximum speed limit allowed.png`

**Questions to Update:**
- Q8: "Unless otherwise shown by a sign, the general speed limit in an urban area is ...km/h."
- Q9: "The legal speed limit which you may drive..."
- Any question mentioning speed limits or regulatory signs

### 2. Overtaking Prohibition Signs  
**Images:**
- `SELECTIVE RESTRICTION SIGNS/Overtaking prohibited for the next 2km.png`
- `SELECTIVE RESTRICTION SIGNS/No over taking vehicles by goods vehicles for the next 500m.png`

**Questions to Update:**
- Q3: "When may you not overtake another vehicle?"
- Q18: "You may overtake another vehicle on the left hand side..."
- Questions about overtaking restrictions

### 3. Stop and Yield Signs
**Images:**
- `CONTROL SIGNS/Come to a complete halt in line with the stop sign.png`
- `CONTROL SIGNS/Stop in line with the Stop sign or before the line.png`
- `CONTROL SIGNS/Indicates that you must yield to other traffic. Gi.png`

**Questions to Update:**
- Q6: "At an intersection..." (yield question)
- Questions about right-of-way and intersection procedures

### 4. Parking and Stopping Signs
**Images:**
- `PROHIBITION SIGNS/No stopping to ensure traffic flow and prevent dri.png`
- `PROHIBITION SIGNS/To prohibit drivers from parking during any time of the day or night.png`
- Multiple reservation signs from RESERVATION SIGNS folder

**Questions to Update:**
- Q15: "You are not allowed to stop..."
- Q16: "You are not allowed to stop..."
- Questions about parking restrictions

### 5. Turning Prohibition Signs
**Images:**
- `PROHIBITION SIGNS/To prohibit vehicles from turning around (u-turn) so that it faces the opposite direction.png`
- `PROHIBITION SIGNS/To prohibit vehicles from turning left at an intersection.png`
- `PROHIBITION SIGNS/To prohibit vehicles from turning left.png`
- `PROHIBITION SIGNS/To prohibit vehicles from turning right at an intersection.png`
- `PROHIBITION SIGNS/To prohibit vehicles from turning right.png`

**Questions to Update:**
- Questions about turning restrictions
- Intersection maneuver questions

### 6. Vehicle Class Restrictions
**Images:**
- `PROHIBITION SIGNS/To prohibit motorcycles on a part of a carriageway for safety reasons.png`
- `SELECTIVE RESTRICTION SIGNS/Applies only to mini-buses.png`
- `SELECTIVE RESTRICTION SIGNS/Speed limit of 60km per hour applies to motorcycles only.png`

**Questions to Update:**
- Questions about vehicle-specific restrictions
- Learner code specific questions

### 7. Time-Based Restrictions
**Images:**
- `SELECTIVE RESTRICTION SIGNS/Applies at night only.png`
- `SELECTIVE RESTRICTION SIGNS/Applies during day time only.png`
- `SELECTIVE RESTRICTION SIGNS/Time_Restriction_07-09_16-18.png.png`
- `SELECTIVE RESTRICTION SIGNS/Time_Restriction_Week_08-16_Sat_08-13.png.png`

**Questions to Update:**
- Questions about time-specific regulations
- Parking time restrictions

### 8. Hazard Warning Signs
**Images:**
- `MOVING HAZARDS AHEAD/` folder (18 images)
- `CHANGES IN VEHICLE MOVEMENT AHEAD/` folder (14 images)
- `ROAD SITUATIONS AHEAD/` various images

**Questions to Update:**
- Questions about road hazards
- Animal crossing warnings
- Construction zone procedures
- Pedestrian safety questions

### 9. Direction and Information Signs
**Images:**
- `DIRECTION SIGN SYMBOLS/` folder (28 images)
- `INFORMATION SIGNS/` folder (13 images)
- `TOURISM SIGN SYMBOL/` folder (144 images)

**Questions to Update:**
- Questions about route guidance
- Information sign meanings
- Tourism and facility identification

### 10. Regulatory and Command Signs
**Images:**
- `COMMAND SIGNS/` folder (9 images)
- `COMPREHENSIVE SIGNS/` folder (3 images)
- `DE-RESTRICTION SIGNS/` folder (6 images)

**Questions to Update:**
- Questions about mandatory directions
- Freeway and residential area rules
- End of restriction zones

### 11. Vehicle Control Diagrams
**Images:**
- `CODE 1/code1.png`
- `CODE 2/code2.png`
- `CODE 3/code3.png`

**Current Usage:** Already correctly mapped to vehicle control questions

## Implementation Plan

### Phase 1: Immediate Obvious Matches
Update questions that directly reference specific sign types:
- Speed limit questions → speed limit signs
- Overtaking questions → overtaking prohibition signs
- Stop/yield questions → stop/yield signs
- Parking questions → parking restriction signs

### Phase 2: Category Expansion
Expand to related questions within each category:
- All road_sign questions should have appropriate images
- Rules_of_road questions that reference specific signs

### Phase 3: Comprehensive Coverage
Ensure all available images are utilized appropriately:
- Match remaining images to relevant questions
- Create new questions if needed for unused images
- Verify no image duplication or inappropriate usage

## Database Update Procedure

1. **Identify Target Questions**: Use the question database to find questions needing images
2. **Select Appropriate Images**: Choose the most relevant image from available options
3. **Update Image URLs**: Add `image_url` field with correct path
4. **Verify Paths**: Use verification script to ensure all paths work
5. **Test Functionality**: Ensure images display correctly in the application

## Verification Checklist

- [ ] All image paths use correct folder structure: `assets/individual_signs/CATEGORY/Filename.png`
- [ ] No broken image links
- [ ] Appropriate image-question relevance
- [ ] No unnecessary image duplication
- [ ] All major sign categories represented
- [ ] Vehicle control diagrams properly assigned

This systematic approach ensures comprehensive coverage of all 206 available images while maintaining question relevance and educational value.