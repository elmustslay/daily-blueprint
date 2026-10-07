import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/srs_storage.dart';
import '../data/tigrinya_drills_data.dart';
import '../domain/tigrinya_models.dart';
import 'scaffolded_text.dart';

/// Dedicated SRS Daily Review screen.
///
/// Shows cards due for review based on forgetting curve, prioritizing
/// cards not seen in a week and cards the user struggles with.
class SrsReviewScreen extends ConsumerStatefulWidget {
  const SrsReviewScreen({super.key});

  @override
  ConsumerState<SrsReviewScreen> createState() => _SrsReviewScreenState();
}

class _SrsReviewScreenState extends ConsumerState<SrsReviewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _feedbackAnimController;
  late Animation<double> _feedbackAnim;

  List<_ReviewCard> _deck = [];
  int _currentIndex = 0;
  int _totalCorrect = 0;
  bool _showingFeedback = false;
  bool _isComplete = false;
  bool? _lastWasCorrect;
  String? _lastExpectedAnswer;

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
    _buildDeck();
  }

  @override
  void dispose() {
    _feedbackAnimController.dispose();
    super.dispose();
  }

  void _buildDeck() {
    final dueRecords = SrsStorage.getDueCards(maxCount: 20);

    final cards = <_ReviewCard>[];
    for (final record in dueRecords) {
      final card = _resolveCardFromKey(record.cardKey);
      if (card != null) {
        cards.add(card);
      }
    }

    // If we have very few due cards, pad with random struggling cards
    if (cards.length < 5) {
      final struggling = SrsStorage.getStrugglingCardKeys(maxCount: 15);
      for (final key in struggling) {
        if (cards.length >= 15) break;
        if (cards.any((c) => c.cardKey == key)) continue;
        final card = _resolveCardFromKey(key);
        if (card != null) cards.add(card);
      }
    }

    cards.shuffle();
    setState(() {
      _deck = cards;
      _currentIndex = 0;
      _totalCorrect = 0;
      _showingFeedback = false;
      _isComplete = cards.isEmpty;
    });
  }

  /// Try to reconstruct a reviewable card from its SRS key.
  ///
  /// Key format: `{pronounId}_{objectTigrinya}_{verbId}_{tense}_{questionWordId}`
  _ReviewCard? _resolveCardFromKey(String key) {
    final parts = key.split('_');
    if (parts.length < 4) return null;

    final pronounId = parts[0];
    final objectTigrinya = parts.length > 1 ? parts[1] : '';
    final verbId = parts.length > 2 ? parts[2] : '';
    final tenseName = parts.length > 3 ? parts[3] : 'present';

    // Flashcard-style card (no verb)
    if (pronounId == 'flashcard' || verbId == 'pronoun') {
      // Try to find the object in all data sources
      final allItems = <TigrinyaObject>[
        ...TigrinyaDrillsData.greetings,
        ...TigrinyaDrillsData.numbers,
        ...TigrinyaDrillsData.advancedNumbers,
        ...TigrinyaDrillsData.timeWords,
        ...TigrinyaDrillsData.demonstratives,
        ...TigrinyaDrillsData.prepositions,
        ...TigrinyaDrillsData.commonPhrases,
        ...TigrinyaDrillsData.nounPossessionItems,
        ...TigrinyaDrillsData.verbObjectSuffixItems,
        ...TigrinyaDrillsData.imperativeItems,
        ...TigrinyaDrillsData.locationWords,
        ...TigrinyaDrillsData.existentialItems,
        ...TigrinyaDrillsData.intimatePhraseItems,
        ...TigrinyaDrillsData.identityItems,
        ...TigrinyaDrillsData.emotionItems,
        ...TigrinyaDrillsData.withConstructionItems,
        ...TigrinyaDrillsData.questionWordBasicItems,
        ...TigrinyaDrillsData.possessivePronouns,
        ...TigrinyaDrillsData.compatibleObjects['family'] ?? [],
        ...TigrinyaDrillsData.compoundSubjectItems,
      ];

      // Find item by tigrinya
      final matchingItems = allItems.where((item) => item.tigrinya == objectTigrinya);
      if (matchingItems.isNotEmpty) {
        final item = matchingItems.first;
        return _ReviewCard(
          cardKey: key,
          promptText: '${item.english} / ${item.amharic}',
          correctAnswer: item.tigrinya,
          isMcq: true,
          allOptions: _generateFlashcardOptions(item, allItems),
        );
      }

      // Also check pronouns
      for (final p in TigrinyaDrillsData.pronouns) {
        if (p.tigrinya == objectTigrinya) {
          return _ReviewCard(
            cardKey: key,
            promptText: '${p.english} / ${p.amharic}',
            correctAnswer: p.tigrinya,
            isMcq: true,
            allOptions: _generatePronounOptions(p),
          );
        }
      }

      return null;
    }

    // Verb-style card
    try {
      final pronoun = TigrinyaDrillsData.getPronounById(pronounId);
      final tense = Tense.values.firstWhere((t) => t.name == tenseName, orElse: () => Tense.present);

      // Find the verb
      Verb? verb;
      try {
        verb = TigrinyaDrillsData.getVerbById(verbId);
      } catch (_) {
        return null;
      }

      final conjugated = verb.conjugate(pronoun.id, tense);
      if (conjugated == null) return null;
      final cleanConj = conjugated.replaceAll('{', '').replaceAll('}', '');

      final tenseLabel = ' [${tense.name}]';
      final promptText = '${pronoun.english} (${pronoun.amharic})$tenseLabel → ${verb.english}';

      // Generate MCQ options from same verb's conjugation table
      final allForms = verb.getMap(tense).allForms
          .map((f) => f.replaceAll('{', '').replaceAll('}', ''))
          .toSet()
          .toList();
      allForms.remove(cleanConj);
      allForms.shuffle();
      final options = [cleanConj, ...allForms.take(7)];
      options.shuffle();

      return _ReviewCard(
        cardKey: key,
        promptText: promptText,
        correctAnswer: cleanConj,
        isMcq: true,
        allOptions: options,
      );
    } catch (_) {
      return null;
    }
  }

  List<String> _generateFlashcardOptions(TigrinyaObject target, List<TigrinyaObject> allItems) {
    final options = <String>{target.tigrinya};
    final shuffled = List<TigrinyaObject>.from(allItems)..shuffle();
    for (final item in shuffled) {
      if (options.length >= 8) break;
      if (item.tigrinya != target.tigrinya) {
        options.add(item.tigrinya);
      }
    }
    final list = options.toList()..shuffle();
    return list;
  }

  List<String> _generatePronounOptions(Pronoun target) {
    final options = <String>{target.tigrinya};
    for (final p in TigrinyaDrillsData.pronouns) {
      if (p.tigrinya != target.tigrinya) options.add(p.tigrinya);
    }
    final list = options.toList()..shuffle();
    return list;
  }

  void _onAnswer(String answer) {
    if (_currentIndex >= _deck.length) return;
    final card = _deck[_currentIndex];
    final isCorrect = answer.trim() == card.correctAnswer.trim();

    if (isCorrect) _totalCorrect++;

    // Record SRS review
    SrsStorage.recordReview(card.cardKey, isCorrect);

    setState(() {
      _showingFeedback = true;
      _lastWasCorrect = isCorrect;
      _lastExpectedAnswer = card.correctAnswer;
    });
    _feedbackAnimController.forward(from: 0);
  }

  void _nextCard() {
    setState(() {
      _currentIndex++;
      _showingFeedback = false;
      if (_currentIndex >= _deck.length) {
        _isComplete = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Review'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: _isComplete
            ? _buildCompletionScreen()
            : _deck.isEmpty
                ? _buildEmptyState()
                : _buildReviewBody(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline_rounded,
                size: 72, color: Colors.greenAccent.withValues(alpha: 0.7)),
            const SizedBox(height: 20),
            const Text(
              'All caught up! 🎉',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            const Text(
              'No cards are due for review right now.\nKeep learning new modules to build your review deck!',
              style: TextStyle(fontSize: 14, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewBody() {
    final card = _deck[_currentIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Progress header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          color: Colors.white.withValues(alpha: 0.03),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.psychology_rounded, size: 16, color: Colors.purpleAccent),
                      const SizedBox(width: 6),
                      Text(
                        'SRS REVIEW · ${_currentIndex + 1} / ${_deck.length}',
                        style: const TextStyle(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Text(
                    '$_totalCorrect / ${_currentIndex > 0 ? _currentIndex : "-"}',
                    style: const TextStyle(fontSize: 13, color: Colors.purpleAccent, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _deck.isEmpty ? 0 : _currentIndex / _deck.length,
                  minHeight: 6,
                  backgroundColor: Colors.purpleAccent.withValues(alpha: 0.15),
                  color: Colors.purpleAccent,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const Spacer(flex: 1),
                // Prompt card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
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
                      const Icon(Icons.psychology_rounded, size: 20, color: Colors.purpleAccent),
                      const SizedBox(height: 8),
                      Text(
                        card.promptText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Answer zone or feedback
                if (_showingFeedback)
                  _buildFeedback()
                else
                  _buildMcqOptions(card),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMcqOptions(_ReviewCard card) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: card.allOptions.map((option) {
        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.40,
          child: ElevatedButton(
            onPressed: () => _onAnswer(option),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purpleAccent.withValues(alpha: 0.12),
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.purpleAccent.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            ),
            child: ScaffoldedText(
              text: option,
              baseStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
              highlightColor: Colors.purpleAccent,
              textAlign: TextAlign.center,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeedback() {
    final isCorrect = _lastWasCorrect ?? false;

    return ScaleTransition(
      scale: _feedbackAnim,
      child: GestureDetector(
        onTap: _nextCard,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isCorrect
                ? Colors.greenAccent.withValues(alpha: 0.1)
                : Colors.redAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCorrect
                  ? Colors.greenAccent.withValues(alpha: 0.5)
                  : Colors.redAccent.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isCorrect ? Colors.greenAccent : Colors.redAccent,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                isCorrect ? 'Correct! ✨' : 'Incorrect',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.greenAccent : Colors.redAccent,
                ),
              ),
              if (!isCorrect && _lastExpectedAnswer != null) ...[
                const SizedBox(height: 12),
                const Text('Expected:', style: TextStyle(fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 4),
                ScaffoldedText(
                  text: _lastExpectedAnswer!,
                  baseStyle: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: Colors.greenAccent, letterSpacing: 1.5,
                  ),
                  highlightColor: Colors.white,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 12),
              Text(
                'Tap to continue',
                style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionScreen() {
    final total = _deck.length;
    final percent = total == 0 ? 0 : (_totalCorrect * 100 ~/ total);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.psychology_rounded, size: 72, color: Colors.purpleAccent),
            const SizedBox(height: 20),
            const Text(
              'Review Complete! 🧠',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              '$percent%',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.purpleAccent),
            ),
            const SizedBox(height: 8),
            Text(
              '$_totalCorrect correct out of $total',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Cards reviewed have been rescheduled based on your performance.',
              style: const TextStyle(fontSize: 12, color: Colors.white54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Done'),
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
                    _buildDeck(); // Rebuild deck with new due cards
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Review More'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
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

/// Internal card model for SRS review.
class _ReviewCard {
  final String cardKey;
  final String promptText;
  final String correctAnswer;
  final bool isMcq;
  final List<String> allOptions;

  const _ReviewCard({
    required this.cardKey,
    required this.promptText,
    required this.correctAnswer,
    this.isMcq = true,
    this.allOptions = const [],
  });
}
