import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chapa_unofficial/chapa_unofficial.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ticketmaster_et/functions/functions.dart';
import 'package:ticketmaster_et/models/newmodels.dart';
import 'package:ticketmaster_et/screens/event_ticket.dart';
import 'package:ticketmaster_et/screens/review/event/add_review_event_screen.dart';
import 'package:ticketmaster_et/screens/signup.dart';
import 'package:ticketmaster_et/screens/thankyouscreen.dart';

import '../provider/loginpersistence.dart';
import '../provider/settings_provider.dart';

String ticketNum = '';

class EventDetail extends StatefulWidget {
  const EventDetail({required this.event, super.key});
  final Event event;
  @override
  State<EventDetail> createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light));
    return Scaffold(
        backgroundColor: Colors.white,
        body: TabBarAndTabViews(
          event: widget.event,
        ));
  }
}

class TabPair {
  final Tab tab;
  final Widget view;
  TabPair({required this.tab, required this.view});
}

class TabBarAndTabViews extends StatefulWidget {
  final Event event;
  const TabBarAndTabViews({
    super.key,
    required this.event,
  });

  @override
  _TabBarAndTabViewsState createState() => _TabBarAndTabViewsState();
}

class _TabBarAndTabViewsState extends State<TabBarAndTabViews>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Event> events = [];
  List<CoverImage> coverimages = [];
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateEvents();
    });
    ticketNum = generateTicketNumber(widget.event.title!);
  }

  late final _settingsProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Now it's safe to listen to SettingsProvider
    _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _settingsProvider.addListener(updateEvents);
    // updateEvents();
  }

  @override
  void dispose() {
    if (_settingsProvider != null) {
      _settingsProvider!.removeListener(updateEvents);
    }
    _tabController.dispose();
    super.dispose();
  }

  bool _hasError = false;
  bool _isLoading = false;

  void updateEvents() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (mounted) {
        final coverimage = await getCoverImagesbyEventID(widget.event.id!,
            Provider.of<SettingsProvider>(context, listen: false).languageCode);
        setState(() {
          coverimages = coverimage;
        });
      } else {
        return;
      }
    } catch (e, s) {
      print(e);
      print(s);
    }
    try {
      if (!mounted) {
        return;
      } else {
        final value = await getEventsbyID(
          widget.event.id!,
          Provider.of<SettingsProvider>(context, listen: false).languageCode,
        );
        setState(() {
          events = value;
          print('VALUE OF THE events for eventdetails: $value');
        });
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e, s) {
      print(e);
      print(s);
      if (mounted) {
        setState(() {
          _hasError = true;
        });
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String generateTicketNumber(String eventTitle) {
    const chars = '0123456789';
    Random rnd = Random();
    String randomDigits = String.fromCharCodes(Iterable.generate(
        4, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));

    String firstFourLettersOfTitle = eventTitle.length >= 4
        ? eventTitle.substring(0, 4).toUpperCase()
        : eventTitle.toUpperCase();

    return 'TM-$firstFourLettersOfTitle-$randomDigits';
  }

  // bool _isLoading = false;
  List<Event> empty = [];
  @override
  Widget build(BuildContext context) {
    // Define the TabPairs list inside the build method
    final isPlaying = ValueNotifier<bool>(true);
    List<TabPair> TabPairs = [
      // TabPair(
      //     tab: Tab(
      //       child: Row(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [ Flexible(child: Text(tr('events')))],
      //       ),
      //     ),
      //     view:  events.isNotEmpty & !_hasError?
      //         events[0].classes!.isNotEmpty?
      //     ListView.builder(
      //         scrollDirection: Axis.vertical,
      //         itemCount: events[0].classes!.length,
      //         itemBuilder: (context, index) {
      //           double deviceheight = MediaQuery.of(context).size.height;
      //           double devicewidth = MediaQuery.of(context).size.width;
      //           final loginDataProvider = Provider.of<LoginDataProvider>(context);
      //
      //           bool _isLoading = false;
      //           return Padding(
      //             padding: const EdgeInsets.all(8.0),
      //             child: Column(
      //
      //               children: [
      //                 Row(
      //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                   children: [
      //                     Row(
      //                       children: [
      //                         GestureDetector(
      //                           onTap: () {
      //                             isPlaying.value = false;
      //                           },
      //                           child: Container(
      //                             height: 100,
      //                             width: 100,
      //                             decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.cyan),
      //                             child: ClipRRect(
      //                               borderRadius: BorderRadius.circular(10.0),
      //                               child:
      //                               CachedNetworkImage(
      //                                 fadeOutDuration:
      //                                 const Duration(milliseconds:
      //                                 300),
      //                                 fadeOutCurve:
      //                                 Curves.easeOut,
      //                                 fadeInDuration:
      //                                 const Duration(milliseconds:
      //                                 700),
      //                                 fadeInCurve:
      //                                 Curves.easeIn,
      //                                 imageUrl:events[0].image!.trim(),
      //                                 imageBuilder:
      //                                     (context, imageProvider) =>
      //                                     Container(
      //                                       decoration:
      //                                       BoxDecoration(
      //                                         image:
      //                                         DecorationImage(
      //                                           image:
      //                                           imageProvider,
      //                                           fit:
      //                                           BoxFit.cover,
      //                                         ),
      //                                       ),
      //                                     ),
      //                               ),
      //                             ),
      //                           ),
      //                         ),
      //                         const SizedBox(height: 8),
      //                         Column(
      //                           crossAxisAlignment: CrossAxisAlignment.start,
      //                           children: [
      //                             Center(
      //                               child: Text(
      //                                   events[0].classes![index].title!
      //                               ),
      //                             ),
      //                             Center(
      //                               child: Text(
      //                                   events[0].classes![index].availableTicket! != 1?
      //                                   '${events[0].classes![index].availableTicket!} available tickets'
      //                                       :
      //                                   '${events[0].classes![index].availableTicket!} available ticket'
      //                               ),
      //                             ),
      //                           ],
      //                         ),
      //                       ],
      //                     ),
      //                     Container(
      //                       width: MediaQuery.of(context).size.width*0.25,
      //
      //                       child: ElevatedButton(
      //                         onPressed: () async {

      //                         },
      //                         style: ButtonStyle(
      //                             minimumSize: MaterialStatePropertyAll(
      //                                 Size(MediaQuery.of(context).size.width * 0.9, 50))),
      //                         child: _isLoading? CircularProgressIndicator(): Text(
      //                             'Pay ETB ${events[0].classes![index].price!}'
      //                         ),
      //                       ),
      //                     ),
      //                   ],
      //                 )
      //
      //               ],
      //             ),
      //           );
      //         }
      //     )
      //         :Center (
      //       child: Image.network('https://i.postimg.cc/4dyhqLLY/THICKET-MASTER-LOGO.png'),
      //     ):Center (
      //       child: Image.network('https://i.postimg.cc/4dyhqLLY/THICKET-MASTER-LOGO.png'),
      //     )
      // ),
      TabPair(
        tab: Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Flexible(child: Text(tr('desc')))],
          ),
        ),
        view: widget.event.desc == '0' || widget.event.desc == null
            ? Center(
                child: Center(
                child: Image.network(
                    'https://i.postimg.cc/4dyhqLLY/THICKET-MASTER-LOGO.png'),
              ))
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    widget.event.desc!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
      ),
      TabPair(
        tab: Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Flexible(child: Text(tr('review')))],
          ),
        ),
        view: EventReview(event: widget.event),
      ),
    ];

    double? deviceheight = MediaQuery.of(context).size.height;
    double? devicewidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        // Pop the outer Navigator's route
        Navigator.of(context).pop();
        // Prevent default behavior of closing the app
        return false;
      },
      child: Scaffold(
        floatingActionButton: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                final loginDataProvider =
                    Provider.of<LoginDataProvider>(context, listen: false);
                final accountProvider =
                    Provider.of<LoginDataProvider>(context, listen: false);
                String? phone =
                    accountProvider.loginData?.phone?.replaceFirst("251", "0");
                if (events.isNotEmpty && events[0].classes!.isNotEmpty) {
                  print('CHECKING PHONE NUMBER: $phone');
                  print('CHECKING PRICE: ${events[0].classes![0].price!}');
                  if (events[0].classes![0].price! != 0) {
                    String txRef =
                        TxRefRandomGenerator.generate(prefix: 'ticketmaster');
                    // Access the generated transaction reference
                    String storedTxRef = TxRefRandomGenerator.gettxRef;
                    // Use the Chapa Flutter SDK to create a new transaction
                    loginDataProvider.loginData != null ||
                            await loginDataProvider.isUserRegistered == true
                        ? await Chapa.getInstance.startPayment(
                            context: context,
                            onInAppPaymentSuccess: (successMsg) async {
                              BookingResponse l;
                              setState(() {
                                // Call setState before bookEvent
                                _isLoading = true;
                              });
                              l = await bookEvent(
                                Booking(
                                    customerId: int.parse(
                                        phone!.replaceFirst("0", "251")),
                                    foodId: events[0].id,
                                    foodPortionId: events[0].classes![0].id,
                                    mealTypeId: phone.replaceFirst("0", "251"),
                                    location: ticketNum,
                                    date: events[0]
                                        .classes![0]
                                        .price!
                                        .toString()),
                              );
                              setState(() {
                                // Call setState after bookEvent
                                _isLoading = false;
                              });
                              print(
                                  'PAYMENT SUCCESS!'); // Handle success events
                              if (l.error == null) {
                                // Show the pop-up card
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      title: const Text(
                                          "Ticket Purchase Successful!"),
                                      content: Text(
                                          "${events[0].classes![0].price!} Birr Paid! Enjoy!"),
                                      actions: [
                                        TextButton(
                                          child: const Text("OK"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                setState(() {
                                  _isLoading = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Error Booking your ticket please try again')));
                              }
                            },
                            amount: '${events[0].classes![0].price!}',
                            currency: 'ETB',
                            txRef: storedTxRef,
                            firstName:
                                accountProvider.loginData?.firstName ?? '',
                            lastName: accountProvider.loginData?.lastName ?? '',
                            phoneNumber: phone ?? '',
                            onInAppPaymentError: (errorMsg) {
                              print('PAYMENT FAILURE'); // Handle error
                            },
                          )
                        : Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                            return const SignupScreen();
                          }));
                  } else {
                    setState(() {
                      _isLoading = false;
                    });
                    BookingResponse l = await bookEvent(
                      Booking(
                          customerId:
                              int.parse(phone!.replaceFirst("0", "251")),
                          foodId: events[0].id,
                          foodPortionId: events[0].classes![0].id,
                          mealTypeId: phone.replaceFirst("0", "251"),
                          location: ticketNum,
                          date: events[0].classes![0].price!.toString()),
                    );
                    print(l);
                    if (l.error == null) {
                      setState(() {
                        _isLoading = false;
                      });
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ThankYouScreen(event: events[0]);
                      }));
                    }
                  }
                } else {
                  setState(() {
                    _isLoading = false;
                  });
                  BookingResponse l = await bookEvent(
                    Booking(
                        customerId: int.parse(phone!.replaceFirst("0", "251")),
                        foodId: events[0].id,
                        foodPortionId: events[0].classes![0].id,
                        mealTypeId: phone.replaceFirst("0", "251"),
                        location: ticketNum,
                        date: events[0].classes![0].price!.toString()),
                  );
                  print(l);
                  if (l.error == null) {
                    setState(() {
                      _isLoading = false;
                    });
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ThankYouScreen(event: events[0]);
                    }));
                  }
                }
              },
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text('order'.tr()),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            children: [
              Container(
                color: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.chevron_left)),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        widget.event.title!,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: devicewidth * 0.04),
                      ),
                    )
                  ],
                ),
              ),
              Stack(children: [
                CarouselSlider.builder(
                  options: CarouselOptions(
                    disableCenter: true,
                    viewportFraction: 1,
                    enlargeCenterPage: false,
                    autoPlay: true,
                  ),
                  itemBuilder:
                      (BuildContext context, int index, pageViewIndex) {
                    if (coverimages.isNotEmpty) {
                      return SizedBox(
                        height: deviceheight * 0.3,
                        width: devicewidth,
                        child: !coverimages[index]
                                .coverimage!
                                .trim()
                                .endsWith('.mp4')
                            ? CachedNetworkImage(
                                fadeOutDuration:
                                    const Duration(milliseconds: 300),
                                fadeOutCurve: Curves.easeOut,
                                fadeInDuration:
                                    const Duration(milliseconds: 700),
                                fadeInCurve: Curves.easeIn,
                                imageUrl: coverimages[index].coverimage!.trim(),
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(
                                height: deviceheight * 0.3,
                                width: devicewidth,
                                child: VideoPlayerWidget(
                                    videoUrl:
                                        coverimages[index].coverimage!.trim()),
                              ),
                      );
                    } else {
                      return Image.asset(
                        'assets/images/na_logo.jpg',
                        fit: BoxFit.cover,
                      );
                    }
                  },
                  itemCount: coverimages.isEmpty ? 4 : coverimages.length,
                ),
                Container(
                  height: deviceheight * 0.3,
                  width: devicewidth,
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                    colors: [Colors.black, Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        widget.event.title!,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: devicewidth * 0.04),
                      ),
                    ),
                  ),
                )
              ]),
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.0),
                          color: const Color(0xFF218A36)),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black,
                      tabs: TabPairs.map((tabPair) => tabPair.tab).toList()),
                ),
              ),
              Expanded(
                  child: TabBarView(
                      controller: _tabController,
                      children:
                          TabPairs.map((tabPair) => tabPair.view).toList())),
            ],
          ),
        ),
      ),
    );
  }
}
