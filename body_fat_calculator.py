import datetime, json, os

START_DATE = datetime.date(2026, 7, 27)
TARGET_DATE = datetime.date(2026, 12, 17)

STARTING_WEIGHT = 157.0
STARTING_BF_PCT = 31.2

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

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
with open(os.path.join(BASE_DIR, 'mynutrition.json'), 'r') as f: cut_data = json.load(f)
with open(os.path.join(BASE_DIR, 'myrefeednutrition.json'), 'r') as f: ref_data = json.load(f)
DAYS = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']

def get_macros(is_ref, day_str):
    d = (ref_data if is_ref else cut_data)['dailyTotals'][day_str]
    ov = globals().get('OVERRIDES', {}).get('ref' if is_ref else 'cut', {})
    val = lambda k, fk: ov.get(k) if ov.get(k) is not None else d[fk]
    return (val('cal','Calories'), val('prot','Protein'), val('carb','Carbs'), val('fat','Fat'), RT_DAYS_REFEED if is_ref else RT_DAYS_CUT)

def run_simulation():
    days = (TARGET_DATE - START_DATE).days
    fat_mass = STARTING_WEIGHT * (STARTING_BF_PCT / 100.0)
    lean_mass = STARTING_WEIGHT - fat_mass
    current_fat, current_lean = fat_mass, lean_mass
    current_glycogen = 500.0
    total_catabolized = 0.0
    
    for day in range(days):
        current_weight = current_fat + current_lean
        current_bf = (current_fat / current_weight) * 100.0
        is_ref = (day // 7 % 6 == 5)
        
        cal, prot, carb, fat, rt = get_macros(is_ref, DAYS[(START_DATE.weekday() + day) % 7])
        
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
            muscle_gain = (0.15 / 7.0) * bf_factor * p_factor * (rt / 4.0)
        else:
            muscle_atrophy = (2.0 - rt) * 0.02 # Lose ~0.04 lbs/day at 0 RT days
        
        # Energy math (building muscle costs energy, atrophying muscle yields energy)
        net_fat_deficit = deficit - (muscle_gain * 2500.0) + (muscle_atrophy * 2500.0)
        max_ox = current_fat * 31.0
        
        # Starvation Shutoff
        if net_fat_deficit > max_ox:
            muscle_gain = 0.0
            net_fat_deficit = deficit + (muscle_atrophy * 2500.0)
            catabolized = (net_fat_deficit - max_ox) / 2500.0
            
            fat_lost = max_ox / 3500.0
            total_catabolized += catabolized
            current_lean -= catabolized
        else:
            fat_lost = net_fat_deficit / 3500.0
            
        current_fat -= fat_lost
        current_lean += muscle_gain - muscle_atrophy
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
    if RT_DAYS_CUT < 2 or RT_DAYS_REFEED < 2: print("⚠️ DISUSE ATROPHY MODEL ACTIVE")
    print(f"TDEE Shift:    {initial_tdee:.0f} -> {final_tdee:.0f} kcal/day")
    print("="*50)

if __name__ == "__main__":
    run_simulation()
