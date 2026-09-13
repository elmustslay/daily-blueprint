import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mastery_provider.dart';
import '../data/tigrinya_drills_data.dart';
import '../domain/tigrinya_models.dart';
import '../domain/tigrinya_tts_service.dart';

class WordBankScreen extends ConsumerStatefulWidget {
  const WordBankScreen({super.key});

  @override
  ConsumerState<WordBankScreen> createState() => _WordBankScreenState();
}

class _WordBankScreenState extends ConsumerState<WordBankScreen> {
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unlockedKeys = ref.watch(vocabProvider);

    // Filter Verbs
    final unlockedVerbs = TigrinyaDrillsData.verbs.where((v) {
      if (!unlockedKeys.contains(v.id)) return false;
      return _matchesSearch(v.lemma, v.translit, v.english, v.amharic);
    }).toList();

    // Filter Question Words
    final unlockedQWs = TigrinyaDrillsData.questionWords.where((qw) {
      if (!unlockedKeys.contains(qw.id)) return false;
      return _matchesSearch(qw.tigrinya, qw.translit, qw.english, qw.amharic);
    }).toList();

    // Filter Objects by Category
    final Map<String, List<TigrinyaObject>> unlockedObjectsByCategory = {};
    for (final entry in TigrinyaDrillsData.compatibleObjects.entries) {
      final unlockedInCat = entry.value.where((obj) {
        if (!unlockedKeys.contains(obj.tigrinya)) return false;
        return _matchesSearch(obj.tigrinya, '', obj.english, obj.amharic);
      }).toList();
      
      if (unlockedInCat.isNotEmpty) {
        unlockedObjectsByCategory[entry.key] = unlockedInCat;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Bank'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: CustomScrollView(
              slivers: [
                if (unlockedVerbs.isNotEmpty) ...[
                  _buildSectionHeader('Verbs (ግሲ)'),
                  _buildVerbList(unlockedVerbs),
                ],
                if (unlockedQWs.isNotEmpty) ...[
                  _buildSectionHeader('Question Words (ሕቶ)'),
                  _buildQWList(unlockedQWs),
                ],
                for (final entry in unlockedObjectsByCategory.entries) ...[
                  _buildSectionHeader(_capitalize(entry.key)),
                  _buildObjectList(entry.value),
                ],
                if (unlockedVerbs.isEmpty &&
                    unlockedQWs.isEmpty &&
                    unlockedObjectsByCategory.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.menu_book, size: 64, color: Colors.white24),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Complete drills to organically unlock words!'
                                : 'No matching words found.',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _matchesSearch(String tigrinya, String translit, String english, String amharic) {
    if (_searchQuery.isEmpty) return true;
    final q = _searchQuery.toLowerCase();
    return tigrinya.toLowerCase().contains(q) ||
        translit.toLowerCase().contains(q) ||
        english.toLowerCase().contains(q) ||
        amharic.toLowerCase().contains(q);
  }

  String _capitalize(String s) => s.isEmpty ? '' : '${s[0].toUpperCase()}${s.substring(1)}';

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Search Tigrinya, English, Amharic...',
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.lightBlueAccent,
          ),
        ),
      ),
    );
  }

  SliverList _buildVerbList(List<Verb> verbs) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final v = verbs[index];
          return _VocabTile(
            tigrinya: v.lemma,
            translit: v.translit,
            english: v.english,
            amharic: v.amharic,
          );
        },
        childCount: verbs.length,
      ),
    );
  }

  SliverList _buildQWList(List<QuestionWord> qws) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final qw = qws[index];
          return _VocabTile(
            tigrinya: qw.tigrinya,
            translit: qw.translit,
            english: qw.english,
            amharic: qw.amharic,
          );
        },
        childCount: qws.length,
      ),
    );
  }

  SliverList _buildObjectList(List<TigrinyaObject> objs) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final obj = objs[index];
          return _VocabTile(
            tigrinya: obj.tigrinya,
            translit: null, // Objects don't have transliteration right now
            english: obj.english,
            amharic: obj.amharic,
          );
        },
        childCount: objs.length,
      ),
    );
  }
}

class _VocabTile extends StatelessWidget {
  final String tigrinya;
  final String? translit;
  final String english;
  final String amharic;

  const _VocabTile({
    required this.tigrinya,
    this.translit,
    required this.english,
    required this.amharic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              tigrinya,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (translit != null && translit!.isNotEmpty) ...[
              const SizedBox(width: 12),
              Text(
                '($translit)',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white54,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Text(
                english,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.lightBlueAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('•', style: TextStyle(color: Colors.white30)),
              ),
              Text(
                amharic,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.amberAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        trailing: InkResponse(
          radius: 24,
          onTap: () {
            TigrinyaTtsService().speak(
              fidelText: tigrinya,
              transliteration: translit,
              forceRefresh: false,
            );
          },
          onLongPress: () {
            TigrinyaTtsService().speak(
              fidelText: tigrinya,
              transliteration: translit,
              forceRefresh: true,
            );
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.volume_up_rounded, color: Colors.cyanAccent),
          ),
        ),
      ),
    );
  }
}
