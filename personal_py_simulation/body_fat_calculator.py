import datetime, json, os, shutil, subprocess

START_DATE = datetime.date(2026, 7, 27)
TARGET_DATE = datetime.date(2026, 12, 17)

STARTING_WEIGHT = 156.0
STARTING_BF_PCT = 31.2
AGE = 23

# WEIGH-IN CHECKPOINT: on this date the sim snaps to the real scale weight.
# Assumes ALL weight lost since START_DATE was fat (lean held at each scenario's starting lean).
# Set CHECKPOINT_WEIGHT = None to disable.
CHECKPOINT_DATE = datetime.date(2026, 10, 6)
CHECKPOINT_WEIGHT = 143.0

# Activity Multipliers (applied to RMR only; TEF is computed separately below)
# These capture: Resistance Training EAT + NEAT + Aerobic activity (steps/LISS/dance)
# Aerobic tracking is unified in the app via HealthKit:
#   - Natural steps (pedometer), LISS (Active Calories × 20), Dance (Active Calories × 20)
#   - Base multiplier (Sedentary + 4 days lifting) = 1.25
#   - Each 1,000 steps adds ~0.03125 to the multiplier

# Dynamic Step Targets (Edit these to test different activity routines)
# Index matches day of the week: [Mon, Tue, Wed, Thu, Fri, Sat, Sun]
DAILY_STEPS = [6000, 8000, 10000, 4000, 4000, 10000, 8000]

RT_DAYS = 4

# OVERRIDES: set to a number to override timeline JSON
OVERRIDES = {'prot': None, 'carb': None, 'fat': None, 'fiber': None, 'cal': None, 'alcohol': 0}

# TRACKING ERROR: Set these to simulate accidentally eating extra macros/calories per day
TRACKING_ERROR = {'cal': 0, 'prot': 0, 'carb': 0, 'fat': 0, 'fiber': 0}

# SLEEP: Sub-optimal sleep (<7.5 hrs) impairs fat oxidation, increases insulin resistance, and reduces MPS
SLEEP_HOURS = 7.5

# MEAL DISTRIBUTION: Number of protein-rich meals reaching the leucine threshold (~2.5-3.0g leucine / ~25-35g protein)
MEALS_PER_DAY = 4

