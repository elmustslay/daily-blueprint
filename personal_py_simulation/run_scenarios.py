import sys
import os
import io
import contextlib

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, SCRIPT_DIR)

def simulate(weight_change, bf_change, schedule_name, week3_def, week4_def, week6_def):
    with open(os.path.join(SCRIPT_DIR, 'body_fat_calculator.py'), 'r') as f:
        code = f.read()
    
    logic = f"""
        week = day // 7
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
        carb = max(0, carb - (daily_cal_deficit / 4.0))
        
        sodium = day_info.get('sodium', 0.0) + ov.get('sodium', 0.0)
"""
    
    code = code.replace("""        sodium = day_info.get('sodium', 0.0) + ov.get('sodium', 0.0)""", logic)
            
    with open(os.path.join(SCRIPT_DIR, 'grid_sim_new.py'), 'w') as f:
        f.write(code)
        
    f = io.StringIO()
    with contextlib.redirect_stdout(f):
        import grid_sim_new
        import importlib
        importlib.reload(grid_sim_new)
        grid_sim_new.run_simulation(weight_change=weight_change, bf_change=bf_change)
        
    return f.getvalue()

scenarios = [
    ("Most-Likely", -4.0, -3.8),
    ("Optimistic", -4.0, -4.7)
]

schedules = [
    ("Option 1 (Baseline Now)", 0, 0, 0),
    ("New Option: -3 Bananas for Week 3 and 4", 315, 315, 0),
]

for s_name, wc, bfc in scenarios:
    print(f"\\n=== {s_name} ===")
    for sched_name, w3, w4, w6 in schedules:
        print(f"\\n{sched_name}:")
        out = simulate(wc, bfc, sched_name, w3, w4, w6)
        for line in out.split('\\n'):
            if "End Lean:" in line or "End Fat:" in line or "Catabolized:" in line or "End BF %" in line:
                print(line)

