import 'package:flutter/material.dart';
import 'package:ticketmaster_et/prefs/setting_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeModePreferences themeModePreferences = ThemeModePreferences();
  LanguagePreferences languagePreferences = LanguagePreferences();

  bool _darktheme = false;
  bool get darkTheme => _darktheme;

  String _languageCode = 'en';
  String get languageCode => _languageCode;

  Future<void> getCurrentThemeMode() async {
    darktheme = await themeModePreferences.getThemeMode();
  }

  set darktheme(bool value) {
    _darktheme = value;
    themeModePreferences.setThemeMode(value);
    notifyListeners();
  }

  Future<void> getLanguageCode() async {
    languageCode = await languagePreferences.getLanguage();
  }

  set languageCode(String value) {
    _languageCode = value;
    languagePreferences.setLanguage(value);
    notifyListeners();
  }
}
