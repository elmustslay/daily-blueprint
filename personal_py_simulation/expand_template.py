import json
import os
import re

def main():
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    template_path = os.path.join(base_dir, 'outputs', 'simulation_ui_template.txt')
    timeline_path = os.path.join(base_dir, 'outputs', 'simulation_timeline.json')
    original_txt_path = os.path.join(base_dir, 'outputs', 'simulation_ui_text.txt')

    if not os.path.exists(template_path):
        print("Error: simulation_ui_template.txt not found.")
        exit(1)
    if not os.path.exists(timeline_path):
        print("Error: simulation_timeline.json not found.")
        exit(1)
    if not os.path.exists(original_txt_path):
        print("Error: simulation_ui_text.txt not found.")
        exit(1)

    with open(template_path, 'r', encoding='utf-8') as f:
        template_text = f.read()

    with open(timeline_path, 'r', encoding='utf-8') as f:
        timeline = json.load(f)

    with open(original_txt_path, 'r', encoding='utf-8') as f:
        original_text = f.read()

    # Parse template per day
    day_templates = {}
    current_day = None
    current_lines = []

    for line in template_text.split('\n'):
        hdr_match = re.match(r'^=== (\w+) ===$', line)
        if hdr_match:
            if current_day:
                day_templates[current_day] = current_lines
            current_day = hdr_match.group(1).lower()[:3]
            current_lines = []
            continue
        if line.startswith('#') or line.startswith('[Active variables:'):
            continue
        if current_day:
            current_lines.append(line)
    
    if current_day:
        day_templates[current_day] = current_lines

    # Trim empty lines at start/end
    for k in day_templates:
        ls = day_templates[k]
        while ls and not ls[0].strip():
            ls.pop(0)
        while ls and not ls[-1].strip():
            ls.pop()

    # Regexes for template expressions
    cond_line_re = re.compile(r'^\{\{#if (!?)(\w+)\}\}(.*)\{\{/if\}\}$')
    whole_ternary_re = re.compile(r'^\{\{(\w+) \? "(.*)" : "(.*)"\}\}$')
    inline_ternary_re = re.compile(r'\{\{(\w+) \? "(.*?)" : "(.*?)"\}\}')

    def expand_template(lines, flags):
        result = []
        for line in lines:
            cm = cond_line_re.match(line)
            if cm:
                neg = (cm.group(1) == '!')
                var = cm.group(2)
                txt = cm.group(3)
                f = flags.get(var, False)
                if (not f) if neg else f:
                    result.append(txt)
                continue
            
            wm = whole_ternary_re.match(line)
            if wm:
                var = wm.group(1)
                f = flags.get(var, False)
                result.append(wm.group(2) if f else wm.group(3))
                continue
            
            def replace_inline(m):
                var = m.group(1)
                f = flags.get(var, False)
                return m.group(2) if f else m.group(3)

            processed = inline_ternary_re.sub(replace_inline, line)
            result.append(processed)
        return result

    # Expand for each day in timeline and keep unique content
    unique_contents = set()
    output_blocks = []

    for day_data in timeline:
        d = day_data['day']
        date_str = day_data['date']
        day_key = day_data['dayName']
        is_refeed = str(day_data.get('isRefeedWeek', False)).lower() == 'true'
        flags = {
            'isRefeedWeek': day_data.get('isRefeedWeek', False),
            'isWinter': day_data.get('isWinter', False),
            'isAshwagandhaOff': day_data.get('isAshwagandhaOff', False),
            'isNextWeekRefeedWeek': day_data.get('isNextWeekRefeedWeek', False),
        }

        template_lines = day_templates.get(day_key)
        if not template_lines:
            continue

        expanded = expand_template(template_lines, flags)
        
        # Trim expanded lines
        while expanded and not expanded[0].strip():
            expanded.pop(0)
        while expanded and not expanded[-1].strip():
            expanded.pop()

        content_str = '\n'.join(expanded) + '\n'
        
        if content_str not in unique_contents:
            unique_contents.add(content_str)
            
            header = f"=== Day {d}: {date_str} ({day_key}) [Refeed: {str(is_refeed).lower()}] ==="
            output_blocks.append(header)
            output_blocks.append(content_str)

    expanded_full_text = '\n'.join(output_blocks).strip()
    original_text_stripped = original_text.strip()
    
    if expanded_full_text == original_text_stripped:
        print("✅ Equivalence check passed! Python expansion of the template matches simulation_ui_text.txt exactly.")
        exit(0)
    else:
        print("❌ Equivalence check failed! The Python expanded template does NOT match simulation_ui_text.txt.")
        # Create a file for the diff/expanded to help debug
        with open(os.path.join(base_dir, 'outputs', 'simulation_ui_expanded_fail.txt'), 'w', encoding='utf-8') as f:
            f.write(expanded_full_text + '\n')
        print("Wrote the failed expansion to outputs/simulation_ui_expanded_fail.txt for debugging.")
        exit(1)

if __name__ == '__main__':
    main()
