import 'package:my_app/features/learn_tigrinya/domain/tigrinya_models.dart';
import 'package:my_app/features/learn_tigrinya/domain/conjugator.dart';

/// All static drill data: pronouns, objects, question words, verbs, and modules.
class TigrinyaDrillsData {
  TigrinyaDrillsData._();

  // ───────────────────────── PRONOUNS ─────────────────────────

  static const List<Pronoun> pronouns = [
    Pronoun(id: 'p1', tigrinya: 'ኣነ', translit: 'Ane', amharic: 'እኔ', english: 'I'),
    Pronoun(id: 'p2', tigrinya: 'ንስኻ', translit: 'Nsakha', amharic: 'አንተ', english: 'You (m.)'),
    Pronoun(id: 'p3', tigrinya: 'ንስኺ', translit: 'Nsakhi', amharic: 'አንቺ', english: 'You (f.)'),
    Pronoun(id: 'p4', tigrinya: 'ንሱ', translit: 'Nsu', amharic: 'እሱ', english: 'He'),
    Pronoun(id: 'p5', tigrinya: 'ንሳ', translit: 'Nsa', amharic: 'እሷ', english: 'She'),
    Pronoun(id: 'p6', tigrinya: 'ንሕና', translit: 'Nhna', amharic: 'እኛ', english: 'We'),
    Pronoun(id: 'p7', tigrinya: 'ንስኻትኩም', translit: 'Nskhatkum', amharic: 'እናንተ (ወ)', english: 'You (pl. m.)'),
    Pronoun(id: 'p8', tigrinya: 'ንስኻትክን', translit: 'Nskhatkin', amharic: 'እናንተ (ሴ)', english: 'You (pl. f.)'),
    Pronoun(id: 'p9', tigrinya: 'ንሳቶም', translit: 'Nsatom', amharic: 'እነሱ (ወ)', english: 'They (m.)'),
    Pronoun(id: 'p10', tigrinya: 'ንሳተን', translit: 'Nsaten', amharic: 'እነሱ (ሴ)', english: 'They (f.)'),
  ];

  static Pronoun getPronounById(String id) =>
      pronouns.firstWhere((p) => p.id == id);

  // ───────────────────────── QUESTION WORDS ─────────────────────────

  static const List<QuestionWord> questionWords = [
    QuestionWord(id: 'qw_what', tigrinya: 'እንታይ', translit: 'Entay', amharic: 'ምን', english: 'What'),
    QuestionWord(id: 'qw_who', tigrinya: 'መን', translit: 'Men', amharic: 'ማን', english: 'Who'),
    QuestionWord(id: 'qw_where', tigrinya: 'ኣበይ', translit: 'Abey', amharic: 'የት', english: 'Where'),
    QuestionWord(id: 'qw_when', tigrinya: 'መዓስ', translit: "Me'as", amharic: 'መቼ', english: 'When'),
    QuestionWord(id: 'qw_how', tigrinya: 'ከመይ', translit: 'Kemey', amharic: 'እንዴት', english: 'How'),
  ];

  // ───────────────────────── NUMBERS & TIME ─────────────────────────

  static const List<TigrinyaObject> numbers = [
    TigrinyaObject(tigrinya: 'ሓደ', amharic: 'አንድ', english: 'one (1)'),
    TigrinyaObject(tigrinya: 'ክልተ', amharic: 'ሁለት', english: 'two (2)'),
    TigrinyaObject(tigrinya: 'ሰለስተ', amharic: 'ሶስት', english: 'three (3)'),
    TigrinyaObject(tigrinya: 'ኣርባዕተ', amharic: 'አራት', english: 'four (4)'),
    TigrinyaObject(tigrinya: 'ሓሙሽተ', amharic: 'አምስት', english: 'five (5)'),
    TigrinyaObject(tigrinya: 'ሽዱሽተ', amharic: 'ስድስት', english: 'six (6)'),
    TigrinyaObject(tigrinya: 'ሸውዓተ', amharic: 'ሰባት', english: 'seven (7)'),
    TigrinyaObject(tigrinya: 'ሸሞንተ', amharic: 'ስምንት', english: 'eight (8)'),
    TigrinyaObject(tigrinya: 'ትሽዓተ', amharic: 'ዘጠኝ', english: 'nine (9)'),
    TigrinyaObject(tigrinya: 'ዓሰርተ', amharic: 'አስር', english: 'ten (10)'),
    TigrinyaObject(tigrinya: 'ዕስራ', amharic: 'ሃያ', english: 'twenty (20)'),
    TigrinyaObject(tigrinya: 'ሰላሳ', amharic: 'ሰላሳ', english: 'thirty (30)'),
    TigrinyaObject(tigrinya: 'ኣርብዓ', amharic: 'አርባ', english: 'forty (40)'),
    TigrinyaObject(tigrinya: 'ሓምሳ', amharic: 'ሃምሳ', english: 'fifty (50)'),
    TigrinyaObject(tigrinya: 'ሱሳ', amharic: 'ስልሳ', english: 'sixty (60)'),
    TigrinyaObject(tigrinya: 'ሰብዓ', amharic: 'ሰባ', english: 'seventy (70)'),
    TigrinyaObject(tigrinya: 'ሰማንያ', amharic: 'ሰማንያ', english: 'eighty (80)'),
    TigrinyaObject(tigrinya: 'ተስዓ', amharic: 'ዘጠና', english: 'ninety (90)'),
    TigrinyaObject(tigrinya: 'ሚእቲ', amharic: 'መቶ', english: 'hundred (100)'),
  ];

  static const List<TigrinyaObject> timeWords = [
    TigrinyaObject(tigrinya: 'ሕጂ', amharic: 'አሁን', english: 'now'),
    TigrinyaObject(tigrinya: 'ሎሚ', amharic: 'ዛሬ', english: 'today'),
    TigrinyaObject(tigrinya: 'ትማሊ', amharic: 'ትናንት', english: 'yesterday'),
    TigrinyaObject(tigrinya: 'ጽባሕ', amharic: 'ነገ', english: 'tomorrow'),
    TigrinyaObject(tigrinya: 'ንግሆ', amharic: 'ጠዋት', english: 'morning'),
    TigrinyaObject(tigrinya: 'ምሸት', amharic: 'ማታ', english: 'evening / night'),
    TigrinyaObject(tigrinya: 'ሰሙን', amharic: 'ሳምንት', english: 'week'),
    TigrinyaObject(tigrinya: 'ወርሒ', amharic: 'ወር', english: 'month'),
    TigrinyaObject(tigrinya: 'ዓመት', amharic: 'ዓመት', english: 'year'),
    TigrinyaObject(tigrinya: 'ድሕሪ', amharic: 'ቆየት ብሎ', english: 'after / later'),
    TigrinyaObject(tigrinya: 'ሰኑይ', amharic: 'ሰኞ', english: 'Monday'),
    TigrinyaObject(tigrinya: 'ሰሉስ', amharic: 'ማክሰኞ', english: 'Tuesday'),
    TigrinyaObject(tigrinya: 'ረቡዕ', amharic: 'ረቡዕ', english: 'Wednesday'),
    TigrinyaObject(tigrinya: 'ሓሙስ', amharic: 'ሓሙስ', english: 'Thursday'),
    TigrinyaObject(tigrinya: 'ዓርቢ', amharic: 'አርብ', english: 'Friday'),
    TigrinyaObject(tigrinya: 'ቀዳም', amharic: 'ቅዳሜ', english: 'Saturday'),
    TigrinyaObject(tigrinya: 'ሰንበት', amharic: 'እሁድ', english: 'Sunday'),
  ];

  // ───────────────────────── DEMONSTRATIVES ─────────────────────────

  static const List<TigrinyaObject> demonstratives = [
    TigrinyaObject(tigrinya: 'እዚ', amharic: 'ይህ', english: 'this (m.)'),
    TigrinyaObject(tigrinya: 'እዛ', amharic: 'ይቺ', english: 'this (f.)'),
    TigrinyaObject(tigrinya: 'እቲ', amharic: 'ያ', english: 'that (m.)'),
    TigrinyaObject(tigrinya: 'እታ', amharic: 'ያቺ', english: 'that (f.)'),
    TigrinyaObject(tigrinya: 'እዚኣቶም', amharic: 'እነዚህ', english: 'these (m.)'),
    TigrinyaObject(tigrinya: 'እዚኣተን', amharic: 'እነዚህ (ሴ)', english: 'these (f.)'),
  ];

  // ───────────────────────── PREPOSITIONS & CONNECTORS ─────────────────────────

  static const List<TigrinyaObject> prepositions = [
    TigrinyaObject(tigrinya: 'ኣብ', amharic: 'በ / ውስጥ', english: 'in / at'),
    TigrinyaObject(tigrinya: 'ናብ', amharic: 'ወደ', english: 'to'),
    TigrinyaObject(tigrinya: 'ካብ', amharic: 'ከ', english: 'from'),
    TigrinyaObject(tigrinya: 'ምስ', amharic: 'ከ...ጋር', english: 'with'),
    TigrinyaObject(tigrinya: 'ን...ን', amharic: 'እና', english: 'and (used as ን...ን around nouns)'),
    TigrinyaObject(tigrinya: 'ግን', amharic: 'ግን', english: 'but'),
    TigrinyaObject(tigrinya: 'ስለ', amharic: 'ስለ / ምክንያት', english: 'because'),
    TigrinyaObject(tigrinya: 'ስለዚ', amharic: 'ስለዚህ', english: 'therefore / so'),
  ];

  // ───────────────────────── COMMON PHRASES ─────────────────────────

  static const List<TigrinyaObject> commonPhrases = [
    TigrinyaObject(tigrinya: 'ሃበኒ', amharic: 'ስጠኝ', english: 'Give me (from a male)'),
    TigrinyaObject(tigrinya: 'ሃብኒ', amharic: 'ስጪኝ', english: 'Give me (from a female)'),
    TigrinyaObject(tigrinya: 'ንገሮ', amharic: 'ንገረው', english: 'Tell him'),
    TigrinyaObject(tigrinya: 'ንገራ', amharic: 'ንገራት', english: 'Tell her'),
    TigrinyaObject(tigrinya: 'የፍቅረካ', amharic: 'አፈቅርሃለሁ', english: 'I love you (to male)'),
    TigrinyaObject(tigrinya: 'የፍቅረኺ', amharic: 'አፈቅርሻለሁ', english: 'I love you (to female)'),
    TigrinyaObject(tigrinya: 'ኣይተረድኣንን', amharic: 'አይገባኝም', english: 'I don\'t understand'),
  ];

  // ───────────────────────── POSSESSIVE PRONOUNS ─────────────────────────

  static const List<TigrinyaObject> possessivePronouns = [
    TigrinyaObject(tigrinya: 'ናተይ', amharic: 'የኔ', english: 'Mine / My'),
    TigrinyaObject(tigrinya: 'ናትኻ', amharic: 'የአንተ', english: 'Yours / Your (m.)'),
    TigrinyaObject(tigrinya: 'ናትኺ', amharic: 'የአንቺ', english: 'Yours / Your (f.)'),
    TigrinyaObject(tigrinya: 'ናቱ', amharic: 'የሱ', english: 'His'),
    TigrinyaObject(tigrinya: 'ናታ', amharic: 'የሷ', english: 'Hers / Her'),
    TigrinyaObject(tigrinya: 'ናትና', amharic: 'የኛ', english: 'Ours / Our'),
    TigrinyaObject(tigrinya: 'ናትኹም', amharic: 'የእናንተ (ወ)', english: 'Yours / Your (pl. m.)'),
    TigrinyaObject(tigrinya: 'ናትኽን', amharic: 'የእናንተ (ሴ)', english: 'Yours / Your (pl. f.)'),
    TigrinyaObject(tigrinya: 'ናቶም', amharic: 'የነሱ (ወ)', english: 'Theirs / Their (m.)'),
    TigrinyaObject(tigrinya: 'ናተን', amharic: 'የነሱ (ሴ)', english: 'Theirs / Their (f.)'),
  ];

  // ───────────────────────── GREETINGS & BASICS ─────────────────────────

  static const List<TigrinyaObject> greetings = [
    TigrinyaObject(tigrinya: 'ሰላም', amharic: 'ሰላም', english: 'Hello'),
    TigrinyaObject(tigrinya: 'ከመይ ኣለኻ?', amharic: 'እንዴት ነህ?', english: 'How are you? (to a male)'),
    TigrinyaObject(tigrinya: 'ከመይ ኣለኺ?', amharic: 'እንዴት ነሽ?', english: 'How are you? (to a female)'),
    TigrinyaObject(tigrinya: 'ጽቡቕ', translit: 'Tsibuq', amharic: 'አሪፍ', english: 'Good / Nice'),
    TigrinyaObject(tigrinya: 'ደሓን', translit: 'Dehan', amharic: 'ደህና', english: 'Fine / Well / Okay'),
    TigrinyaObject(tigrinya: 'የቐንየለይ', amharic: 'አመሰግናለሁ', english: 'Thank you'),
    TigrinyaObject(tigrinya: 'በጃኻ', amharic: 'እባክህ', english: 'Please (to a male)'),
    TigrinyaObject(tigrinya: 'በጃኺ', amharic: 'እባክሽ', english: 'Please (to a female)'),
    TigrinyaObject(tigrinya: 'ይቕረታ', amharic: 'ይቅርታ', english: 'Sorry / Excuse me'),
    TigrinyaObject(tigrinya: 'እወ', amharic: 'አዎ', english: 'Yes'),
    TigrinyaObject(tigrinya: 'ኣይፋል', amharic: 'አይ', english: 'No'),
    TigrinyaObject(tigrinya: 'ደሓን ኩን', amharic: 'ደህና ሁን', english: 'Goodbye (to a male)'),
    TigrinyaObject(tigrinya: 'ደሓን ኩኒ', amharic: 'ደህና ሁኚ', english: 'Goodbye (to a female)'),
  ];


