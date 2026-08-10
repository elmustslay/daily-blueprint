import sys
import os
import io
import contextlib

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, SCRIPT_DIR)
import temp_sim

def simulate(weight_change, bf_change, schedule_name, week3_def, week4_def, week6_def):
    with open(os.path.join(SCRIPT_DIR, 'temp_sim.py'), 'r') as f:
        code = f.read()
    
    logic = f"""
        week = day // 7
        # baseline macros are already parsed
        if week < 2:
            daily_cal_deficit = 1278.0 / 7.0
        elif week == 2:
            daily_cal_deficit = {week3_def} / 7.0
        elif week == 3:
            daily_cal_deficit = {week4_def} / 7.0
        elif day_info['isRefeed']:
            daily_cal_deficit = 0.0
        elif week >= 5:
            daily_cal_deficit = {week6_def} / 7.0
        else:
            daily_cal_deficit = 0.0

        logged_cal = max(0, logged_cal - daily_cal_deficit)
        carb = max(0, carb - (daily_cal_deficit / 4.0)) # assume carb deficit
"""
    
    # replace the old banana logic
    code = code.replace("""        # progressive banana logic
        week = day // 7
        if week < 3:
            banana_deficit_per_week = 7
        elif week < 6:
            banana_deficit_per_week = 3
        else:
            banana_deficit_per_week = 0

        # Subtract macros for missing bananas
        daily_banana_deficit = banana_deficit_per_week / 7.0
        
        logged_cal = max(0, logged_cal - (daily_banana_deficit * 105.0))
        prot = max(0, prot - (daily_banana_deficit * 1.3))
        carb = max(0, carb - (daily_banana_deficit * 27.0))
        fat = max(0, fat - (daily_banana_deficit * 0.3))""", logic)
            
    with open(os.path.join(SCRIPT_DIR, 'grid_sim.py'), 'w') as f:
        f.write(code)
        
    f = io.StringIO()
    with contextlib.redirect_stdout(f):
        import grid_sim
        import importlib
        importlib.reload(grid_sim)
        grid_sim.run_simulation(weight_change=weight_change, bf_change=bf_change)
        
    return f.getvalue()

scenarios = [
    ("Most-Likely", -4.0, -3.8),
    ("Optimistic", -4.0, -4.7)
]

schedules = [
    ("A: Push Aggressive (-1278 for 4 weeks)", 1278, 1278, 0),
    ("B: Baseline Now (0 deficit)", 0, 0, 0),
    ("C: Taper down (-600 then -300)", 600, 300, 0),
]

for s_name, wc, bfc in scenarios:
    print(f"\\n=== {s_name} ===")
    for sched_name, w3, w4, w6 in schedules:
        print(f"\\n{sched_name}:")
        out = simulate(wc, bfc, sched_name, w3, w4, w6)
        for line in out.split('\\n'):
            if "End Lean:" in line or "End Fat:" in line or "Catabolized:" in line:
                print(line)

