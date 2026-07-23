import datetime
import json
import os

# ==========================================
# 1. EDIT YOUR METRICS HERE
# ==========================================
STARTING_WEIGHT_LBS = 157.0
STARTING_BODY_FAT_PERCENT = 32.0  # e.g., 32.0 for 32%

# ==========================================
# 2. EDIT YOUR PLAN TIMELINE HERE
# ==========================================
START_DATE = datetime.date(2026, 7, 27)
TARGET_DATE = datetime.date(2026, 12, 17)

# ==========================================
# 3. EDIT YOUR NUTRITION / ACTIVITY HERE
# ==========================================
# 1.45 = Moderately Active (Accounts for 6 days of gym/LISS but assumes a sedentary desk job for the other 22 hours of the day)
ACTIVITY_MULTIPLIER = 1.45

# Restore dynamic loading from JSON
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
with open(os.path.join(BASE_DIR, 'mynutrition.json'), 'r') as f:
    cut_data = json.load(f)
    CUT_WEEK_CALORIES = cut_data['weeklyTotals']['Calories'] / 7.0

with open(os.path.join(BASE_DIR, 'myrefeednutrition.json'), 'r') as f:
    refeed_data = json.load(f)
    REFEED_WEEK_CALORIES = refeed_data['weeklyTotals']['Calories'] / 7.0

# ==========================================
# SIMULATION LOGIC (DO NOT EDIT BELOW)
# ==========================================
def run_simulation():
    days = (TARGET_DATE - START_DATE).days
    
    fat_mass = STARTING_WEIGHT_LBS * (STARTING_BODY_FAT_PERCENT / 100.0)
    lean_mass = STARTING_WEIGHT_LBS - fat_mass
    
    current_fat = fat_mass
    current_lean = lean_mass
    
    initial_tdee = 0.0
    final_tdee = 0.0
    total_muscle_catabolized = 0.0
    
    for day in range(days):
        current_weight = current_fat + current_lean
        current_bf_pct = (current_fat / current_weight) * 100.0
        
        # Week 1 starts on July 27
        week_num = day // 7
        
        # 5 weeks cut, 1 week refeed
        is_refeed = (week_num % 6 == 5)
        daily_intake = REFEED_WEEK_CALORIES if is_refeed else CUT_WEEK_CALORIES
        
        # 1. Dynamic BMR (Katch-McArdle estimate based on Lean Body Mass)
        lean_kg = current_lean / 2.20462
        rmr = 370 + (21.6 * lean_kg)
        
        # 2. Adaptive Thermogenesis (Metabolic Adaptation)
        weight_scaling = (current_weight / STARTING_WEIGHT_LBS) ** 0.55
        
        # FIX 4: Refeed Hormonal Bounce-Back (Leptin & T3 temporarily soften adaptive thermogenesis)
        if is_refeed:
            weight_scaling = 1.0 - ((1.0 - weight_scaling) * 0.5)
            
        tdee = (rmr * ACTIVITY_MULTIPLIER) * weight_scaling
        
        if day == 0:
            initial_tdee = tdee
        if day == days - 1:
            final_tdee = tdee
            
        deficit = tdee - daily_intake
        
        # 3. Dynamic Recomp Rate with Diminishing Returns
        bf_factor = max(0.0, (current_bf_pct - 12.0) / (STARTING_BODY_FAT_PERCENT - 12.0))
        daily_muscle_gain = (0.15 / 7.0) * bf_factor
        
        # 4. Caloric Cost of Muscle Synthesis (~2,500 kcal/lb of muscle synthesized)
        muscle_energy_cost = daily_muscle_gain * 2500.0
        
        # Net energy remaining for fat loss after paying muscle synthesis cost
        net_fat_deficit = deficit - muscle_energy_cost
        
        # FIX 3: Alpert's Max Fat Oxidation Capacity (Max ~31 kcal per lb of body fat per day)
        # If deficit > max fat oxidation rate, fat cannot supply all energy -> rest comes from muscle catabolism
        max_fat_oxidation_kcal = current_fat * 31.0
        
        if net_fat_deficit > max_fat_oxidation_kcal:
            energy_shortfall = net_fat_deficit - max_fat_oxidation_kcal
            fat_lost_lbs = max_fat_oxidation_kcal / 3500.0
            muscle_lost_lbs = energy_shortfall / 2500.0
            current_lean -= muscle_lost_lbs
            total_muscle_catabolized += muscle_lost_lbs
        else:
            # FIX 1: Allow negative deficit (surplus) to correctly add fat mass
            fat_lost_lbs = net_fat_deficit / 3500.0
            
        # Update body composition
        current_fat -= fat_lost_lbs
        current_lean += daily_muscle_gain
        
    current_weight = current_fat + current_lean
    ending_bf_pct = (current_fat / current_weight) * 100.0

    print("="*55)
    print(f"PROJECTION FOR: {TARGET_DATE.strftime('%B %d, %Y')} ({days} days)")
    print("="*55)
    print(f"Starting Weight:         {STARTING_WEIGHT_LBS:.1f} lbs ({STARTING_BODY_FAT_PERCENT:.1f}% BF)")
    print(f"Ending Weight:           {current_weight:.1f} lbs")
    print(f"Ending Lean Mass:        {current_lean:.1f} lbs (+{current_lean - lean_mass:.1f} lbs net muscle)")
    print(f"Ending Fat Mass:         {current_fat:.1f} lbs (-{fat_mass - current_fat:.1f} lbs fat)")
    print(f"Ending Body Fat %:       {ending_bf_pct:.1f}%")
    print(f"Muscle Catabolized:      {total_muscle_catabolized:.2f} lbs")
    print("-" * 55)
    print(f"Initial Start TDEE:      {initial_tdee:.0f} kcal/day")
    print(f"Final Adapted TDEE:      {final_tdee:.0f} kcal/day")
    print(f"Cut Daily Intake:        {CUT_WEEK_CALORIES:.0f} kcal/day")
    print(f"Refeed Daily Intake:     {REFEED_WEEK_CALORIES:.0f} kcal/day")
    print("-" * 55)
    print("💡 NOTE ON SCALE WEIGHT (FIX 2): Expect initial 2-4 lbs drop in week 1")
    print("   from glycogen/water depletion, and +2-4 lbs temporary scale spike")
    print("   during refeed week as muscle glycogen & water replenish.")
    print("="*55)

if __name__ == "__main__":
    run_simulation()

