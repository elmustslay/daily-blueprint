import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Singleton service providing Google Cloud Text-to-Speech (TTS)
/// for authentic Amharic/Tigrinya voice synthesis using the 'am-ET' neural voice.
class TigrinyaTtsService {
  static final TigrinyaTtsService _instance = TigrinyaTtsService._internal();
  factory TigrinyaTtsService() => _instance;

  TigrinyaTtsService._internal() {
    _initPlayer();
  }

  // API key is securely loaded from .env
  static String get _googleCloudApiKey => dotenv.env['GOOGLE_CLOUD_API_KEY'] ?? '';

  late final AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  void _initPlayer() {
    _audioPlayer = AudioPlayer();
    
    // Ignore silent switch on iOS
    _audioPlayer.setAudioContext(AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {AVAudioSessionOptions.mixWithOthers},
      ),
      android: AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: true,
        contentType: AndroidContentType.speech,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gainTransientMayDuck,
      ),
    ));

    _audioPlayer.onPlayerComplete.listen((_) {
      _isPlaying = false;
    });
  }

  final Map<String, String> _audioFileCache = {};

  /// Synthesizes and plays the given Tigrinya [fidelText] using Google Cloud TTS.
  Future<void> speak({
    required String fidelText,
    String? transliteration,
    bool preferTransliteration = false,
    bool forceRefresh = false,
  }) async {
    try {
      final textToSpeak = preferTransliteration && transliteration != null
          ? transliteration
          : fidelText;

      final cleanText = textToSpeak.replaceAll('{', '').replaceAll('}', '').trim();
      if (cleanText.isEmpty) return;

      if (_googleCloudApiKey.isEmpty) {
        return;
      }

      await _audioPlayer.stop();
      _isPlaying = true;

      if (forceRefresh) {
        _audioFileCache.remove(cleanText);
      }

      // Check Cache First
      if (_audioFileCache.containsKey(cleanText)) {
        final filePath = _audioFileCache[cleanText]!;
        if (File(filePath).existsSync()) {
          await _audioPlayer.play(DeviceFileSource(filePath));
          return;
        } else {
          _audioFileCache.remove(cleanText);
        }
      }

      final url = Uri.parse(
          'https://texttospeech.googleapis.com/v1/text:synthesize?key=$_googleCloudApiKey');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'input': {'text': cleanText},
          'voice': {
            'languageCode': 'am-ET',
            'name': 'am-ET-Wavenet-A', // High-quality Neural voice
          },
          'audioConfig': {
            'audioEncoding': 'MP3',
            'speakingRate': 0.85,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final base64Audio = data['audioContent'];
        if (base64Audio != null) {
          final audioBytes = base64Decode(base64Audio);
          
          final tempDir = await getTemporaryDirectory();
          final safeName = cleanText.replaceAll(RegExp(r'[^a-zA-Z0-9\u1200-\u137F]'), '_');
          final file = File('${tempDir.path}/tts_$safeName.mp3');
          await file.writeAsBytes(audioBytes);
          
          _audioFileCache[cleanText] = file.path; // Cache file path
          await _audioPlayer.play(DeviceFileSource(file.path));
        }
      } else {
        _isPlaying = false;
      }
    } catch (e) {
      _isPlaying = false;
    }
  }

  /// Stops any active speech playback.
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
    } catch (_) {}
  }
}
