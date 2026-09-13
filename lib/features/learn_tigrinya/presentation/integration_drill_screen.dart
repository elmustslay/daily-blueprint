import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/tigrinya_models.dart';
import '../domain/integration_engine.dart';
import '../data/mastery_provider.dart';
import '../data/srs_storage.dart';
import '../domain/tigrinya_tts_service.dart';

/// Screen for end-of-unit integration modules.
///
/// Users see an English sentence, tap words to reveal Tigrinya translations,
/// type their full Tigrinya translation, then self-grade after seeing the answer.
class IntegrationDrillScreen extends ConsumerStatefulWidget {
  final DrillModule module;

  const IntegrationDrillScreen({super.key, required this.module});

  @override
  ConsumerState<IntegrationDrillScreen> createState() => _IntegrationDrillScreenState();
}

class _IntegrationDrillScreenState extends ConsumerState<IntegrationDrillScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  late AnimationController _feedbackAnimController;
  late Animation<double> _feedbackAnim;

  List<IntegrationSentence> _sentences = [];
  int _currentIndex = 0;
  int _totalCorrect = 0;
  int _totalAnswered = 0;

  // Per-sentence state
  Set<int> _revealedParts = {}; // Indices of parts the user has tapped to reveal
  bool _hasSubmitted = false; // User has submitted their answer
  bool _showingSelfGrade = false; // Showing self-grade buttons

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
    _generateSentences();
  }

  @override
  void dispose() {
    _textController.dispose();
    _feedbackAnimController.dispose();
    super.dispose();
  }

  void _generateSentences() {
    final engine = IntegrationEngine(integrationLevel: widget.module.integrationLevel);
    setState(() {
      _sentences = engine.generateSentences(count: 10);
      _currentIndex = 0;
      _totalCorrect = 0;
      _totalAnswered = 0;
      _resetSentenceState();
    });
  }

  void _resetSentenceState() {
    _revealedParts = {};
    _hasSubmitted = false;
    _showingSelfGrade = false;
    _textController.clear();
  }

  void _onTapPart(int index) {
    if (_hasSubmitted) return;
    setState(() {
      _revealedParts.add(index);
    });

    // Track hint peek in SRS — penalize for needing hints
    final sentence = _sentences[_currentIndex];
    if (index < sentence.parts.length) {
      final part = sentence.parts[index];
      // Create a composite key for this concept
      final cardKey = 'integration_${part.category}_${part.tigrinya}';
      SrsStorage.recordHintPeek(cardKey);
    }
  }

  void _onSubmit() {
    setState(() {
      _hasSubmitted = true;
      _showingSelfGrade = true;
    });
    _feedbackAnimController.forward(from: 0);
  }

  void _onSelfGrade(bool gotIt) {
    _totalAnswered++;
    if (gotIt) _totalCorrect++;

    // Record SRS for each concept in this sentence
    final sentence = _sentences[_currentIndex];
    for (final part in sentence.parts) {
      final cardKey = 'integration_${part.category}_${part.tigrinya}';
      SrsStorage.recordReview(cardKey, gotIt);
    }

    // Move to next
    setState(() {
      _currentIndex++;
      if (_currentIndex >= _sentences.length) {
        // Done
      } else {
        _resetSentenceState();
      }
    });
  }

  bool get _isComplete => _currentIndex >= _sentences.length;

  double get _scorePercent => _totalAnswered == 0 ? 0 : _totalCorrect / _totalAnswered;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.module.name),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: _isComplete ? _buildCompletionScreen() : _buildDrillBody(),
      ),
    );
  }

  Widget _buildDrillBody() {
    if (_sentences.isEmpty) {
      return const Center(child: Text('No sentences available.', style: TextStyle(color: Colors.white54)));
    }

    final sentence = _sentences[_currentIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Progress header
        _buildProgressHeader(),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Instruction
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.deepPurpleAccent.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.translate_rounded, size: 18, color: Colors.deepPurpleAccent),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Translate this sentence into Tigrinya.\nTap any word to peek at its translation.',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // English sentence with tappable words
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Full English sentence
                      Text(
                        sentence.fullEnglish,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white12),
                      const SizedBox(height: 12),

                      // Tappable word chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: List.generate(sentence.parts.length, (i) {
                          final part = sentence.parts[i];
                          final isRevealed = _revealedParts.contains(i);

                          return GestureDetector(
                            onTap: () => _onTapPart(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isRevealed
                                    ? Colors.deepPurpleAccent.withValues(alpha: 0.2)
                                    : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isRevealed
                                      ? Colors.deepPurpleAccent.withValues(alpha: 0.6)
                                      : Colors.white24,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    part.english,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isRevealed ? Colors.deepPurpleAccent : Colors.white70,
                                    ),
                                  ),
                                  if (isRevealed) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      part.tigrinya,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    Text(
                                      part.category,
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.deepPurpleAccent.withValues(alpha: 0.6),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ] else ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.touch_app_rounded, size: 12, color: Colors.white.withValues(alpha: 0.3)),
                                        const SizedBox(width: 2),
                                        Text('tap', style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.3))),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Answer input (if not yet submitted)
                if (!_hasSubmitted) ...[
                  const Text(
                    'Write the Tigrinya translation:',
                    style: TextStyle(fontSize: 13, color: Colors.white54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _textController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText: 'ኣነ...',
                      hintStyle: const TextStyle(color: Colors.white24),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.deepPurpleAccent.withValues(alpha: 0.4)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.deepPurpleAccent.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 2),
                      ),
                    ),
                    onSubmitted: (_) => _onSubmit(),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Show Answer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],

                // Self-grade zone (after submission)
                if (_showingSelfGrade) ...[
                  ScaleTransition(
                    scale: _feedbackAnim,
                    child: _buildSelfGradeZone(sentence),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      color: Colors.white.withValues(alpha: 0.03),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.extension_rounded, size: 16, color: Colors.deepPurpleAccent),
                  const SizedBox(width: 6),
                  Text(
                    'INTEGRATION ${widget.module.integrationLevel} · ${_currentIndex + 1} / ${_sentences.length}',
                    style: const TextStyle(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Text(
                '$_totalCorrect / $_totalAnswered',
                style: const TextStyle(fontSize: 13, color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _sentences.isEmpty ? 0 : _currentIndex / _sentences.length,
              minHeight: 6,
              backgroundColor: Colors.deepPurpleAccent.withValues(alpha: 0.15),
              color: Colors.deepPurpleAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelfGradeZone(IntegrationSentence sentence) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurpleAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Text(
            'Correct Answer:',
            style: TextStyle(fontSize: 13, color: Colors.white54, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),

          // Show correct Tigrinya answer with speaker
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  sentence.fullTigrinya,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkResponse(
                radius: 24,
                onTap: () {
                  TigrinyaTtsService().speak(fidelText: sentence.fullTigrinya);
                },
                child: const Icon(Icons.volume_up_rounded, color: Colors.cyanAccent, size: 22),
              ),
            ],
          ),

          // Show user's answer for comparison
          if (_textController.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.white12),
            const SizedBox(height: 8),
            const Text('Your answer:', style: TextStyle(fontSize: 11, color: Colors.white38)),
            const SizedBox(height: 4),
            Text(
              _textController.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
                letterSpacing: 1,
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Part-by-part breakdown
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: sentence.parts.map((part) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.deepPurpleAccent.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(part.english, style: const TextStyle(fontSize: 11, color: Colors.white54)),
                      Text(part.tigrinya, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // Self-grade buttons
          const Text(
            'Did you get it right?',
            style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _onSelfGrade(false),
                  icon: const Icon(Icons.close_rounded, size: 20),
                  label: const Text('Missed It'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
                    foregroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.4)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _onSelfGrade(true),
                  icon: const Icon(Icons.check_rounded, size: 20),
                  label: const Text('Got It!'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.withValues(alpha: 0.2),
                    foregroundColor: Colors.greenAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: Colors.greenAccent.withValues(alpha: 0.4)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen() {
    final percent = (_scorePercent * 100).toInt();
    final passed = _scorePercent >= 0.85;

    // Save mastery
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(masteryProvider.notifier).saveMastery(
        widget.module.id, Tense.present, DrillStage.selfGrade, _scorePercent,
      );
    });

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              passed ? Icons.emoji_events_rounded : Icons.replay_rounded,
              size: 72,
              color: passed ? Colors.amberAccent : Colors.deepPurpleAccent,
            ),
            const SizedBox(height: 20),
            Text(
              passed ? 'Integration Mastered! 🧩' : 'Keep Practicing!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: passed ? Colors.greenAccent : Colors.deepPurpleAccent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$_totalCorrect correct out of $_totalAnswered',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              passed
                  ? 'You\'ve proven you can combine everything from this unit! 🎉'
                  : '85% needed to pass. Concepts you struggled with will appear in your Daily Review.',
              style: TextStyle(
                fontSize: 13,
                color: passed ? Colors.greenAccent : Colors.white54,
                fontWeight: passed ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _generateSentences,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