# HORMONAL CALIBRATION (from blood work drawn post-refeed)
# Total T: 533 ng/dL at age 23 (~40th percentile; but irrelevant — muscle uses Free T)
# Free T: 132.7 pg/mL (85th percentile bioavailable androgens; ref 35-155)
# TSH: 4.44 mIU/L while ON ashwagandha (suggests subclinical hypothyroid tendency)
TESTOSTERONE_FACTOR = 1.0   # Free T is 85th percentile — no MPS penalty warranted
THYROID_TDEE_PENALTY = 0.13  # TSH 4.44 on Ash = true baseline likely >5.0; model -13% max TDEE drop

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
    liver_glycogen = 100.0
    muscle_glycogen = 400.0
    current_cortisol_water = 0.0
    total_catabolized = 0.0
    consecutive_disuse_days = 0
    ketone_adaptation_days = 0
    fat_history = []
    consecutive_deficit_days = 0
    consecutive_healing_days = 0
    cns_tdee_factor = 1.0
    refeed_sodium_water = 0.0
    na_k_water = 0.0
    tdee_history = []
    
    # 1. Sleep Modifiers (Clinical data: ~5.5 hrs sleep = -55% fat oxidation in deficit, +impaired P-ratio in surplus)
    sleep_deficit = max(0.0, 7.5 - SLEEP_HOURS)
    sleep_fat_ox_multiplier = max(0.1, 1.0 - (sleep_deficit * 0.275))
    sleep_mps_multiplier = max(0.1, 1.0 - (sleep_deficit * 0.20))
    
    # 2. Protein Distribution & Leucine Triggering (Now calculated dynamically via Chrononutrition Engine)
    # leucine_distribution_efficiency will be calculated per-day
    
    checkpoint_day = (CHECKPOINT_DATE - START_DATE).days if CHECKPOINT_WEIGHT else -1
    
    for day in range(days):
        if day == checkpoint_day:
            current_lean = lean_mass
            current_fat = max(ESSENTIAL_FAT_LBS, CHECKPOINT_WEIGHT - lean_mass)
        current_weight = current_fat + current_lean
        current_bf = (current_fat / current_weight) * 100.0
        
        day_info = TIMELINE[day % len(TIMELINE)]
            
        cal_val = day_info['cal']
        prot_val = day_info['prot']
        carb_val = day_info['carb']
        fiber_val = day_info.get('fiber', 0.0)
        fat_val = day_info['fat']
        rt = RT_DAYS
        
        ov = OVERRIDES
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
        fat_minimum = current_weight * 0.20 # Hormonal pushback threshold (lowered due to Omega-3 supplementation)
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
        meal_carb_schedule = []
        
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
            meal_carb_schedule.append((hour, meal_carb))
            
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
        
        # BMR, Activity, and Adaptive Thermogenesis estimates (needed early for glycerol estimation)
        rmr = 370 + (21.6 * (current_lean / 2.20462))
        scaling = (current_weight / STARTING_WEIGHT) ** 0.55
        neat_bf_drop = max(0.0, (15.0 - current_bf) * 12.0) if current_bf < 15.0 else 0.0
        cns_fatigue_penalty = max(0.50, 1.0 - (min(consecutive_deficit_days, 28) / 28.0) * 0.50)
        cns_tdee_factor = max(1.0 - THYROID_TDEE_PENALTY, 1.0 - (min(consecutive_deficit_days, 28) / 28.0) * THYROID_TDEE_PENALTY)
        daily_steps = DAILY_STEPS[day % 7]
        current_act = 1.25 + (daily_steps * 0.00003125)

        # Estimate daily deficit to calculate free glycerol glucose from lipolysis
        estimated_base_tdee = (rmr * current_act * scaling * cns_tdee_factor) - neat_bf_drop
        estimated_deficit = max(0.0, estimated_base_tdee - cal)
        estimated_fat_lost_grams = (estimated_deficit * sleep_fat_ox_multiplier) / 9.0
        glycerol_glucose = estimated_fat_lost_grams * 0.10

        # 1. Dynamic CNS Glucose Demand & Ketone Adaptation
        if net_carb < 50.0 and liver_glycogen < 50.0:
            ketone_adaptation_days = min(5, ketone_adaptation_days + 1)
        elif net_carb > 100.0: # Massive insulin spike halts hepatic ketogenesis immediately
            ketone_adaptation_days = 0 
        else:
            ketone_adaptation_days = max(0, ketone_adaptation_days - 1)
            
        keto_shift = ketone_adaptation_days / 5.0
        cns_glucose_need = 115.0 - (75.0 * keto_shift) # 115g -> 40g
        
        # 2. Gluconeogenesis (GNG) Subsystem with 1.6:1 Amino Acid Conversion Ratio
        # Brain uses glycerol from fat first before stealing protein
        carb_deficit_for_cns = max(0.0, cns_glucose_need - net_carb - glycerol_glucose)
        protein_stolen_for_cns = carb_deficit_for_cns * GNG_EFFICIENCY_RATIO
        effective_prot = max(0.0, prot - protein_stolen_for_cns)
        
        # Direct skeletal catabolism if dietary protein cannot even cover the GNG glucose requirement
        direct_gluconeogenic_catabolism = max(0.0, protein_stolen_for_cns - prot) / 100.0
        
        # Prevent double-spending: Brain gets carbs first, muscles get the leftovers
        carbs_available_for_glycogen = max(0.0, net_carb - cns_glucose_need)
        
        # Partition carbs into pre-workout vs post-workout for glycogen modeling
        if gym_hours and meal_carb_schedule:
            gym_start = gym_hours[0]
            total_meal_carbs = sum(mc for _, mc in meal_carb_schedule)
            pre_gym_carbs = sum(mc for h, mc in meal_carb_schedule if h <= gym_start)
            pre_workout_fraction = (pre_gym_carbs / total_meal_carbs) if total_meal_carbs > 0 else 0.5
            pre_workout_net_carb = carbs_available_for_glycogen * pre_workout_fraction
            post_workout_net_carb = carbs_available_for_glycogen * (1.0 - pre_workout_fraction)
        else:
            pre_workout_net_carb = carbs_available_for_glycogen
            post_workout_net_carb = 0.0
        
        # BMR & TEF (Protein: 25%, Carbs: 8%, Fat: 2%, Alcohol: 15%)
        # TEF applies to oral food only, NOT internally catabolized muscle
        exact_tef = (prot * 4 * 0.25) + (carb * 4 * 0.08) + (fat * 9 * 0.02) + (alcohol * 7 * 0.15)
        
        # Base TDEE before checking for deficit/surplus (so we can mathematically detect biological refeeds)
        base_tdee = (rmr * current_act * scaling * cns_tdee_factor) + (exact_tef - (cal * 0.10)) - neat_bf_drop
        is_biological_refeed = (net_carb > 200.0 and cal >= base_tdee)
        
        if is_biological_refeed:
            # Mathematical detection of a carbohydrate surplus triggers Leptin & Thyroid T3 bounce-back
            scaling = 1.0 - ((1.0 - scaling) * (0.5 * min(1.0, net_carb / 250.0)))
            neat_bf_drop *= 0.50 # Surplus partially restores spontaneous NEAT
            # Cortisol drop / "Whoosh" flush: high carbs and lowered diet stress excrete water retention
            current_cortisol_water = max(0.0, current_cortisol_water * 0.70)
        
        # Final TDEE recalculation using the potentially restored `scaling` and `neat_bf_drop`
        unfatigued_tdee = (rmr * current_act * scaling) + (exact_tef - (cal * 0.10)) - neat_bf_drop
        tdee = (rmr * current_act * scaling * cns_tdee_factor) + (exact_tef - (cal * 0.10)) - neat_bf_drop
        
        deficit = tdee - cal
        tdee_history.append(tdee)
        unfatigued_deficit = unfatigued_tdee - cal
        
        if deficit > 0:
            # Deficit cortisol accumulation (Cortisol cross-binding to aldosterone receptors causing water retention)
            current_cortisol_water += max(0.0, (deficit / 1000.0) * 0.015) * (1.0 + (sleep_deficit * 0.25))
            current_cortisol_water = min(4.5, current_cortisol_water) # Cap realistic water retention at ~4.5 lbs
        
        # Track prolonged deficit fatigue (CNS and Endocrine strain)
        if is_biological_refeed:
            # A biological refeed heals the CNS, overriding any temporary TDEE bounce it causes
            consecutive_healing_days += 1
            heal_factor = 5 if consecutive_healing_days >= 2 else 3
            consecutive_deficit_days = max(0, consecutive_deficit_days - heal_factor)
        elif unfatigued_deficit > (unfatigued_tdee * 0.05): # Any real deficit accumulates fatigue
            consecutive_deficit_days += 1
            consecutive_healing_days = 0
        elif unfatigued_deficit < 0: # Surplus actively heals fatigue faster
            consecutive_healing_days += 1
            # 48-hour Leptin peak: 2nd consecutive day of surplus heals exponentially more
            heal_factor = 5 if consecutive_healing_days >= 2 else 3
            consecutive_deficit_days = max(0, consecutive_deficit_days - heal_factor)
        else: # Maintenance/Refeed heals it normally
            consecutive_healing_days += 1
            heal_factor = 3 if consecutive_healing_days >= 2 else 2
            consecutive_deficit_days = max(0, consecutive_deficit_days - heal_factor)
        
        if day == 0: initial_tdee = tdee
        if day == days - 1: final_tdee = tdee
        
        # (Moved CNS demand and GNG logic earlier)
        
        # 3. Insulin-Mediated Suppression of Muscle Protein Breakdown (MPB)
        # Using chrononutrition average instead of flat daily carbs
        carb_mpb_factor = 0.75 + (0.25 * avg_insulin_protection)
        
        # 4. Glycogen-Driven Resistance Training Stimulus Factor
        # Only pre-workout carbs are available for glycogen loading before performance is evaluated
        liver_space = 100.0 - liver_glycogen
        liver_replenish = min(liver_space, pre_workout_net_carb)
        liver_glycogen += liver_replenish
        muscle_glycogen = max(15.0, min(400.0, muscle_glycogen + (pre_workout_net_carb - liver_replenish)))
        
        # Intramuscular glycogen < 250g impairs calcium release and high-intensity force output
        glycogen_performance_factor = max(0.08, min(1.0, muscle_glycogen / 250.0))
        
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
                           pre_workout_synergy * post_workout_synergy * interference_penalty * 
                           cns_fatigue_penalty * TESTOSTERONE_FACTOR)
            # MPS Daily Ceiling: Natural lifters have a practical maximum rate of muscle
            # protein synthesis (~0.04 lbs/day). Prevents unrealistic "catch-up" rebound
            # during diet breaks where all multipliers are at 1.0.
            muscle_gain = min(muscle_gain, 0.04)
        else:
            consecutive_disuse_days += 1
            if consecutive_disuse_days <= 7:
                muscle_atrophy = (2.0 - rt) * 0.005 # Mild initial loss (mostly sarcoplasmic)
            else:
                muscle_atrophy = (2.0 - rt) * 0.018 # Prolonged bed-rest disuse rate
        
        # Energy balance partitioning (Synthesis costs 2,500 kcal/lb; Breakdown yields 750 kcal/lb)
        total_tissue_breakdown = muscle_atrophy + direct_gluconeogenic_catabolism
        net_deficit = deficit + (muscle_gain * LEAN_SYNTHESIS_COST_KCAL) - (total_tissue_breakdown * LEAN_CATABOLIC_YIELD_KCAL)
        
        # -------------------------------------------------------------
        # METABOLIC LIMIT & RECOMP CALIBRATION
        # -------------------------------------------------------------
        # Biological maximum fat oxidation (Alpert's limit: 31.0 kcal/lb of fat/day)
        # Insulin lipolysis blocker: high insulin suppresses HSL, shutting down fat oxidation
        insulin_lipolysis_blocker = max(0.1, 1.0 - avg_insulin_protection)
        max_ox = current_fat * 31.0 * insulin_lipolysis_blocker
        
        if current_bf <= ESSENTIAL_BF_PCT or current_fat <= ESSENTIAL_FAT_LBS:
            max_ox = 0.0
        if alcohol > 0:
            max_ox = max(0.0, max_ox - (alcohol * 7.0))
            
        if net_deficit > 0:
            actual_fat_deficit = net_deficit * sleep_fat_ox_multiplier
            if actual_fat_deficit > max_ox:
                # We are demanding more energy from fat than biology allows.
                # First, down-regulate muscle synthesis to try and close the gap.
                fat_shortfall = actual_fat_deficit - max_ox
                total_shortfall = fat_shortfall / sleep_fat_ox_multiplier
                muscle_synthesis_cost = muscle_gain * LEAN_SYNTHESIS_COST_KCAL
                
                if muscle_synthesis_cost >= total_shortfall:
                    # We can perfectly balance the equation just by building less muscle!
                    muscle_gain -= (total_shortfall / LEAN_SYNTHESIS_COST_KCAL)
                    net_deficit -= total_shortfall
                else:
                    # Even with 0 muscle growth, we are STILL starving beyond max_ox.
                    muscle_gain = 0.0
                    net_deficit = deficit - (total_tissue_breakdown * LEAN_CATABOLIC_YIELD_KCAL)

        # -------------------------------------------------------------
        # FINAL ENERGY PARTITIONING
        # -------------------------------------------------------------
        if net_deficit > 0:
            # TRUE DEFICIT (Post-Adjustments)
            actual_fat_deficit = net_deficit * sleep_fat_ox_multiplier
            forced_lean_deficit = net_deficit - actual_fat_deficit
            
            overflow_deficit = max(0.0, actual_fat_deficit - max_ox)
            fat_lost = min(actual_fat_deficit, max_ox) / FAT_ENERGY_DENSITY_KCAL
            catabolized = ((forced_lean_deficit + overflow_deficit) / LEAN_CATABOLIC_YIELD_KCAL) + direct_gluconeogenic_catabolism
            
            total_catabolized += catabolized
            current_fat = max(ESSENTIAL_FAT_LBS, current_fat - fat_lost)
            current_lean += muscle_gain - muscle_atrophy - catabolized
            
        else:
            # TRUE SURPLUS (Or Atrophy-Induced / Failed-Recomp Surplus)
            true_surplus = -net_deficit 
            surplus_fat_gain = true_surplus / FAT_ENERGY_DENSITY_KCAL
            catabolized = direct_gluconeogenic_catabolism
            
            total_catabolized += catabolized
            current_fat += surplus_fat_gain
            current_lean += muscle_gain - muscle_atrophy - catabolized
        
        # Pure Mathematical Glycogen turnover: Base + Gym Hours + LISS/Walking/Dancing
        liver_space_post = 100.0 - liver_glycogen
        liver_replenish_post = min(liver_space_post, post_workout_net_carb)
        liver_glycogen += liver_replenish_post
        muscle_glycogen = max(15.0, min(400.0, muscle_glycogen + (post_workout_net_carb - liver_replenish_post)))
        
        liver_glycogen = max(5.0, liver_glycogen - 50.0) # Base turnover
        muscle_depletion = (len(gym_hours) * 30.0) + (40.0 if daily_steps >= 8000 else 0.0)
        muscle_glycogen = max(15.0, muscle_glycogen - muscle_depletion)
        
        # Sodium-based fluid retention (massive carbs/sodium spike aldosterone transiently)
        if is_biological_refeed:
            refeed_sodium_water = min(2.5, refeed_sodium_water + 0.5)
        else:
            refeed_sodium_water = max(0.0, refeed_sodium_water - 0.3)
        
        # Dynamic mineral hydration (Na:K rolling state)
        if potassium > 0:
            day_na_k = sodium / potassium
            if day_na_k > 1.0:
                na_k_water = min(2.0, na_k_water * 0.7 + (day_na_k - 1.0) * 0.45)
            elif day_na_k < 0.5:
                na_k_water = max(-0.5, na_k_water * 0.7 - 0.15)
            else:
                na_k_water *= 0.85

    total_glycogen = liver_glycogen + muscle_glycogen
    glycogen_mass_lbs = ((total_glycogen * 5.0) / 453.592) - ((500.0 * 5.0) / 453.592)
    
    # Apply fluid and glycogen shifts directly to lean mass so the scale weight balances
    fluid_shifts = glycogen_mass_lbs + current_cortisol_water + refeed_sodium_water + na_k_water
    actual_lean_weight = current_lean + fluid_shifts
    scale_w = current_fat + actual_lean_weight
    
    # Calculate true metabolic adaptation using 7-day rolling averages
    avg_initial_tdee = sum(tdee_history[:7]) / 7.0
    avg_final_tdee = sum(tdee_history[-7:]) / 7.0
    
    print("="*50)
    print(f"PROJECTION FOR: {TARGET_DATE.strftime('%b %d, %Y')} ({days} days)")
    print(f"Start Scale:   {sim_start_weight:.1f} lbs ({sim_start_bf_pct:.1f}% BF)")
    if CHECKPOINT_WEIGHT and 0 <= checkpoint_day < days:
        print(f"Checkpoint:    {CHECKPOINT_WEIGHT:.1f} lbs on {CHECKPOINT_DATE.strftime('%b %d')} ({(CHECKPOINT_WEIGHT - lean_mass) / CHECKPOINT_WEIGHT * 100:.1f}% BF, all loss = fat)")
    print(f"End Scale:     {scale_w:.1f} lbs")
    print(f"End Lean:      {actual_lean_weight:.1f} lbs (Dry Structural Change: {current_lean - lean_mass:+.1f} lbs)")
    print(f"End Fat:       {current_fat:.1f} lbs ({current_fat - fat_mass:+.1f} lbs net)")
    print(f"End BF %:      {(current_fat / scale_w) * 100:.1f}%")
    print(f"Catabolized:   {total_catabolized:.2f} lbs (Starvation & Gluconeogenesis)")
    if current_cortisol_water > 0.3:
        print(f"Water Masking: +{current_cortisol_water:.1f} lbs (Cortisol Extracellular Fluid)")
    if sleep_deficit > 0: 
        print(f"⚠️ SLEEP PENALTY ACTIVE: -{sleep_deficit*0.275*100:.0f}% Fat Ox, -{sleep_deficit*0.2*100:.0f}% MPS")
    if RT_DAYS < 2: 
        print("⚠️ DISUSE ATROPHY MODEL ACTIVE")
    print(f"Avg TDEE:      {avg_initial_tdee:.0f} -> {avg_final_tdee:.0f} kcal/day")
    print("="*50)

if __name__ == "__main__":
    run_simulation() #no change 
    run_simulation(weight_change=-4.0, bf_change=-4.7) #optmistic
    print()
    run_simulation(weight_change=-4.0, bf_change=-3.8) #most-likely
    print()
    run_simulation(weight_change=-4.0, bf_change=-2.5) #pessimistic
