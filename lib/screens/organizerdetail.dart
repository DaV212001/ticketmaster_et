import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ticketmaster_et/functions/functions.dart';
import 'package:ticketmaster_et/models/newmodels.dart';
import 'package:ticketmaster_et/screens/event_detail.dart';

import '../models/newmodels.dart';
import '../models/newmodels.dart';
import '../provider/settings_provider.dart';
import 'category_events.dart';

class OrganizerDetail extends StatefulWidget {
  const OrganizerDetail({required this.organizer, super.key});
  final Organizer organizer;
  @override
  State<OrganizerDetail> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrganizerDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: TabBarAndTabViews(organizer: widget.organizer));
  }
}

// class FavoritesScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(child: Text('Favorites Screen')),
//     );
//   }
// }

class InfoCard extends StatelessWidget {
  final String title;
  final String body;
  final Function() onMoreTap;

  final String subInfoTitle;
  final String subInfoText;
  final Widget subIcon;

  const InfoCard(
      {required this.title,
        this.body = """Delivery boy departed at 20:00""",
        required this.onMoreTap,
        this.subIcon = const CircleAvatar(
          child: Icon(
            Icons.payment,
            color: Colors.white,
          ),
          backgroundColor: Colors.cyanAccent,
          radius: 25,
        ),
        this.subInfoText = "ETB 545",
        this.subInfoTitle = "Fee",
        Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(25.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.05),
                offset: const Offset(0, 10),
                blurRadius: 0,
                spreadRadius: 0,
              )
            ],
            gradient: const RadialGradient(
              colors: [Colors.cyanAccent, Color(0xFF3AE0C4)],
              focal: Alignment.topCenter,
              radius: .85,
            )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 26,
                    fontFamily: 'Oswald',
                  ),
                ),
                Container(
                  width: 75,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100.0),
                    gradient: const LinearGradient(
                        colors: [Colors.white, Colors.white],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter),
                  ),
                  child: GestureDetector(
                    onTap: onMoreTap,
                    child: const Center(
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400,
                              fontFamily: 'Oswald'),
                        )),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              body,
              style: TextStyle(
                color: Colors.black.withOpacity(.75),
                fontSize: 17,
                fontWeight: FontWeight.w400,
                fontFamily: 'Oswald',
              ),
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              height: 75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    subIcon,
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(subInfoTitle),
                        Text(
                          subInfoText,
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TabPair {
  final Tab tab;
  final Widget view;
  TabPair({required this.tab, required this.view});
}

class TabBarAndTabViews extends StatefulWidget {
  final Organizer organizer;
  const TabBarAndTabViews({required this.organizer});

  @override
  _TabBarAndTabViewsState createState() => _TabBarAndTabViewsState();
}

class _TabBarAndTabViewsState extends State<TabBarAndTabViews>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Event> events = [];
  bool _isLoaded = false;
List<CoverImage> coverimages = [];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateEvents();
    });
  }
  late final  _settingsProvider;
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
    try {
      if (mounted) {
        final coverimage = await getCoverImagesbyOrganizerID(
            widget.organizer.id!, Provider
            .of<SettingsProvider>(context, listen: false)
            .languageCode);
        setState(() {
          coverimages = coverimage;
        });
      } else{
        return;
      }
    } catch(e){
      print(e);
    }

    try {
      if (!mounted) {
        return;
      } else {

        final value = await getEventsByOrganizerId(
          widget.organizer.id!,
          Provider.of<SettingsProvider>(context, listen: false).languageCode,
        );
        setState(() {
          events = value;
          print('VALUE OF THE events for orgDetails: $value');
        });
      }
    } catch (e) {
      print(e);
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
              children: [ Flexible(child: Text(tr('events')))],
            ),
          ),
          view:  events.isNotEmpty || !_hasError?
          ListView.builder(
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
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                    return EventDetail(event: events.isNotEmpty?events[index]: empty[index]);
                                  }));
                            },
                            child: Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child:
                                CachedNetworkImage(
                                  fadeOutDuration:
                                  const Duration(milliseconds:
                                  300),
                                  fadeOutCurve:
                                  Curves.easeOut,
                                  fadeInDuration:
                                  const Duration(milliseconds:
                                  700),
                                  fadeInCurve:
                                  Curves.easeIn,
                                  imageUrl:events[index].image!.trim(),
                                  imageBuilder:
                                      (context, imageProvider) =>
                                      Container(
                                        decoration:
                                        BoxDecoration(
                                          image:
                                          DecorationImage(
                                            image:
                                            imageProvider,
                                            fit:
                                            BoxFit.cover,
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
              }
          )
              :Center (
            child: Image.network('https://i.postimg.cc/VkBQ3FS6/na-logo.png'),
          )
      ),
      TabPair(
        tab: Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Flexible(child: Text(tr('desc')))],
          ),
        ),
        view: widget.organizer.desc=='0'||widget.organizer.desc==null?Center(
            child: Center (
              child: Image.network('https://i.postimg.cc/VkBQ3FS6/na-logo.png'),
            )
        ):Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              child: Text(
                widget.organizer.desc!,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
      TabPair(
        tab: Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [ Flexible(child: Text(tr('review')))],
          ),
        ),
        view: Center(
            child: Center (
              child: Image.network('https://i.postimg.cc/VkBQ3FS6/na-logo.png'),
            )
        ),
      ),
    ];

    double? deviceheight =MediaQuery.of(context).size.height;
    double? devicewidth =MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          Stack(
              children:[CarouselSlider.builder(

                options: CarouselOptions(
                  disableCenter: true,
                  viewportFraction: 1,
                  enlargeCenterPage: false,
                  autoPlay: true,
                ),

                itemBuilder:
                    (BuildContext context, int index, pageViewIndex) {

                  if (events.isNotEmpty&&coverimages.isNotEmpty) {
                    return
                      Container(
                        height: deviceheight*0.3,
                        width: devicewidth,
                        child: CachedNetworkImage(
                          fadeOutDuration:
                          const Duration(milliseconds:
                          300),
                          fadeOutCurve:
                          Curves.easeOut,
                          fadeInDuration:
                          const Duration(milliseconds:
                          700),
                          fadeInCurve:
                          Curves.easeIn,
                          imageUrl:coverimages[index].coverimage!.trim(),
                          imageBuilder:
                              (context, imageProvider) =>
                              Container(
                                decoration:
                                BoxDecoration(
                                  image:
                                  DecorationImage(
                                    image:
                                    imageProvider,
                                    fit:
                                    BoxFit.cover,
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
                itemCount:
                coverimages.isEmpty ? 4 : coverimages.length,
              ),
                if(events.isNotEmpty)if(coverimages.isNotEmpty)Container(
                  height: deviceheight*0.3,
                  width: devicewidth,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.black, Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.topCenter ,
                      child: Text(
                        widget.organizer.name!,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: devicewidth * 0.04
                        ),
                      ),
                    ),
                  ),
                )
              ]
          ),
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
                  children: TabPairs.map((tabPair) => tabPair.view).toList())),
        ],
      ),
    );
  }
}
