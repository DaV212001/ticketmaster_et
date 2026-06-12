import 'dart:ui';

import 'package:app_links/app_links.dart';
import 'package:chapa_unofficial/chapa_unofficial.dart';
// import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticketmaster_et/controllers/current_location_controller.dart';
import 'package:ticketmaster_et/controllers/delivery_address_controller.dart';
import 'package:ticketmaster_et/controllers/time_controller.dart';
import 'package:ticketmaster_et/prefs/config_preferences.dart';
import 'package:ticketmaster_et/prefs/routes.dart';
import 'package:ticketmaster_et/prefs/translations.dart';
import 'package:ticketmaster_et/provider/loginpersistence.dart';
import 'package:ticketmaster_et/provider/settings_provider.dart';
import 'package:ticketmaster_et/screens/event_detail.dart';
import 'package:ticketmaster_et/screens/event_ticket.dart';
import 'package:ticketmaster_et/screens/organizerdetail.dart';

import 'controllers/theme_controller.dart';
import 'functions/functions.dart';
import 'models/newmodels.dart';

SettingsProvider settingsProvider = SettingsProvider();
late String langCode;
late String countryCode;

Future<void> appInit() async {
  print(DateTime.now().toString());
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //     options: const FirebaseOptions(
  //         apiKey: "AIzaSyBFvsvmM4KnG8EymvVw61ogE1hYeaSuDkY",
  //         appId: "1:195442595047:android:3015a02a01eeae43c5fe42",
  //         messagingSenderId: "195442595047",
  //         projectId: "ticket-master-et"));
  // await FirebaseHandler().initNotifications();
  // AwesomeNotifications().initialize(
  //   'resource://drawable/icon',
  //   [
  //     NotificationChannel(
  //         channelKey: 'basic_channel',
  //         channelName: 'Basic Notifications',
  //         defaultColor: Colors.teal,
  //         importance: NotificationImportance.High,
  //         channelShowBadge: true,
  //         channelDescription: 'Basic Notifications'),
  //     NotificationChannel(
  //         channelKey: 'scheduled_channel',
  //         channelName: 'Scheduled Notifications',
  //         defaultColor: Colors.teal,
  //         locked: true,
  //         importance: NotificationImportance.High,
  //         channelDescription: 'Scheduled Notifications'),
  //   ],
  // );
  // await EasyLocalization.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  langCode = await preferences.getString('langCode') ?? 'en';
  countryCode = await preferences.getString('countryCode') ?? '';
  print('COUNTRY CODE $countryCode');
  // await settingsProvider.getCurrentThemeMode();
  settingsProvider.languageCode =
      langCode + (countryCode.isNotEmpty ? '-' + countryCode : '');
  await settingsProvider.getLanguageCode();
  print(settingsProvider.languageCode);
}

void main() async {
  Chapa.configure(privateKey: "CHASECK-kSr6JwoZUw0IlZ6maJJqgxiFQMnz4MUX");
  await appInit();
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  ConfigPreference.init();
  // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  //   statusBarColor: Color(0xFF23981C), // Change this to your desired color
  //   statusBarIconBrightness: Brightness.light, // For light icons
  //   statusBarBrightness: Brightness.dark, // For iOS status bar
  // ));
  runApp(
    TicketMasterET(
      settingsProvider: settingsProvider,
    ),
  );
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
    // return FutureBuilder(
    //   builder: ((context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return const MaterialApp(
    //         debugShowCheckedModeBanner: true,
    //         home: Scaffold(
    //           body: Center(
    //             child: CircularProgressIndicator(),
    //           ),
    //         ),
    //       );
    //     } else if (snapshot.hasError) {
    //       GetMaterialApp(
    //         debugShowCheckedModeBanner: true,
    //         home: Scaffold(
    //           body: Center(
    //             child: Text(tr('error_occured')),
    //           ),
    //         ),
    //       );
    //     }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          return widget.settingsProvider;
        }),
        // ChangeNotifierProvider(
        //   create: (context) => LoginDataProvider(),
        // ),
        ChangeNotifierProvider(
          create: (context) => CommentsModel(),
        ),
      ],
      child: Consumer<SettingsProvider>(
          builder: (context, settingsProvider, snapshot) {
        return const LandingPage();
      }),
    );
  }
  // future: appInit(),
  // );
}

class InitialNavigationMiddleware extends GetMiddleware {
  Future<void> _checkFirstTimeUser() async {}
  @override
  RouteSettings? redirect(String? route) {
    bool isFirstTimeUser = true;
    print("Checking First TimeUser");
    final prefs = ConfigPreference.getStorage();
    final hasLaunchedBefore = prefs.getBool('hasLaunchedBefore') ?? false;
    if (hasLaunchedBefore) {
      isFirstTimeUser = false;
    } else {
      prefs.setBool('hasLaunchedBefore', true);
    }

    Logger().i("First Time User status $isFirstTimeUser");
    if (isFirstTimeUser) {
      Logger().i("SplashScreen $isFirstTimeUser");
      return const RouteSettings(name: Routes.splashRoute);
    }
    // else if (!ConfigPreference.isUserLoggedIn()) {
    //   Logger().i("SignupScreen $isFirstTimeUser");
    //   return const RouteSettings(name: Routes.loginRoute);
    // }
    // Check if the user is logged in
    // bool isLoggedIn = loginDataProvider.loginData != null;
    // if (!isLoggedIn) {
    //   return const RouteSettings(name: '/login'); // Redirect to login page
    // }
    return null; // Allow the navigation
  }
}

