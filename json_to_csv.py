import json
import csv
import os

# Get the directory where the script is located
script_dir = os.path.dirname(os.path.abspath(__file__))
input_file = os.path.join(script_dir, "mynutrition.json")
output_file = os.path.join(script_dir, "mynutrition.csv")

def convert():
    if not os.path.exists(input_file):
        print(f"Error: {input_file} not found.")
        return

    with open(input_file, 'r') as f:
        data = json.load(f)

    # Extract metrics (Matching new Casing/Names)
    metrics = ["Calories", "Protein", "Carbs", "Fat"]
    
    # Safely get micros
    all_micros = set()
    if "weeklyTotals" in data and "Micros" in data["weeklyTotals"]:
        all_micros.update(data["weeklyTotals"]["Micros"].keys())
    
    if "dailyTotals" in data:
        for day in data["dailyTotals"]:
            if "Micros" in data["dailyTotals"][day]:
                all_micros.update(data["dailyTotals"][day]["Micros"].keys())

    sorted_micros = sorted(list(all_micros))
    all_metrics = metrics + sorted_micros

    days = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]
    header = ["Metric", "Weekly Total"] + [day.capitalize() for day in days]

    rows = []
    for metric in all_metrics:
        row = [metric]
        
        # Weekly total
        weekly = data.get("weeklyTotals", {})
        if metric in metrics:
            row.append(weekly.get(metric, 0))
        else:
            row.append(weekly.get("Micros", {}).get(metric, 0))
            
        # Daily totals
        for day in days:
            day_data = data.get("dailyTotals", {}).get(day, {})
            if metric in metrics:
                row.append(day_data.get(metric, 0))
            else:
                row.append(day_data.get("Micros", {}).get(metric, 0))
        
        rows.append(row)

    with open(output_file, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(header)
        writer.writerows(rows)

    print(f"Success: Spreadsheet updated at {output_file}")

if __name__ == "__main__":
    convert()