  // ───────────────────── COMPATIBLE OBJECTS ───────────────────

  static const Map<String, List<TigrinyaObject>> compatibleObjects = {
    'money': [
      TigrinyaObject(tigrinya: 'ገንዘብ', amharic: 'ገንዘብ', english: 'money'),
      TigrinyaObject(tigrinya: 'ዋጋ', amharic: 'ዋጋ', english: 'price'),
    ],
    'edible': [
      TigrinyaObject(tigrinya: 'እንጀራ', amharic: 'እንጀራ', english: 'injera'),
      TigrinyaObject(tigrinya: 'ባኒ', amharic: 'ዳቦ', english: 'bread'),
      TigrinyaObject(tigrinya: 'ብርቱኳን', amharic: 'ብርቱካን', english: 'orange'),
      TigrinyaObject(tigrinya: 'መግቢ', amharic: 'ምግብ', english: 'food'),
    ],
    'potable': [
      TigrinyaObject(tigrinya: 'ማይ', amharic: 'ውሃ', english: 'water'),
      TigrinyaObject(tigrinya: 'ቡን', amharic: 'ቡና', english: 'coffee'),
      TigrinyaObject(tigrinya: 'ሻሂ', amharic: 'ሻይ', english: 'tea'),
    ],
    'readable': [
      TigrinyaObject(tigrinya: 'መጽሐፍ', amharic: 'መጽሐፍ', english: 'book'),
      TigrinyaObject(tigrinya: 'ጋዜጣ', amharic: 'ጋዜጣ', english: 'newspaper'),
    ],
    'drivable': [
      TigrinyaObject(tigrinya: 'ቢሲክሌት', amharic: 'ሳይክል', english: 'bicycle'),
      TigrinyaObject(tigrinya: 'መኪና', amharic: 'መኪና', english: 'car'),
    ],
    'destination': [
      TigrinyaObject(tigrinya: 'ናብ ገዛ', amharic: 'ወደ ቤት', english: 'home / to the house'),
      TigrinyaObject(tigrinya: 'ናብ ከተማ', amharic: 'ወደ ከተማ', english: 'to the city'),
    ],
    'audible': [
      TigrinyaObject(tigrinya: 'ነቲ ወሬ', amharic: 'ወሬውን', english: 'the news'),
      TigrinyaObject(tigrinya: 'ድምጺ', amharic: 'ድምጽ', english: 'voice/sound'),
    ],
    'visual': [
      TigrinyaObject(tigrinya: 'ቴለቪዥን', amharic: 'ቴሌቪዥን', english: 'television'),
      TigrinyaObject(tigrinya: 'ስእሊ', amharic: 'ስዕል', english: 'picture'),
    ],
    'romantic_nouns': [
      TigrinyaObject(tigrinya: 'ንጉስ', translit: 'nigus', amharic: 'ንጉስ', english: 'king'),
      TigrinyaObject(tigrinya: 'ልበይ', translit: 'libey', amharic: 'ልቤ', english: 'my heart'),
      TigrinyaObject(tigrinya: 'ፍቕረይ', translit: 'fikrey', amharic: 'ፍቅሬ', english: 'my love'),
      TigrinyaObject(tigrinya: 'ምቁር ወዲ', translit: 'mqur wedi', amharic: 'ቆንጆ ልጅ', english: 'handsome guy'),
      TigrinyaObject(tigrinya: 'ህይወተይ', translit: 'hywetey', amharic: 'ህይወቴ', english: 'my life'),
      TigrinyaObject(tigrinya: 'ናተይ', translit: 'natey', amharic: 'የኔ', english: 'mine'),
      TigrinyaObject(tigrinya: 'ሓበሻ ወዲ', translit: 'habesha wedi', amharic: 'ሃበሻ ልጅ', english: 'Habesha guy'),
    ],
    'music': [
      TigrinyaObject(tigrinya: 'ደርፊ', translit: 'derfi', amharic: 'ዘፈን', english: 'song'),
      TigrinyaObject(tigrinya: 'ሙዚቃ', translit: 'muziqa', amharic: 'ሙዚቃ', english: 'music'),
      TigrinyaObject(tigrinya: 'ደርፋይ', translit: 'derfay', amharic: 'ዘፋኝ', english: 'singer'),
    ],
    'language': [
      TigrinyaObject(tigrinya: 'ትግርኛ', amharic: 'ትግርኛ', english: 'Tigrinya'),
      TigrinyaObject(tigrinya: 'እንግሊዝኛ', amharic: 'እንግሊዝኛ', english: 'English'),
      TigrinyaObject(tigrinya: 'ኣምሓርኛ', amharic: 'አማርኛ', english: 'Amharic'),
      TigrinyaObject(tigrinya: 'ቁሩብ ትግርኛ', amharic: 'ትንሽ ትግርኛ', english: 'a little Tigrinya'),
    ],
    'temporal': timeWords,
    'financial': [
      TigrinyaObject(tigrinya: 'ሒሳብ', amharic: 'ሂሳብ', english: 'the bill / check'),
      TigrinyaObject(tigrinya: 'ክራይ', amharic: 'ኪራይ', english: 'rent'),
      TigrinyaObject(tigrinya: 'ግብሪ', amharic: 'ግብር', english: 'tax / duty'),
    ],
    'location': [
      TigrinyaObject(tigrinya: 'ኣብ ገዛ', amharic: 'እቤት', english: 'at home / in the house'),
      TigrinyaObject(tigrinya: 'ኣብ ከተማ', amharic: 'ከተማ ውስጥ', english: 'in the city'),
      TigrinyaObject(tigrinya: 'ኣብ ስራሕ', amharic: 'ስራ ቦታ', english: 'at work'),
    ],
    'giveable': [
      TigrinyaObject(tigrinya: 'ገንዘብ', amharic: 'ገንዘብ', english: 'money'),
      TigrinyaObject(tigrinya: 'ስልኪ', amharic: 'ስልክ', english: 'phone'),
      TigrinyaObject(tigrinya: 'ቁጽሪ ስልኪ', amharic: 'ስልክ ቁጥር', english: 'phone number'),
      TigrinyaObject(tigrinya: 'ማይ', amharic: 'ውሃ', english: 'water'),
    ],
    'family': [
      TigrinyaObject(tigrinya: 'ኣቦ', amharic: 'አባት', english: 'father'),
      TigrinyaObject(tigrinya: 'ኣደ', amharic: 'እናት', english: 'mother'),
      TigrinyaObject(tigrinya: 'ሓው', amharic: 'ወንድም', english: 'brother'),
      TigrinyaObject(tigrinya: 'ሓፍቲ', amharic: 'እህት', english: 'sister'),
      TigrinyaObject(tigrinya: 'ውላድ', amharic: 'ልጅ', english: 'child / children'),
      TigrinyaObject(tigrinya: 'ሰብኣይ', amharic: 'ባል', english: 'husband'),
      TigrinyaObject(tigrinya: 'ሰበይቲ', amharic: 'ሚስት', english: 'wife'),
      TigrinyaObject(tigrinya: 'ዓርኪ', amharic: 'ጓደኛ', english: 'friend'),
    ],
    'places': [
      TigrinyaObject(tigrinya: 'ገዛ', amharic: 'ቤት', english: 'house'),
      TigrinyaObject(tigrinya: 'ቤት ትምህርቲ', amharic: 'ትምህርት ቤት', english: 'school'),
      TigrinyaObject(tigrinya: 'ሆስፒታል', amharic: 'ሆስፒታል', english: 'hospital'),
      TigrinyaObject(tigrinya: 'ዕዳጋ', amharic: 'ገበያ', english: 'market'),
      TigrinyaObject(tigrinya: 'ቤተ-ክርስትያን', amharic: 'ቤተ-ክርስትያን', english: 'church'),
    ],
    'body': [
      TigrinyaObject(tigrinya: 'ርእሲ', amharic: 'ራስ', english: 'head'),
      TigrinyaObject(tigrinya: 'ኢድ', amharic: 'እጅ', english: 'hand'),
      TigrinyaObject(tigrinya: 'ዓይኒ', amharic: 'ዐይን', english: 'eye'),
      TigrinyaObject(tigrinya: 'ሕማም', amharic: 'ህመም', english: 'sickness / pain'),
      TigrinyaObject(tigrinya: 'ልቢ', translit: 'libi', amharic: 'ልብ', english: 'heart'),
      TigrinyaObject(tigrinya: 'ገጽ', translit: 'geTsi', amharic: 'ፊት', english: 'face'),
      TigrinyaObject(tigrinya: 'ከንፈር', translit: 'kenfer', amharic: 'ከንፈር', english: 'lips'),
      TigrinyaObject(tigrinya: 'ኣፍ', translit: 'af', amharic: 'አፍ', english: 'mouth'),
    ],
    'objects': [
      TigrinyaObject(tigrinya: 'ማዕጾ', amharic: 'በር', english: 'door'),
      TigrinyaObject(tigrinya: 'መስኮት', amharic: 'መስኮት', english: 'window'),
      TigrinyaObject(tigrinya: 'ክዳን', amharic: 'ልብስ', english: 'clothes'),
    ],
  };

  // ───────────────────────── VERBS ─────────────────────────

