import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/tigrinya_models.dart';
import '../domain/drill_session_notifier.dart';
import '../data/mastery_provider.dart';
import '../data/tigrinya_drills_data.dart';
import '../data/srs_storage.dart';
import '../domain/conjugator.dart';
import '../domain/tigrinya_tts_service.dart';
import 'scaffolded_text.dart';
class TigrinyaDrillScreen extends ConsumerStatefulWidget {
  final DrillModule module;
  final Tense tense;
  final DrillStage initialStage;
  final bool isReview;

  const TigrinyaDrillScreen({
    super.key,
    required this.module,
    required this.tense,
    required this.initialStage,
    this.isReview = false,
  });

  @override
  ConsumerState<TigrinyaDrillScreen> createState() =>
      _TigrinyaDrillScreenState();
}

class _TigrinyaDrillScreenState extends ConsumerState<TigrinyaDrillScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  late AnimationController _feedbackAnimController;
  late Animation<double> _feedbackAnim;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _feedbackAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _feedbackAnim = CurvedAnimation(
      parent: _feedbackAnimController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _feedbackAnimController.dispose();
    super.dispose();
  }

  void _ensureStarted() {
    if (!_hasStarted) {
      _hasStarted = true;
      ref
          .read(drillSessionProvider.notifier)
          .startSession(widget.module, widget.tense, widget.initialStage, isReview: widget.isReview);
    }
  }

  @override
  Widget build(BuildContext context) {
    _ensureStarted();
    final session = ref.watch(drillSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isReview ? 'Review Session' : widget.module.name),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: session.isComplete
            ? _buildCompletionOverlay(session)
            : _buildDrillBody(session),
      ),
    );
  }

  // ────────────────────── DRILL BODY ──────────────────────

  Widget _buildDrillBody(DrillSessionState session) {
    if (session.stage == DrillStage.teach && !session.isReviewSession) {
      return _buildTeachStage(session);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildProgressHeader(session),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const Spacer(flex: 1),
                _buildPromptCard(session),
                const SizedBox(height: 24),
                if (session.showingFeedback)
                  _buildFeedbackBanner(session)
                else
                  _buildAnswerZone(session),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  // ────────────────────── TEACH STAGE ──────────────────────
  
  Widget _buildTeachStage(DrillSessionState session) {
    final isVerb = widget.module.type == DrillModuleType.verb;
    List<Widget> listItems = [];
    if (isVerb) {
      for (final verbId in widget.module.verbIds) {
        final verb = TigrinyaDrillsData.getVerbById(verbId);
        final conjugations = verb.getMap(widget.tense);

        listItems.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              '${verb.english} / ${verb.amharic} (${verb.lemma})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
              textAlign: TextAlign.center,
            ),
          ),
        );
        for (final p in TigrinyaDrillsData.pronouns) {
          final c = conjugations[p.id] ?? p.tigrinya;
          listItems.add(_buildTeachRow(p.tigrinya, '${p.english} / ${p.amharic}', c));
        }
      }
      // Vocab preview: show the nouns that will appear in sentences
      final vocabSet = <String>{};
      for (final verbId in widget.module.verbIds) {
        final verb = TigrinyaDrillsData.getVerbById(verbId);
        for (final cat in verb.categories) {
          final objs = TigrinyaDrillsData.compatibleObjects[cat];
          if (objs != null) {
            for (final obj in objs) {
              vocabSet.add(obj.tigrinya);
            }
          }
        }
      }
      if (vocabSet.isNotEmpty) {
        listItems.add(
          const Padding(
            padding: EdgeInsets.only(top: 20, bottom: 8),
            child: Text('📖 Vocabulary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.cyanAccent), textAlign: TextAlign.center),
          ),
        );
        for (final verbId in widget.module.verbIds) {
          final verb = TigrinyaDrillsData.getVerbById(verbId);
          for (final cat in verb.categories) {
            final objs = TigrinyaDrillsData.compatibleObjects[cat];
            if (objs != null) {
              for (final obj in objs) {
                listItems.add(_buildTeachRow(obj.english, obj.amharic, obj.tigrinya));
              }
            }
          }
        }
      }
    } else if (widget.module.type == DrillModuleType.pronoun) {
      listItems = TigrinyaDrillsData.pronouns.map((p) {
        return _buildTeachRow(p.tigrinya, '${p.english} / ${p.amharic}', p.tigrinya);
      }).toList();
    } else if (widget.module.type == DrillModuleType.adjective) {
      // Teach adjective forms
      listItems.add(
        const Padding(
          padding: EdgeInsets.only(top: 8, bottom: 4),
          child: Text('📝 Adjectives (ቅጽል)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orangeAccent), textAlign: TextAlign.center),
        ),
      );
      for (final adj in TigrinyaDrillsData.adjectives) {
        listItems.add(_buildTeachRow(
          '${adj.english} / ${adj.amharic}',
          '♂ ${adj.male}  ♀ ${adj.female}  👥 ${adj.plural}',
          adj.male,
        ));
      }
      // Teach the "to be" verbs
      listItems.add(
        const Padding(
          padding: EdgeInsets.only(top: 16, bottom: 4),
          child: Text('✅ "To Be" (ምዃን)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.greenAccent), textAlign: TextAlign.center),
        ),
      );
      for (final p in TigrinyaDrillsData.pronouns) {
        final bePlain = VerbConjugator.bePositive[p.id]!.replaceAll('{', '').replaceAll('}', '');
        listItems.add(_buildTeachRow(p.english, p.amharic, bePlain));
      }
      // Teach the "not to be" verbs
      listItems.add(
        const Padding(
          padding: EdgeInsets.only(top: 16, bottom: 4),
          child: Text('❌ "Not To Be" (ኣይኮን)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent), textAlign: TextAlign.center),
        ),
      );
      for (final p in TigrinyaDrillsData.pronouns) {
        final beNeg = VerbConjugator.beNegative[p.id]!.replaceAll('{', '').replaceAll('}', '');
        listItems.add(_buildTeachRow(p.english, p.amharic, beNeg));
      }
    } else if (widget.module.type == DrillModuleType.number) {
      listItems = TigrinyaDrillsData.numbers.map((n) {
        return _buildTeachRow(n.english, n.amharic, n.tigrinya);
      }).toList();
    } else if (widget.module.type == DrillModuleType.time) {
      listItems = TigrinyaDrillsData.timeWords.map((t) {
        return _buildTeachRow(t.english, t.amharic, t.tigrinya);
      }).toList();
    } else if (widget.module.type == DrillModuleType.questionWord) {
      listItems = TigrinyaDrillsData.questionWords.map((qw) {
        return _buildTeachRow(qw.english, qw.amharic, qw.tigrinya);
      }).toList();
    } else if (widget.module.type == DrillModuleType.greeting) {
      listItems = TigrinyaDrillsData.greetings.map((g) {
        return _buildTeachRow(g.english, g.amharic, g.tigrinya);
      }).toList();
    } else if (widget.module.type == DrillModuleType.demonstrative) {
      listItems = TigrinyaDrillsData.demonstratives.map((d) {
        return _buildTeachRow(d.english, d.amharic, d.tigrinya);
      }).toList();
    } else if (widget.module.type == DrillModuleType.family) {
      listItems = TigrinyaDrillsData.compatibleObjects['family']!.map((f) {
        return _buildTeachRow(f.english, f.amharic, f.tigrinya);
      }).toList();
    } else if (widget.module.type == DrillModuleType.preposition) {
      listItems = TigrinyaDrillsData.prepositions.map((p) {
        return _buildTeachRow(p.english, p.amharic, p.tigrinya);
      }).toList();
    } else if (widget.module.type == DrillModuleType.phrase) {
      listItems = TigrinyaDrillsData.commonPhrases.map((p) {
        return _buildTeachRow(p.english, p.amharic, p.tigrinya);
      }).toList();
    } else if (widget.module.type == DrillModuleType.possessivePronoun) {
      listItems = TigrinyaDrillsData.possessivePronouns.map((p) {
        return _buildTeachRow(p.english, p.amharic, p.tigrinya);
      }).toList();
    } else if (widget.module.type == DrillModuleType.possession) {
      listItems.add(
        const Padding(
          padding: EdgeInsets.only(top: 8, bottom: 4),
          child: Text('✅ I Have (ኣለኒ)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.greenAccent), textAlign: TextAlign.center),
        ),
      );
      for (final p in TigrinyaDrillsData.pronouns) {
        final form = TigrinyaDrillsData.possession['positive']![p.id]!;
        listItems.add(_buildTeachRow('${p.english} have', p.amharic, form));
      }
      listItems.add(
        const Padding(
          padding: EdgeInsets.only(top: 16, bottom: 4),
          child: Text('❌ I Don\'t Have (የብለይን)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent), textAlign: TextAlign.center),
        ),
      );
      for (final p in TigrinyaDrillsData.pronouns) {
        final form = TigrinyaDrillsData.possession['negative']![p.id]!;
        listItems.add(_buildTeachRow('${p.english} don\'t have', p.amharic, form));
      }
    } else if (widget.module.type == DrillModuleType.sentence) {
      listItems.add(
        const Padding(
          padding: EdgeInsets.only(top: 8, bottom: 8),
          child: Text('🔹 Tigrinya Sentence Order (SOV)\nSubject + Object + Verb', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amberAccent), textAlign: TextAlign.center),
        ),
      );
      listItems.add(_buildTeachRow('I drink water', 'እኔ ውሃ እጠጣለሁ', 'ኣነ ማይ እሰቲ'));
      listItems.add(_buildTeachRow('He eats bread', 'እሱ ዳቦ ይበላል', 'ንሱ ባኒ ይበልዕ'));
      listItems.add(_buildTeachRow('She goes home', 'እሷ ወደ ቤት ትሄዳለች', 'ንሳ ናብ ገዛ ትኸይድ'));
    } else if (widget.module.type == DrillModuleType.nounPossession) {
      listItems = TigrinyaDrillsData.nounPossessionItems.map((n) {
        return _buildTeachRow(n.english, n.amharic, n.tigrinya);
      }).toList();
    } else if (widget.module.type == DrillModuleType.verbObjectSuffix) {
      listItems = TigrinyaDrillsData.verbObjectSuffixItems.map((v) {
        return _buildTeachRow(v.english, v.amharic, v.tigrinya);
      }).toList();
    } else if (widget.module.type == DrillModuleType.imperative) {
      listItems = TigrinyaDrillsData.imperativeItems.map((i) {
        return _buildTeachRow(i.english, i.amharic, i.tigrinya);
      }).toList();
    } else if (widget.module.type == DrillModuleType.locationWord) {
      listItems = TigrinyaDrillsData.locationWords.map((l) {
        return _buildTeachRow(l.english, l.amharic, l.tigrinya);
      }).toList();
    } else if (widget.module.type == DrillModuleType.existential) {
      listItems = TigrinyaDrillsData.existentialItems.map((e) {
        return _buildTeachRow(e.english, e.amharic, e.tigrinya);
      }).toList();
    } else if (widget.module.type == DrillModuleType.intimatePhrase) {
      listItems = TigrinyaDrillsData.intimatePhraseItems.map((i) {
        return _buildTeachRow(i.english, i.amharic, i.tigrinya);
      }).toList();
    } else if (widget.module.type == DrillModuleType.identityToBe) {
      listItems.add(
        const Padding(
          padding: EdgeInsets.only(top: 8, bottom: 4),
          child: Text('✅ I Am... (ኣነ ... እየ)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.greenAccent), textAlign: TextAlign.center),
        ),
      );
      for (final item in TigrinyaDrillsData.identityItems) {
        listItems.add(_buildTeachRow(item.english, item.amharic, item.tigrinya));
      }
    } else if (widget.module.type == DrillModuleType.emotion) {
      listItems = TigrinyaDrillsData.emotionItems.map((e) {
        return _buildTeachRow(e.english, e.amharic, e.tigrinya);
      }).toList();
    } else if (widget.module.type == DrillModuleType.withConstruction) {
      listItems = TigrinyaDrillsData.withConstructionItems.map((w) {
        return _buildTeachRow(w.english, w.amharic, w.tigrinya);
      }).toList();
    } else if (widget.module.type == DrillModuleType.questionWordBasic) {
      listItems = TigrinyaDrillsData.questionWordBasicItems.map((q) {
        return _buildTeachRow(q.english, q.amharic, q.tigrinya);
      }).toList();
    }
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
           Text(
             'Study Card — ${widget.tense.name.toUpperCase()}',
             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.lightBlueAccent),
           ),
           if (isVerb) ...[
             const SizedBox(height: 6),
             Text(
               {
                 Tense.present: 'ምሳሌ (Amharic Equivalent): እኔ አውቃለሁ',
                 Tense.past: 'ምሳሌ (Amharic Equivalent): እኔ አወቅኩ',
                 Tense.continuous: 'ምሳሌ (Amharic Equivalent): እኔ እያወቅኩ ነው',
                 Tense.future: 'ምሳሌ (Amharic Equivalent): እኔ ላውቅ ነው / እኔ አውቃለሁ',
                 Tense.negative: 'ምሳሌ (Amharic Equivalent): እኔ አላውቅም',
               }[widget.tense] ?? '',
               style: const TextStyle(fontSize: 14, color: Colors.greenAccent, fontWeight: FontWeight.w600),
             ),
           ],
           const SizedBox(height: 12),
           if (widget.module.patternRules.containsKey(widget.tense))
             Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(
                 color: Colors.lightBlueAccent.withValues(alpha: 0.1),
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: Colors.lightBlueAccent.withValues(alpha: 0.3)),
               ),
               child: ScaffoldedText(
                 text: widget.module.patternRules[widget.tense]!,
                 baseStyle: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
                 highlightColor: Colors.lightBlueAccent,
               ),
             ),
           const SizedBox(height: 16),
           Expanded(
             child: Container(
               decoration: BoxDecoration(
                 color: Theme.of(context).cardColor,
                 borderRadius: BorderRadius.circular(16),
                 border: Border.all(color: Colors.white12),
               ),
               child: ListView.separated(
                 padding: const EdgeInsets.all(16),
                 itemCount: listItems.length,
                 separatorBuilder: (context, index) => const Divider(color: Colors.white12),
                 itemBuilder: (context, index) => listItems[index],
               ),
             ),
           ),
           const SizedBox(height: 20),
           ElevatedButton(
             onPressed: () {
                // Mark teach as complete and return
                ref.read(masteryProvider.notifier).saveMastery(widget.module.id, widget.tense, DrillStage.teach, 1.0);
                Navigator.of(context).pop();
             },
             style: ElevatedButton.styleFrom(
               backgroundColor: Colors.greenAccent.withValues(alpha: 0.2),
               foregroundColor: Colors.greenAccent,
               minimumSize: const Size.fromHeight(56),
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
             ),
             child: const Text('I\'m Ready!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
           ),
        ],
      ),
    );
  }

  Widget _buildTeachRow(String title, String subtitle, String highlightText, {String? translit}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white54)),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ScaffoldedText(
                    text: highlightText,
                    baseStyle: const TextStyle(fontSize: 20, color: Colors.white),
                    highlightColor: Colors.lightBlueAccent,
                  ),
                  if (translit != null)
                    Text(translit, style: const TextStyle(fontSize: 12, color: Colors.white54, fontStyle: FontStyle.italic)),
                ],
              ),
              InkResponse(
                radius: 24,
                onTap: () {
                  TigrinyaTtsService().speak(
                    fidelText: highlightText,
                    transliteration: translit,
                    forceRefresh: false,
                  );
                },
                onLongPress: () {
                  TigrinyaTtsService().speak(
                    fidelText: highlightText,
                    transliteration: translit,
                    forceRefresh: true,
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.volume_up_rounded, color: Colors.cyanAccent, size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ────────────────────── PROGRESS HEADER ──────────────────────

  Widget _buildProgressHeader(DrillSessionState session) {
    final tenseLabel = widget.tense.name;
    final modeLabel = session.stage.name;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      color: Colors.white.withValues(alpha: 0.03),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${tenseLabel.toUpperCase()} · ${modeLabel.toUpperCase()}',
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                    fontWeight: FontWeight.w500),
              ),
              Text(
                '${session.totalCorrect} / ${session.totalAnswered}',
                style: const TextStyle(
                    fontSize: 13,
                    color: Colors.lightBlueAccent,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: session.progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.lightBlueAccent.withValues(alpha: 0.15),
              color: Colors.lightBlueAccent,
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────── PROMPT CARD ──────────────────────

  Widget _buildPromptCard(DrillSessionState session) {
    final card = session.currentCard;
    if (card == null) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
              if (card.questionWord != null) ...[
            Text(
              card.promptText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5),
            ),
          ] else if (card.pronoun == null || widget.module.type == DrillModuleType.pronoun) ...[
            Text(
              card.promptText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5),
            ),
          ] else ...[
            // Pronoun display
            Text(
              card.pronoun!.tigrinya,
              style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2),
            ),
            const SizedBox(height: 6),
            Text(
              '${card.pronoun!.english} / ${card.pronoun!.amharic}',
              style: const TextStyle(
                  fontSize: 15, color: Colors.white70, fontWeight: FontWeight.w500),
            ),
            if (card.pronoun!.translit.isNotEmpty)
              Text(
                card.pronoun!.translit,
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white38,
                    fontStyle: FontStyle.italic),
              ),
          ],
          
          // Verb info (for verb modules)
          if (card.verb != null && card.questionWord == null) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white12),
            const SizedBox(height: 12),

            // Verb lemma
            Text(
              '${card.verb!.lemma} — ${card.verb!.english}',
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.lightBlueAccent,
                  fontWeight: FontWeight.w600),
            ),
            Text(
              card.verb!.amharic,
              style: const TextStyle(fontSize: 13, color: Colors.white54),
            ),

            // SOV sentence display with clickable object
            if (card.object != null) ...[
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Subject
                  _buildSovChip(card.pronoun!.tigrinya, Colors.lightBlueAccent),
                  const SizedBox(width: 8),
                  const Text('+',
                      style:
                          TextStyle(fontSize: 18, color: Colors.white38)),
                  const SizedBox(width: 8),
                  // Object (clickable)
                  GestureDetector(
                    onTap: () => _showObjectTooltip(card.object!),
                    child: _buildSovChip(
                      card.object!.tigrinya,
                      Colors.orangeAccent,
                      hasTooltip: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('+',
                      style:
                          TextStyle(fontSize: 18, color: Colors.white38)),
                  const SizedBox(width: 8),
                  // Verb placeholder
                  _buildSovChip('???', Colors.greenAccent),
                ],
              ),
            ],
            
            // Sentence context in Amharic
            const SizedBox(height: 24),
            const Text(
              'TRANSLATION TARGET:',
              style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5),
            ),
            const SizedBox(height: 4),
            Text(
              '${card.pronoun!.amharic} + ${card.object?.amharic ?? "..."} + ${card.verb!.amharic} (${widget.tense.name})',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (widget.tense == Tense.past)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.purpleAccent.withValues(alpha: 0.4)),
                  ),
                  child: const Text(
                    'Past Tense',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.purpleAccent),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSovChip(String text, Color color, {bool hasTooltip = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: color),
          ),
          if (hasTooltip) ...[
            const SizedBox(width: 4),
            Icon(Icons.info_outline, size: 13, color: color.withValues(alpha: 0.7)),
          ],
        ],
      ),
    );
  }

  // ────────────────────── OBJECT TOOLTIP ──────────────────────

  void _showObjectTooltip(TigrinyaObject obj) {
    // Track hint peek in SRS
    final session = ref.read(drillSessionProvider);
    final card = session.currentCard;
    if (card != null) {
      final cardKey = '${card.pronoun?.id ?? 'flashcard'}_${card.object?.tigrinya ?? ''}_${card.verb?.id ?? 'pronoun'}_${card.tense.name}_${card.questionWord?.id ?? ''}';
      SrsStorage.recordHintPeek(cardKey);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              obj.tigrinya,
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.orangeAccent),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTranslationChip('Amharic', obj.amharic, Colors.lightBlueAccent),
                const SizedBox(width: 16),
                _buildTranslationChip('English', obj.english, Colors.greenAccent),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  // ────────────────────── ANSWER ZONE ──────────────────────

  Widget _buildAnswerZone(DrillSessionState session) {
    if (session.stage == DrillStage.mcq) {
      return _buildMcqOptions(session);
    } else {
      return _buildTypingInput(session);
    }
  }

  Widget _buildMcqOptions(DrillSessionState session) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: session.mcqOptions.map((option) {
        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.40,
          child: ElevatedButton(
            onPressed: () => _onAnswer(stripScaffolding(option)), // pass stripped answer to engine
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlueAccent.withValues(alpha: 0.12),
              foregroundColor: Colors.white,
              side: BorderSide(
                  color: Colors.lightBlueAccent.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            ),
            child: ScaffoldedText(
              text: option,
              baseStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1),
              highlightColor: Colors.lightBlueAccent,
              textAlign: TextAlign.center,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypingInput(DrillSessionState session) {
    return Column(
      children: [
        const Text(
          'Type the Ge\'ez answer:',
          style: TextStyle(fontSize: 13, color: Colors.white54),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _textController,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5),
          decoration: InputDecoration(
            hintText: 'ኣነ...',
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Colors.lightBlueAccent.withValues(alpha: 0.4)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Colors.lightBlueAccent.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Colors.lightBlueAccent, width: 2),
            ),
          ),
          onSubmitted: (value) => _onAnswer(value),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => _onAnswer(_textController.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlueAccent,
            padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Submit',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  void _onAnswer(String answer) {
    ref.read(drillSessionProvider.notifier).submitAnswer(answer);
    _textController.clear();
    _feedbackAnimController.forward(from: 0);
  }

  // ────────────────────── FEEDBACK BANNER ──────────────────────

  Widget _buildFeedbackBanner(DrillSessionState session) {
    final result = session.lastResult;
    if (result == null) return const SizedBox();

    return ScaleTransition(
      scale: _feedbackAnim,
      child: GestureDetector(
        onTap: () {
          ref.read(drillSessionProvider.notifier).nextCard();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: result.isCorrect
                ? Colors.greenAccent.withValues(alpha: 0.1)
                : Colors.redAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: result.isCorrect
                  ? Colors.greenAccent.withValues(alpha: 0.5)
                  : Colors.redAccent.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                result.isCorrect
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: result.isCorrect ? Colors.greenAccent : Colors.redAccent,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                result.isCorrect ? 'Correct! ✨' : 'Incorrect',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: result.isCorrect
                      ? Colors.greenAccent
                      : Colors.redAccent,
                ),
              ),
              if (!result.isCorrect) ...[
                const SizedBox(height: 12),
                // Expected answer
                const Text('Expected: ', style: TextStyle(fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 4),
                ScaffoldedText(
                  text: result.expectedAnswer,
                  baseStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                    letterSpacing: 1.5,
                  ),
                  highlightColor: Colors.white,
                  textAlign: TextAlign.center,
                ),
                if (result.userAnswer.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style:
                          const TextStyle(fontSize: 14, color: Colors.white70),
                      children: [
                        const TextSpan(text: 'You answered: '),
                        TextSpan(
                          text: result.userAnswer,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amberAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '🔁 Added to retry queue (2 consecutive correct to clear)',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                'Tap to continue',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.4)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────── COMPLETION OVERLAY ──────────────────────

  Widget _buildCompletionOverlay(DrillSessionState session) {
    if (session.isReviewSession) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.all_inclusive_rounded, size: 72, color: Colors.indigoAccent),
            const SizedBox(height: 20),
            const Text(
              'Review Paused',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              'Score: ${(session.scorePercent * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.indigoAccent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${session.totalCorrect} correct out of ${session.totalAnswered}',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.exit_to_app_rounded),
                  label: const Text('End Review'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(drillSessionProvider.notifier).startSession(
                        widget.module, widget.tense, widget.initialStage, isReview: true);
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Continue'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final percent = (session.scorePercent * 100).toInt();
    final passed = session.scorePercent >= 0.85;
    final isChunked = session.totalChunks > 1;
    final isLastChunk = session.chunkIndex >= session.totalChunks - 1;
    final hasMoreChunks = isChunked && passed && !isLastChunk;

    // Save mastery (and chunk progress for chunked modules)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isChunked && passed) {
        // Save chunk completion + update overall mastery
        ChunkStorage.completeChunk(
          widget.module.id,
          widget.tense,
          session.stage,
          session.chunkIndex + 1,
          session.totalChunks,
        );
        ref.read(masteryProvider.notifier).saveMastery(
          widget.module.id,
          widget.tense,
          session.stage,
          (session.chunkIndex + 1) / session.totalChunks,
        );
      } else {
        ref
            .read(masteryProvider.notifier)
            .saveMastery(widget.module.id, widget.tense, session.stage, session.scorePercent);
      }
    });

    // Build chunk status text
    String statusText;
    String titleText;
    if (isChunked) {
      if (passed) {
        if (isLastChunk) {
          titleText = 'All Chunks Complete! 🎉';
          statusText = 'Module mastered — all ${session.totalChunks} chunks done!';
        } else {
          titleText = 'Chunk ${session.chunkIndex + 1} of ${session.totalChunks} Passed!';
          statusText = 'Next chunk ready. Keep going!';
        }
      } else {
        titleText = 'Keep Practicing!';
        statusText = 'Chunk ${session.chunkIndex + 1} of ${session.totalChunks} — ${(0.85 * 100).toInt()}% needed';
      }
    } else {
      titleText = passed ? 'Module Mastered! 🎉' : 'Keep Practicing!';
      statusText = passed ? 'Progress Saved! 🔓' : '${(0.85 * 100).toInt()}% needed to pass';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              passed ? Icons.emoji_events_rounded : Icons.replay_rounded,
              size: 72,
              color: passed ? Colors.amberAccent : Colors.lightBlueAccent,
            ),
            const SizedBox(height: 20),
            Text(
              titleText,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Score: $percent%',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: passed ? Colors.greenAccent : Colors.lightBlueAccent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${session.totalCorrect} correct out of ${session.totalAnswered}',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              statusText,
              style: TextStyle(
                  fontSize: 14,
                  color: passed ? Colors.greenAccent : Colors.white54,
                  fontWeight: passed ? FontWeight.w600 : FontWeight.normal),
              textAlign: TextAlign.center,
            ),
            // Chunk progress dots
            if (isChunked) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(session.totalChunks, (i) {
                  final isDone = i < session.chunkIndex + (passed ? 1 : 0);
                  final isCurrent = i == session.chunkIndex;
                  return Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone
                          ? Colors.greenAccent
                          : isCurrent
                              ? Colors.amberAccent
                              : Colors.white24,
                    ),
                  );
                }),
              ),
            ],
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 16),
                if (hasMoreChunks)
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(drillSessionProvider.notifier).startSession(
                          widget.module, widget.tense, widget.initialStage);
                    },
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Next Chunk'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent.shade700,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(drillSessionProvider.notifier).startSession(
                          widget.module, widget.tense, widget.initialStage);
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
