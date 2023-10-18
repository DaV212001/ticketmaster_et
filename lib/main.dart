import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticketmaster_et/constants/theme.dart';
import 'package:ticketmaster_et/provider/loginpersistence.dart';
import 'package:ticketmaster_et/provider/settings_provider.dart';
import 'package:ticketmaster_et/screens/login.dart';
import 'package:ticketmaster_et/screens/splash_screen.dart';
import 'main_layout_screen.dart';
import 'models/translation.dart';
import 'package:chapa_unofficial/chapa_unofficial.dart';

SettingsProvider settingsProvider = SettingsProvider();
late String langCode;
late String countryCode;

Future<void> appInit() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  langCode = await preferences.getString('langCode')?? 'en';
  countryCode = await preferences.getString('countryCode')??'';
  print('COUNTRY CODE $countryCode');
  await settingsProvider.getCurrentThemeMode();
  settingsProvider.languageCode = langCode + (countryCode.isNotEmpty ? '-' + countryCode : '');
  await settingsProvider.getLanguageCode();
  print(settingsProvider.languageCode);
}


void main() async {
  Chapa.configure(privateKey: "CHASECK-kSr6JwoZUw0IlZ6maJJqgxiFQMnz4MUX");
  await appInit();
  runApp(EasyLocalization(
    supportedLocales: Translation.all,
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    startLocale: Locale(langCode, countryCode),
    child: TicketMasterET(
      settingsProvider: settingsProvider,
    ),
  ));
}

class TicketMasterET extends StatefulWidget {
  const TicketMasterET({required this.settingsProvider, super.key});

  final SettingsProvider settingsProvider;

  @override
  State<TicketMasterET> createState() => _TicketMasterETState();
}

class _TicketMasterETState extends State<TicketMasterET>
    with ChangeNotifier, WidgetsBindingObserver {


  @override
  void dispose() {
    super.dispose(); // This line was missing
  }


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(builder: ((context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const MaterialApp(
          debugShowCheckedModeBanner: true,
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      } else if (snapshot.hasError) {
        MaterialApp(
          debugShowCheckedModeBanner: true,
          home: Scaffold(
            body: Center(
              child: Text(tr('error_occured')),
            ),
          ),
        );
      }

      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) {
            return widget.settingsProvider;
          }),
      ChangeNotifierProvider(
      create: (context) => LoginDataProvider(),
      ),
        ],
        child: Consumer<SettingsProvider>(
            builder: (context, settingsProvider, snapshot) {
          return LandingPage();
        }),
      );
    }));
  }
}


class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool isFirstTimeUser = true;

  @override
  void initState() {

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Load login data after the widget has been built
      await Provider.of<LoginDataProvider>(context, listen: false).loadLoginData();
    });
    _checkFirstTimeUser();
  }
  Future<void> _checkFirstTimeUser() async {
    print("Checking First TimeUser");
    final prefs = await SharedPreferences.getInstance();
    final hasLaunchedBefore = prefs.getBool('hasLaunchedBefore') ?? false;
    if (hasLaunchedBefore) {
      setState(() {
        isFirstTimeUser = false;
      });
    } else {
      await prefs.setBool('hasLaunchedBefore', true);
    }
  }
  @override
  Widget build(BuildContext context) {
    final loginDataProvider = Provider.of<LoginDataProvider>(context);
    Widget homeScreen;
    print("First Time User status $isFirstTimeUser");
    if (isFirstTimeUser) {
      print("SplashScreen $isFirstTimeUser");
      homeScreen = SplashScreen();
    } else if (loginDataProvider.loginData != null) {
      print("TicketMatserHomePage $isFirstTimeUser");
      homeScreen = TicketMatserHomePage(title: tr('ticketmaster_name'));
    } else {
      print("SignupScreen $isFirstTimeUser");
      homeScreen = LoginScreen();
    }
    return MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: Styles.themeData(
            isDarkTheme: settingsProvider.darkTheme,
            context: context,
            isM3Enabled: false),
        // home: loginDataProvider.loginData != null?
        // TicketMatserHomePage(title: tr('ticketmaster_name')) : MaterialApp(home: SignupScreen()),
        home: homeScreen
    );
  }
}