  static final List<Verb> verbs = [
    VerbConjugator.generate(
      id: 'v_eat',
      lemma: 'ምብላዕ',
      translit: "Mibla'i",
      english: 'To eat',
      amharic: 'መብላት',
      categories: ['edible'],
      present: ConjugationMap({
        'p1': '{እ}በልዕ', 'p2': '{ት}በልዕ', 'p3': '{ት}በል{ዒ}', 'p4': '{ይ}በልዕ', 'p5': '{ት}በልዕ', 
        'p6': '{ን}በልዕ', 'p7': '{ት}በል{ዑ}', 'p8': '{ት}በል{ዓ}', 'p9': '{ይ}በል{ዑ}', 'p10': '{ይ}በል{ዓ}',
      }),
      past: ConjugationMap({
        'p1': 'በሊ{ዐ}', 'p2': 'በሊ{ዕኻ}', 'p3': 'በሊ{ዕኺ}', 'p4': 'በሊ{ዑ}', 'p5': 'በሊ{ዓ}', 
        'p6': 'በሊ{ዕና}', 'p7': 'በሊ{ዕኹም}', 'p8': 'በሊ{ዕኽን}', 'p9': 'በሊ{ዖም}', 'p10': 'በሊ{ዐን}',
      }),
    ),
    VerbConjugator.generate(
      id: 'v_drink',
      lemma: 'ምስታይ',
      translit: 'Mistay',
      english: 'To drink',
      amharic: 'መጠጣት',
      categories: ['potable'],
      present: ConjugationMap({
        'p1': '{እ}ሰቲ', 'p2': '{ት}ሰቲ', 'p3': '{ት}ሰት{ዪ}', 'p4': '{ይ}ሰቲ', 'p5': '{ት}ሰቲ', 
        'p6': '{ን}ሰቲ', 'p7': '{ት}ሰት{ዩ}', 'p8': '{ት}ሰት{ያ}', 'p9': '{ይ}ሰት{ዩ}', 'p10': '{ይ}ሰት{ያ}',
      }),
      past: ConjugationMap({
        'p1': 'ሰት{የ}', 'p2': 'ሰቲ{ኻ}', 'p3': 'ሰቲ{ኺ}', 'p4': 'ሰት{ዩ}', 'p5': 'ሰት{ያ}', 
        'p6': 'ሰቲ{ና}', 'p7': 'ሰቲ{ኹም}', 'p8': 'ሰቲ{ኽን}', 'p9': 'ሰት{ዮም}', 'p10': 'ሰት{የን}',
      }),
    ),
    VerbConjugator.generate(
      id: 'v_go',
      lemma: 'ምኻድ',
      translit: 'Mikhad',
      english: 'To go',
      amharic: 'መሄድ',
      categories: ['destination'],
      present: ConjugationMap({
        'p1': '{እ}ኸይድ', 'p2': '{ት}ኸይድ', 'p3': '{ት}ኸይ{ዲ}', 'p4': '{ይ}ኸይድ', 'p5': '{ት}ኸይድ', 
        'p6': '{ን}ኸይድ', 'p7': '{ት}ኸይ{ዱ}', 'p8': '{ት}ኸይ{ዳ}', 'p9': '{ይ}ኸይ{ዱ}', 'p10': '{ይ}ኸይ{ዳ}',
      }),
      past: ConjugationMap({
        'p1': 'ኸይ{ደ}', 'p2': 'ኸይድ{ካ}', 'p3': 'ኸይድ{ኪ}', 'p4': 'ኸይ{ዱ}', 'p5': 'ኸይ{ዳ}', 
        'p6': 'ኸይድ{ና}', 'p7': 'ኸይድ{ኩም}', 'p8': 'ኸይድ{ክን}', 'p9': 'ኸይ{ዶም}', 'p10': 'ኸይ{ደን}',
      }),
    ),
    VerbConjugator.generate(
      id: 'v_read',
      lemma: 'ምንባብ',
      translit: 'Menbab',
      english: 'To read',
      amharic: 'ማንበብ',
      categories: ['readable'],
      present: ConjugationMap({
        'p1': '{ኣ}ነብብ', 'p2': '{ተ}ነብብ', 'p3': '{ተ}ነብ{ቢ}', 'p4': '{የ}ንብብ', 'p5': '{ተ}ነብብ', 
        'p6': '{ነ}ነብብ', 'p7': '{ተ}ነብ{ቡ}', 'p8': '{ተ}ነብ{ባ}', 'p9': '{የ}ንብ{ቡ}', 'p10': '{የ}ንብ{ባ}',
      }),
      past: ConjugationMap({
        'p1': 'ኣንቢ{በ}', 'p2': 'ኣንቢብ{ካ}', 'p3': 'ኣንቢብ{ኪ}', 'p4': 'ኣንቢ{ቡ}', 'p5': 'ኣንቢ{ባ}', 
        'p6': 'ኣንቢብ{ና}', 'p7': 'ኣንቢብ{ኩም}', 'p8': 'ኣንቢብ{ክን}', 'p9': 'ኣንቢ{ቦም}', 'p10': 'ኣንቢ{በን}',
      }),
    ),
    VerbConjugator.generate(
      id: 'v_ride',
      lemma: 'ምዝዋር',
      translit: 'Mizwar',
      english: 'To ride/drive',
      amharic: 'መንዳት',
      categories: ['drivable'],
      present: ConjugationMap({
        'p1': '{እ}ዝውር', 'p2': '{ት}ዝውር', 'p3': '{ት}ዘው{ሪ}', 'p4': '{ይ}ዝውር', 'p5': '{ት}ዝውር', 
        'p6': '{ን}ዝውር', 'p7': '{ት}ዘው{ሩ}', 'p8': '{ት}ዘው{ራ}', 'p9': '{ይ}ዘው{ሩ}', 'p10': '{ይ}ዘው{ራ}',
      }),
      past: ConjugationMap({
        'p1': 'ዘዊ{ረ}', 'p2': 'ዘዊር{ካ}', 'p3': 'ዘዊር{ኪ}', 'p4': 'ዘዊ{ሩ}', 'p5': 'ዘዊ{ራ}', 
        'p6': 'ዘዊር{ና}', 'p7': 'ዘዊር{ኩም}', 'p8': 'ዘዊር{ክን}', 'p9': 'ዘዊ{ሮም}', 'p10': 'ዘዊ{ረን}',
      }),
    ),
    VerbConjugator.generate(
      id: 'v_speak',
      lemma: 'ምዝራብ',
      translit: 'Mizrab',
      english: 'To speak',
      amharic: 'መናገር',
      categories: ['language'],
      present: ConjugationMap({
        'p1': '{እ}ዛረብ', 'p2': '{ት}ዛረብ', 'p3': '{ት}ዛረ{ቢ}', 'p4': '{ይ}ዛረብ', 'p5': '{ት}ዛረብ', 
        'p6': '{ን}ዛረብ', 'p7': '{ት}ዛረ{ቡ}', 'p8': '{ት}ዛረ{ባ}', 'p9': '{ይ}ዛረ{ቡ}', 'p10': '{ይ}ዛረ{ባ}',
      }),
      past: ConjugationMap({
        'p1': 'ተዛሪ{በ}', 'p2': 'ተዛሪብ{ካ}', 'p3': 'ተዛሪብ{ኪ}', 'p4': 'ተዛሪ{ቡ}', 'p5': 'ተዛሪ{ባ}', 
        'p6': 'ተዛሪብ{ና}', 'p7': 'ተዛሪብ{ኩም}', 'p8': 'ተዛሪብ{ክን}', 'p9': 'ተዛሪ{ቦም}', 'p10': 'ተዛሪ{በን}',
      }),
    ),
    VerbConjugator.generate(
      id: 'v_hear',
      lemma: 'ምስማዕ',
      translit: "Misma'i",
      english: 'To hear',
      amharic: 'መስማት',
      categories: ['audible'],
      present: ConjugationMap({
        'p1': '{እ}ሰምዕ', 'p2': '{ት}ሰምዕ', 'p3': '{ት}ሰም{ዒ}', 'p4': '{ይ}ሰምዕ', 'p5': '{ት}ሰምዕ', 
        'p6': '{ን}ሰምዕ', 'p7': '{ት}ሰም{ዑ}', 'p8': '{ት}ሰም{ዓ}', 'p9': '{ይ}ሰም{ዑ}', 'p10': '{ይ}ሰም{ዓ}',
      }),
      past: ConjugationMap({
        'p1': 'ሰሚ{ዐ}', 'p2': 'ሰሚዕ{ኻ}', 'p3': 'ሰሚዕ{ኺ}', 'p4': 'ሰሚ{ዑ}', 'p5': 'ሰሚ{ዓ}', 
        'p6': 'ሰሚዕ{ና}', 'p7': 'ሰሚዕ{ኹም}', 'p8': 'ሰሚዕ{ኽን}', 'p9': 'ሰሚ{ዖም}', 'p10': 'ሰሚ{ዐን}',
      }),
    ),
    VerbConjugator.generate(
      id: 'v_know',
      lemma: 'ምፍላጥ',
      translit: 'Miflat',
      english: 'To know',
      amharic: 'ማወቅ',
      categories: ['language', 'romantic_nouns'],
      present: ConjugationMap({
        'p1': '{እ}ፈልጥ', 'p2': '{ት}ፈልጥ', 'p3': '{ት}ፈል{ጢ}', 'p4': '{ይ}ፈልጥ', 'p5': '{ት}ፈልጥ', 
        'p6': '{ን}ፈልጥ', 'p7': '{ት}ፈል{ጡ}', 'p8': '{ት}ፈል{ጣ}', 'p9': '{ይ}ፈል{ጡ}', 'p10': '{ይ}ፈል{ጣ}',
      }),
      past: ConjugationMap({
        'p1': 'ፈሊ{ጠ}', 'p2': 'ፈሊጥ{ካ}', 'p3': 'ፈሊጥ{ኪ}', 'p4': 'ፈሊ{ጡ}', 'p5': 'ፈሊ{ጣ}', 
        'p6': 'ፈሊጥ{ና}', 'p7': 'ፈሊጥ{ኩም}', 'p8': 'ፈሊጥ{ክን}', 'p9': 'ፈሊ{ጦም}', 'p10': 'ፈሊ{ጠን}',
      }),
    ),
    VerbConjugator.generate(
      id: 'v_come',
      lemma: 'ምምጻእ',
      translit: "Mimtsa'i",
      english: 'To come',
      amharic: 'መምጣት',
      categories: ['destination'],
      present: ConjugationMap({
        'p1': '{እ}መጽእ', 'p2': '{ት}መጽእ', 'p3': '{ት}መጽ{ኢ}', 'p4': '{ይ}መጽእ', 'p5': '{ት}መጽእ', 
        'p6': '{ን}መጽእ', 'p7': '{ት}መጽ{ኡ}', 'p8': '{ት}መጽ{ኣ}', 'p9': '{ይ}መጽ{ኡ}', 'p10': '{ይ}መጽ{ኣ}',
      }),
      past: ConjugationMap({
        'p1': 'መጺ{አ}', 'p2': 'መጺ{እኻ}', 'p3': 'መጺ{እኺ}', 'p4': 'መጺ{ኡ}', 'p5': 'መጺ{ኣ}', 
        'p6': 'መጺ{እና}', 'p7': 'መጺ{እኹም}', 'p8': 'መጺ{እኽን}', 'p9': 'መጺ{ኦም}', 'p10': 'መጺ{አን}',
      }),
    ),
    VerbConjugator.generate(
      id: 'v_see',
      lemma: 'ምርኣይ',
      translit: "Mir'ay",
      english: 'To see',
      amharic: 'ማየት',
      categories: ['visual', 'romantic_nouns'],
      present: ConjugationMap({
        'p1': '{እ}ርኢ', 'p2': '{ት}ርኢ', 'p3': '{ት}ርእ{ዪ}', 'p4': '{ይ}ርኢ', 'p5': '{ት}ርኢ', 
        'p6': '{ን}ርኢ', 'p7': '{ት}ርእ{ዩ}', 'p8': '{ት}ርእ{ያ}', 'p9': '{ይ}ርእ{ዩ}', 'p10': '{ይ}ርእ{ያ}',
      }),
      past: ConjugationMap({
        'p1': 'ርእ{የ}', 'p2': 'ርኢ{ኻ}', 'p3': 'ርኢ{ኺ}', 'p4': 'ርእ{ዩ}', 'p5': 'ርእ{ያ}', 
        'p6': 'ርኢ{ና}', 'p7': 'ርኢ{ኹም}', 'p8': 'ርኢ{ኽን}', 'p9': 'ርእ{ዮም}', 'p10': 'ርእ{የን}',
      }),
    ),
    VerbConjugator.generate(
      id: 'v_want',
      lemma: 'ምድላይ',
      translit: 'Midlay',
      english: 'To want',
      amharic: 'መፈለግ',
      categories: ['edible', 'potable', 'readable', 'drivable', 'audible', 'visual', 'romantic_nouns'],
      present: ConjugationMap({
        'p1': '{እ}ደሊ', 'p2': '{ት}ደሊ', 'p3': '{ት}ደል{ዪ}', 'p4': '{ይ}ደሊ', 'p5': '{ት}ደሊ', 
        'p6': '{ን}ደሊ', 'p7': '{ት}ደል{ዩ}', 'p8': '{ት}ደል{ያ}', 'p9': '{ይ}ደል{ዩ}', 'p10': '{ይ}ደል{ያ}',
      }),
      past: ConjugationMap({
        'p1': 'ደሊ{የ}', 'p2': 'ደሊ{ኻ}', 'p3': 'ደሊ{ኺ}', 'p4': 'ደል{ዩ}', 'p5': 'ደል{ያ}', 
        'p6': 'ደሊ{ና}', 'p7': 'ደሊ{ኹም}', 'p8': 'ደሊ{ኽን}', 'p9': 'ደል{ዮም}', 'p10': 'ደል{የን}',
      }),
    ),
    VerbConjugator.generate(
      id: 'v_wait',
      lemma: 'ምጽባይ',
      translit: 'Mitsbay',
      english: 'To wait',
      amharic: 'መጠበቅ',
      categories: ['location', 'temporal'], // Can map to hotel/restaurant or time
      present: ConjugationMap({
        'p1': '{እ}ጽበ', 'p2': '{ት}ጽበ', 'p3': '{ት}ጽበ{ዪ}', 'p4': '{ይ}ጽበ', 'p5': '{ት}ጽበ', 
        'p6': '{ን}ጽበ', 'p7': '{ት}ጽበ{ዩ}', 'p8': '{ት}ጽበ{ያ}', 'p9': '{ይ}ጽበ{ዩ}', 'p10': '{ይ}ጽበ{ያ}',
      }),
      past: ConjugationMap({
        'p1': 'ጸቢ{የ}', 'p2': 'ጸቢ{ኻ}', 'p3': 'ጸቢ{ኺ}', 'p4': 'ጸቢ{ዩ}', 'p5': 'ጸቢ{ያ}', 
        'p6': 'ጸቢ{ና}', 'p7': 'ጸቢ{ኹም}', 'p8': 'ጸቢ{ኽን}', 'p9': 'ጸቢ{ዮም}', 'p10': 'ጸቢ{የን}',
      }),
    ),
    VerbConjugator.generate(
      id: 'v_meet',
      lemma: 'ምርካብ',
      translit: 'Mirkab',
      english: 'To meet / find',
      amharic: 'ማግኘት',
      categories: ['location'], 
      present: ConjugationMap({
        'p1': '{እ}ረክብ', 'p2': '{ት}ረክብ', 'p3': '{ት}ረኽ{ቢ}', 'p4': '{ይ}ረክብ', 'p5': '{ት}ረክብ', 
        'p6': '{ን}ረክብ', 'p7': '{ት}ረኽ{ቡ}', 'p8': '{ት}ረኽ{ባ}', 'p9': '{ይ}ረኽ{ቡ}', 'p10': '{ይ}ረኽ{ባ}',
      }),
      past: ConjugationMap({
        'p1': 'ረኺ{በ}', 'p2': 'ረኺብ{ካ}', 'p3': 'ረኺብ{ኪ}', 'p4': 'ረኺ{ቡ}', 'p5': 'ረኺ{ባ}', 
        'p6': 'ረኺብ{ና}', 'p7': 'ረኺብ{ኩም}', 'p8': 'ረኺብ{ክን}', 'p9': 'ረኺ{ቦም}', 'p10': 'ረኺ{በን}',
      }),
    ),
    VerbConjugator.generate(
      id: 'v_pay',
      lemma: 'ምኽፋል',
      translit: 'Mikhfal',
      english: 'To pay',
      amharic: 'መክፈል',
      categories: ['financial'],
      present: ConjugationMap({
        'p1': '{እ}ኸፍል', 'p2': '{ት}ኸፍል', 'p3': '{ት}ኸፍ{ሊ}', 'p4': '{ይ}ኸፍል', 'p5': '{ት}ኸፍል', 
        'p6': '{ን}ኸፍል', 'p7': '{ት}ኸፍ{ሉ}', 'p8': '{ት}ኸፍ{ላ}', 'p9': '{ይ}ኸፍ{ሉ}', 'p10': '{ይ}ኸፍ{ላ}',
      }),
      past: ConjugationMap({
        'p1': 'ከፊ{ለ}', 'p2': 'ከፊል{ካ}', 'p3': 'ከፊል{ኪ}', 'p4': 'ከፊ{ሉ}', 'p5': 'ከፊ{ላ}', 
        'p6': 'ከፊል{ና}', 'p7': 'ከፊል{ኩም}', 'p8': 'ከፊል{ክን}', 'p9': 'ከፊ{ሎም}', 'p10': 'ከፊ{ለን}',
      }),
    ),
    VerbConjugator.generate(
      id: 'v_love',
      lemma: 'ምፍታው',
      translit: 'Miftew',
      english: 'To love / To like',
      amharic: 'መውደድ',
      categories: ['edible', 'potable', 'language', 'romantic_nouns'],
      present: ConjugationMap({
        'p1': '{እ}ፈቱ', 'p2': '{ት}ፈቱ', 'p3': '{ት}ፈት{ዊ}', 'p4': '{ይ}ፈቱ', 'p5': '{ት}ፈቱ', 
        'p6': '{ን}ፈቱ', 'p7': '{ት}ፈት{ዉ}', 'p8': '{ት}ፈት{ዋ}', 'p9': '{ይ}ፈት{ዉ}', 'p10': '{ይ}ፈት{ዋ}',
      }),
      past: ConjugationMap({
        'p1': 'ፈቶ{ኹ}', 'p2': 'ፈቶ{ኻ}', 'p3': 'ፈቶ{ኺ}', 'p4': 'ፈተ{ወ}', 'p5': 'ፈተ{ወት}', 
        'p6': 'ፈቶ{ና}', 'p7': 'ፈቶ{ኹም}', 'p8': 'ፈቶ{ኽን}', 'p9': 'ፈተ{ዉ}', 'p10': 'ፈተ{ዋ}',
      }),
    ),
    VerbConjugator.generate(
      id: 'v_give',
      lemma: 'ምሃብ',
      translit: 'Mihab',
      english: 'To give',
      amharic: 'መስጠት',
      categories: ['giveable'],
      present: ConjugationMap({
        'p1': '{እ}ህብ', 'p2': '{ት}ህብ', 'p3': '{ት}ህ{ቢ}', 'p4': '{ይ}ህብ', 'p5': '{ት}ህብ', 
        'p6': '{ን}ህብ', 'p7': '{ት}ህ{ቡ}', 'p8': '{ት}ህ{ባ}', 'p9': '{ይ}ህ{ቡ}', 'p10': '{ይ}ህ{ባ}',
      }),
      past: ConjugationMap({
        'p1': 'ሃብ{ኩ}', 'p2': 'ሃብ{ካ}', 'p3': 'ሃብ{ኪ}', 'p4': 'ሃ{በ}', 'p5': 'ሃ{በት}', 
        'p6': 'ሃብ{ና}', 'p7': 'ሃብ{ኩም}', 'p8': 'ሃብ{ክን}', 'p9': 'ሃ{ቡ}', 'p10': 'ሃ{ባ}',
      }),
    ),
    VerbConjugator.generate(
      id: 'v_work',
      lemma: 'ምስራሕ',
      translit: 'Misrah',
      english: 'To work',
      amharic: 'መስራት',
      categories: ['location'],
      present: ConjugationMap({
        'p1': '{እ}ሰርሕ', 'p2': '{ት}ሰርሕ', 'p3': '{ት}ሰር{ሒ}', 'p4': '{ይ}ሰርሕ', 'p5': '{ት}ሰርሕ', 
        'p6': '{ን}ሰርሕ', 'p7': '{ት}ሰር{ሑ}', 'p8': '{ት}ሰር{ሓ}', 'p9': '{ይ}ሰር{ሑ}', 'p10': '{ይ}ሰር{ሓ}',
      }),
      past: ConjugationMap({
        'p1': 'ሰራሕ{ኩ}', 'p2': 'ሰራሕ{ካ}', 'p3': 'ሰራሕ{ኪ}', 'p4': 'ሰር{ሐ}', 'p5': 'ሰር{ሐት}', 
        'p6': 'ሰራሕ{ና}', 'p7': 'ሰራሕ{ኩም}', 'p8': 'ሰራሕ{ክን}', 'p9': 'ሰር{ሑ}', 'p10': 'ሰር{ሓ}',
      }),
    ),
    VerbConjugator.generate(
      id: 'v_write',
      lemma: 'ምጽሓፍ',
      translit: 'Mits\'haf',
      english: 'To write',
      amharic: 'መጻፍ',
      categories: ['giveable'],
      present: ConjugationMap({
        'p1': '{እ}ጽሕፍ', 'p2': '{ት}ጽሕፍ', 'p3': '{ት}ጽሕ{ፊ}', 'p4': '{ይ}ጽሕፍ', 'p5': '{ት}ጽሕፍ', 
        'p6': '{ን}ጽሕፍ', 'p7': '{ት}ጽሕ{ፉ}', 'p8': '{ት}ጽሕ{ፋ}', 'p9': '{ይ}ጽሕ{ፉ}', 'p10': '{ይ}ጽሕ{ፋ}',
      }),
      past: ConjugationMap({
        'p1': 'ጸሓፍ{ኩ}', 'p2': 'ጸሓፍ{ካ}', 'p3': 'ጸሓፍ{ኪ}', 'p4': 'ጸሓ{ፈ}', 'p5': 'ጸሓ{ፈት}', 
        'p6': 'ጸሓፍ{ና}', 'p7': 'ጸሓፍ{ኩም}', 'p8': 'ጸሓፍ{ክን}', 'p9': 'ጸሓ{ፉ}', 'p10': 'ጸሓ{ፋ}',
      }),
    ),
    VerbConjugator.generate(
      id: 'v_sleep',
      lemma: 'ምድቃስ',
      translit: 'Midqas',
      english: 'To sleep',
      amharic: 'መተኛት',
      categories: ['location'],
      present: ConjugationMap({
        'p1': '{እ}ድቅስ', 'p2': '{ት}ድቅስ', 'p3': '{ት}ድቅ{ሲ}', 'p4': '{ይ}ድቅስ', 'p5': '{ት}ድቅስ', 
        'p6': '{ን}ድቅስ', 'p7': '{ት}ድቅ{ሱ}', 'p8': '{ት}ድቅ{ሳ}', 'p9': '{ይ}ድቅ{ሱ}', 'p10': '{ይ}ድቅ{ሳ}',
      }),
      past: ConjugationMap({
        'p1': 'ደቀስ{ኩ}', 'p2': 'ደቀስ{ካ}', 'p3': 'ደቀስ{ኪ}', 'p4': 'ደቀ{ሰ}', 'p5': 'ደቀ{ሰት}', 
        'p6': 'ደቀስ{ና}', 'p7': 'ደቀስ{ኩም}', 'p8': 'ደቀስ{ክን}', 'p9': 'ደቀ{ሱ}', 'p10': 'ደቀ{ሳ}',
      }),
    ),
    VerbConjugator.generate(
      id: 'v_learn',
      lemma: 'ምምሃር',
      translit: 'Mimhar',
      english: 'To learn / study',
      amharic: 'መማር',
      categories: ['language'],
      present: ConjugationMap({
        'p1': '{እ}ምሃር', 'p2': '{ት}ምሃር', 'p3': '{ት}ምሃ{ሪ}', 'p4': '{ይ}ምሃር', 'p5': '{ት}ምሃር', 
        'p6': '{ን}ምሃር', 'p7': '{ት}ምሃ{ሩ}', 'p8': '{ት}ምሃ{ራ}', 'p9': '{ይ}ምሃ{ሩ}', 'p10': '{ይ}ምሃ{ራ}',
      }),
      past: ConjugationMap({
        'p1': 'ተምሃር{ኩ}', 'p2': 'ተምሃር{ካ}', 'p3': 'ተምሃር{ኪ}', 'p4': 'ተምሃ{ረ}', 'p5': 'ተምሃ{ረት}', 
        'p6': 'ተምሃር{ና}', 'p7': 'ተምሃር{ኩም}', 'p8': 'ተምሃር{ክን}', 'p9': 'ተምሃ{ሩ}', 'p10': 'ተምሃ{ራ}',
      }),
    ),
    VerbConjugator.generate(
      id: 'v_buy',
      lemma: 'ምግዛእ',
      translit: 'Migza\'',
      english: 'To buy',
      amharic: 'መግዛት',
      categories: ['edible', 'potable', 'objects'],
      present: ConjugationMap({
        'p1': '{እ}ገዝእ', 'p2': '{ት}ገዝእ', 'p3': '{ት}ገዝ{ኢ}', 'p4': '{ይ}ገዝእ', 'p5': '{ት}ገዝእ', 
        'p6': '{ን}ገዝእ', 'p7': '{ት}ገዝ{ኡ}', 'p8': '{ት}ገዝ{ኣ}', 'p9': '{ይ}ገዝ{ኡ}', 'p10': '{ይ}ገዝ{ኣ}',
      }),
      past: ConjugationMap({
        'p1': 'ገዛእ{ኩ}', 'p2': 'ገዛእ{ካ}', 'p3': 'ገዛእ{ኪ}', 'p4': 'ገዝ{አ}', 'p5': 'ገዝ{አት}', 
        'p6': 'ገዛእ{ና}', 'p7': 'ገዛእ{ኩም}', 'p8': 'ገዛእ{ክን}', 'p9': 'ገዝ{ኡ}', 'p10': 'ገዝ{ኣ}',
      }),
    ),
    VerbConjugator.generate(
      id: 'v_open',
      lemma: 'ምኽፋት',
      translit: 'Mikhfat',
      english: 'To open',
      amharic: 'መክፈት',
      categories: ['objects'],
      present: ConjugationMap({
        'p1': '{እ}ኸፍት', 'p2': '{ት}ኸፍት', 'p3': '{ት}ኸፍ{ቲ}', 'p4': '{ይ}ኸፍት', 'p5': '{ት}ኸፍት', 
        'p6': '{ን}ኸፍት', 'p7': '{ት}ኸፍ{ቱ}', 'p8': '{ት}ኸፍ{ታ}', 'p9': '{ይ}ኸፍ{ቱ}', 'p10': '{ይ}ኸፍ{ታ}',
      }),
      past: ConjugationMap({
        'p1': 'ከፈት{ኩ}', 'p2': 'ከፈት{ካ}', 'p3': 'ከፈት{ኪ}', 'p4': 'ከፈ{ተ}', 'p5': 'ከፈ{ተት}', 
        'p6': 'ከፈት{ና}', 'p7': 'ከፈት{ኩም}', 'p8': 'ከፈት{ክን}', 'p9': 'ከፈ{ቱ}', 'p10': 'ከፈ{ታ}',
      }),
    ),
    VerbConjugator.generate(
      id: 'v_close',
      lemma: 'ምዕጻው',
      translit: 'Mi\'tsaw',
      english: 'To close',
      amharic: 'መዝጋት',
      categories: ['objects'],
      present: ConjugationMap({
        'p1': '{እ}ዓጹ', 'p2': '{ት}ዓጹ', 'p3': '{ት}ዓጽ{ዊ}', 'p4': '{ይ}ዓጹ', 'p5': '{ት}ዓጹ', 
        'p6': '{ን}ዓጹ', 'p7': '{ት}ዓጽ{ዉ}', 'p8': '{ት}ዓጽ{ዋ}', 'p9': '{ይ}ዓጽ{ዉ}', 'p10': '{ይ}ዓጽ{ዋ}',
      }),
      past: ConjugationMap({
        'p1': 'ዓጾ{ኹ}', 'p2': 'ዓጾ{ኻ}', 'p3': 'ዓጾ{ኺ}', 'p4': 'ዓጸ{ወ}', 'p5': 'ዓጸ{ወት}', 
        'p6': 'ዓጾ{ና}', 'p7': 'ዓጾ{ኹም}', 'p8': 'ዓጾ{ኽን}', 'p9': 'ዓጸ{ዉ}', 'p10': 'ዓጸ{ዋ}',
      }),
    ),
    VerbConjugator.generate(
      id: 'v_think',
      lemma: 'ምሕሳብ',
      translit: 'Mihsab',
      english: 'To think',
      amharic: 'ማሰብ',
      categories: ['temporal'],
      present: ConjugationMap({
        'p1': '{እ}ሓስብ', 'p2': '{ት}ሓስብ', 'p3': '{ት}ሓስ{ቢ}', 'p4': '{ይ}ሓስብ', 'p5': '{ት}ሓስብ', 
        'p6': '{ን}ሓስብ', 'p7': '{ት}ሓስ{ቡ}', 'p8': '{ት}ሓስ{ባ}', 'p9': '{ይ}ሓስ{ቡ}', 'p10': '{ይ}ሓስ{ባ}',
      }),
      past: ConjugationMap({
        'p1': 'ሓሰብ{ኩ}', 'p2': 'ሓሰብ{ካ}', 'p3': 'ሓሰብ{ኪ}', 'p4': 'ሓሰ{በ}', 'p5': 'ሓሰ{በት}', 
        'p6': 'ሓሰብ{ና}', 'p7': 'ሓሰብ{ኩም}', 'p8': 'ሓሰብ{ክን}', 'p9': 'ሓሰ{ቡ}', 'p10': 'ሓሰ{ባ}',
      }),
    ),
    VerbConjugator.generate(
      id: 'v_sit',
      lemma: 'ምቕማጥ',
      translit: 'Miqmat\'',
      english: 'To sit',
      amharic: 'መቀመጥ',
      categories: ['location'],
      present: ConjugationMap({
        'p1': '{እ}ቕመጥ', 'p2': '{ት}ቕመጥ', 'p3': '{ት}ቕመ{ጢ}', 'p4': '{ይ}ቕመጥ', 'p5': '{ት}ቕመጥ', 
        'p6': '{ን}ቕመጥ', 'p7': '{ት}ቕመ{ጡ}', 'p8': '{ት}ቕመ{ጣ}', 'p9': '{ይ}ቕመ{ጡ}', 'p10': '{ይ}ቕመ{ጣ}',
      }),
      past: ConjugationMap({
        'p1': 'ተቐመጥ{ኩ}', 'p2': 'ተቐመጥ{ካ}', 'p3': 'ተቐመጥ{ኪ}', 'p4': 'ተቐመ{ጠ}', 'p5': 'ተቐመ{ጠት}', 
        'p6': 'ተቐመጥ{ና}', 'p7': 'ተቐመጥ{ኩም}', 'p8': 'ተቐመጥ{ክን}', 'p9': 'ተቐመ{ጡ}', 'p10': 'ተቐመ{ጣ}',
      }),
    ),
    VerbConjugator.generate(
      id: 'v_live',
      lemma: 'ምንባር',
      translit: 'Minbar',
      english: 'To live / stay',
      amharic: 'መኖር',
      categories: ['location'],
      present: ConjugationMap({
        'p1': '{እ}ነብር', 'p2': '{ት}ነብር', 'p3': '{ት}ነብ{ሪ}', 'p4': '{ይ}ነብር', 'p5': '{ት}ነብር', 
        'p6': '{ን}ነብር', 'p7': '{ት}ነብ{ሩ}', 'p8': '{ት}ነብ{ራ}', 'p9': '{ይ}ነብ{ሩ}', 'p10': '{ይ}ነብ{ራ}',
      }),
      past: ConjugationMap({
        'p1': 'ነበር{ኩ}', 'p2': 'ነበር{ካ}', 'p3': 'ነበር{ኪ}', 'p4': 'ነበ{ረ}', 'p5': 'ነበ{ረት}', 
        'p6': 'ነበር{ና}', 'p7': 'ነበር{ኩም}', 'p8': 'ነበር{ክን}', 'p9': 'ነበ{ሩ}', 'p10': 'ነበ{ራ}',
      }),
    ),
    VerbConjugator.generate(
      id: 'v_miss',
      lemma: 'ምናፋቕ',
      translit: 'Menafaq',
      english: 'To miss',
      amharic: 'መናፈቅ',
      categories: ['romantic_nouns', 'family'],
      present: ConjugationMap({
        'p1': '{እ}ናፍቕ', 'p2': '{ት}ናፍቕ', 'p3': '{ት}ናፍ{ቒ}', 'p4': '{ይ}ናፍቕ', 'p5': '{ት}ናፍቕ', 
        'p6': '{ን}ናፍቕ', 'p7': '{ት}ናፍ{ቑ}', 'p8': '{ት}ናፍ{ቓ}', 'p9': '{ይ}ናፍ{ቑ}', 'p10': '{ይ}ናፍ{ቓ}',
      }),
      past: ConjugationMap({
        'p1': 'ናፈቕ{ኩ}', 'p2': 'ናፈቕ{ካ}', 'p3': 'ናፈቕ{ኪ}', 'p4': 'ናፈ{ቐ}', 'p5': 'ናፈ{ቐት}', 
        'p6': 'ናፈቕ{ና}', 'p7': 'ናፈቕ{ኩም}', 'p8': 'ናፈቕ{ክን}', 'p9': 'ናፈ{ቑ}', 'p10': 'ናፈ{ቓ}',
      }),
    ),
    VerbConjugator.generate(
      id: 'v_kiss',
      lemma: 'ምስዓም',
      translit: "Mes'am",
      english: 'To kiss',
      amharic: 'መሳም',
      categories: ['romantic_nouns', 'body'],
      present: ConjugationMap({
        'p1': '{እ}ስዕም', 'p2': '{ት}ስዕም', 'p3': '{ት}ስዕ{ሚ}', 'p4': '{ይ}ስዕም', 'p5': '{ት}ስዕም', 
        'p6': '{ን}ስዕም', 'p7': '{ት}ስዕ{ሙ}', 'p8': '{ት}ስዕ{ማ}', 'p9': '{ይ}ስዕ{ሙ}', 'p10': '{ይ}ስዕ{ማ}',
      }),
      past: ConjugationMap({
        'p1': 'ስዓም{ኩ}', 'p2': 'ስዓም{ካ}', 'p3': 'ስዓም{ኪ}', 'p4': 'ስዓ{መ}', 'p5': 'ስዓ{መት}', 
        'p6': 'ስዓም{ና}', 'p7': 'ስዓም{ኩም}', 'p8': 'ስዓም{ክን}', 'p9': 'ስዓ{ሙ}', 'p10': 'ስዓ{ማ}',
      }),
    ),
    VerbConjugator.generate(
      id: 'v_touch',
      lemma: 'ምትንካፍ',
      translit: 'Metnkaf',
      english: 'To touch',
      amharic: 'መንካት',
      categories: ['romantic_nouns', 'body'],
      present: ConjugationMap({
        'p1': '{እ}ትንክፍ', 'p2': '{ት}ትንክፍ', 'p3': '{ት}ትንኽ{ፊ}', 'p4': '{ይ}ትንክፍ', 'p5': '{ት}ትንክፍ', 
        'p6': '{ን}ትንክፍ', 'p7': '{ት}ትንኽ{ፉ}', 'p8': '{ት}ትንኽ{ፋ}', 'p9': '{ይ}ትንኽ{ፉ}', 'p10': '{ይ}ትንኽ{ፋ}',
      }),
      past: ConjugationMap({
        'p1': 'ተንከፍ{ኩ}', 'p2': 'ተንከፍ{ካ}', 'p3': 'ተንከፍ{ኪ}', 'p4': 'ተንከ{ፈ}', 'p5': 'ተንከ{ፈት}', 
        'p6': 'ተንከፍ{ና}', 'p7': 'ተንከፍ{ኩም}', 'p8': 'ተንከፍ{ክን}', 'p9': 'ተንከ{ፉ}', 'p10': 'ተንከ{ፋ}',
      }),
    ),
    VerbConjugator.generate(
      id: 'v_sing',
      lemma: 'ምድራፍ',
      translit: 'Midraf',
      english: 'To sing',
      amharic: 'መዝፈን',
      categories: ['music', 'audible'],
      present: ConjugationMap({
        'p1': '{እ}ደርፍ', 'p2': '{ት}ደርፍ', 'p3': '{ት}ደር{ፊ}', 'p4': '{ይ}ደርፍ', 'p5': '{ት}ደርፍ', 
        'p6': '{ን}ደርፍ', 'p7': '{ት}ደር{ፉ}', 'p8': '{ት}ደር{ፋ}', 'p9': '{ይ}ደር{ፉ}', 'p10': '{ይ}ደር{ፋ}',
      }),
      past: ConjugationMap({
        'p1': 'ደራፍ{ኩ}', 'p2': 'ደራፍ{ካ}', 'p3': 'ደራፍ{ኪ}', 'p4': 'ደረ{ፈ}', 'p5': 'ደረ{ፈት}', 
        'p6': 'ደራፍ{ና}', 'p7': 'ደራፍ{ኩም}', 'p8': 'ደራፍ{ክን}', 'p9': 'ደረ{ፉ}', 'p10': 'ደረ{ፋ}',
      }),
    ),
  ];


