import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/tigrinya_drills_data.dart';
import '../data/mastery_provider.dart';
import '../data/srs_storage.dart';
import '../domain/tigrinya_models.dart';
import '../domain/drill_engine.dart';
import 'tigrinya_drill_screen.dart';
import 'word_bank_screen.dart';
import 'srs_review_screen.dart';
import 'integration_drill_screen.dart';

class LearnTigranyaScreen extends ConsumerWidget {
  const LearnTigranyaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(masteryProvider);
    final modules = TigrinyaDrillsData.modules;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn Tigranya'),
        actions: [
          IconButton(
            icon: Icon(
              MasteryStorage.auditorMode
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: MasteryStorage.auditorMode
                  ? Colors.amberAccent
                  : null,
            ),
            tooltip: MasteryStorage.auditorMode
                ? 'Auditor Mode ON — tap to lock'
                : 'Auditor Mode — tap to unlock all',
            onPressed: () async {
              await MasteryStorage.setAuditorMode(!MasteryStorage.auditorMode);
              ref.invalidate(masteryProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu_book_rounded),
            tooltip: 'Word Bank',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WordBankScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_backup_restore_rounded),
            tooltip: 'Reset All Progress',
            onPressed: () => _showResetDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, ref),
          _buildDailyReviewCard(context),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: modules.length,
              itemBuilder: (context, index) {
                final module = modules[index];
                final isUnlocked =
                    MasteryStorage.isModuleUnlocked(index, modules);

                return _buildModuleCard(
                  context,
                  ref,
                  module: module,
                  index: index,
                  isUnlocked: isUnlocked,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset All Progress?'),
        content: const Text('This will delete all mastery data, SRS review history, and chunk progress. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              ref.read(masteryProvider.notifier).resetAllProgress();
              Navigator.of(ctx).pop();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final showFemPlural = MasteryStorage.showFemininePlurals;
    return Container(
      color: Colors.lightBlueAccent.withValues(alpha: 0.08),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'ትግሪኛ ንመሃር ',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlueAccent),
              ),
              GestureDetector(
                onTap: () async {
                  await MasteryStorage.setFemininePlurals(!showFemPlural);
                  ref.invalidate(masteryProvider);
                },
                child: RotatedBox(
                  quarterTurns: showFemPlural ? 2 : 0,
                  child: const Text('💊', style: TextStyle(fontSize: 22)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Master pronouns, then verbs one-by-one. 85% unlocks the next stage.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDailyReviewCard(BuildContext context) {
    final dueCount = SrsStorage.getDueCardCount();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SrsReviewScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purpleAccent.withValues(alpha: 0.15),
              Colors.deepPurpleAccent.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.purpleAccent.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.psychology_rounded, color: Colors.purpleAccent, size: 22),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Review',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    dueCount > 0
                        ? '$dueCount card${dueCount == 1 ? '' : 's'} due for review'
                        : 'All caught up!',
                    style: const TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                ],
              ),
            ),
            if (dueCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.purpleAccent.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$dueCount',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
            else
              const Icon(Icons.check_circle_outline_rounded, color: Colors.greenAccent, size: 22),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context,
    WidgetRef ref, {
    required DrillModule module,
    required int index,
    required bool isUnlocked,
  }) {
    final cardColor = isUnlocked
        ? Theme.of(context).cardColor
        : Theme.of(context).cardColor.withValues(alpha: 0.5);

    // Check if fully mastered (all 5 tenses typing passed, or just present for single-tense modules)
    final singleTenseTypes = {
      DrillModuleType.pronoun, DrillModuleType.questionWord, DrillModuleType.number,
      DrillModuleType.time, DrillModuleType.greeting, DrillModuleType.possession,
      DrillModuleType.adjective, DrillModuleType.demonstrative, DrillModuleType.family,
      DrillModuleType.preposition, DrillModuleType.phrase, DrillModuleType.possessivePronoun,
      DrillModuleType.compoundSubject, DrillModuleType.identityToBe, DrillModuleType.emotion,
      DrillModuleType.withConstruction, DrillModuleType.questionWordBasic, DrillModuleType.integration,
    };
    bool isFullyMastered = false;
    if (isUnlocked) {
      if (module.type == DrillModuleType.integration) {
        // Integration modules pass when selfGrade stage >= 85%
        isFullyMastered = MasteryStorage.getMastery(module.id, Tense.present, DrillStage.selfGrade) >= 0.85;
      } else if (singleTenseTypes.contains(module.type)) {
        isFullyMastered = MasteryStorage.isTypingPassed(module.id, Tense.present);
      } else {
        isFullyMastered = Tense.values.every((t) => MasteryStorage.isTypingPassed(module.id, t));
      }
    }

    final isIntegration = module.type == DrillModuleType.integration;
    final accentColor = isIntegration ? Colors.deepPurpleAccent : Colors.lightBlueAccent;

    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isIntegration && isUnlocked
              ? Colors.deepPurpleAccent.withValues(alpha: 0.06)
              : cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnlocked
                ? (isFullyMastered
                    ? Colors.greenAccent.withValues(alpha: 0.6)
                    : isIntegration
                        ? Colors.deepPurpleAccent.withValues(alpha: 0.4)
                        : Theme.of(context).dividerColor)
                : Theme.of(context).dividerColor.withValues(alpha: 0.3),
            width: isFullyMastered ? 1.5 : isIntegration ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Module Header ──
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? accentColor.withValues(alpha: 0.15)
                          : Colors.grey.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isUnlocked
                          ? (isIntegration
                              ? Icon(Icons.extension_rounded, size: 18, color: accentColor)
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: accentColor,
                                    fontSize: 16,
                                  ),
                                ))
                          : const Icon(Icons.lock_rounded,
                              size: 18, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          module.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isUnlocked ? Colors.white : Colors.white54,
                          ),
                        ),
                        Text(
                          module.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: isUnlocked ? Colors.white70 : Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isUnlocked && isFullyMastered)
                    const Icon(Icons.emoji_events_rounded,
                        color: Colors.amberAccent, size: 24),
                ],
              ),

              if (isUnlocked) ...[
                const SizedBox(height: 14),

                // Integration module: special rendering
                if (module.type == DrillModuleType.integration) ...[
                  _buildIntegrationContent(context, ref, module, isFullyMastered),
                ] else ...[

                // Chunk progress indicator for chunked modules
                if (DrillEngine.getTotalChunks(module.type) > 1) ...[
                  Builder(builder: (context) {
                    final totalChunks = DrillEngine.getTotalChunks(module.type);
                    final mcqDone = ChunkStorage.getChunksCompleted(module.id, DrillStage.mcq);
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.view_module_rounded, size: 14, color: Colors.white54),
                          const SizedBox(width: 6),
                          Text(
                            'Chunk ${mcqDone < totalChunks ? mcqDone + 1 : totalChunks} of $totalChunks',
                            style: const TextStyle(fontSize: 11, color: Colors.white54),
                          ),
                          const SizedBox(width: 8),
                          ...List.generate(totalChunks, (i) {
                            return Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i < mcqDone
                                    ? Colors.greenAccent
                                    : i == mcqDone
                                        ? Colors.amberAccent
                                        : Colors.white24,
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                ],
                if (singleTenseTypes.contains(module.type))
                  _buildTenseRow(context, ref, module, Tense.present, "Standard")
                else ...[ 
                  // Progressive tense gating: only show next tense after passing typing on the previous
                  for (int ti = 0; ti < Tense.values.length; ti++) ...[
                    if (ti == 0 || MasteryStorage.isTypingPassed(module.id, Tense.values[ti - 1]))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildTenseRow(context, ref, module, Tense.values[ti], Tense.values[ti].name),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Opacity(
                          opacity: 0.4,
                          child: Row(
                            children: [
                              const Icon(Icons.lock_outline_rounded, size: 16, color: Colors.white38),
                              const SizedBox(width: 8),
                              Text(
                                '${Tense.values[ti].name} — pass ${Tense.values[ti - 1].name} typing first',
                                style: const TextStyle(fontSize: 13, color: Colors.white38),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ],

                if (isFullyMastered) ...[
                   const SizedBox(height: 8),
                   ElevatedButton.icon(
                     onPressed: () => _startReview(context, ref, module),
                     icon: const Icon(Icons.all_inclusive_rounded),
                     label: const Text('Endless Review'),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.indigoAccent,
                       minimumSize: const Size.fromHeight(40),
                     ),
                   ),
                ],
                ], // end else (non-integration)
              ],
              
              if (!isUnlocked && module.type == DrillModuleType.questionWord) ...[
                const SizedBox(height: 8),
                const Text(
                  'Requires 85% MCQ on Present & Past for all verbs.',
                  style: TextStyle(fontSize: 12, color: Colors.amberAccent),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTenseRow(
    BuildContext context,
    WidgetRef ref,
    DrillModule module,
    Tense tense,
    String label,
  ) {
    final isUnlocked = MasteryStorage.isTenseUnlocked(module.id, tense);
    if (!isUnlocked) {
       return Row(
         children: [
           const Icon(Icons.lock_outline, size: 14, color: Colors.white38),
           const SizedBox(width: 6),
           Text(
             '${label[0].toUpperCase()}${label.substring(1)} — Requires previous tense',
             style: const TextStyle(fontSize: 12, color: Colors.white38),
           ),
         ],
       );
    }

    final isTeachComplete = MasteryStorage.isTeachComplete(module.id, tense);
    final isMcqPassed = MasteryStorage.isMcqPassed(module.id, tense);
    final isTypingPassed = MasteryStorage.isTypingPassed(module.id, tense);
    
    final mcqMastery = MasteryStorage.getMastery(module.id, tense, DrillStage.mcq);
    final typingMastery = MasteryStorage.getMastery(module.id, tense, DrillStage.typing);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
             '${label[0].toUpperCase()}${label.substring(1)}',
             style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.lightBlueAccent),
           ),
           const SizedBox(height: 8),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               _buildStageIndicator(
                 context: context,
                 label: 'Teach',
                 icon: Icons.menu_book_rounded,
                 isUnlocked: true,
                 isComplete: isTeachComplete,
                 score: isTeachComplete ? 1.0 : 0.0,
                 onTap: () => _startDrill(context, ref, module, tense, DrillStage.teach),
               ),
               const Icon(Icons.arrow_right_alt_rounded, color: Colors.white24, size: 16),
               _buildStageIndicator(
                 context: context,
                 label: 'MCQ',
                 icon: Icons.touch_app_rounded,
                 isUnlocked: isTeachComplete,
                 isComplete: isMcqPassed,
                 score: mcqMastery,
                 onTap: () => _startDrill(context, ref, module, tense, DrillStage.mcq),
               ),
               const Icon(Icons.arrow_right_alt_rounded, color: Colors.white24, size: 16),
               _buildStageIndicator(
                 context: context,
                 label: 'Type',
                 icon: Icons.keyboard_rounded,
                 isUnlocked: isMcqPassed,
                 isComplete: isTypingPassed,
                 score: typingMastery,
                 onTap: () => _startDrill(context, ref, module, tense, DrillStage.typing),
               ),
             ],
           ),
        ],
      ),
    );
  }

  Widget _buildStageIndicator({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isUnlocked,
    required bool isComplete,
    required double score,
    required VoidCallback onTap,
  }) {
    final color = isComplete 
        ? Colors.greenAccent 
        : (isUnlocked ? Colors.lightBlueAccent : Colors.white38);
        
    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Opacity(
        opacity: isUnlocked ? 1.0 : 0.5,
        child: Column(
          children: [
             Container(
               padding: const EdgeInsets.all(8),
               decoration: BoxDecoration(
                 color: color.withValues(alpha: 0.1),
                 shape: BoxShape.circle,
                 border: Border.all(color: color.withValues(alpha: 0.5)),
               ),
               child: Icon(isUnlocked ? icon : Icons.lock_rounded, size: 18, color: color),
             ),
             const SizedBox(height: 4),
             Text(
               label,
               style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
             ),
             if (isUnlocked && score > 0 && !isComplete)
               Text(
                 '${(score * 100).toInt()}%',
                 style: const TextStyle(fontSize: 9, color: Colors.white70),
               ),
          ],
        ),
      ),
    );
  }

  void _startDrill(BuildContext context, WidgetRef ref, DrillModule module,
      Tense tense, DrillStage stage) {
    if (module.type == DrillModuleType.integration) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => IntegrationDrillScreen(module: module),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TigrinyaDrillScreen(
            module: module,
            tense: tense,
            initialStage: stage,
          ),
        ),
      );
    }
  }

  Widget _buildIntegrationContent(BuildContext context, WidgetRef ref, DrillModule module, bool isFullyMastered) {
    final mastery = MasteryStorage.getMastery(module.id, Tense.present, DrillStage.selfGrade);
    final hasTried = mastery > 0;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.deepPurpleAccent.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.deepPurpleAccent.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(
                isFullyMastered ? Icons.check_circle_rounded : Icons.extension_rounded,
                size: 20,
                color: isFullyMastered ? Colors.greenAccent : Colors.deepPurpleAccent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFullyMastered
                          ? 'Mastered! \u2014 ${(mastery * 100).toInt()}%'
                          : hasTried
                              ? 'Best score: ${(mastery * 100).toInt()}% \u2014 85% needed'
                              : 'Combine everything from this unit!',
                      style: TextStyle(
                        fontSize: 12,
                        color: isFullyMastered ? Colors.greenAccent : Colors.white54,
                        fontWeight: isFullyMastered ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => IntegrationDrillScreen(module: module),
              ),
            );
          },
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(isFullyMastered ? 'Practice Again' : 'Start Integration'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            minimumSize: const Size.fromHeight(42),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
  
  void _startReview(BuildContext context, WidgetRef ref, DrillModule module) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TigrinyaDrillScreen(
          module: module,
          tense: Tense.present, // Review handles tense internally
          initialStage: DrillStage.mcq,
          isReview: true,
        ),
      ),
    );
  }
}
