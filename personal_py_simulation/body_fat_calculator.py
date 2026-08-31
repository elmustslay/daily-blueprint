import datetime, json, os, shutil, subprocess

START_DATE = datetime.date(2026, 7, 27)
TARGET_DATE = datetime.date(2026, 12, 17)

STARTING_WEIGHT = 156.0
STARTING_BF_PCT = 31.2
AGE = 23

# Activity Multipliers (applied to RMR only; TEF is computed separately below)
# These capture: Resistance Training EAT + NEAT + Aerobic activity (steps/LISS/dance)
# Aerobic tracking is unified in the app via HealthKit:
#   - Natural steps (pedometer), LISS (Active Calories × 20), Dance (Active Calories × 20)
#   - App target: Cut = 55,000 unified steps/week, Refeed = 27,000 unified steps/week
#   - Mix doesn't matter: multiplier holds within ±0.03 regardless of walk vs dance vs LISS split
# 1.50 = Cut Week (4 days RT + 55k unified steps + NEAT, range 1.50-1.55)
# 1.375 = Refeed Week (4 days RT, NO LISS + 27k unified steps + NEAT, range 1.37-1.41)
CUT_ACT = 1.50
REFEED_ACT = 1.375
RT_DAYS_CUT = 4
RT_DAYS_REFEED = 4

# OVERRIDES: set to a number to override timeline JSON
OVERRIDES = {
    'cut': {'prot': None, 'carb': None, 'fat': None, 'fiber': None, 'cal': None, 'alcohol': 0},
    'ref': {'prot': None, 'carb': None, 'fat': None, 'fiber': None, 'cal': None, 'alcohol': 0}
}

# TRACKING ERROR: Set these to simulate accidentally eating extra macros/calories per day
TRACKING_ERROR = {'cal': 0, 'prot': 0, 'carb': 0, 'fat': 0, 'fiber': 0}

# SLEEP: Sub-optimal sleep (<7.5 hrs) impairs fat oxidation, increases insulin resistance, and reduces MPS
SLEEP_HOURS = 7.5

# MEAL DISTRIBUTION: Number of protein-rich meals reaching the leucine threshold (~2.5-3.0g leucine / ~25-35g protein)
MEALS_PER_DAY = 4

# ESSENTIAL FAT MINIMUM: Biological floor where survival mechanisms shut down fat oxidation entirely
ESSENTIAL_BF_PCT = 5.0 # ~5.0% in adult males
ESSENTIAL_FAT_LBS = 6.0

# ENERGETIC DENSITY ASYMMETRY (Cost of Synthesis vs Yield of Breakdown)
LEAN_SYNTHESIS_COST_KCAL = 2500.0 # ATP-intensive protein synthesis and tissue construction
LEAN_CATABOLIC_YIELD_KCAL = 750.0  # Muscle tissue is ~75% water/glycogen, yielding ~750 kcal/lb of lean tissue
FAT_ENERGY_DENSITY_KCAL = 3500.0   # Adipose tissue energy density

# GLUCONEOGENESIS (GNG) CONVERSION RATIO
# It requires ~1.6g of glucogenic amino acids to synthesize 1.0g of blood glucose via hepatic deamination & Cori cycle
GNG_EFFICIENCY_RATIO = 1.6

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def sync_from_dart():
    """Robust cross-platform resolution of Flutter binary to sync Dart plan to JSON."""
    flutter_bin = shutil.which('flutter')
    if not flutter_bin:
        candidates = [
            os.path.expanduser('~/development/flutter/bin/flutter'),
            os.path.expanduser('~/flutter/bin/flutter'),
            '/opt/homebrew/bin/flutter',
            '/usr/local/bin/flutter',
            'C:\\src\\flutter\\bin\\flutter.bat',
            'C:\\flutter\\bin\\flutter.bat',
        ]
        if 'FLUTTER_ROOT' in os.environ:
            candidates.insert(0, os.path.join(os.environ['FLUTTER_ROOT'], 'bin', 'flutter'))
        for c in candidates:
            if os.path.exists(c):
                flutter_bin = c
                break

    if not flutter_bin:
        print("⚠️ Flutter executable not found in PATH or standard locations (using existing JSON).")
        return

    try:
        res = subprocess.run([flutter_bin, 'test', 'test/export_nutrition_test.dart'], cwd=BASE_DIR, capture_output=True, text=True)
        if res.returncode == 0:
            print("⚡ Synced simulation timeline with Dart daily plan")
        else:
            print(f"⚠️ Flutter test warning (using existing JSON): {res.stderr.strip()}")
    except Exception as e:
        print(f"⚠️ Could not auto-run flutter test: {e}")

