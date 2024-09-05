import 'dart:ui';

import 'package:chapa_unofficial/chapa_unofficial.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:esys_flutter_share_plus/esys_flutter_share_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticketmaster_et/constants/theme.dart';
import 'package:ticketmaster_et/provider/loginpersistence.dart';
import 'package:ticketmaster_et/provider/settings_provider.dart';
import 'package:ticketmaster_et/screens/event_detail.dart';
import 'package:ticketmaster_et/screens/event_ticket.dart';
import 'package:ticketmaster_et/screens/login.dart';
import 'package:ticketmaster_et/screens/organizerdetail.dart';
import 'package:ticketmaster_et/screens/splash_screen.dart';
import 'package:uni_links/uni_links.dart';

import 'functions/functions.dart';
import 'main_layout_screen.dart';
import 'models/newmodels.dart';
import 'models/translation.dart';

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
  settingsProvider.languageCode =
      langCode + (countryCode.isNotEmpty ? '-' + countryCode : '');
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
    return FutureBuilder(
      builder: ((context, snapshot) {
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
            ChangeNotifierProvider(
              create: (context) => CommentsModel(),
            ),
          ],
          child: Consumer<SettingsProvider>(
              builder: (context, settingsProvider, snapshot) {
            return const LandingPage();
          }),
        );
      }),
      future: appInit(),
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
      await Provider.of<LoginDataProvider>(context, listen: false)
          .loadLoginData();
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
        home: homeScreen);
  }
}

class DeepLinkHandler extends StatefulWidget {
  final Widget child;

  const DeepLinkHandler({Key? key, required this.child}) : super(key: key);

  @override
  _DeepLinkHandlerState createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends State<DeepLinkHandler>
    with WidgetsBindingObserver {
  Uri? _initialUri;
  Uri? _latestUri;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getInitialUriFromPlugin().then((uri) {
      if (uri != null) {
        setState(() {
          _initialUri = uri;
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<Uri?> getInitialUriFromPlugin() async {
    try {
      final uri = await getInitialUri();
      return uri;
    } on PlatformException catch (err) {
      print('Failed to get initial uri: $err');
      return null;
    }
  }

  @override
  Future<bool> didPushRouteInformation(
      RouteInformation routeInformation) async {
    print('DEVVVVV NOTIFYINGGGGG THATTTTT    didPushRouteInformation called');
    print('ANDDDDD THAT I HAVE RLLLL: ${routeInformation.location!}');
    final uri = Uri.parse(routeInformation.location!);
    setState(() {
      _latestUri = uri;
    });

    // Return true if the deep link matches the expected scheme and host
    if (_latestUri != null &&
        _latestUri?.scheme == 'https' &&
        _latestUri?.host == 'ticketmaster-et.com') {
      return true;
    }

    // Return false if the deep link does not match the expected scheme and host
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        print(
            'CHECKING TO SEEE IF WE CAN USE THE INITIAL URLLLLLL: $_initialUri');
        // Check if the deep link matches the expected scheme and host
        if (!_navigated &&
            ((_initialUri != null &&
                    _initialUri?.scheme == 'https' &&
                    _initialUri?.host == 'ticketmaster-et.com') ||
                (_latestUri != null &&
                    _latestUri?.scheme == 'https' &&
                    _latestUri?.host == 'ticketmaster-et.com'))) {
          print('CHECKING FOR ORIGINALLL URL CORRECTNESS!!!!!: $_latestUri');
          // Extract the video file name from the deep link
          final videoFileName =
              _latestUri?.pathSegments.last ?? _initialUri?.pathSegments.last;
          print('CHECKING FOR URL CORRECTNESS!!!!!:  $videoFileName');
          // Construct the video URL
          final videoUrl =
              'https://admin.ticketmaster-et.com/public/storage/upcoming/$videoFileName';

          // Navigate to VideoPlayerWidget with the video URL
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        DeepLinkNavigation(videoUrl: videoUrl)));
          });
          _navigated = true;
        }
        // If no deep link is detected, return the normal home screen of your app
        return widget.child;
      },
    );
  }
}