class AuthNavigationMiddleware extends GetMiddleware {
  Future<void> _checkFirstTimeUser() async {}
  @override
  RouteSettings? redirect(String? route) {
    bool isFirstTimeUser = true;
    print("Checking First TimeUser");
    // final prefs = ConfigPreference.getStorage();
    // final hasLaunchedBefore = prefs.getBool('hasLaunchedBefore') ?? false;
    // if (hasLaunchedBefore) {
    //   isFirstTimeUser = false;
    // } else {
    //   prefs.setBool('hasLaunchedBefore', true);
    // }
    //
    // Logger().i("First Time User status $isFirstTimeUser");
    // if (isFirstTimeUser) {
    //   Logger().i("SplashScreen $isFirstTimeUser");
    //   return const RouteSettings(name: Routes.splashRoute);
    // }
    if (!ConfigPreference.isUserLoggedIn()) {
      Logger().i("SignupScreen $isFirstTimeUser");
      Get.snackbar('Sign In', 'You need to sign in to continue to checkout',
          backgroundColor: Colors.red, colorText: Colors.white);
      return const RouteSettings(name: Routes.loginRoute);
    }
    // else if (!ConfigPreference.isUserLoggedIn()) {
    //   Logger().i("SignupScreen $isFirstTimeUser");
    //   return const RouteSettings(name: Routes.loginRoute);
    // }
    // Check if the user is logged in
    // bool isLoggedIn = loginDataProvider.loginData != null;
    // if (!isLoggedIn) {
    //   return const RouteSettings(name: '/login'); // Redirect to login page
    // }
    return null; // Allow the navigation
  }
}

class TimeCheckerMiddleware extends GetMiddleware {
  bool get _isClosed {
    final hour = DateTime.now().hour;
    final minute = DateTime.now().minute;
    final second = DateTime.now().second;

    // CLOSED if time is from 18:00:00 → 06:59:59
    // OPEN if time is from 07:00:01 → 17:59:59
    final isBeforeOpen = hour < 7; // 00:00 → 06:59
    final isAfterClose = hour >= 18; // 18:00 → 23:59
    final isExactly7am = hour == 7 && minute == 0 && second == 0;

    // Closed unless it's strictly after 07:00:01
    return (isBeforeOpen || isAfterClose) && !isExactly7am;
    // final hour = DateTime.now().hour;
    // return hour <= 7 || hour >= 18;
  }

  @override
  RouteSettings? redirect(String? route) {
    if (_isClosed) {
      // Prevent navigation completely by returning the same route
      // but indicating that navigation should not proceed.
      return RouteSettings(name: Get.currentRoute);
    }

    return null; // allow navigation
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  LoginDataProvider login = Get.put(LoginDataProvider(), tag: 'login');
  DeliveryAddressController deliveryAddressController =
      Get.put(DeliveryAddressController(), tag: DeliveryAddressController.tag);
  CurrentLocationController currentLocationController =
      Get.put(CurrentLocationController(), tag: CurrentLocationController.tag);
  TimeController timeController =
      Get.put(TimeController(), tag: TimeController.tag, permanent: true);

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<SettingsProvider>(context);
    Get.put(ThemeModeController(context));
    return Obx(() => GetMaterialApp(
          // localizationsDelegates: context.localizationDelegates,
          // supportedLocales: context.supportedLocales,
          // locale: context.locale,
          debugShowCheckedModeBanner: false,
          translations: AppTranslation(),
          locale: ThemeModeController.getLocale(),
          fallbackLocale: const Locale('en', 'US'),
          theme: ThemeModeController.getThemeMode(),
          // home: loginDataProvider.loginData != null?
          // TicketMatserHomePage(title: tr('ticketmaster_name')) : MaterialApp(home: SignupScreen()),
          initialRoute: Routes.mainLayoutRoute,
          getPages: Pages.pages,
        ));
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
      final uri = await AppLinks().getInitialLink();
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
    initial = await getEvents('${baseUrlFunc}event',
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
                                      'https://i.postimg.cc/9FkTYfDq/THICKET-MASTER-LOGO.jpg',
                                  width: 65,
                                  height: 65,
                                  errorBuilder: (context, obj, stack) =>
                                      Image.asset(
                                          'assets/images/THICKET_MASTER_LOGO.png'),
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
                                  stops: const [
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
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                modified[0].place!,
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                modified[0].date!,
                                                style: const TextStyle(
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
                                      Share.share(
                                        'https://ticketmaster-et.com$videofilename',
                                        subject:
                                            'Check out Ticketmaster ET to book a ticket for ${modified[0].title}',
                                      );
                                    },
                                    icon: const Icon(
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
                                    child: Text('buy_tickets'.tr)),
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
          return const Center(child: CircularProgressIndicator());
        }
      }),
    );
  }
}