  static Verb getVerbById(String id) => verbs.firstWhere((v) => v.id == id);

  static const List<Adjective> adjectives = [
    Adjective(
      id: 'adj_happy',
      english: 'Happy',
      amharic: 'ደስተኛ',
      male: 'ሕጉስ',
      female: 'ሕጉስቲ',
      plural: 'ሕጉሳት',
    ),
    Adjective(
      id: 'adj_sad',
      english: 'Sad',
      amharic: 'ሀዘነተኛ',
      male: 'ጉሁይ',
      female: 'ጉሁይቲ',
      plural: 'ጉሁያት',
    ),
    Adjective(
      id: 'adj_big',
      english: 'Big',
      amharic: 'ትልቅ',
      male: 'ዓቢ',
      female: 'ዓባይ',
      plural: 'ዓበይቲ',
    ),
    Adjective(
      id: 'adj_small',
      english: 'Small',
      amharic: 'ትንሽ',
      male: 'ንእሽቶ',
      female: 'ንእሽቶ',
      plural: 'ናእሽቱ',
    ),
    Adjective(
      id: 'adj_good',
      english: 'Good',
      amharic: 'ጥሩ',
      male: 'ጽቡቕ',
      female: 'ጽብቕቲ',
      plural: 'ጽቡቓት',
    ),
    Adjective(
      id: 'adj_bad',
      english: 'Bad',
      amharic: 'መጥፎ',
      male: 'ሕማቕ',
      female: 'ሕምቕቲ',
      plural: 'ሕማቓት',
    ),
    Adjective(
      id: 'adj_tall',
      english: 'Tall / Long',
      amharic: 'ረጅም',
      male: 'ነዊሕ',
      female: 'ነዋሕ',
      plural: 'ነዋሕቲ',
    ),
    Adjective(
      id: 'adj_short',
      english: 'Short',
      amharic: 'አጭር',
      male: 'ሓጺር',
      female: 'ሓጻር',
      plural: 'ሓጸርቲ',
    ),
    Adjective(
      id: 'adj_fast',
      english: 'Fast',
      amharic: 'ፈጣን',
      male: 'ቕልጡፍ',
      female: 'ቕልጥፍቲ',
      plural: 'ቕልጡፋት',
    ),
  ];

