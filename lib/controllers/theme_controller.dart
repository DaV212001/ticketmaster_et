import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/theme.dart';
import '../prefs/config_preferences.dart';

class ThemeModeController extends GetxController {
  static late Rx<ThemeData> _themeMode;
  static late BuildContext _context;
  static RxBool isDark = false.obs;
  static RxString languageCode = ConfigPreference.getLanguage().obs;
  ThemeModeController(BuildContext context) {
    _context = context;
  }
  static void saveLanguage(Locale language) {
    ConfigPreference.setLanguage(language.languageCode);
    languageC.value = language.languageCode == 'en'
        ? 'English'
        : language.languageCode == 'am'
            ? 'አማርኛ'
            : language.languageCode == 'es'
                ? 'ትግርኛ'
                : language.languageCode == 'fr'
                    ? 'Somali'
                    : 'Oromiffa';
    // CategoryController catC = Get.find();
    // catC.categories.clear();
    // catC.fetchCategories();
    // HomeController homeC = Get.find();
    // homeC.categories.clear();
    // homeC.fetchTopCompanies();
    // homeC.fetchSubCategories();
    // homeC.fetchCategories(fetchAllCategorysFood: true);
    languageCode.value = language.languageCode;
  }

  static Locale getLocale() {
    return ConfigPreference.getLanguage() == 'en'
        ? const Locale('en', 'US')
        : ConfigPreference.getLanguage() == 'am'
            ? const Locale('am')
            : ConfigPreference.getLanguage() == 'it' // oromifa
                ? const Locale('it')
                : ConfigPreference.getLanguage() == 'fr'
                    ? const Locale('fr')
                    : const Locale('es'); //tigrigna
  }

  static final RxString languageC =
      RxString(ConfigPreference.getLanguage() == 'en'
          ? 'English'
          : ConfigPreference.getLanguage() == 'am'
              ? 'አማርኛ'
              : ConfigPreference.getLanguage() == 'es'
                  ? 'ትግርኛ'
                  : ConfigPreference.getLanguage() == 'fr'
                      ? 'Somali'
                      : 'Oromiffa');

  static String getLanguage() {
    return languageC.value;
  }

  @override
  void onInit() {
    super.onInit();
    _themeMode = Styles.themeData(
            isDarkTheme: !ConfigPreference.getThemeIsLight(),
            context: _context,
            isM3Enabled: false)
        .obs;
    isDark.value = _themeMode.value.cardColor ==
        Styles.themeData(
                isDarkTheme: true, context: _context, isM3Enabled: false)
            .cardColor;
  }

  static ThemeData getThemeMode() => _themeMode.value;
  static void setThemeMode(ThemeData value) {
    _themeMode.value = value;
    isDark.value = _themeMode.value.cardColor ==
        Styles.themeData(
                isDarkTheme: true, context: _context, isM3Enabled: false)
            .cardColor;
  }
}
