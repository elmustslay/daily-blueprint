import datetime, json, os

START_DATE = datetime.date(2026, 7, 27)
TARGET_DATE = datetime.date(2026, 12, 17)

STARTING_WEIGHT = 157.0
STARTING_BF_PCT = 31.2

# w, g = 153.0, 0.5; STARTING_BF_PCT = (w - (STARTING_WEIGHT * (1 - STARTING_BF_PCT/100)) - g) / w * 100; STARTING_WEIGHT = w

# 1.54 = Cut Week (4 days Resistance training, 2 days LISS (130-140bp for 1 hr), 3 days Standing Desk (for 3-4 hrs), High Water Intake -- walk a lot in office too)
# 1.375 = Refeed Week (4 days Resistance training, NO LISS, NO Standing Desk -- actively avoid walk/excerise)
CUT_ACT = 1.54 
REFEED_ACT = 1.375
RT_DAYS_CUT = 4
RT_DAYS_REFEED = 4

# OVERRIDES: set to a number to override JSON
OVERRIDES = {
    'cut': {'prot': None, 'carb': None, 'fat': None, 'cal': None},
    'ref': {'prot': None, 'carb': None, 'fat': None, 'cal': None}
}

# TRACKING ERROR: Set these to simulate accidentally eating extra macros/calories per day
# (e.g., getting a heavy hand of rice at Chipotle or forgetting to track cooking oil)
TRACKING_ERROR = {'cal': 0, 'prot': 0, 'carb': 0, 'fat': 0}

# SLEEP: Sub-optimal sleep (<7.5 hrs) impairs fat oxidation and muscle protein synthesis
SLEEP_HOURS = 7.5

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

def sync_from_dart():
    import subprocess, shutil
    flutter_bin = shutil.which('flutter')
    if not flutter_bin:
        candidates = [
            os.path.expanduser('~/development/flutter/bin/flutter'),
            os.path.expanduser('~/flutter/bin/flutter'),
            '/opt/homebrew/bin/flutter',
            '/usr/local/bin/flutter',
        ]
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

timeline_path = os.path.join(BASE_DIR, 'simulation_timeline.json')
if not os.path.exists(timeline_path):
    raise FileNotFoundError("simulation_timeline.json was not found. Please ensure flutter test exports it.")

with open(timeline_path, 'r') as f:
    TIMELINE = json.load(f)

