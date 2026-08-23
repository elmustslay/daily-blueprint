/// Generates a 7-day templated simulation_ui_template.txt with inline
/// variable expressions, and verifies equivalence with the old output.
///
/// Variables: isRefeedWeek, isWinter, isAshwagandhaOff, isNextWeekRefeedWeek
///
/// Template syntax:
///   {{#if VAR}}line{{/if}}              — line only when VAR is true
///   {{#if !VAR}}line{{/if}}             — line only when VAR is false
///   {{VAR ? "trueVal" : "falseVal"}}    — inline substitution

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/daily_plan/data/daily_plan_data.dart';

// ── Diff utilities ──────────────────────────────────────────

enum _DiffOp { keep, onlyA, onlyB }

class _DiffEntry {
  final _DiffOp op;
  final String? aLine, bLine;
  _DiffEntry(this.op, {this.aLine, this.bLine});
}

List<_DiffEntry> _computeDiff(List<String> a, List<String> b) {
  final m = a.length, n = b.length;
  final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));
  for (int i = 1; i <= m; i++) {
    for (int j = 1; j <= n; j++) {
      dp[i][j] = a[i - 1] == b[j - 1]
          ? dp[i - 1][j - 1] + 1
          : (dp[i - 1][j] > dp[i][j - 1] ? dp[i - 1][j] : dp[i][j - 1]);
    }
  }
  final result = <_DiffEntry>[];
  int i = m, j = n;
  while (i > 0 || j > 0) {
    if (i > 0 && j > 0 && a[i - 1] == b[j - 1]) {
      result.add(_DiffEntry(_DiffOp.keep, aLine: a[i - 1]));
      i--;
      j--;
    } else if (j > 0 && (i == 0 || dp[i][j - 1] >= dp[i - 1][j])) {
      result.add(_DiffEntry(_DiffOp.onlyB, bLine: b[j - 1]));
      j--;
    } else {
      result.add(_DiffEntry(_DiffOp.onlyA, aLine: a[i - 1]));
      i--;
    }
  }
  return result.reversed.toList();
}

// ── Patch ───────────────────────────────────────────────────

class _Patch {
  final String variable;
  final Set<int> deleted; // baseline indices removed when var=true
  final Map<int, String> replaced; // baseline idx → variant text
  final Map<int, List<String>> insertions; // after baseline idx (-1=before first)

  _Patch(this.variable)
      : deleted = {},
        replaced = {},
        insertions = {};

  bool get isEmpty => deleted.isEmpty && replaced.isEmpty && insertions.isEmpty;
}

String _commonPrefix(String a, String b) {
  int i = 0;
  while (i < a.length && i < b.length && a[i] == b[i]) i++;
  return a.substring(0, i);
}

String _commonSuffix(String a, String b) {
  int ai = a.length - 1, bi = b.length - 1;
  int count = 0;
  while (ai >= 0 && bi >= 0 && a[ai] == b[bi]) {
    ai--;
    bi--;
    count++;
  }
  return a.substring(a.length - count);
}

bool _isSimilar(String a, String b) {
  if (a == b) return true;
  final p = _commonPrefix(a, b);
  if (p.length >= 5) return true;
  final shorter = a.length < b.length ? a.length : b.length;
  return shorter > 0 && p.length > shorter * 0.3;
}

_Patch _buildPatch(List<String> baseline, List<String> variant, String variable) {
  final diff = _computeDiff(baseline, variant);
  final patch = _Patch(variable);
  int baseIdx = -1;
  int i = 0;
  while (i < diff.length) {
    if (diff[i].op == _DiffOp.keep) {
      baseIdx++;
      i++;
    } else {
      final onlyAs = <MapEntry<int, String>>[];
      final onlyBs = <String>[];
      while (i < diff.length && diff[i].op != _DiffOp.keep) {
        if (diff[i].op == _DiffOp.onlyA) {
          baseIdx++;
          onlyAs.add(MapEntry(baseIdx, diff[i].aLine!));
        } else {
          onlyBs.add(diff[i].bLine!);
        }
        i++;
      }
      int paired = 0;
      final limit = onlyAs.length < onlyBs.length ? onlyAs.length : onlyBs.length;
      for (int p = 0; p < limit; p++) {
        if (_isSimilar(onlyAs[p].value, onlyBs[p])) {
          patch.replaced[onlyAs[p].key] = onlyBs[p];
          paired++;
        } else {
          break;
        }
      }
      for (int p = paired; p < onlyAs.length; p++) {
        patch.deleted.add(onlyAs[p].key);
      }
      final insIdx = onlyAs.isNotEmpty ? onlyAs.last.key : baseIdx;
      for (int p = paired; p < onlyBs.length; p++) {
        patch.insertions.putIfAbsent(insIdx, () => []).add(onlyBs[p]);
      }
    }
  }
  return patch;
}

