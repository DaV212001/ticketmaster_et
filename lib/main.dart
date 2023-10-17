import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticketmaster_et/constants/theme.dart';
import 'package:ticketmaster_et/provider/loginpersistence.dart';
import 'package:ticketmaster_et/provider/settings_provider.dart';
import 'package:ticketmaster_et/screens/signup.dart';
import 'package:ticketmaster_et/screens/splash_screen.dart';
import 'models/translation.dart';
import 'main_layout_screen.dart';
import 'package:chapa_unofficial/chapa_unofficial.dart';

SettingsProvider settingsProvider = SettingsProvider();
late String langCode;
late String countryCode;

Future<void> appInit() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  langCode = await preferences.getString('langCode') ?? 'en';
  countryCode = await preferences.getString('countryCode') ?? '';
  print('COUNTRY CODE $countryCode');
  await settingsProvider.getCurrentThemeMode();
  print("1");
  // settingsProvider.languageCode =
  //     langCode + (countryCode.isNotEmpty ? '-' + countryCode : '');
  print("2");
  await settingsProvider.getLanguageCode();
  print("3");
  print(settingsProvider.languageCode);
  print("4");
}

void main() async {
  print("main 1");
  Chapa.configure(privateKey: "CHASECK-aQDv2MqkPRx2Ia9W9WiuC2m69VOGE6OO");
  await appInit();
  print("main 2");
  runApp(EasyLocalization(
    supportedLocales: Translation.all,
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    startLocale:Locale('en'),
    // startLocale: Locale(langCode, countryCode),
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
    // ...
  }
// ...

  @override
  void initState() {
    super.initState();
    print("_TicketMasterETState Start");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: ((context, snapshot) {
        print("TicketMasterET 1");
        if (snapshot.connectionState == ConnectionState.waiting) {
          print("TicketMasterET 2");
          return const MaterialApp(
            debugShowCheckedModeBanner: true,
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          print("TicketMasterET 4");
          return MaterialApp(
            debugShowCheckedModeBanner: true,
            home: Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            ),
          );
        } else {
          print("TicketMasterET 5");
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => settingsProvider),
              ChangeNotifierProvider(
                create: (context) => LoginDataProvider(),
              ),
            ],
            child: Consumer<SettingsProvider>(
              builder: (context, settingsProvider, snapshot) {
                return LandingPage();
              },
            ),
          );
        }
      }),
      future: null,
    );
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
      homeScreen = SignupScreen();
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