import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:ticketmaster_et/screens/category/category_tab.dart';

import '../constants/theme.dart';
import '../prefs/config_preferences.dart';
import 'home_category_controller.dart';

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
    if (Get.isRegistered<HomeCategoryController>(
        tag: HomeCategoryController.tag)) {
      HomeCategoryController hcc = Get.find(tag: HomeCategoryController.tag);
      hcc.fetchAll();
    }
    if (Get.isRegistered<CategoryController>()) {
      CategoryController cc = Get.find();
      cc.updateCategoriesAndSubCategories();
    }
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
    Logger().f(!ConfigPreference.getThemeIsLight());
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

  static bool isCurrentlyLight() =>
      _themeMode.value ==
      Styles.themeData(
          isDarkTheme: false, context: _context, isM3Enabled: false);
  static void toggleThemeMode() {
    bool isCurrentlyLight = _themeMode.value ==
        Styles.themeData(
            isDarkTheme: false, context: _context, isM3Enabled: false);
    setThemeMode(Styles.themeData(
        isDarkTheme: isCurrentlyLight, context: _context, isM3Enabled: false));
    ConfigPreference.setThemeIsLight(!isCurrentlyLight);
    Logger().d(isCurrentlyLight);
  }
}