  // ───────────────────────── DRILL MODULES ─────────────────────────

  static const Map<Tense, String> defaultPatternRules = {
    Tense.present: '1st person (I/We) take the {እ-} and {ን-} prefixes. 3rd person (He/They) take the {ይ-} prefix. 2nd person (You) and 3rd person (She) take the {ት-} prefix. Feminine singular adds a {-ዒ}/{-ዪ} suffix, and plurals add {-ዑ}/{-ዩ} or {-ዓ}/{-ያ} suffixes.',
    Tense.past: 'The root morphs and suffixes are added. 1st person (I/We) take {-ዐ}/{-የ} and {-ና}. 2nd person (You) take {-ካ}/{-ኻ} (masc) and {-ኪ}/{-ኺ} (fem) — use {-ኻ}/{-ኺ} after vowels, and {-ካ}/{-ኪ} after consonants! 3rd person (He/She) take {-ዑ}/{-ዩ} and {-ዓ}/{-ያ}. Plurals take {-ኹም}/{-ኩም} or {-ዖም}/{-ዐን}.',
    Tense.continuous: 'Formed by combining the {Present Tense Verb} with the auxiliary word {ኣሎ}. The auxiliary is conjugated: {ኣለኹ} (I), {ኣለና} (We), {ኣለኻ}/{ኣለኺ} (You m/f), {ኣሎ}/{ኣላ} (He/She).',
    Tense.future: 'Wraps the present tense verb in a {ክ-} or {ክት-} prefix, and adds the auxiliary {እዩ}. The auxiliary conjugates: 1st person takes {እየ}/{ኢና}. 2nd person takes {ኢኻ}/{ኢኺ}. 3rd person takes {እዩ}/{እያ}.',
    Tense.negative: 'Present negative surrounds the present verb with an {ኣይ-} prefix and a {-ን} suffix. The prefix becomes {ኣይት-} for 2nd person and She, and {ኣይን-} for We.',
  };