// ── Template generation ─────────────────────────────────────

String _makeSubstitution(String baseLine, String variantLine, String variable) {
  final prefix = _commonPrefix(baseLine, variantLine);
  final restA = baseLine.substring(prefix.length);
  final restB = variantLine.substring(prefix.length);
  final suffix = _commonSuffix(restA, restB);
  final aPart = restA.substring(0, restA.length - suffix.length);
  final bPart = restB.substring(0, restB.length - suffix.length);
  if (aPart.isEmpty && bPart.isEmpty) return baseLine;

  final commonLen = prefix.length + suffix.length;
  final avgLen = (baseLine.length + variantLine.length) / 2;
  if (avgLen > 0 && commonLen / avgLen > 0.3 && (prefix.isNotEmpty || suffix.isNotEmpty)) {
    return '$prefix{{$variable ? "$bPart" : "$aPart"}}$suffix';
  }
  return '{{$variable ? "$variantLine" : "$baseLine"}}';
}

List<String> _mergePatches(List<String> baseline, List<_Patch> patches) {
  final tpl = <String>[];

  for (final p in patches) {
    if (p.insertions.containsKey(-1)) {
      for (final l in p.insertions[-1]!) {
        tpl.add('{{#if ${p.variable}}}$l{{/if}}');
      }
    }
  }

  for (int idx = 0; idx < baseline.length; idx++) {
    final line = baseline[idx];
    _Patch? delP, repP;
    String? repText;
    for (final p in patches) {
      if (p.deleted.contains(idx)) { delP = p; break; }
      if (p.replaced.containsKey(idx)) { repP = p; repText = p.replaced[idx]; break; }
    }
    if (delP != null) {
      tpl.add('{{#if !${delP.variable}}}$line{{/if}}');
    } else if (repP != null) {
      tpl.add(_makeSubstitution(line, repText!, repP.variable));
    } else {
      tpl.add(line);
    }
    for (final p in patches) {
      if (p.insertions.containsKey(idx)) {
        for (final ins in p.insertions[idx]!) {
          tpl.add('{{#if ${p.variable}}}$ins{{/if}}');
        }
      }
    }
  }
  return tpl;
}

// ── Template expansion (verification) ───────────────────────

List<String> _expandTemplate(List<String> lines, Map<String, bool> flags) {
  final result = <String>[];
  for (var line in lines) {
    // {{#if VAR}}text{{/if}} or {{#if !VAR}}text{{/if}}
    final cm = RegExp(r'^\{\{#if (!?)(\w+)\}\}(.*)\{\{/if\}\}$').firstMatch(line);
    if (cm != null) {
      final neg = cm.group(1) == '!';
      final v = cm.group(2)!;
      final txt = cm.group(3)!;
      final f = flags[v] ?? false;
      if (neg ? !f : f) result.add(txt);
      continue;
    }
    // Whole-line ternary: {{VAR ? "A" : "B"}}
    final wm = RegExp(r'^\{\{(\w+) \? "(.*)" : "(.*)"}}$').firstMatch(line);
    if (wm != null) {
      final v = wm.group(1)!;
      result.add((flags[v] ?? false) ? wm.group(2)! : wm.group(3)!);
      continue;
    }
    // Inline ternaries
    var processed = line;
    processed = processed.replaceAllMapped(
      RegExp(r'\{\{(\w+) \? "(.*?)" : "(.*?)"\}\}'),
      (m) => (flags[m.group(1)!] ?? false) ? m.group(2)! : m.group(3)!,
    );
    result.add(processed);
  }
  return result;
}

// ── Rendering ───────────────────────────────────────────────

List<String> _renderSchedule(String dayKey) {
  final schedule = DailyPlanData.schedules[dayKey] ?? [];
  final lines = <String>[];
  for (var item in schedule) {
    lines.add('[${item.time}] ${item.title}');
    for (var detail in item.details) {
      lines.add('  - $detail');
    }
  }
  return lines;
}

// ── Tests ───────────────────────────────────────────────────

