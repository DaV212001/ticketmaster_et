import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ticketmaster_et/functions/functions.dart';
import 'package:ticketmaster_et/models/newmodels.dart';
import 'package:ticketmaster_et/screens/event_detail.dart';

import '../../../provider/settings_provider.dart';
import '../../review/sub_category/add_review_sub_cat_screen.dart';

class SubCatDetail extends StatefulWidget {
  const SubCatDetail(
      {required this.subCategory, super.key, required this.selectedIndex});
  final SubCategory subCategory;
  final ValueNotifier<int> selectedIndex;
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
          subCategories: widget.subCategory,
          selectedIndex: widget.selectedIndex,
        ));
  }
}

class TabPair {
  final Tab tab;
  final Widget view;
  TabPair({required this.tab, required this.view});
}

class TabBarAndTabViews extends StatefulWidget {
  final SubCategory subCategories;
  final ValueNotifier<int> selectedIndex;
  const TabBarAndTabViews(
      {required this.subCategories, required this.selectedIndex});

  @override
  _TabBarAndTabViewsState createState() => _TabBarAndTabViewsState();
}

class _TabBarAndTabViewsState extends State<TabBarAndTabViews>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Event> events = [];
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

  void updateEvents() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (mounted) {
        final coverimage = await getCoverImagesbySubCatID(
            widget.subCategories.id!,
            Provider.of<SettingsProvider>(context, listen: false).languageCode);
        setState(() {
          coverimages = coverimage;
        });
      } else {
        return;
      }
    } catch (e) {
      print(e);
    }
    try {
      if (!mounted) {
        return;
      } else {
        final value = await getEventsBySubCategoryId(
          widget.subCategories.id!,
          Provider.of<SettingsProvider>(context, listen: false).languageCode,
        );
        setState(() {
          events = value;
          print(
              'VALUE OF THE events for Subcatdetails: $value, events are empty: ${events.isEmpty}');
        });
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Flexible(child: Text(tr('events')))],
            ),
          ),
          view: _isLoading
              ? const Center(
                  child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator()))
              : !events.isEmpty
                  ? ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      print("Event INDEX = ${index}");
                                      print("Event ID = ${events[index].id}");
                                      print(
                                          "Event title = ${events[index].title}");
                                      print(
                                          "Event categoryId = ${events[index].categoryId}");
                                      print(
                                          "Event subCategoryId = ${events[index].subCategoryId}");
                                      print(
                                          "Event organizerId = ${events[index].organizerId}");
                                      print(
                                          "=================================");

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return EventDetail(
                                              event: events.isNotEmpty
                                                  ? events[index]
                                                  : empty[index],
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: Container(
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
                                          imageUrl: events[index].image!.trim(),
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
                                  ),
                                  const SizedBox(height: 8),
                                  Center(child: Text(events[index].title!)),
                                ],
                              ),
                            ],
                          ),
                        );
                      })
                  : Column(
                      children: [
                        Center(
                          child: Image.network(
                            'https://i.postimg.cc/VkBQ3FS6/na-logo.png',
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
        view: widget.subCategories.desc == '0' ||
                widget.subCategories.desc == null
            ? Column(
                children: [
                  Center(
                      child: Center(
                    child: Image.network(
                      'https://i.postimg.cc/VkBQ3FS6/na-logo.png',
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
                    widget.subCategories.desc!,
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
        view: SubCategoryReview(subCategories: widget.subCategories),
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
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0),
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
                    return Container(
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
                decoration: BoxDecoration(
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
                      widget.subCategories.name!,
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
                        color: Color(0xFF00A600)),
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
}
