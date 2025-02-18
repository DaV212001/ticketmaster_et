import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chapa_unofficial/chapa_unofficial.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ticketmaster_et/functions/functions.dart';
import 'package:ticketmaster_et/models/newmodels.dart';

import '../../../provider/loginpersistence.dart';
import '../../../provider/settings_provider.dart';
import '../../review/sub_category/add_review_sub_cat_screen.dart';
import '../../signup.dart';

class SubCatDetail extends StatefulWidget {
  const SubCatDetail({
    required this.id,
    super.key,
  });
  final int id;
  @override
  State<SubCatDetail> createState() => _SubCatDetailState();
}

class _SubCatDetailState extends State<SubCatDetail> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light));
    return Scaffold(
        backgroundColor: Colors.white,
        body: TabBarAndTabViews(
          id: widget.id,
        ));
  }
}

class TabPair {
  final Tab tab;
  final Widget view;
  TabPair({required this.tab, required this.view});
}

class TabBarAndTabViews extends StatefulWidget {
  final int id;
  const TabBarAndTabViews({
    required this.id,
  });

  @override
  _TabBarAndTabViewsState createState() => _TabBarAndTabViewsState();
}

class _TabBarAndTabViewsState extends State<TabBarAndTabViews>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<FoodPortions> foodPortions = [];
  List<CoverImage> coverimages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateEvents();
    });
  }

  late final _settingsProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Now it's safe to listen to SettingsProvider
    _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _settingsProvider.addListener(updateEvents);
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
  SubCategory subCategory = SubCategory();

  void updateEvents() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (mounted) {
        final subCategoryFromAPI = await getSubCatbyID(widget.id!,
            Provider.of<SettingsProvider>(context, listen: false).languageCode);
        setState(() {
          subCategory = subCategoryFromAPI;
        });
      } else {
        return;
      }
    } catch (e, s) {
      print(e);
      print(s);
    }
    try {
      if (mounted) {
        final coverimage = await getCoverImagesbySubCatID(widget.id!,
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
        final value = await getEventsBySubCategoryId(
          widget.id!,
          Provider.of<SettingsProvider>(context, listen: false).languageCode,
        );
        setState(() {
          foodPortions = value;
          print(
              'VALUE OF THE events for Subcatdetails: $value, events are empty: ${foodPortions.isEmpty}');
        });
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e, s) {
      setState(() {
        _isLoading = false;
      });
      print(e);
      print(s);
      if (mounted)
        setState(() {
          _hasError = true;
        });
    }
  }

  List<Event> empty = [];
  @override
  Widget build(BuildContext context) {
    // Define the TabPairs list inside the build method
    List<TabPair> TabPairs = [
      TabPair(
          tab: Tab(
            child: Text(tr('portions'), style: TextStyle(fontSize: 10)),
          ),
          view: _isLoading
              ? const Center(
                  child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator()))
              : foodPortions.isNotEmpty
                  ? ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: foodPortions.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () async {
                            String location = '';
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: TextField(
                                      onChanged: (val) {
                                        location = val;
                                      },
                                      decoration: InputDecoration(
                                        hintText: tr('enter_location'),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              width: 2),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              width: 2),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              width: 2),
                                        ),
                                      ),
                                    ),
                                    content: ElevatedButton(
                                        onPressed: () async {
                                          if (location.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Error: Please enter location')),
                                            );
                                            return;
                                          }
                                          await payForPortion(
                                              context, location);
                                        },
                                        child: Text(
                                            'Pay ${foodPortions[index].price}')),
                                  );
                                });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: CachedNetworkImage(
                                          fadeOutDuration:
                                              const Duration(milliseconds: 300),
                                          fadeOutCurve: Curves.easeOut,
                                          fadeInDuration:
                                              const Duration(milliseconds: 700),
                                          fadeInCurve: Curves.easeIn,
                                          imageUrl:
                                              foodPortions[index].image!.trim(),
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Center(
                                              child: Text(
                                            foodPortions[index].name!,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                fontWeight: FontWeight.bold),
                                          )),
                                          Center(
                                              child: Text(
                                                  (foodPortions[index].price!)
                                                      .toStringAsFixed(2))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      })
                  : Column(
                      children: [
                        Center(
                          child: Image.network(
                            'https://i.postimg.cc/4dyhqLLY/THICKET-MASTER-LOGO.png',
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: MediaQuery.of(context).size.width * 0.4,
                          ),
                        ),
                        Text(
                          !_hasError
                              ? 'No events found'
                              : 'Error while fetching events',
                          style: TextStyle(fontSize: 20),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: ElevatedButton(
                              onPressed: () => updateEvents(),
                              style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 55)),
                              child: const Text('Retry')),
                        )
                      ],
                    )),
      TabPair(
        tab: Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Flexible(child: Text(tr('desc')))],
          ),
        ),
        view: subCategory.desc == '0' || subCategory.desc == null
            ? Column(
                children: [
                  Center(
                      child: Center(
                    child: Image.network(
                      'https://i.postimg.cc/4dyhqLLY/THICKET-MASTER-LOGO.png',
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: MediaQuery.of(context).size.width * 0.4,
                    ),
                  )),
                  const Text(
                    'No description found',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    subCategory.desc!,
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
        view: SubCategoryReview(subCategories: subCategory),
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
      child: SafeArea(
        child: Column(
          children: [
            Stack(children: [
              CarouselSlider.builder(
                options: CarouselOptions(
                  disableCenter: true,
                  viewportFraction: 1,
                  enlargeCenterPage: false,
                  autoPlay: true,
                ),
                itemBuilder: (BuildContext context, int index, pageViewIndex) {
                  if (coverimages.isNotEmpty) {
                    return SizedBox(
                      height: deviceheight * 0.3,
                      width: devicewidth,
                      child: CachedNetworkImage(
                        fadeOutDuration: const Duration(milliseconds: 300),
                        fadeOutCurve: Curves.easeOut,
                        fadeInDuration: const Duration(milliseconds: 700),
                        fadeInCurve: Curves.easeIn,
                        imageUrl: coverimages[index].coverimage!.trim(),
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
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
                      _isLoading ? '' : subCategory.name!,
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
                        color: Color(0xFF218A36)),
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
    );
  }

  Future<void> payForPortion(BuildContext context, String location) async {
    final loginDataProvider =
        Provider.of<LoginDataProvider>(context, listen: false);
    final accountProvider =
        Provider.of<LoginDataProvider>(context, listen: false);
    String? phone = accountProvider.loginData?.phone?.replaceFirst("251", "0");
    String txRef = TxRefRandomGenerator.generate(prefix: 'ticketmaster');
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
                    customerId: int.parse(phone!.replaceFirst("0", "251")),
                    foodId: foodPortions[0].foodId,
                    foodPortionId: foodPortions[0].id,
                    mealTypeId: "1",
                    location: location,
                    date: DateTime.now().toIso8601String()),
              );
              setState(() {
                // Call setState after bookEvent
                _isLoading = false;
              });
              print('PAYMENT SUCCESS!'); // Handle success events
              if (l.error == null) {
                // Show the pop-up card
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      title: const Text("Ticket Purchase Successful!"),
                      content:
                          Text("${foodPortions[0].price!} Birr Paid! Enjoy!"),
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
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content:
                        Text('Error Booking your ticket please try again')));
              }
            },
            amount: '${foodPortions[0].price!}',
            currency: 'ETB',
            txRef: storedTxRef,
            firstName: accountProvider.loginData?.firstName ?? '',
            lastName: accountProvider.loginData?.lastName ?? '',
            phoneNumber: phone ?? '',
            onInAppPaymentError: (errorMsg) {
              print('PAYMENT FAILURE'); // Handle error
            },
          )
        : Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const SignupScreen();
          }));
  }
}