class DeepLinkNavigation extends StatefulWidget {
  const DeepLinkNavigation({super.key, required this.videoUrl});
  final String videoUrl;
  @override
  State<DeepLinkNavigation> createState() => _DeepLinkNavigationState();
}

class _DeepLinkNavigationState extends State<DeepLinkNavigation> {
  List<Event> modified = [];
  List<Organizer> modifiedOrg = [];
  Organizer? organizer;
  List<Event> initial = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateEvents();
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (mounted) {
      Provider.of<SettingsProvider>(context, listen: false)
          .removeListener(updateEvents);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<SettingsProvider>(context).addListener(updateEvents);
  }

  Future<void> updateEvents() async {
    print('CHECKING IDDDDDDDD VIDEO URL PASSED ISSSS: ${widget.videoUrl}');
    initial = await getEvents('https://api.ticketmaster-et.com/api/event',
        Provider.of<SettingsProvider>(context, listen: false).languageCode);
    for (Event eve in initial) {
      print('CHECKING IDDDD IDS IN INITIAL AREEEEE ${eve.upcomingImage}');
      if (eve.upcomingImage! == widget.videoUrl) {
        modified.add(eve);
      }
    }
    await getOrganizers(
            Provider.of<SettingsProvider>(context, listen: false).languageCode)
        .then((value) => setState(() {
              print("updateCategories Called 3.1");
              modifiedOrg = value;
              //  print( 'VALUE OF THE EVENTS: $value');
              print("updateCategories Called 3.2");
            }));
  }

  @override
  Widget build(BuildContext context) {
    print(initial);
    print(modified);
    if (modified.isNotEmpty && modifiedOrg.isNotEmpty) {
      for (Organizer org in modifiedOrg) {
        if (org.id == int.parse(modified[0].organizerId!)) {
          organizer = org;
          break;
        }
      }
    }

    return FutureBuilder(
      future: updateEvents(),
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayerWidget(
                  videoUrl: modified[0].upcomingImage!,
                ),
                Positioned(
                  right: 8,
                  child: Column(
                    children: [
                      if (modifiedOrg.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0, top: 30),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: ((context) {
                                return OrganizerDetail(
                                  organizer: organizer!,
                                );
                              })));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.green, width: 2),
                                  borderRadius: BorderRadius.circular(50)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.network(
                                  organizer?.image ??
                                      'https://i.postimg.cc/VkBQ3FS6/na-logo.png',
                                  width: 65,
                                  height: 65,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0.5,
                  child: Stack(
                    children: [
                      ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: [
                                0.0,
                                0.2
                              ],
                                  colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7)
                              ])),
                        ),
                      ),
                      Container(
                        color: Colors.transparent,
                        height: 150,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 120,
                                    child: ListView.builder(
                                        itemCount: 3,
                                        itemBuilder: (context, index) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                modified[0].desc!,
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                modified[0].place!,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                modified[0].date!,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          );
                                        }),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      String videofilename = modified[0]
                                          .upcomingImage!
                                          .replaceFirst(
                                              "https://admin.ticketmaster-et.com/public/storage/upcoming",
                                              '');
                                      Share.text(
                                          'Check out Ticketmaster ET to book a ticket for ${modified[0].title}',
                                          'https://ticketmaster-et.com$videofilename',
                                          'text/plain');
                                    },
                                    icon: Icon(
                                      Icons.share,
                                      size: 20,
                                    )),
                                SizedBox(
                                  height: 25,
                                ),
                                ElevatedButton(
                                    onPressed: () async {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: ((context) {
                                        return EventDetail(
                                          event: modified[0],
                                        );
                                      })));
                                    },
                                    style: ButtonStyle(
                                        side: MaterialStatePropertyAll(
                                            BorderSide(
                                                style: BorderStyle.solid,
                                                color: Theme.of(context)
                                                    .primaryColor)),
                                        shadowColor: MaterialStatePropertyAll(
                                            Colors.white.withOpacity(0.5)),
                                        backgroundColor:
                                            const MaterialStatePropertyAll(
                                                Colors.transparent)),
                                    child: Text(tr('buy_tickets'))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      }),
    );
  }
}