def run_simulation():
    target_days = (TARGET_DATE - START_DATE).days
    if target_days <= 0:
        print(f"⚠️ TARGET_DATE ({TARGET_DATE}) must be after START_DATE ({START_DATE})")
        return

    days = target_days
    fat_mass = STARTING_WEIGHT * (STARTING_BF_PCT / 100.0)
    lean_mass = STARTING_WEIGHT - fat_mass
    current_fat, current_lean = fat_mass, lean_mass
    current_glycogen = 500.0
    total_catabolized = 0.0
    
    # Calculate sleep modifiers based on clinical data (e.g., 5.5 hours = -55% fat oxidation)
    sleep_deficit = max(0.0, 7.5 - SLEEP_HOURS)
    sleep_fat_ox_multiplier = max(0.1, 1.0 - (sleep_deficit * 0.275))
    sleep_mps_multiplier = max(0.1, 1.0 - (sleep_deficit * 0.2))
    
    for day in range(days):
        current_weight = current_fat + current_lean
        current_bf = (current_fat / current_weight) * 100.0
        
        day_info = TIMELINE[day % len(TIMELINE)]
        is_ref = day_info['isRefeed']
        cal_val = day_info['cal']
        prot_val = day_info['prot']
        carb_val = day_info['carb']
        fat_val = day_info['fat']
        rt = RT_DAYS_REFEED if is_ref else RT_DAYS_CUT
        
        ov = OVERRIDES.get('ref' if is_ref else 'cut', {})
        cal = (ov.get('cal') if ov.get('cal') is not None else cal_val) + TRACKING_ERROR.get('cal', 0)
        prot = (ov.get('prot') if ov.get('prot') is not None else prot_val) + TRACKING_ERROR.get('prot', 0)
        carb = (ov.get('carb') if ov.get('carb') is not None else carb_val) + TRACKING_ERROR.get('carb', 0)
        fat = (ov.get('fat') if ov.get('fat') is not None else fat_val) + TRACKING_ERROR.get('fat', 0)
        
        # BMR & TEF
        rmr = 370 + (21.6 * (current_lean / 2.20462))
        exact_tef = (prot * 4 * 0.25) + (carb * 4 * 0.08) + (fat * 9 * 0.02)
        
        # Adaptive Thermogenesis & Hormonal Bounce-Back
        scaling = (current_weight / STARTING_WEIGHT) ** 0.55
        if is_ref: scaling = 1.0 - ((1.0 - scaling) * (0.5 * min(1.0, carb / 300.0)))
        
        tdee = (rmr * (REFEED_ACT if is_ref else CUT_ACT) * scaling) + max(0.0, exact_tef - (cal * 0.10))
        deficit = tdee - cal
        
        if day == 0: initial_tdee = tdee
        if day == days - 1: final_tdee = tdee
        
        # Muscle Synthesis vs Disuse Atrophy
        muscle_gain, muscle_atrophy = 0.0, 0.0
        if rt >= 2:
            p_factor = min(1.0, prot / current_lean)
            bf_factor = max(0.0, (current_bf - 12.0) / (STARTING_BF_PCT - 12.0))
            muscle_gain = (0.15 / 7.0) * bf_factor * p_factor * (rt / 4.0) * sleep_mps_multiplier
        else:
            muscle_atrophy = (2.0 - rt) * 0.02 # Lose ~0.04 lbs/day at 0 RT days
        
        # Energy math
        net_deficit = deficit - (muscle_gain * 2500.0) + (muscle_atrophy * 2500.0)
        
        # 1. Standard biological maximum fat oxidation (Alpert's limit)
        max_ox = current_fat * 31.0 
        
        # 2. Sleep alters energy partitioning: force a percentage of the deficit onto lean mass
        actual_fat_deficit = net_deficit * sleep_fat_ox_multiplier
        forced_lean_deficit = net_deficit - actual_fat_deficit
        
        # 3. Starvation Shutoff (If even the reduced fat deficit exceeds max_ox limit)
        if actual_fat_deficit > max_ox:
            muscle_gain = 0.0
            
            # Recalculate deficit without the muscle gain energy cost
            net_deficit = deficit + (muscle_atrophy * 2500.0)
            actual_fat_deficit = net_deficit * sleep_fat_ox_multiplier
            forced_lean_deficit = net_deficit - actual_fat_deficit
            
            # Any fat deficit over the max_ox limit is also forced onto lean mass
            overflow_deficit = actual_fat_deficit - max_ox
            fat_lost = max_ox / 3500.0
            catabolized = (forced_lean_deficit + overflow_deficit) / 2500.0
        else:
            fat_lost = actual_fat_deficit / 3500.0
            catabolized = forced_lean_deficit / 2500.0
            
        total_catabolized += catabolized
        current_fat -= fat_lost
        current_lean += muscle_gain - muscle_atrophy - catabolized
        current_glycogen = max(100.0, min(500.0, current_glycogen + carb - (130.0 if is_ref else 180.0)))

    tissue_w = current_fat + current_lean
    scale_w = tissue_w + ((current_glycogen * 4.0) / 453.592) - ((500.0 * 4.0) / 453.592)
    
    print("="*50)
    print(f"PROJECTION FOR: {TARGET_DATE.strftime('%b %d, %Y')} ({days} days)")
    print(f"Start Scale:   {STARTING_WEIGHT:.1f} lbs ({STARTING_BF_PCT:.1f}% BF)")
    print(f"End Scale:     {scale_w:.1f} lbs (Tissue: {tissue_w:.1f} lbs)")
    print(f"End Lean:      {current_lean:.1f} lbs ({current_lean - lean_mass:+.1f} lbs net)")
    print(f"End Fat:       {current_fat:.1f} lbs ({current_fat - fat_mass:+.1f} lbs net)")
    print(f"End BF %:      {(current_fat / tissue_w) * 100:.1f}%")
    print(f"Catabolized:   {total_catabolized:.2f} lbs (Starvation)")
    if sleep_deficit > 0: print(f"⚠️ SLEEP PENALTY ACTIVE: -{sleep_deficit*0.275*100:.0f}% Fat Ox, -{sleep_deficit*0.2*100:.0f}% MPS")
    if RT_DAYS_CUT < 2 or RT_DAYS_REFEED < 2: print("⚠️ DISUSE ATROPHY MODEL ACTIVE")
    print(f"TDEE Shift:    {initial_tdee:.0f} -> {final_tdee:.0f} kcal/day")
    print("="*50)

if __name__ == "__main__":
    run_simulation()
