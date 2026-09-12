import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tigrinya_models.dart';
import 'drill_engine.dart';
import '../data/tigrinya_drills_data.dart';

class DrillSessionState {
  final DrillModule? module;
  final Tense? tense;
  final DrillStage stage;
  final bool isReviewSession;
  
  final DrillCard? currentCard;
  final List<String> mcqOptions;
  final AnswerResult? lastResult;
  final bool showingFeedback;

  final int totalAnswered;
  final int totalCorrect;
  final double progress;
  final bool isComplete;
  
  // Data for Teach stage
  final List<Pronoun> studyPronouns;
  final ConjugationMap? studyMap;

  const DrillSessionState({
    this.module,
    this.tense,
    this.stage = DrillStage.teach,
    this.isReviewSession = false,
    this.currentCard,
    this.mcqOptions = const [],
    this.lastResult,
    this.showingFeedback = false,
    this.totalAnswered = 0,
    this.totalCorrect = 0,
    this.progress = 0.0,
    this.isComplete = false,
    this.studyPronouns = const [],
    this.studyMap,
  });

  DrillSessionState copyWith({
    DrillModule? module,
    Tense? tense,
    DrillStage? stage,
    bool? isReviewSession,
    DrillCard? currentCard,
    List<String>? mcqOptions,
    AnswerResult? lastResult,
    bool? showingFeedback,
    int? totalAnswered,
    int? totalCorrect,
    double? progress,
    bool? isComplete,
    List<Pronoun>? studyPronouns,
    ConjugationMap? studyMap,
  }) {
    return DrillSessionState(
      module: module ?? this.module,
      tense: tense ?? this.tense,
      stage: stage ?? this.stage,
      isReviewSession: isReviewSession ?? this.isReviewSession,
      currentCard: currentCard ?? this.currentCard,
      mcqOptions: mcqOptions ?? this.mcqOptions,
      lastResult: lastResult ?? this.lastResult,
      showingFeedback: showingFeedback ?? this.showingFeedback,
      totalAnswered: totalAnswered ?? this.totalAnswered,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      progress: progress ?? this.progress,
      isComplete: isComplete ?? this.isComplete,
      studyPronouns: studyPronouns ?? this.studyPronouns,
      studyMap: studyMap ?? this.studyMap,
    );
  }

  double get scorePercent => totalAnswered == 0 ? 0 : totalCorrect / totalAnswered;
}

class DrillSessionNotifier extends Notifier<DrillSessionState> {
  DrillEngine? _engine;

  @override
  DrillSessionState build() {
    return const DrillSessionState();
  }

  void startSession(DrillModule module, Tense tense, DrillStage stage, {bool isReview = false}) {
    _engine = DrillEngine(module: module, tense: tense);
    
    if (isReview) {
      _engine!.generateReviewDeck();
    } else {
      _engine!.generateDeck();
    }
    
    // Setup teach data if applicable
    ConjugationMap? map;
    if (module.type == DrillModuleType.verb && module.verbIds.isNotEmpty) {
       final firstVerb = TigrinyaDrillsData.getVerbById(module.verbIds.first);
       map = firstVerb.getMap(tense);
    }
    
    state = DrillSessionState(
      module: module,
      tense: tense,
      stage: stage,
      isReviewSession: isReview,
      currentCard: _engine!.currentCard,
      mcqOptions: stage == DrillStage.mcq ? _engine!.generateMcqOptions() : [],
      progress: 0.0,
      studyPronouns: TigrinyaDrillsData.pronouns,
      studyMap: map,
    );
  }

  void submitAnswer(String input) {
    if (_engine == null) return;
    
    final result = _engine!.checkAnswer(input);
    
    state = state.copyWith(
      lastResult: result,
      showingFeedback: true,
      totalAnswered: _engine!.totalAnswered,
      totalCorrect: _engine!.totalCorrect,
      progress: _engine!.deckLength > 0 ? _engine!.currentIndex / _engine!.deckLength : 0.0,
    );
  }

  void nextCard() {
    if (_engine == null) return;
    
    _engine!.advance();
    
    if (_engine!.isComplete) {
      if (state.isReviewSession) {
         // Auto-reshuffle and continue for endless review
         _engine!.generateReviewDeck();
         state = state.copyWith(
           showingFeedback: false,
           currentCard: _engine!.currentCard,
           mcqOptions: state.stage == DrillStage.mcq ? _engine!.generateMcqOptions() : [],
         );
      } else {
         state = state.copyWith(
           showingFeedback: false,
           isComplete: true,
           progress: 1.0,
         );
      }
    } else {
      state = state.copyWith(
        showingFeedback: false,
        currentCard: _engine!.currentCard,
        mcqOptions: state.stage == DrillStage.mcq ? _engine!.generateMcqOptions() : [],
        progress: _engine!.currentIndex / _engine!.deckLength,
      );
    }
  }
}

final drillSessionProvider = NotifierProvider<DrillSessionNotifier, DrillSessionState>(
  DrillSessionNotifier.new,
);
