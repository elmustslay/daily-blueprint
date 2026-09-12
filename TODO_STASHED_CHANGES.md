# 🔒 Stashed Changes — Integrate Later

> **Created**: September 5, 2026
> **When to integrate**: After finishing the Cluster Dextrin research/decision

## How to retrieve

```bash
git stash list          # Find the stash (should be stash@{0})
git stash pop           # Apply and remove from stash
# OR
git stash apply         # Apply but keep in stash as backup
```

## What's in the stash

These changes were staged on `main` and stashed before the strikethrough-bullet-points feature was added.

### Summary of changes:
1. **Cluster Dextrin removal from defaults** — `commuteToGymNutrition` no longer includes `NutritionAddOn.dextrin` by default
2. **`isResistanceDay` flag** — New parameter on `_commuteToGym()` replacing the implicit `withDextrin` logic for determining resistance vs LISS days
3. **Banana count adjustments** — 2 bananas for resistance days, 1 for LISS (refeed gets bananas regardless)
4. **Lite Salt dosage** — Changed from 0.5 tsp to 0.55 tsp, now tied to `isResistanceDay` instead of `withDextrin`
5. **Pre-workout text update** — "literally right before walking out the door (digests during commute)"
6. **Lunch banana addition** — 2 medium bananas added to refeed lunch
7. **Kiwi count adjustments** — Tuesday kiwi changed from 2→1, Wednesday kiwi changed to 2
8. **Sunday chores kiwi removal** — Removed conditional kiwi text from Sunday
9. **Saturday LISS `isResistanceDay: false`** — Properly flagged
10. **`temp_sim.py` deleted** — Removed temporary simulation script
11. **Nutrition output files updated** — All JSON/CSV outputs regenerated
12. **Shopping list updated** — Reflects ingredient changes

### Files changed:
- `lib/features/daily_plan/data/daily_plan_data.dart`
- `lib/features/shopping_list/presentation/shopping_list_screen.dart`
- `outputs/` (multiple nutrition JSON/CSV files)
- `personal_py_simulation/temp_sim.py` (deleted)
- `test/daily_plan_data_test.dart`
- `test/shopping_list_ui_match_test.dart`