  static const List<DrillModule> modules = [
    // ── UNIT 1: DAY-1 SURVIVAL (Weeks 1-2) ──
    DrillModule(
      id: 'mod_greet',
      name: 'Greetings & Basics',
      description: 'Hello, Thank you, Yes, No — essential survival words',
      type: DrillModuleType.greeting,
    ),
    DrillModule(
      id: 'mod_1',
      name: 'Pronouns',
      description: 'Match English/Amharic pronouns to Tigrinya',
      type: DrillModuleType.pronoun,
    ),
    DrillModule(
      id: 'mod_dem',
      name: 'Demonstratives: This & That',
      description: 'Learn to say this, that, and these',
      type: DrillModuleType.demonstrative,
    ),
    DrillModule(
      id: 'mod_prep',
      name: 'Prepositions & Connectors',
      description: 'In, to, from, with, and (ን...ን), but, because',
      type: DrillModuleType.preposition,
    ),
    DrillModule(
      id: 'mod_3',
      name: 'Numbers',
      description: 'Master counting from 1 to 100',
      type: DrillModuleType.number,
    ),

    // ── INTEGRATION 1: Unit 1 Review ──
    DrillModule(
      id: 'mod_integration_1',
      name: '🧩 Integration 1',
      description: 'Combine Greetings + Pronouns + Demonstratives + Prepositions + Numbers',
      type: DrillModuleType.integration,
      integrationLevel: 1,
    ),

    // ── UNIT 2: FIRST VERBS (Weeks 3-4) ──
    DrillModule(
      id: 'mod_4',
      name: 'The Basics: Eat & Drink',
      description: 'Conjugate "To eat" and "To drink"',
      type: DrillModuleType.verb,
      verbIds: ['v_eat', 'v_drink'],
      patternRules: defaultPatternRules,
    ),
    DrillModule(
      id: 'mod_6',
      name: 'Movement: Go, Come, Wait',
      description: 'Conjugate movement and waiting verbs',
      type: DrillModuleType.verb,
      verbIds: ['v_go', 'v_come', 'v_wait'],
      patternRules: defaultPatternRules,
    ),
    DrillModule(
      id: 'mod_fam',
      name: 'Family Vocab',
      description: 'Mother, father, brother, sister...',
      type: DrillModuleType.family,
    ),

    // ── INTEGRATION 2: Unit 2 Review ──
    DrillModule(
      id: 'mod_integration_2',
      name: '🧩 Integration 2',
      description: 'Combine verbs (eat, drink, go, come, wait) with pronouns + objects',
      type: DrillModuleType.integration,
      integrationLevel: 2,
    ),

    // ── UNIT 3: BUILDING SENTENCES (Weeks 5-6) ──
    DrillModule(
      id: 'mod_2',
      name: 'Adjectives (To Be)',
      description: 'Combine pronouns with adjectives: "I am happy", "He is tall"',
      type: DrillModuleType.adjective,
      patternRules: defaultPatternRules,
    ),
    DrillModule(
      id: 'mod_identity',
      name: 'Identity: I Am A...',
      description: 'Say who you are: "I am a student" (ኣነ ተማሃራይ እየ), "He is a doctor"',
      type: DrillModuleType.identityToBe,
    ),
    DrillModule(
      id: 'mod_sentence_builder',
      name: 'Sentence Builder (SOV)',
      description: 'Combine Subject + Object + Verb into full Tigrinya sentences',
      type: DrillModuleType.sentence,
      verbIds: ['v_eat', 'v_drink', 'v_go', 'v_come', 'v_wait'],
    ),
    DrillModule(
      id: 'mod_possess',
      name: 'Possession: I Have / I Don\'t Have',
      description: 'Learn to say "I have" (ኣለኒ) and "I don\'t have" (የብለይን)',
      type: DrillModuleType.possession,
    ),
    DrillModule(
      id: 'mod_existential',
      name: 'There Is / There Isn\'t',
      description: 'Express existence: ማይ ኣሎ (there is water), መግቢ የለን (there is no food)',
      type: DrillModuleType.existential,
    ),
    DrillModule(
      id: 'mod_qw_basic',
      name: 'Question Words: What, Who, Where',
      description: 'Learn the essential question words as vocabulary',
      type: DrillModuleType.questionWordBasic,
    ),

    // ── INTEGRATION 3: Unit 3 Review ──
    DrillModule(
      id: 'mod_integration_3',
      name: '🧩 Integration 3',
      description: 'Build sentences with adjectives, possession, identity, SOV, existentials',
      type: DrillModuleType.integration,
      integrationLevel: 3,
    ),

    // ── UNIT 4: EXPANDING VERBS (Weeks 7-8) ──
    DrillModule(
      id: 'mod_7',
      name: 'Communication: Speak, Hear, Know',
      description: 'Learn communication verbs',
      type: DrillModuleType.verb,
      verbIds: ['v_speak', 'v_hear', 'v_know'],
      patternRules: defaultPatternRules,
    ),
    DrillModule(
      id: 'mod_rw',
      name: 'Read & Write',
      description: 'Learn to read and write',
      type: DrillModuleType.verb,
      verbIds: ['v_read', 'v_write'],
      patternRules: defaultPatternRules,
    ),
    DrillModule(
      id: 'mod_8',
      name: 'Question Word Drills',
      description: 'Entay, Men, Abey combined with verbs you know',
      type: DrillModuleType.questionWord,
      verbIds: ['v_eat', 'v_drink', 'v_go', 'v_come', 'v_wait', 'v_speak', 'v_hear', 'v_know', 'v_read', 'v_write'],
      patternRules: defaultPatternRules,
    ),

    // ── INTEGRATION 4: Unit 4 Review ──
    DrillModule(
      id: 'mod_integration_4',
      name: '🧩 Integration 4',
      description: 'Question words + verbs + pronouns in full sentences',
      type: DrillModuleType.integration,
      integrationLevel: 4,
    ),

    // ── UNIT 5: OWNERSHIP & TIME (Weeks 9-10) ──
    DrillModule(
      id: 'mod_possess_pronoun',
      name: 'Independent Possessives',
      description: 'Learn to say mine, yours, his, hers, etc. (e.g. ናተይ, ናትኻ)',
      type: DrillModuleType.possessivePronoun,
    ),
    DrillModule(
      id: 'mod_noun_possession',
      name: 'Noun Suffixes (-ይ, -ኻ, -ኺ)',
      description: 'My house, your father, my head (ገዛይ, ኣቦኻ, ርእሰይ)',
      type: DrillModuleType.nounPossession,
    ),
    DrillModule(
      id: 'mod_5',
      name: 'Time, Days & Dates',
      description: 'Yesterday, tomorrow, Monday, Tuesday...',
      type: DrillModuleType.time,
    ),
    DrillModule(
      id: 'mod_location',
      name: 'Location Words',
      description: 'Above, below, near, far, inside, outside (ላዕሊ, ታሕቲ, ጥቃ, ርሑቅ)',
      type: DrillModuleType.locationWord,
    ),
    DrillModule(
      id: 'mod_compound_subject',
      name: 'Compound Subjects: ኣነን ኣቦይን',
      description: 'Combine subjects with "ን...ን" and conjugate as we/you(pl.)/they',
      type: DrillModuleType.compoundSubject,
    ),

    // ── INTEGRATION 5: Unit 5 Review ──
    DrillModule(
      id: 'mod_integration_5',
      name: '🧩 Integration 5',
      description: 'Time + possessives + location + compound subjects in sentences',
      type: DrillModuleType.integration,
      integrationLevel: 5,
    ),

    // ── UNIT 6: DAILY LIFE & TENSES (Weeks 11-12) ──
    DrillModule(
      id: 'mod_9',
      name: 'Daily Life: See, Want, Ride, Pay',
      description: 'Learn common daily life verbs',
      type: DrillModuleType.verb,
      verbIds: ['v_see', 'v_want', 'v_ride', 'v_pay'],
      patternRules: defaultPatternRules,
    ),
    DrillModule(
      id: 'mod_ws',
      name: 'Work & Study: Work, Learn, Think',
      description: 'Learn verbs for work and study',
      type: DrillModuleType.verb,
      verbIds: ['v_work', 'v_learn', 'v_think'],
      patternRules: defaultPatternRules,
    ),
    DrillModule(
      id: 'mod_continuous',
      name: 'Continuous Tense: Right Now',
      description: 'Practice "I am eating" (እበልዕ ኣለኹ), "He is going" with ኣሎ/ኣላ',
      type: DrillModuleType.verb,
      verbIds: ['v_eat', 'v_drink', 'v_go', 'v_come', 'v_speak', 'v_hear', 'v_see', 'v_want', 'v_work', 'v_learn', 'v_think'],
      patternRules: defaultPatternRules,
    ),
    DrillModule(
      id: 'mod_future',
      name: 'Future Tense: I Will...',
      description: 'Practice "I will go" (ክኸይድ እየ), "She will eat" with ክ-/ክት-',
      type: DrillModuleType.verb,
      verbIds: ['v_eat', 'v_drink', 'v_go', 'v_come', 'v_speak', 'v_hear', 'v_see', 'v_want', 'v_work', 'v_learn', 'v_think'],
      patternRules: defaultPatternRules,
    ),
    DrillModule(
      id: 'mod_negative',
      name: 'Negative: I Don\'t / I Didn\'t',
      description: 'Practice "I don\'t eat" (ኣይበልዕን), "He doesn\'t go" with ኣይ-...-ን',
      type: DrillModuleType.verb,
      verbIds: ['v_eat', 'v_drink', 'v_go', 'v_come', 'v_speak', 'v_hear', 'v_see', 'v_want', 'v_work', 'v_learn', 'v_think'],
      patternRules: defaultPatternRules,
    ),
    DrillModule(
      id: 'mod_10',
      name: 'Social: Love, Give, Meet',
      description: 'Learn social interaction verbs',
      type: DrillModuleType.verb,
      verbIds: ['v_love', 'v_give', 'v_meet'],
      patternRules: defaultPatternRules,
    ),
    DrillModule(
      id: 'mod_emotion',
      name: 'Endearments & Emotions ❤️',
      description: 'I love you, I miss you, you are mine, my heart — romantic phrases',
      type: DrillModuleType.emotion,
    ),
    DrillModule(
      id: 'mod_imperative',
      name: 'Commands: Do This!',
      description: 'Give orders: Go! (ኪድ!), Eat! (ብላዕ!), Come! (ምጻእ!), Speak! (ተዛረብ!)',
      type: DrillModuleType.imperative,
    ),

    // ── INTEGRATION 6: Unit 6 Review ──
    DrillModule(
      id: 'mod_integration_6',
      name: '🧩 Integration 6',
      description: 'Full sentences with tenses, emotions, imperatives, and social verbs',
      type: DrillModuleType.integration,
      integrationLevel: 6,
    ),

    // ── UNIT 7: ADVANCED (Weeks 13-14) ──
    DrillModule(
      id: 'mod_hl',
      name: 'Home Life: Sleep, Open, Close, Sit, Live',
      description: 'Learn verbs around the house',
      type: DrillModuleType.verb,
      verbIds: ['v_sleep', 'v_open', 'v_close', 'v_sit', 'v_live'],
      patternRules: defaultPatternRules,
    ),
    DrillModule(
      id: 'mod_shop',
      name: 'Shopping: Buy',
      description: 'Learn to buy things',
      type: DrillModuleType.verb,
      verbIds: ['v_buy'],
      patternRules: defaultPatternRules,
    ),
    DrillModule(
      id: 'mod_with',
      name: 'With (ምስ) Constructions',
      description: 'Combine ምስ with nouns and verbs: "I went with my friend", "Sing with me!"',
      type: DrillModuleType.withConstruction,
    ),
    DrillModule(
      id: 'mod_romance_verbs',
      name: 'Romance & Song: Miss, Kiss, Touch, Sing',
      description: 'Express longing, affection, and joy through new verbs',
      type: DrillModuleType.verb,
      verbIds: ['v_miss', 'v_kiss', 'v_touch', 'v_sing'],
      patternRules: defaultPatternRules,
    ),
    DrillModule(
      id: 'mod_verb_object_suffix',
      name: 'Verb Object Suffixes (-ኒ, -ኻ, -ዮ)',
      description: 'Attach direct objects to verbs: He gave me (ሃበኒ), I gave him (ሃብኩዎ)',
      type: DrillModuleType.verbObjectSuffix,
    ),
    DrillModule(
      id: 'mod_phrase',
      name: 'Common Phrases',
      description: 'Give me, Tell him, I love you, I don\'t understand',
      type: DrillModuleType.phrase,
    ),
    DrillModule(
      id: 'mod_intimate',
      name: 'Intimate Commands 🔥',
      description: 'Passionate phrases: Kiss me deeply!, Hold me tight!, Don\'t stop!',
      type: DrillModuleType.intimatePhrase,
    ),

    // ── INTEGRATION 7: Final Review ──
    DrillModule(
      id: 'mod_integration_7',
      name: '🧩 Integration 7: Final',
      description: 'Everything combined — advanced verbs, with-constructions, verb suffixes, phrases',
      type: DrillModuleType.integration,
      integrationLevel: 7,
    ),
  ];

  static const Map<String, ConjugationMap> possession = {
    'positive': ConjugationMap({
      'p1': 'ኣለ{ኒ}', 'p2': 'ኣለ{ኻ}', 'p3': 'ኣለ{ኺ}', 'p4': 'ኣለ{ዎ}', 'p5': 'ኣለ{ዋ}', 
      'p6': 'ኣለ{ና}', 'p7': 'ኣለ{ኹም}', 'p8': 'ኣለ{ኽን}', 'p9': 'ኣለ{ዎም}', 'p10': 'ኣለ{ወን}',
    }),
    'negative': ConjugationMap({
      'p1': '{የብለይ}ን', 'p2': '{የብልኻ}ን', 'p3': '{የብልኺ}ን', 'p4': '{የብሉ}ን', 'p5': '{የብላ}ን', 
      'p6': '{የብልና}ን', 'p7': '{የብልኹም}ን', 'p8': '{የብልኽን}ን', 'p9': '{የብሎም}ን', 'p10': '{የብለን}ን',
    }),
  };