void main() {
  final planStart = DailyPlanData.planStartDate; // 2026-07-27 (Mon)

  // Mock dates for each flag configuration:
  //   Baseline   (all false): Week 1  — Jul 27+
  //   Refeed     (isRefeedWeek=T):  Week 5  — day 28+
  //   AshOff     (isAshwagandhaOff=T): Week 9  — day 56+
  //   Winter     (isWinter=T):     Week 19 — day 126+  (Nov 30+)
  //   NextRefeed (isNextWeekRefeedWeek=T): Week 4  — day 21+
  DateTime _dateFor(String dayKey, int weekDayOffset) =>
      planStart.add(Duration(days: weekDayOffset));

  final dayKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  // Week offsets: each offset is the day-0 of that week (Monday) relative to planStart
  const baseWeekOff = 0;   // Week 1
  const refeedWeekOff = 28; // Week 5
  const ashOffWeekOff = 56; // Week 9
  const winterWeekOff = 126; // Week 19
  const nextRefeedWeekOff = 21; // Week 4

  test('Generate templated simulation_ui_template.txt', () async {
    final output = StringBuffer();
    output.writeln('# Daily Plan Template');
    output.writeln('#');
    output.writeln('# Variables: isRefeedWeek, isWinter, isAshwagandhaOff, isNextWeekRefeedWeek');
    output.writeln('#');
    output.writeln('# Syntax:');
    output.writeln('#   {{#if VAR}}line{{/if}}              - include line when VAR is true');
    output.writeln('#   {{#if !VAR}}line{{/if}}             - include line when VAR is false');
    output.writeln('#   {{VAR ? "trueText" : "falseText"}}  - inline substitution');
    output.writeln('');

    for (int d = 0; d < 7; d++) {
      final dayKey = dayKeys[d];
      final dayOffset = d; // 0=mon, 1=tue, ..., 6=sun

      // 1) Render baseline
      DailyPlanData.mockCurrentDate = _dateFor(dayKey, baseWeekOff + dayOffset);
      final baseline = _renderSchedule(dayKey);

      // 2) Build a patch for each variable
      final patches = <_Patch>[];

      // isRefeedWeek
      DailyPlanData.mockCurrentDate = _dateFor(dayKey, refeedWeekOff + dayOffset);
      var p = _buildPatch(baseline, _renderSchedule(dayKey), 'isRefeedWeek');
      if (!p.isEmpty) patches.add(p);

      // isWinter
      DailyPlanData.mockCurrentDate = _dateFor(dayKey, winterWeekOff + dayOffset);
      p = _buildPatch(baseline, _renderSchedule(dayKey), 'isWinter');
      if (!p.isEmpty) patches.add(p);

      // isAshwagandhaOff
      DailyPlanData.mockCurrentDate = _dateFor(dayKey, ashOffWeekOff + dayOffset);
      p = _buildPatch(baseline, _renderSchedule(dayKey), 'isAshwagandhaOff');
      if (!p.isEmpty) patches.add(p);

      // isNextWeekRefeedWeek
      DailyPlanData.mockCurrentDate = _dateFor(dayKey, nextRefeedWeekOff + dayOffset);
      p = _buildPatch(baseline, _renderSchedule(dayKey), 'isNextWeekRefeedWeek');
      if (!p.isEmpty) patches.add(p);

      // 3) Merge patches → template
      final templateLines = _mergePatches(baseline, patches);

      // 4) Write day section
      final activeVars = patches.map((p) => p.variable).toList();
      output.writeln('=== ${dayNames[d]} ===');
      if (activeVars.isNotEmpty) {
        output.writeln('[Active variables: ${activeVars.join(", ")}]');
      }
      for (final line in templateLines) {
        output.writeln(line);
      }
      output.writeln('');
    }

    DailyPlanData.mockCurrentDate = null;

    final file = File('outputs/simulation_ui_template.txt');
    await file.writeAsString(output.toString());
    print('✅ Generated outputs/simulation_ui_template.txt');
    expect(file.existsSync(), isTrue);
  });

  test('Verify template equivalence with old simulation output', () async {
    // ── Load template ──
    final templateFile = File('outputs/simulation_ui_template.txt');
    expect(templateFile.existsSync(), isTrue, reason: 'Run the generation test first');
    final templateText = await templateFile.readAsString();

    // Parse into per-day templates
    final dayTemplates = <String, List<String>>{};
    String? curDay;
    List<String> curLines = [];

    for (final line in templateText.split('\n')) {
      final hdr = RegExp(r'^=== (\w+) ===$').firstMatch(line);
      if (hdr != null) {
        if (curDay != null) dayTemplates[curDay!] = curLines;
        curDay = hdr.group(1)!.toLowerCase().substring(0, 3);
        curLines = [];
        continue;
      }
      if (line.startsWith('#') || line.startsWith('[Active variables:')) continue;
      if (curDay != null) curLines.add(line);
    }
    if (curDay != null) dayTemplates[curDay!] = curLines;

    // Trim leading/trailing blanks from each day template
    for (final k in dayTemplates.keys) {
      var ls = dayTemplates[k]!;
      while (ls.isNotEmpty && ls.first.trim().isEmpty) ls.removeAt(0);
      while (ls.isNotEmpty && ls.last.trim().isEmpty) ls.removeLast();
    }

    // ── Load old simulation ──
    final oldFile = File('outputs/simulation_ui_text.txt');
    expect(oldFile.existsSync(), isTrue);
    final oldText = await oldFile.readAsString();

    // Parse day blocks
    final blocks = <Map<String, dynamic>>[];
    final hdrRe = RegExp(r'=== Day (\d+): (\d{4})-(\d{2})-(\d{2}) \((\w+)\) \[Refeed: (\w+)\] ===');
    String? bDay;
    DateTime? bDate;
    StringBuffer bContent = StringBuffer();

    for (final line in oldText.split('\n')) {
      final m = hdrRe.firstMatch(line);
      if (m != null) {
        if (bDay != null) {
          blocks.add({'dayKey': bDay, 'date': bDate, 'content': bContent.toString()});
        }
        bDay = m.group(5);
        final dIndex = int.parse(m.group(1)!); bDate = DailyPlanData.planStartDate.add(Duration(days: dIndex));
        bContent = StringBuffer();
        continue;
      }
      if (bDay != null) bContent.writeln(line);
    }
    if (bDay != null) {
      blocks.add({'dayKey': bDay, 'date': bDate, 'content': bContent.toString()});
    }

    print('Verifying ${blocks.length} unique day blocks...');

    int verified = 0;
    for (final block in blocks) {
      final dayKey = block['dayKey'] as String;
      final date = block['date'] as DateTime;

      DailyPlanData.mockCurrentDate = date;
      final flags = {
        'isRefeedWeek': DailyPlanData.isRefeedWeek(),
        'isWinter': DailyPlanData.isWinter(),
        'isAshwagandhaOff': DailyPlanData.isAshwagandhaOff(),
        'isNextWeekRefeedWeek': DailyPlanData.isNextWeekRefeedWeek(),
      };

      final template = dayTemplates[dayKey];
      expect(template, isNotNull, reason: 'No template for $dayKey');

      final expanded = _expandTemplate(template!, flags);

      // Get old content lines (trimmed)
      var oldLines = (block['content'] as String).split('\n');
      while (oldLines.isNotEmpty && oldLines.last.trim().isEmpty) oldLines.removeLast();
      while (oldLines.isNotEmpty && oldLines.first.trim().isEmpty) oldLines.removeAt(0);

      var expLines = expanded.toList();
      while (expLines.isNotEmpty && expLines.last.trim().isEmpty) expLines.removeLast();
      while (expLines.isNotEmpty && expLines.first.trim().isEmpty) expLines.removeAt(0);

      // Compare
      final maxLen = oldLines.length > expLines.length ? oldLines.length : expLines.length;
      for (int l = 0; l < maxLen; l++) {
        final old = l < oldLines.length ? oldLines[l] : '<MISSING>';
        final exp = l < expLines.length ? expLines[l] : '<MISSING>';
        expect(exp, equals(old),
            reason: 'Line $l mismatch for $dayKey '
                '(${date.toString().substring(0, 10)}, flags=$flags)');
      }
      verified++;
    }

    DailyPlanData.mockCurrentDate = null;
    print('✅ Verified $verified unique day blocks match template expansion');

    // Also run the Python equivalence check
    print('Running Python equivalence check...');
    final result = await Process.run('python3', ['personal_py_simulation/expand_template.py']);
    if (result.exitCode != 0) {
      final fallback = await Process.run('python', ['personal_py_simulation/expand_template.py']);
      if (fallback.exitCode != 0) {
        print('❌ Python check failed: ${fallback.stdout}\n${fallback.stderr}');
        fail('Python equivalence check failed');
      } else {
        print(fallback.stdout.toString().trim());
      }
    } else {
      print(result.stdout.toString().trim());
    }
  });
}

