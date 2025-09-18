
-- Evolve Driving Academy K53 Questions - Complete Set with Images
-- This file replaces all existing questions with the official Evolve Driving Academy questions
-- Run this in Supabase SQL Editor after clearing the database

-- First, clear existing questions (optional - use if you want to replace everything)
-- DELETE FROM questions;

INSERT INTO questions (id, category, learner_code, question_text, options, correct_index, explanation, version, is_active, difficulty_level, image_url, created_at, updated_at)
SELECT 
  gen_random_uuid(),
  data.category,
  data.learner_code,
  data.question_text,
  data.options,
  data.correct_index,
  data.explanation,
  1,
  true,
  data.difficulty_level,
  data.image_url,
  NOW(),
  NOW()
FROM (
  VALUES
    -- RULES OF THE ROAD QUESTIONS (72 questions)
    -- All Rules of the Road questions apply to all learner codes (1, 2, 3)
    
    -- Q1
    ('rules_of_road', 1, 'You may...', '[{"text": "Drive your vehicle on the sidewalk at night"}, {"text": "Reverse your vehicle only if it is safe to do so"}, {"text": "Leave the engine of your vehicle idling when you put petrol in it"}]'::jsonb, 1, 'You may only reverse your vehicle when it is safe to do so. Driving on sidewalks is illegal and leaving engine running while refueling is dangerous.', 2, NULL),
    
    -- Q2
    ('rules_of_road', 1, 'When you want to change lanes and drive from one lane to the other you must...', '[{"text": "Only do it when it is safe to do so"}, {"text": "Switch on your indicators in time to show what you are going to do"}, {"text": "Use the mirrors of your vehicle to ensure that you know of other traffic around you"}, {"text": "All of the above are correct"}]'::jsonb, 3, 'All options are correct: change lanes only when safe, use indicators in time, and check mirrors for surrounding traffic.', 2, NULL),
    
    -- Q3 - Overtaking prohibition
    ('rules_of_road', 1, 'When may you not overtake another vehicle?... When you ...', '[{"text": "Are nearing the top of hill"}, {"text": "Are nearing a curve"}, {"text": "Can only see 100m in front of you because of dust over the road"}, {"text": "All of the above are correct"}]'::jsonb, 3, 'You may not overtake when nearing hills, curves, or when visibility is limited to 100m due to dust or other obstructions.', 3, 'assets/individual_signs/Overtaking prohibited for the next 2km.png'),
    
    -- Q4
    ('rules_of_road', 1, 'When are you allowed to drive on the shoulder of a road?', '[{"text": "Any time if you want to let another vehicle to pass you"}, {"text": "In daytime when you want to allow another vehicle pass you and its safe"}, {"text": "When on a freeway with 4 lanes in both directions, you want to drive slower than 120 km/h"}, {"text": "When you have a flat tyre and you want to park there to change it"}, {"text": "Only (ii) and (iv) are correct"}]'::jsonb, 4, 'You may only drive on the shoulder to allow another vehicle to pass (when safe) or when you have a flat tire and need to park to change it.', 2, NULL),
    
    -- Q5
    ('rules_of_road', 1, 'You may not obtain a learner''s licence if...', '[{"text": "You already have a licence that authorises the driving of the same vehicle class"}, {"text": "You are declared unfit to obtain a driving licence for a certain period and that period still prevails"}, {"text": "Your licence was suspended temporarily and the suspension has not yet expired"}, {"text": "All of the above are correct"}]'::jsonb, 3, 'All conditions prevent obtaining a learner''s license: existing license for same class, declared unfit period, or active suspension.', 2, NULL),
    
    -- Q6 - Yield sign
    ('rules_of_road', 1, 'At an intersection...', '[{"text": "Vehicles have the right of way over pedestrians"}, {"text": "You must yield to oncoming traffic if you want to turn right"}, {"text": "You can use a stop sign as a yield sign if there is no other traffic"}]'::jsonb, 1, 'When turning right at an intersection, you must yield to oncoming traffic. Pedestrians have right of way at crossings.', 1, 'assets/individual_signs/Indicates that you must yield to other traffic. Gi.png'),
    
    -- Q7
    ('rules_of_road', 1, 'The licence for your vehicle (clearance certificate) is valid for...', '[{"text": "12 months"}, {"text": "90 days"}, {"text": "21 days"}]'::jsonb, 0, 'A vehicle license (clearance certificate) is typically valid for 12 months and must be renewed annually.', 1, NULL),
    
    -- Q8 - Speed limit sign
    ('rules_of_road', 1, 'Unless otherwise shown by a sign, the general speed limit in an urban area is ...km/h.', '[{"text": "60"}, {"text": "80"}, {"text": "100"}]'::jsonb, 0, 'The default speed limit in urban areas is 60 km/h unless otherwise indicated by road signs.', 1, 'assets/individual_signs/Maximum speed limit allowed.png'),
    
    -- Q9 - Speed limit sign
    ('rules_of_road', 1, 'The legal speed limit which you may drive...', '[{"text": "Is always 120km/h outside an urban area"}, {"text": "Can be determined by yourself if you look at the number of lanes the road has"}, {"text": "Is shown to you by signs next to the road"}]'::jsonb, 2, 'Legal speed limits are indicated by road signs. Do not assume limits based on road type or number of lanes.', 1, 'assets/individual_signs/Maximum speed limit allowed.png'),
    
    -- Q10
    ('rules_of_road', 1, 'You may...', '[{"text": "Leave your vehicles engine running without supervision"}, {"text": "Allow someone to ride on the bumper of your vehicle"}, {"text": "Put your arm out of the window only to give legal hand signals"}]'::jsonb, 2, 'You may only extend your arm out of the window to give legal hand signals. Never leave engine running unattended or allow riding on bumpers.', 1, NULL),
    
    -- Q11
    ('rules_of_road', 1, 'If you see that someone wants to overtake you, you must...', '[{"text": "Not drive faster"}, {"text": "Keep to the left as far as is safe"}, {"text": "Give hand signals to allow the person to pass safely"}, {"text": "Only (i) and (ii) are correct"}]'::jsonb, 3, 'When being overtaken, do not accelerate and keep left as far as safe. Hand signals are not required for this situation.', 2, NULL),
    
    -- Q12
    ('rules_of_road', 1, 'The furthest that your vehicle''s dim light may shine in front of you, is...m', '[{"text": "45"}, {"text": "100"}, {"text": "150"}]'::jsonb, 0, 'Dim (dipped) headlights should illuminate the road for approximately 45 meters ahead of your vehicle.', 1, NULL),
    
    -- Q13 - Residential area
    ('rules_of_road', 1, 'What is the longest period that a vehicle may be parked on one place on a road outside urban areas?', '[{"text": "7 days"}, {"text": "48 hours"}, {"text": "24 hours"}]'::jsonb, 0, 'Outside urban areas, a vehicle may be parked in one place for up to 7 days unless otherwise prohibited.', 1, 'assets/individual_signs/Residential area.png'),
    
    -- Q14
    ('rules_of_road', 1, 'At an intersection...', '[{"text": "You can pass another vehicle waiting to turn right on his left side by going off the road"}, {"text": "You can stop in it to off load passengers"}, {"text": "Pedestrians who are already crossing the road when the red man signal starts showing, have right of way"}]'::jsonb, 2, 'Pedestrians already crossing when the signal changes to red have right of way to complete their crossing safely.', 2, NULL),
    
    -- Q15 - No stopping/parking
    ('rules_of_road', 1, 'You are not allowed to stop...', '[{"text": "On the pavement"}, {"text": "With the front of your vehicle facing oncoming traffic"}, {"text": "Next to any obstruction in the road"}]'::jsonb, 0, 'Stopping on the pavement (sidewalk) is prohibited as it obstructs pedestrian access.', 1, 'assets/individual_signs/No stopping to ensure traffic flow and prevent dri.png'),
    
    -- Q16 - No stopping/parking
    ('rules_of_road', 1, 'You are not allowed to stop...', '[{"text": "Where you are also prohibited to park"}, {"text": "5m from a bridge"}, {"text": "Opposite a vehicle, where the roadway is 10m wide"}]'::jsonb, 0, 'If an area is designated as no parking, it also means no stopping. Other restrictions may have specific distances.', 2, 'assets/individual_signs/No stopping to ensure traffic flow and prevent dri.png'),
    
    -- Q17
    ('rules_of_road', 1, 'You may pass another vehicle on the left-hand side if it...', '[{"text": "Indicates that it is going to turn right"}, {"text": "Drives on the right-hand side of a road with a shoulder were you can pass"}, {"text": "Drives in a town in the right hand lane with 2 lanes in the same direction"}, {"text": "Only (i) and (iii) are correct"}]'::jsonb, 3, 'You may pass on the left when a vehicle is turning right or when in multi-lane roads with designated lanes.', 2, NULL),
    
    -- Q18 - Overtaking prohibition
    ('rules_of_road', 1, 'You may overtake another vehicle on the left hand side...', '[{"text": "When that vehicle is going to turn right and the road is wide enough that it is not necessary to drive on the shoulder"}, {"text": "Where the road has 2 lanes for traffic in the same direction"}, {"text": "If a police officer instructs you to do so"}, {"text": "All of the above are correct"}]'::jsonb, 3, 'All scenarios allow overtaking on the left: vehicle turning right, multi-lane roads, or when directed by authorities.', 2, 'assets/individual_signs/No over taking vehicles by goods vehicles for the next 500m.png'),
    
    -- Q19
    ('rules_of_road', 1, 'You may on a public road...', '[{"text": "Pass another vehicle turning right, on it''s left-hand side without driving on the shoulder of the road"}, {"text": "Pass another vehicle at any place on the left-hand side if it is turning right"}, {"text": "Not pass any vehicle on the left-hand side"}]'::jsonb, 0, 'You may pass on the left of a vehicle turning right, provided you can do so without driving on the shoulder.', 2, NULL),
    
    -- Q20
    ('rules_of_road', 1, 'The last action that you must take before moving to another lane is to...', '[{"text": "Switch on your indicator"}, {"text": "Check the blind spot"}, {"text": "Look in rear view mirror"}]'::jsonb, 1, 'The final check before changing lanes should be a blind spot check to ensure no vehicles are in your intended path.', 1, NULL),
    
    -- Q21
    ('rules_of_road', 1, 'When are you allowed to drive your vehicle on the right-hand side of a road with traffic in both directions?', '[{"text": "When you switch the emergency lights of your vehicle on"}, {"text": "When a traffic officer shows you to do so"}, {"text": "Under no circumstances"}]'::jsonb, 1, 'You may drive on the right side only when directed by a traffic officer or in specific emergency situations.', 2, NULL),
    
    -- Q22 - Traffic signals
    ('rules_of_road', 1, 'If you come to a robot and the red light flashes, you must...', '[{"text": "Stop and wait for the light to change to green before you go"}, {"text": "Stop and go only if it safe to do so"}, {"text": "Look out for a road block as the light shows you a policestop"}]'::jsonb, 1, 'A flashing red light functions as a stop sign - stop completely and proceed only when safe to do so.', 1, NULL),
    
    -- Q23
    ('rules_of_road', 1, 'A vehicle of which the brakes are not good, must be towed', '[{"text": "With a rope"}, {"text": "With a tow-bar"}, {"text": "On a trailer"}]'::jsonb, 2, 'A vehicle with faulty brakes must be transported on a trailer or flatbed tow truck for safety.', 2, NULL),
    
    -- Q24
    ('rules_of_road', 1, 'A safe following distance is, when the vehicle in front of you suddenly stops, you could....', '[{"text": "Stop without swerving"}, {"text": "Swerve and stop next to it"}, {"text": "Swerve and pass"}]'::jsonb, 0, 'Maintain sufficient distance to stop completely without swerving if the vehicle ahead stops suddenly.', 1, NULL),
    
    -- Q25
    ('rules_of_road', 1, 'You may not', '[{"text": "Have passengers in the vehicle if you only have a learner''s licence"}, {"text": "Leave your vehicle unattended while the engine is running"}, {"text": "Drive in reverse for more than a 100m"}]'::jsonb, 1, 'Never leave a vehicle unattended with the engine running. Learner drivers may carry passengers with supervision.', 1, NULL),
    
    -- Q26
    ('rules_of_road', 1, 'If you want to change lanes you must', '[{"text": "Switch on your indicator and change lanes"}, {"text": "Give the necessary signal and after looking for other traffic, change lanes"}, {"text": "Apply the brakes lightly and then change lanes"}]'::jsonb, 1, 'Signal your intention, check mirrors and blind spots for other traffic, then change lanes when safe.', 1, NULL),
    
    -- Q27
    ('rules_of_road', 1, 'The fastest speed at which you may tow a vehicle with a rope is .. km/h', '[{"text": "60"}, {"text": "45"}, {"text": "30"}]'::jsonb, 2, 'When towing with a rope, the maximum speed is 30 km/h for safety reasons.', 1, NULL),
    
    -- Q28
    ('rules_of_road', 1, 'You may cross or enter a public road...', '[{"text": "If the road is clear of traffic for a short distance"}, {"text": "If the road is clear of traffic for a long distance and it can be done without obstructing traffic"}, {"text": "In any manner as long as you use your indicators in time"}]'::jsonb, 1, 'Enter roads only when you have clear visibility for a sufficient distance and can do so without obstructing traffic.', 2, NULL),
    
    -- Q29
    ('rules_of_road', 1, 'Your vehicle''s headlights must be switched on...', '[{"text": "At any time of the day when you can not see persons and vehicle''s 150m in front of you"}, {"text": "From sunset to sunrise"}, {"text": "When it rains and you cannot see vehicles 100m in front of you"}, {"text": "All of the above are correct"}]'::jsonb, 3, 'Headlights must be used from sunset to sunrise, in poor visibility (<150m), and when raining with visibility <100m.', 2, NULL),
    
    -- Q30
    ('rules_of_road', 1, 'You may not drive into an intersection when...', '[{"text": "The robot (traffic signal) is yellow and you are already in the intersection"}, {"text": "The vehicle in front of you wants to turn right and the road is wide enough to pass on the left side"}, {"text": "There is not enough space in the intersection to turn right without blocking other traffic"}]'::jsonb, 2, 'Do not enter an intersection unless there is sufficient space to clear it without obstructing cross traffic.', 2, NULL),
    
    -- Q31
    ('rules_of_road', 1, 'When you were involved in an accident you...', '[{"text": "Must immediately stop your vehicle"}, {"text": "Must determine the damage to the vehicles"}, {"text": "May refuse to give your name and address to anyone except the police"}, {"text": "Only (i) and (ii) are correct"}]'::jsonb, 3, 'After an accident, stop immediately and assess damage. You must provide details to other involved parties, not just police.', 2, NULL),
    
    -- Q32
    ('rules_of_road', 1, 'When you were involved in an accident you...', '[{"text": "Must immediately stop your vehicle"}, {"text": "Must see if someone is injured"}, {"text": "May use a bit of alcohol for the shock"}, {"text": "Only (i) and (