  // ────────────── NOUN POSSESSION SUFFIXES ──────────────
  static const List<TigrinyaObject> nounPossessionItems = [
    // House (ገዛ)
    TigrinyaObject(tigrinya: 'ገዛይ', amharic: 'ቤቴ', english: 'my house'),
    TigrinyaObject(tigrinya: 'ገዛኻ', amharic: 'ቤትህ', english: 'your house (m.)'),
    TigrinyaObject(tigrinya: 'ገዛኺ', amharic: 'ቤትሽ', english: 'your house (f.)'),
    TigrinyaObject(tigrinya: 'ገዛኡ', amharic: 'ቤቱ', english: 'his house'),
    TigrinyaObject(tigrinya: 'ገዛኣ', amharic: 'ቤቷ', english: 'her house'),
    TigrinyaObject(tigrinya: 'ገዛና', amharic: 'ቤታችን', english: 'our house'),
    TigrinyaObject(tigrinya: 'ገዛኹም', amharic: 'ቤታችሁ', english: 'your house (pl.)'),
    TigrinyaObject(tigrinya: 'ገዛኦም', amharic: 'ቤታቸው', english: 'their house'),

    // Father (ኣቦ)
    TigrinyaObject(tigrinya: 'ኣቦይ', amharic: 'አባቴ', english: 'my father'),
    TigrinyaObject(tigrinya: 'ኣቦኻ', amharic: 'አባትህ', english: 'your father (m.)'),
    TigrinyaObject(tigrinya: 'ኣቦኺ', amharic: 'አባትሽ', english: 'your father (f.)'),
    TigrinyaObject(tigrinya: 'ኣቦኡ', amharic: 'አባቱ', english: 'his father'),
    TigrinyaObject(tigrinya: 'ኣቦኣ', amharic: 'አባቷ', english: 'her father'),
    TigrinyaObject(tigrinya: 'ኣቦና', amharic: 'አባታችን', english: 'our father'),

    // Mother (ኣደ -> ኣዲ- before vowel suffixes)
    TigrinyaObject(tigrinya: 'ኣደይ', amharic: 'እናቴ', english: 'my mother'),
    TigrinyaObject(tigrinya: 'ኣደኻ', amharic: 'እናትህ', english: 'your mother (m.)'),
    TigrinyaObject(tigrinya: 'ኣደኺ', amharic: 'እናትሽ', english: 'your mother (f.)'),
    TigrinyaObject(tigrinya: 'ኣዲኡ', amharic: 'እናቱ', english: 'his mother'),
    TigrinyaObject(tigrinya: 'ኣዲኣ', amharic: 'እናቷ', english: 'her mother'),

    // Brother (ሓው)
    TigrinyaObject(tigrinya: 'ሓወይ', amharic: 'ወንድሜ', english: 'my brother'),
    TigrinyaObject(tigrinya: 'ሓውኻ', amharic: 'ወንድምህ', english: 'your brother (m.)'),
    TigrinyaObject(tigrinya: 'ሓውኺ', amharic: 'ወንድምሽ', english: 'your brother (f.)'),
    TigrinyaObject(tigrinya: 'ሓዉ', amharic: 'ወንድሙ', english: 'his brother'),
    TigrinyaObject(tigrinya: 'ሓዋ', amharic: 'ወንድሟ', english: 'her brother'),

    // Sister (ሓፍቲ)
    TigrinyaObject(tigrinya: 'ሓፍተይ', amharic: 'እህቴ', english: 'my sister'),
    TigrinyaObject(tigrinya: 'ሓፍትኻ', amharic: 'እህትህ', english: 'your sister (m.)'),
    TigrinyaObject(tigrinya: 'ሓፍትኺ', amharic: 'እህትሽ', english: 'your sister (f.)'),
    TigrinyaObject(tigrinya: 'ሓፍቱ', amharic: 'እህቱ', english: 'his sister'),
    TigrinyaObject(tigrinya: 'ሓፍታ', amharic: 'እህቷ', english: 'her sister'),

    // Head / Self (ርእሲ)
    TigrinyaObject(tigrinya: 'ርእሰይ', amharic: 'ራሴ', english: 'my head'),
    TigrinyaObject(tigrinya: 'ርእስኻ', amharic: 'ራስህ', english: 'your head (m.)'),
    TigrinyaObject(tigrinya: 'ርእስኺ', amharic: 'ራስሽ', english: 'your head (f.)'),
    TigrinyaObject(tigrinya: 'ርእሱ', amharic: 'ራሱ', english: 'his head'),
    TigrinyaObject(tigrinya: 'ርእሳ', amharic: 'ራሷ', english: 'her head'),

    // Car (መኪና)
    TigrinyaObject(tigrinya: 'መኪናይ', amharic: 'መኪናዬ', english: 'my car'),
    TigrinyaObject(tigrinya: 'መኪናኻ', amharic: 'መኪናህ', english: 'your car (m.)'),
    TigrinyaObject(tigrinya: 'መኪናኺ', amharic: 'መኪናሽ', english: 'your car (f.)'),
    TigrinyaObject(tigrinya: 'መኪናኡ', amharic: 'መኪናው', english: 'his car'),

    // Friend (ዓርኪ)
    TigrinyaObject(tigrinya: 'ዓርከይ', amharic: 'ጓደኛዬ', english: 'my friend'),
    TigrinyaObject(tigrinya: 'ዓርክኻ', amharic: 'ጓደኛህ', english: 'your friend (m.)'),
    TigrinyaObject(tigrinya: 'ዓርክኺ', amharic: 'ጓደኛሽ', english: 'your friend (f.)'),
    TigrinyaObject(tigrinya: 'ዓርኩ', amharic: 'ጓደኛው', english: 'his friend'),
    TigrinyaObject(tigrinya: 'ዓርካ', amharic: 'ጓደኛዋ', english: 'her friend'),
  ];

  // ────────────── VERB DIRECT OBJECT SUFFIXES ──────────────
  static const List<TigrinyaObject> verbObjectSuffixItems = [
    // Gave (ሃበ - He gave)
    TigrinyaObject(tigrinya: 'ሃበኒ', amharic: 'ሰጠኝ', english: 'He gave me'),
    TigrinyaObject(tigrinya: 'ሃበኻ', amharic: 'ሰጠህ', english: 'He gave you (m.)'),
    TigrinyaObject(tigrinya: 'ሃበኺ', amharic: 'ሰጠሽ', english: 'He gave you (f.)'),
    TigrinyaObject(tigrinya: 'ሃቦ', amharic: 'ሰጠው', english: 'He gave him'),
    TigrinyaObject(tigrinya: 'ሃባ', amharic: 'ሰጣት', english: 'He gave her'),
    TigrinyaObject(tigrinya: 'ሃበና', amharic: 'ሰጠን', english: 'He gave us'),
    TigrinyaObject(tigrinya: 'ሃበኹም', amharic: 'ሰጣችሁ', english: 'He gave you (pl.)'),
    TigrinyaObject(tigrinya: 'ሃቦም', amharic: 'ሰጣቸው', english: 'He gave them'),

    // Saw (ረኣየ - He saw)
    TigrinyaObject(tigrinya: 'ረኣየኒ', amharic: 'አየኝ', english: 'He saw me'),
    TigrinyaObject(tigrinya: 'ረኣየኻ', amharic: 'አየህ', english: 'He saw you (m.)'),
    TigrinyaObject(tigrinya: 'ረኣየኺ', amharic: 'አየሽ', english: 'He saw you (f.)'),
    TigrinyaObject(tigrinya: 'ረኣዮ', amharic: 'አየው', english: 'He saw him'),
    TigrinyaObject(tigrinya: 'ረኣያ', amharic: 'አያት', english: 'He saw her'),
    TigrinyaObject(tigrinya: 'ረኣየና', amharic: 'አየን', english: 'He saw us'),

    // Told (ነገረ - He told)
    TigrinyaObject(tigrinya: 'ነገረኒ', amharic: 'ነገረኝ', english: 'He told me'),
    TigrinyaObject(tigrinya: 'ነገረኻ', amharic: 'ነገረህ', english: 'He told you (m.)'),
    TigrinyaObject(tigrinya: 'ነገረኺ', amharic: 'ነገረሽ', english: 'He told you (f.)'),
    TigrinyaObject(tigrinya: 'ነገሮ', amharic: 'ነገረው', english: 'He told him'),
    TigrinyaObject(tigrinya: 'ነገራ', amharic: 'ነገራት', english: 'He told her'),
  ];

  // ────────────── IMPERATIVE / COMMAND FORMS ──────────────
  static const List<TigrinyaObject> imperativeItems = [
    // Masculine singular commands
    TigrinyaObject(tigrinya: 'ኪድ!', amharic: 'ሂድ!', english: 'Go! (to m.)'),
    TigrinyaObject(tigrinya: 'ምጻእ!', amharic: 'ና!', english: 'Come! (to m.)'),
    TigrinyaObject(tigrinya: 'ብላዕ!', amharic: 'ብላ!', english: 'Eat! (to m.)'),
    TigrinyaObject(tigrinya: 'ስተ!', amharic: 'ጠጣ!', english: 'Drink! (to m.)'),
    TigrinyaObject(tigrinya: 'ተጸበ!', amharic: 'ጠብቅ!', english: 'Wait! (to m.)'),
    TigrinyaObject(tigrinya: 'ተዛረብ!', amharic: 'ተናገር!', english: 'Speak! (to m.)'),
    TigrinyaObject(tigrinya: 'ሃበኒ!', amharic: 'ስጠኝ!', english: 'Give me! (to m.)'),
    TigrinyaObject(tigrinya: 'ተቐመጥ!', amharic: 'ተቀመጥ!', english: 'Sit! (to m.)'),
    TigrinyaObject(tigrinya: 'ኣንብብ!', amharic: 'አንብብ!', english: 'Read! (to m.)'),
    TigrinyaObject(tigrinya: 'ጽሐፍ!', amharic: 'ጻፍ!', english: 'Write! (to m.)'),
    // Feminine singular commands
    TigrinyaObject(tigrinya: 'ኪዲ!', amharic: 'ሂጂ!', english: 'Go! (to f.)'),
    TigrinyaObject(tigrinya: 'ምጻኢ!', amharic: 'ነይ!', english: 'Come! (to f.)'),
    TigrinyaObject(tigrinya: 'ብላዒ!', amharic: 'ብዪ!', english: 'Eat! (to f.)'),
    TigrinyaObject(tigrinya: 'ስተይ!', amharic: 'ጠጪ!', english: 'Drink! (to f.)'),
    TigrinyaObject(tigrinya: 'ተጸበዪ!', amharic: 'ጠብቂ!', english: 'Wait! (to f.)'),
    TigrinyaObject(tigrinya: 'ተዛረቢ!', amharic: 'ተናገሪ!', english: 'Speak! (to f.)'),
  ];

  // ────────────── LOCATION VOCABULARY ──────────────
  static const List<TigrinyaObject> locationWords = [
    TigrinyaObject(tigrinya: 'ላዕሊ', amharic: 'ላይ / ወደ ላይ', english: 'above / up'),
    TigrinyaObject(tigrinya: 'ታሕቲ', amharic: 'ታች / ወደ ታች', english: 'below / down'),
    TigrinyaObject(tigrinya: 'ቅድሚ', amharic: 'ፊት / በፊት', english: 'in front / before'),
    TigrinyaObject(tigrinya: 'ድሕሪ', amharic: 'ኋላ / በኋላ', english: 'behind / after'),
    TigrinyaObject(tigrinya: 'ጥቃ', amharic: 'አጠገብ / በአጠገብ', english: 'near / beside'),
    TigrinyaObject(tigrinya: 'ርሑቅ', amharic: 'ሩቅ', english: 'far'),
    TigrinyaObject(tigrinya: 'ውሽጢ', amharic: 'ውስጥ', english: 'inside'),
    TigrinyaObject(tigrinya: 'ግዳም', amharic: 'ውጭ', english: 'outside'),
  ];

