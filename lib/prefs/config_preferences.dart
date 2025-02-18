import 'package:shared_preferences/shared_preferences.dart';

class ConfigPreference {
  // prevent making instance
  ConfigPreference._();

  // get storage
  static late SharedPreferences _sharedPreferences;

  // STORING KEYS
  static const String _lightThemeKey = 'is_theme_light';
  static const String _isFirstLaunchKey = 'is_phonebook_first_launch';

  /// init get storage services
  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static setStorage(SharedPreferences sharedPreferences) {
    _sharedPreferences = sharedPreferences;
  }

  /// set theme current type as light theme
  static Future<void> setThemeIsLight(bool lightTheme) =>
      _sharedPreferences.setBool(_lightThemeKey, lightTheme);

  /// get if the current theme type is light
  static bool getThemeIsLight() =>
      _sharedPreferences.getBool(_lightThemeKey) ?? true;
  // todo set the default theme (true for light, false for dark)

  /// check if the app is first launch
  static bool? isFirstLaunch() => _sharedPreferences.getBool(_isFirstLaunchKey);

  /// est first launch flag to false
  static Future<void> setFirstLaunchCompleted() =>
      _sharedPreferences.setBool(_isFirstLaunchKey, false);

  /// clear all data from shared pref
  static Future<void> clear() async => await _sharedPreferences.clear();

  static const LANGUAGE_STATUS = "languageStatus";

  static setLanguage(String value) async {
    _sharedPreferences.setString(LANGUAGE_STATUS, value);
  }

  static String getLanguage() {
    return _sharedPreferences.getString(LANGUAGE_STATUS) ?? 'en';
  }
}