sync_from_dart()

timeline_path = os.path.join(BASE_DIR, 'outputs', 'simulation_timeline.json')
if not os.path.exists(timeline_path):
    raise FileNotFoundError("simulation_timeline.json was not found. Please ensure flutter test exports it.")

with open(timeline_path, 'r') as f:
    TIMELINE = json.load(f)

def run_simulation(weight_change=0.0, bf_change=0.0):
    sim_start_weight = STARTING_WEIGHT + weight_change
    sim_start_bf_pct = STARTING_BF_PCT + bf_change
        
    target_days = (TARGET_DATE - START_DATE).days
    if target_days <= 0:
        print(f"⚠️ TARGET_DATE ({TARGET_DATE}) must be after START_DATE ({START_DATE})")
        return

    days = target_days
    fat_mass = sim_start_weight * (sim_start_bf_pct / 100.0)
    lean_mass = sim_start_weight - fat_mass
    current_fat, current_lean = fat_mass, lean_mass
    current_glycogen = 500.0
    current_cortisol_water = 0.0
    total_catabolized = 0.0
    consecutive_disuse_days = 0
    ketone_adaptation_days = 0
    fat_history = []
    mineral_water_retention = 0.0
    
    # 1. Sleep Modifiers (Clinical data: ~5.5 hrs sleep = -55% fat oxidation in deficit, +impaired P-ratio in surplus)
    sleep_deficit = max(0.0, 7.5 - SLEEP_HOURS)
    sleep_fat_ox_multiplier = max(0.1, 1.0 - (sleep_deficit * 0.275))
    sleep_mps_multiplier = max(0.1, 1.0 - (sleep_deficit * 0.20))
    
    # 2. Protein Distribution & Leucine Triggering (Now calculated dynamically via Chrononutrition Engine)
    # leucine_distribution_efficiency will be calculated per-day
    
    for day in range(days):
        current_weight = current_fat + current_lean
        current_bf = (current_fat / current_weight) * 100.0
        
        day_info = TIMELINE[day % len(TIMELINE)]
        is_ref = day_info['isRefeed']
        cal_val = day_info['cal']
        prot_val = day_info['prot']
        carb_val = day_info['carb']
        fiber_val = day_info.get('fiber', 0.0)
        fat_val = day_info['fat']
        rt = RT_DAYS_REFEED if is_ref else RT_DAYS_CUT
        
        ov = OVERRIDES.get('ref' if is_ref else 'cut', {})
        logged_cal = (ov.get('cal') if ov.get('cal') is not None else cal_val) + TRACKING_ERROR.get('cal', 0)
        
        prot = (ov.get('prot') if ov.get('prot') is not None else prot_val) + TRACKING_ERROR.get('prot', 0)
        carb = (ov.get('carb') if ov.get('carb') is not None else carb_val) + TRACKING_ERROR.get('carb', 0)
        fiber = (ov.get('fiber') if ov.get('fiber') is not None else fiber_val) + TRACKING_ERROR.get('fiber', 0)
        fat = (ov.get('fat') if ov.get('fat') is not None else fat_val) + TRACKING_ERROR.get('fat', 0)
        alcohol = ov.get('alcohol') if ov.get('alcohol') is not None else day_info.get('alcohol', 0.0)
        
        sodium = day_info.get('sodium', 0.0) + ov.get('sodium', 0.0)
        potassium = day_info.get('potassium', 0.0) + ov.get('potassium', 0.0)
        
        fat_history.append(fat)
        if len(fat_history) > 3:
            fat_history.pop(0)
            
        avg_fat = sum(fat_history) / len(fat_history)
        fat_minimum = current_weight * 0.30
        hormonal_fat_penalty = 1.0
        if avg_fat < fat_minimum:
            deficit_g = fat_minimum - avg_fat
            hormonal_fat_penalty = max(0.85, 1.0 - (deficit_g * 0.01))
            
        # Net Carbs for CNS & Glycogen (Fiber does not produce free glucose for brain/glycogen)
        net_carb = max(0.0, carb - fiber)
        
        # Calculate true calories from macros (catches un-tracked macro errors)
        # We use net_carb (4 kcal) and assign fiber a conservative 1.5 kcal/g 
        derived_cals = (prot * 4.0) + (net_carb * 4.0) + (fiber * 1.5) + (fat * 9.0) + (alcohol * 7.0)
        cal = max(logged_cal, derived_cals)
        
        # =========================================================================
        # HOURLY CHRONONUTRITION ENGINE
        # =========================================================================
        meals = day_info.get('meals', [])
        hourly_insulin = [0.0] * 24
        hourly_mps = [0.0] * 24
        gym_hours = []
        has_liss = False
        
        for meal in meals:
            try:
                time_str = meal.get('time', '12:00 pm')
                parts = time_str.split('-')
                start_part = parts[0].strip()
                am_pm = 'am'
                if len(parts) > 1 and 'pm' in parts[1].lower(): am_pm = 'pm'
                elif 'pm' in start_part.lower(): am_pm = 'pm'
                
                start_time = start_part.lower().replace('am', '').replace('pm', '').strip()
                hour_str = start_time.split(':')[0]
                hour = int(hour_str)
                if am_pm == 'pm' and hour != 12: hour += 12
                if am_pm == 'am' and hour == 12: hour = 0
            except:
                hour = 12 # fallback
                
            title = meal.get('title', '').lower()
            if 'commute to gym (resistance)' in title:
                # Commute is usually hour 17 (5 PM). Gym is roughly hours 18, 19, 20 (6 PM - 8 PM).
                gym_hours.extend([(hour+1)%24, (hour+2)%24, (hour+3)%24])
            if 'commute to gym (liss)' in title:
                has_liss = True
                
            meal_carb = meal.get('carb', 0.0)
            meal_prot = meal.get('prot', 0.0)
            
            # Insulin pulse (Carbs stimulate insulin, blocking MPB)
            if meal_carb > 5.0:
                pulse_strength = min(1.0, meal_carb / 50.0)
                for h in range(4): # 4-hour insulin decay
                    idx = (hour + h) % 24
                    hourly_insulin[idx] = max(hourly_insulin[idx], pulse_strength * (1.0 - (h * 0.25)))
            
            # MPS Leucine Trigger (Protein spikes Muscle Protein Synthesis)
            age_leucine_threshold = max(20.0, 20.0 + (AGE - 35) * 0.5)
            if meal_prot > age_leucine_threshold:
                # Casein or late-night chores provide 7-8 hour slow drip
                duration = 8 if ('casein' in title or 'chore' in title or 'night' in title) else 3
                for h in range(duration):
                    idx = (hour + h) % 24
                    hourly_mps[idx] = 1.0
                    
        avg_insulin_protection = sum(hourly_insulin) / 24.0
        avg_mps_activation = sum(hourly_mps) / 24.0
        
        leucine_distribution_efficiency = min(1.0, 0.50 + (0.50 * avg_mps_activation))
        
        # Pre-Workout Synergy: Insulin + MPS spikes immediately preceding the gym
        pre_workout_synergy = 1.0
        if gym_hours:
            start_gym = gym_hours[0]
            pre_hours = [(start_gym - 2) % 24, (start_gym - 1) % 24] # 2 hours before gym
            pre_insulin = sum(hourly_insulin[h] for h in pre_hours) / 2.0
            pre_mps = sum(hourly_mps[h] for h in pre_hours) / 2.0
            # Up to a 5% synergy bonus to muscle synthesis if both are fully active pre-workout
            pre_workout_synergy += (pre_insulin * pre_mps) * 0.05
            
        # Post-Workout Synergy: Insulin + MPS spikes immediately following the gym
        post_workout_synergy = 1.0
        if gym_hours:
            end_gym = gym_hours[-1]
            pw_hours = [(end_gym + 1) % 24, (end_gym + 2) % 24] # Next 2 hours after gym
            pw_insulin = sum(hourly_insulin[h] for h in pw_hours) / 2.0
            pw_mps = sum(hourly_mps[h] for h in pw_hours) / 2.0
            # Up to a 5% synergy bonus to muscle synthesis if both are fully active post-workout
            post_workout_synergy += (pw_insulin * pw_mps) * 0.05
        # =========================================================================
        
        # BMR & TEF (Protein: 25%, Carbs: 8%, Fat: 2%, Alcohol: 15%)
        rmr = 370 + (21.6 * (current_lean / 2.20462))
        exact_tef = (prot * 4 * 0.25) + (carb * 4 * 0.08) + (fat * 9 * 0.02) + (alcohol * 7 * 0.15)
        
        # Adaptive Thermogenesis (Mass scaling + Hormonal NEAT drop below 15% BF + Prolonged deficit fatigue)
        scaling = (current_weight / STARTING_WEIGHT) ** 0.55
        
        # Hormonal NEAT suppression when getting extremely lean (<15% in males)
        neat_bf_drop = max(0.0, (15.0 - current_bf) * 12.0) if current_bf < 15.0 else 0.0
        
        if is_ref:
            # Refeed hormonal restoration (Leptin & Thyroid T3 bounce-back fueled by carbohydrate refeeding)
            scaling = 1.0 - ((1.0 - scaling) * (0.5 * min(1.0, net_carb / 250.0)))
            neat_bf_drop *= 0.50 # Refeed partially restores spontaneous NEAT
            # Cortisol drop / "Whoosh" flush: high carbs and lowered diet stress excrete water retention
            current_cortisol_water = max(0.0, current_cortisol_water * 0.70)
        else:
            # Deficit cortisol accumulation (Cortisol cross-binding to aldosterone receptors causing water retention)
            current_cortisol_water += max(0.0, (cal_val / 2000.0) * 0.015) * (1.0 + (sleep_deficit * 0.25))
            current_cortisol_water = min(4.5, current_cortisol_water) # Cap realistic water retention at ~4.5 lbs
        
        tdee = (rmr * (REFEED_ACT if is_ref else CUT_ACT) * scaling) + max(0.0, exact_tef - (cal * 0.10)) - neat_bf_drop
        deficit = tdee - cal
        
        if day == 0: initial_tdee = tdee
        if day == days - 1: final_tdee = tdee
        
        # 1. Dynamic CNS Glucose Demand & Ketone Adaptation
        # In non-ketoadapted state, the brain/RBCs require ~115g glucose/day.
        # Under sustained low carbs (<50g) and depleted glycogen (<180g), hepatic ketogenesis ramps up over 3-5 days,
        # allowing beta-hydroxybutyrate to cover ~70% of brain energy, lowering the glucose requirement to ~40g/day.
        if net_carb < 50.0 and current_glycogen < 180.0:
            ketone_adaptation_days = min(5, ketone_adaptation_days + 1)
        else:
            ketone_adaptation_days = max(0, ketone_adaptation_days - 1)
            
        keto_shift = ketone_adaptation_days / 5.0
        cns_glucose_need = 115.0 - (75.0 * keto_shift) # 115g -> 40g
        
        # 2. Gluconeogenesis (GNG) Subsystem with 1.6:1 Amino Acid Conversion Ratio
        carb_deficit_for_cns = max(0.0, cns_glucose_need - net_carb)
        protein_stolen_for_cns = carb_deficit_for_cns * GNG_EFFICIENCY_RATIO
        effective_prot = max(0.0, prot - protein_stolen_for_cns)
        
        # Direct skeletal catabolism if dietary protein cannot even cover the GNG glucose requirement
        direct_gluconeogenic_catabolism = max(0.0, protein_stolen_for_cns - prot) / 100.0
        
        # 3. Insulin-Mediated Suppression of Muscle Protein Breakdown (MPB)
        # Using chrononutrition average instead of flat daily carbs
        carb_mpb_factor = 0.75 + (0.25 * avg_insulin_protection)
        
        # 4. Glycogen-Driven Resistance Training Stimulus Factor
        # Intramuscular glycogen < 250g impairs calcium release and high-intensity force output
        glycogen_performance_factor = max(0.70, min(1.0, current_glycogen / 250.0))
        
        # 5. Optimal P-Ratio Anabolic Window (Biphasic Curve for Body Fat vs MPS)
        # Peak anabolic sensitivity is between 10% and 22% BF.
        # Below 10%: starvation signaling / low leptin blunts MPS.
        # Above 22%: adipokine inflammation & peripheral insulin resistance progressively blunt MPS.
        if current_bf < 10.0:
            bf_factor = max(0.0, (current_bf - ESSENTIAL_BF_PCT) / (10.0 - ESSENTIAL_BF_PCT))
        elif current_bf > 22.0:
            bf_factor = max(0.45, 1.0 - ((current_bf - 22.0) * 0.025))
        else:
            bf_factor = 1.0
            
        # 6. Muscle Synthesis (MPS) vs Disuse Atrophy
        muscle_gain, muscle_atrophy = 0.0, 0.0
        if rt >= 2:
            consecutive_disuse_days = 0
            
            interference_penalty = 0.90 if (gym_hours and has_liss) else 1.0
            
            p_factor = min(1.0, effective_prot / current_lean) * hormonal_fat_penalty
            muscle_gain = ((0.15 / 7.0) * bf_factor * p_factor * (rt / 4.0) * 
                           sleep_mps_multiplier * glycogen_performance_factor * 
                           carb_mpb_factor * leucine_distribution_efficiency * 
                           pre_workout_synergy * post_workout_synergy * interference_penalty)
        else:
            consecutive_disuse_days += 1
            if consecutive_disuse_days <= 7:
                muscle_atrophy = (2.0 - rt) * 0.005 # Mild initial loss (mostly sarcoplasmic)
            else:
                muscle_atrophy = (2.0 - rt) * 0.018 # Prolonged bed-rest disuse rate
        
        # Energy balance partitioning (Synthesis costs 2,500 kcal/lb; Breakdown yields 750 kcal/lb)
        net_deficit = deficit - (muscle_gain * LEAN_SYNTHESIS_COST_KCAL) + (muscle_atrophy * LEAN_CATABOLIC_YIELD_KCAL)
        
        if net_deficit > 0:
            # -------------------------------------------------------------
            # CALORIC DEFICIT LOGIC
            # -------------------------------------------------------------
            # Biological maximum fat oxidation (Alpert's limit: 31.0 kcal/lb of fat/day)
            max_ox = current_fat * 31.0 
            
            # Essential Fat Floor: If at essential fat limit, fat oxidation drops to 0
            if current_bf <= ESSENTIAL_BF_PCT or current_fat <= ESSENTIAL_FAT_LBS:
                max_ox = 0.0
            
            # Alcohol blocks hepatic fat oxidation while acetate is cleared
            if alcohol > 0:
                alcohol_cals = alcohol * 7.0
                max_ox = max(0.0, max_ox - alcohol_cals)
            
            # Sleep alters deficit partitioning: forces a percentage onto lean mass
            actual_fat_deficit = net_deficit * sleep_fat_ox_multiplier
            forced_lean_deficit = net_deficit - actual_fat_deficit
            
            # Starvation / Essential Fat overflow check
            if actual_fat_deficit > max_ox:
                muscle_gain = 0.0
                net_deficit = deficit + (muscle_atrophy * LEAN_CATABOLIC_YIELD_KCAL)
                actual_fat_deficit = net_deficit * sleep_fat_ox_multiplier
                forced_lean_deficit = net_deficit - actual_fat_deficit
                overflow_deficit = max(0.0, actual_fat_deficit - max_ox)
                fat_lost = max_ox / FAT_ENERGY_DENSITY_KCAL
                catabolized = ((forced_lean_deficit + overflow_deficit) / LEAN_CATABOLIC_YIELD_KCAL) + direct_gluconeogenic_catabolism
            else:
                fat_lost = actual_fat_deficit / FAT_ENERGY_DENSITY_KCAL
                catabolized = (forced_lean_deficit / LEAN_CATABOLIC_YIELD_KCAL) + direct_gluconeogenic_catabolism
                
            total_catabolized += catabolized
            current_fat = max(ESSENTIAL_FAT_LBS, current_fat - fat_lost)
            current_lean += muscle_gain - muscle_atrophy - catabolized
        else:
            # -------------------------------------------------------------
            # CALORIC SURPLUS LOGIC (Fixed P-ratio and synthesis energy cost)
            # -------------------------------------------------------------
            surplus = -net_deficit # positive surplus calories
            
            # Forbes curve P-ratio: leaner bodies partition more surplus to lean mass; higher BF partitions more to fat
            base_p_lean = max(0.15, min(0.65, 0.65 - (current_bf - 10.0) * 0.018))
            rt_surplus_factor = min(1.0, rt / 4.0)
            
            # Sleep deprivation causes peripheral insulin resistance, directing more surplus into adipose tissue
            effective_p_lean = base_p_lean * rt_surplus_factor * sleep_mps_multiplier * hormonal_fat_penalty
            
            surplus_to_lean = surplus * effective_p_lean
            surplus_to_fat = surplus - surplus_to_lean
            
            surplus_lean_gain = surplus_to_lean / LEAN_SYNTHESIS_COST_KCAL
            surplus_fat_gain = surplus_to_fat / FAT_ENERGY_DENSITY_KCAL
            
            current_fat += surplus_fat_gain
            current_lean += (surplus_lean_gain + muscle_gain)
            catabolized = 0.0
        
        # Glycogen turnover (intramuscular pool: 100g - 500g)
        current_glycogen = max(100.0, min(500.0, current_glycogen + net_carb - (130.0 if is_ref else 180.0)))

    tissue_w = current_fat + current_lean
    glycogen_mass_lbs = ((current_glycogen * 5.0) / 453.592) - ((500.0 * 5.0) / 453.592)
    
    # Sodium-induced fluid retention during Refeed Weeks
    refeed_sodium_water = 2.5 if is_ref else 0.0
    
    # Dynamic mineral hydration (Sodium:Potassium bloat)
    na_k_ratio = sodium / potassium if potassium > 0 else 1.0
    if na_k_ratio > 1.0:
        mineral_water_retention = (na_k_ratio - 1.0) * 1.5
    elif na_k_ratio < 0.5:
        mineral_water_retention = -0.5
    
    scale_w = tissue_w + glycogen_mass_lbs + current_cortisol_water + refeed_sodium_water + mineral_water_retention
    
    print("="*50)
    print(f"PROJECTION FOR: {TARGET_DATE.strftime('%b %d, %Y')} ({days} days)")
    print(f"Start Scale:   {sim_start_weight:.1f} lbs ({sim_start_bf_pct:.1f}% BF)")
    print(f"End Scale:     {scale_w:.1f} lbs (Tissue: {tissue_w:.1f} lbs)")
    print(f"End Lean:      {current_lean:.1f} lbs ({current_lean - lean_mass:+.1f} lbs net)")
    print(f"End Fat:       {current_fat:.1f} lbs ({current_fat - fat_mass:+.1f} lbs net)")
    print(f"End BF %:      {(current_fat / tissue_w) * 100:.1f}%")
    print(f"Catabolized:   {total_catabolized:.2f} lbs (Starvation & Gluconeogenesis)")
    if current_cortisol_water > 0.3:
        print(f"Water Masking: +{current_cortisol_water:.1f} lbs (Cortisol Extracellular Fluid)")
    if sleep_deficit > 0: 
        print(f"⚠️ SLEEP PENALTY ACTIVE: -{sleep_deficit*0.275*100:.0f}% Fat Ox, -{sleep_deficit*0.2*100:.0f}% MPS")
    if RT_DAYS_CUT < 2 or RT_DAYS_REFEED < 2: 
        print("⚠️ DISUSE ATROPHY MODEL ACTIVE")
    print(f"TDEE Shift:    {initial_tdee:.0f} -> {final_tdee:.0f} kcal/day")
    print("="*50)

if __name__ == "__main__":
    run_simulation() #no change 
    run_simulation(weight_change=-4.0, bf_change=-4.7) #optmistic
    print()
    run_simulation(weight_change=-4.0, bf_change=-3.8) #most-likely
    print()
    run_simulation(weight_change=-4.0, bf_change=-2.5) #pessimistic