  // ────────────── COMPOUND SUBJECT ITEMS ──────────────
  // Rule: I + anyone → We (p6), You + anyone → You pl. (p7/p8),
  //        He/She + someone → They (p9/p10)
  static const List<TigrinyaObject> compoundSubjectItems = [
    // ── GROUP 1: I + family → We (p6) conjugation ──
    // eat p6 = ንበልዕ
    TigrinyaObject(tigrinya: 'ኣነን ኣቦይን ንበልዕ', amharic: 'እኔና አባቴ እንበላለን', english: 'My father and I eat'),
    // drink p6 = ንሰቲ
    TigrinyaObject(tigrinya: 'ኣነን ኣደይን ንሰቲ', amharic: 'እኔና እናቴ እንጠጣለን', english: 'My mother and I drink'),
    // go p6 = ንኸይድ
    TigrinyaObject(tigrinya: 'ኣነን ሓወይን ንኸይድ', amharic: 'እኔና ወንድሜ እንሄዳለን', english: 'My brother and I go'),
    // come p6 = ንመጽእ
    TigrinyaObject(tigrinya: 'ኣነን ሓፍተይን ንመጽእ', amharic: 'እኔና እህቴ እንመጣለን', english: 'My sister and I come'),
    // speak p6 = ንዛረብ
    TigrinyaObject(tigrinya: 'ኣነን ዓርከይን ንዛረብ', amharic: 'እኔና ጓደኛዬ እንናገራለን', english: 'My friend and I speak'),
    // hear p6 = ንሰምዕ
    TigrinyaObject(tigrinya: 'ኣነን ኣቦይን ንሰምዕ', amharic: 'እኔና አባቴ እንሰማለን', english: 'My father and I hear'),

    // ── GROUP 2: You + someone → You plural (p7/p8) ──
    // eat p7 = ትበልዑ
    TigrinyaObject(tigrinya: 'ንስኻን ንሱን ትበልዑ', amharic: 'አንተና እሱ ትበላላችሁ', english: 'You (m.) and he eat'),
    // go p7 = ትኸይዱ
    TigrinyaObject(tigrinya: 'ንስኻን ሓውኻን ትኸይዱ', amharic: 'አንተና ወንድምህ ትሄዳላችሁ', english: 'You (m.) and your brother go'),
    // drink p8 = ትሰትያ
    TigrinyaObject(tigrinya: 'ንስኺን ሓፍትኺን ትሰትያ', amharic: 'አንቺና እህትሽ ትጠጣላችሁ', english: 'You (f.) and your sister drink'),
    // speak p7 = ትዛረቡ
    TigrinyaObject(tigrinya: 'ንስኻን ዓርክኻን ትዛረቡ', amharic: 'አንተና ጓደኛህ ትናገራላችሁ', english: 'You (m.) and your friend speak'),
    // come p8 = ትመጽኣ
    TigrinyaObject(tigrinya: 'ንስኺን ኣደኺን ትመጽኣ', amharic: 'አንቺና እናትሽ ትመጣላችሁ', english: 'You (f.) and your mother come'),
    // wait p7 = ትጽበዩ
    TigrinyaObject(tigrinya: 'ንስኻን ኣቦኻን ትጽበዩ', amharic: 'አንተና አባትህ ትጠብቃላችሁ', english: 'You (m.) and your father wait'),

    // ── GROUP 3: He/She + someone → They (p9/p10) ──
    // eat p9 = ይበልዑ
    TigrinyaObject(tigrinya: 'ንሱን ኣቦኡን ይበልዑ', amharic: 'እሱና አባቱ ይበላሉ', english: 'He and his father eat'),
    // go p10 = ይኸይዳ
    TigrinyaObject(tigrinya: 'ንሳን ሓፍታን ይኸይዳ', amharic: 'እሷና እህቷ ይሄዳሉ', english: 'She and her sister go'),
    // come p9 = ይመጽኡ
    TigrinyaObject(tigrinya: 'ንሱን ሓዉን ይመጽኡ', amharic: 'እሱና ወንድሙ ይመጣሉ', english: 'He and his brother come'),
    // drink p10 = ይሰትያ
    TigrinyaObject(tigrinya: 'ንሳን ኣዲኣን ይሰትያ', amharic: 'እሷና እናቷ ይጠጣሉ', english: 'She and her mother drink'),
    // know p9 = ይፈልጡ
    TigrinyaObject(tigrinya: 'ንሱን ንሳን ይፈልጡ', amharic: 'እሱና እሷ ያውቃሉ', english: 'He and she know'),
    // read p9 = የንብቡ
    TigrinyaObject(tigrinya: 'ንሱን ዓርኩን የንብቡ', amharic: 'እሱና ጓደኛው ያነብባሉ', english: 'He and his friend read'),
  ];

  // ────────────── EXISTENTIAL (THERE IS / THERE ISN'T) ──────────────
  static const List<TigrinyaObject> existentialItems = [
    TigrinyaObject(tigrinya: 'ማይ ኣሎ', amharic: 'ውሃ አለ', english: 'There is water'),
    TigrinyaObject(tigrinya: 'ማይ የለን', amharic: 'ውሃ የለም', english: 'There is no water'),
    TigrinyaObject(tigrinya: 'መግቢ ኣሎ', amharic: 'ምግብ አለ', english: 'There is food'),
    TigrinyaObject(tigrinya: 'መግቢ የለን', amharic: 'ምግብ የለም', english: 'There is no food'),
    TigrinyaObject(tigrinya: 'ቡን ኣሎ', amharic: 'ቡና አለ', english: 'There is coffee'),
    TigrinyaObject(tigrinya: 'ቡን የለን', amharic: 'ቡና የለም', english: 'There is no coffee'),
    TigrinyaObject(tigrinya: 'ገንዘብ ኣሎ', amharic: 'ገንዘብ አለ', english: 'There is money'),
    TigrinyaObject(tigrinya: 'ገንዘብ የለን', amharic: 'ገንዘብ የለም', english: 'There is no money'),
    TigrinyaObject(tigrinya: 'ሰብ ኣሎ', amharic: 'ሰው አለ', english: 'There is someone / somebody is there'),
    TigrinyaObject(tigrinya: 'ሰብ የለን', amharic: 'ሰው የለም', english: 'There is nobody'),
  ];

  // ────────────── INTIMATE / PASSIONATE COMMANDS ──────────────
  static const List<TigrinyaObject> intimatePhraseItems = [
    TigrinyaObject(tigrinya: 'ኣጸቢቕካ ስዓመኒ!', amharic: 'በጥልቅ ሳመኝ!', english: 'Kiss me deeply! (to m.)'),
    TigrinyaObject(tigrinya: 'ኣጥቢቕካ ሓቖፈኒ!', amharic: 'አጥብቀህ እቀፈኝ!', english: 'Hold me tight! (to m.)'),
    TigrinyaObject(tigrinya: 'ብሓይሊ ሓዘኒ!', amharic: 'በኃይል ያዘኝ!', english: 'Hold me roughly / firmly! (to m.)'),
    TigrinyaObject(tigrinya: 'ኩሉ ኣካላተይ ተንክፈኒ!', amharic: 'ሁሉንም ገላዬን ንካኝ!', english: 'Touch me everywhere! (to m.)'),
    TigrinyaObject(tigrinya: 'ኣይተቋርጽ!', amharic: 'አታቁም!', english: 'Don\'t stop! (to m.)'),
    TigrinyaObject(tigrinya: 'ይደልየካ ኣለኹ!', amharic: 'እፈልግሃለሁ!', english: 'I want you! / I desire you! (to m.)'),
    TigrinyaObject(tigrinya: 'ናባይ ቅረብ!', amharic: 'ወደ እኔ ቅረብ!', english: 'Come closer to me! (to m.)'),
    TigrinyaObject(tigrinya: 'ኣብ ልዕለይ ኩን!', amharic: 'በላዬ ላይ ሁን!', english: 'Get on top of me! (to m.)'),
  ];

  // ────────────── IDENTITY / "TO BE" CONSTRUCTIONS ──────────────
  static const List<TigrinyaObject> identityItems = [
    // Positive identity (Subject + Noun + ኢኻ/እዩ/etc.)
    TigrinyaObject(tigrinya: 'ኣነ ተማሃራይ እየ', amharic: 'እኔ ተማሪ ነኝ', english: 'I am a student (m.)'),
    TigrinyaObject(tigrinya: 'ንስኻ ተማሃራይ ኢኻ', amharic: 'አንተ ተማሪ ነህ', english: 'You are a student (m.)'),
    TigrinyaObject(tigrinya: 'ንሱ ሓኪም እዩ', amharic: 'እሱ ዶክተር ነው', english: 'He is a doctor'),
    TigrinyaObject(tigrinya: 'ንሳ መምህርቲ እያ', amharic: 'እሷ መምህር ናት', english: 'She is a teacher'),
    TigrinyaObject(tigrinya: 'ንሕና ተማሃሮ ኢና', amharic: 'እኛ ተማሪዎች ነን', english: 'We are students'),
    TigrinyaObject(tigrinya: 'ኣነ ኤርትራዊ እየ', amharic: 'እኔ ኤርትራዊ ነኝ', english: 'I am Eritrean (m.)'),
    TigrinyaObject(tigrinya: 'ንሱ ኢትዮጵያዊ እዩ', amharic: 'እሱ ኢትዮጵያዊ ነው', english: 'He is Ethiopian'),
    TigrinyaObject(tigrinya: 'ኣነ ሰራሕተኛ እየ', amharic: 'እኔ ሰራተኛ ነኝ', english: 'I am a worker'),
    // Negative identity (Subject + Noun + ኣይኮንኩን/etc.)
    TigrinyaObject(tigrinya: 'ኣነ ሓኪም ኣይኮንኩን', amharic: 'እኔ ዶክተር አይደለሁም', english: 'I am not a doctor'),
    TigrinyaObject(tigrinya: 'ንሱ መምህር ኣይኮነን', amharic: 'እሱ መምህር አይደለም', english: 'He is not a teacher'),
    TigrinyaObject(tigrinya: 'ንስኻ ተማሃራይ ኣይኮንካን', amharic: 'አንተ ተማሪ አይደለህም', english: 'You are not a student (m.)'),
    TigrinyaObject(tigrinya: 'ንሕና ሓከማት ኣይኮንናን', amharic: 'እኛ ዶክተሮች አይደለንም', english: 'We are not doctors'),
  ];

  // ────────────── EMOTION / ENDEARMENT PHRASES ──────────────
  static const List<TigrinyaObject> emotionItems = [
    TigrinyaObject(tigrinya: 'የፍቅረካ', translit: 'yefqireka', amharic: 'አፈቅርሃለሁ', english: 'I love you (to m.)'),
    TigrinyaObject(tigrinya: 'ናፊቐካ', translit: 'nafiqeka', amharic: 'ናፍቀኻለሁ', english: 'I miss you (to m.)'),
    TigrinyaObject(tigrinya: 'ናተይ ኢኻ', translit: 'natey ikha', amharic: 'የኔ ነህ', english: 'You are mine (to m.)'),
    TigrinyaObject(tigrinya: 'ብጣዕሚ ጽቡቕ ኢኻ', translit: 'bta\'mi tsbuk ikha', amharic: 'በጣም ቆንጆ ነህ', english: 'You are very handsome (to m.)'),
    TigrinyaObject(tigrinya: 'ብዛዕባኻ ይሓስብ ኣለኹ', translit: 'bza\'baka yhasb aleku', amharic: 'ስለ አንተ አስባለሁ', english: 'I\'m thinking about you (to m.)'),
    TigrinyaObject(tigrinya: 'ፍቕረይ', translit: 'fqrey', amharic: 'ፍቅሬ', english: 'My love'),
    TigrinyaObject(tigrinya: 'ህይወተይ', translit: 'hywetey', amharic: 'ህይወቴ', english: 'My life'),
    TigrinyaObject(tigrinya: 'ልበይ', translit: 'libey', amharic: 'ልቤ', english: 'My heart'),
    TigrinyaObject(tigrinya: 'ምቁር ወዲ', translit: 'mqur wedi', amharic: 'ቆንጆ ልጅ', english: 'Handsome guy'),
    TigrinyaObject(tigrinya: 'ይደልየካ ኣለኹ', translit: 'yidelyeka aleku', amharic: 'እፈልግሃለሁ', english: 'I want you / I desire you (to m.)'),
  ];

  // ────────────── "WITH" (ምስ) CONSTRUCTIONS ──────────────
  static const List<TigrinyaObject> withConstructionItems = [
    TigrinyaObject(tigrinya: 'ምስ ዓርከይ ኸድኩ', amharic: 'ከ ጓደኛየ ጋር ሄድኩ', english: 'I went with my friend'),
    TigrinyaObject(tigrinya: 'ምስ ሓወይ ተዛረብኩ', amharic: 'ከ ወንድሜ ጋር ተናገርኩ', english: 'I spoke with my brother'),
    TigrinyaObject(tigrinya: 'ምስ ኣደይ በላዕኩ', amharic: 'ከ እናቴ ጋር በላሁ', english: 'I ate with my mother'),
    TigrinyaObject(tigrinya: 'ምሳይ ምጻእ!', amharic: 'ከ እኔ ጋር ና!', english: 'Come with me! (to m.)'),
    TigrinyaObject(tigrinya: 'ምሳኻ ክኸይድ እየ', amharic: 'ከ አንተ ጋር እሄዳለሁ', english: 'I will go with you (to m.)'),
    TigrinyaObject(tigrinya: 'ምሳይ ድረፍ!', amharic: 'ከ እኔ ጋር ዘፍን!', english: 'Sing with me! (to m.)'),
    TigrinyaObject(tigrinya: 'ስዓመኒ', amharic: 'ሳመኝ', english: 'Kiss me! (to m.)'),
    TigrinyaObject(tigrinya: 'ምሳኻ ክድቅስ እየ', amharic: 'ከ አንተ ጋር እተኛለሁ', english: 'I will sleep with you (to m.)'),
  ];

  // ────────────── BASIC QUESTION WORDS (Vocabulary Only) ──────────────
  // Same data as questionWords but presented as simple flashcards
  static const List<TigrinyaObject> questionWordBasicItems = [
    TigrinyaObject(tigrinya: 'እንታይ', amharic: 'ምን', english: 'What'),
    TigrinyaObject(tigrinya: 'መን', amharic: 'ማን', english: 'Who'),
    TigrinyaObject(tigrinya: 'ኣበይ', amharic: 'የት', english: 'Where'),
    TigrinyaObject(tigrinya: 'መዓስ', amharic: 'መቼ', english: 'When'),
    TigrinyaObject(tigrinya: 'ከመይ', amharic: 'እንዴት', english: 'How'),
    TigrinyaObject(tigrinya: 'ንምንታይ', amharic: 'ለምን', english: 'Why'),
    TigrinyaObject(tigrinya: 'ክንደይ', amharic: 'ስንት', english: 'How many / How much'),
  ];
}
