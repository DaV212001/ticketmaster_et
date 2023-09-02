import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticketmaster_et/constants/theme.dart';
import 'package:ticketmaster_et/provider/settings_provider.dart';
import 'models/translation.dart';
import 'screens/home_screen.dart';

SettingsProvider settingsProvider = SettingsProvider();
late String langCode;

Future<void> appInit() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  langCode = preferences.getString('languageStatus') ?? 'en';
  await settingsProvider.getCurrentThemeMode();
  await settingsProvider.getLanguageCode();
}

void main() async {
  Chapa.configure(privateKey: "CHASECK_TEST-QlVxOwMIyNJCuIipknSMvWfTWJ0pm2K4");
  await appInit();
  runApp(EasyLocalization(
    supportedLocales: Translation.all,
    path: 'assets/translations',
    fallbackLocale: Translation.all[0],
    startLocale: Locale(langCode),
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
        const MaterialApp(
          debugShowCheckedModeBanner: true,
          home: Scaffold(
            body: Center(
              child: Text('Error occurred'),
            ),
          ),
        );
      }

      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) {
            return widget.settingsProvider;
          })
        ],
        child: Consumer<SettingsProvider>(
            builder: (context, settingsProvider, snapshot) {
          return MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: Styles.themeData(
                isDarkTheme: settingsProvider.darkTheme,
                context: context,
                isM3Enabled: false),
            home: TicketMatserHomePage(title: tr('ticketmaster_name')),
          );
        }),
      );
    }));
  }
}
