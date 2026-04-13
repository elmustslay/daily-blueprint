import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsLogic {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get instance {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized');
    }
    return _prefs!;
  }
}
