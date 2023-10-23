import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ticketmaster_et/functions/functions.dart';
import 'package:ticketmaster_et/models/newmodels.dart';
import 'package:ticketmaster_et/screens/event_ticket.dart';
import 'package:ticketmaster_et/screens/review/event/add_review_event_screen.dart';

import '../provider/settings_provider.dart';
import 'category_events.dart';

class EventDetail extends StatefulWidget {
  const EventDetail({required this.event, super.key});
  final Event event;
  @override
  State<EventDetail> createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light
    ));
    return Scaffold(
        backgroundColor: Colors.white,
        body: TabBarAndTabViews(event: widget.event, ));
  }
}


class TabPair {
  final Tab tab;
  final Widget view;
  TabPair({required this.tab, required this.view});
}

class TabBarAndTabViews extends StatefulWidget {
  final Event event;
  const TabBarAndTabViews({required this.event, });

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

    try{
      if(mounted){
        final coverimage = await getCoverImagesbyEventID(widget.event.id!,
            Provider.of<SettingsProvider>(context, listen: false).languageCode
        );
        setState(() {
          coverimages = coverimage;
        });
      }else{
        return;
      }
    } catch(e){
      print(e);
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
      }
    } catch (e) {
      print(e);
      if(mounted)
        setState(() {
          _hasError = true;
        });
    }
  }



  List<Event> empty = [];
  @override
  Widget build(BuildContext context) {
    // Define the TabPairs list inside the build method
    final isPlaying = ValueNotifier<bool>(true);
    List<TabPair> TabPairs = [
      TabPair(
          tab: Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [ Flexible(child: Text(tr('events')))],
            ),
          ),
          view:  events.isNotEmpty & !_hasError?
              events[0].classes!.isNotEmpty?
          ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: events[0].classes!.length,
              itemBuilder: (context, index) {

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              isPlaying.value = false;
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                    return EventTicket(event: events[0], classId: events[0].classes![index].id);
                                  }));
                            },
                            child: Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.cyan),
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
                                  imageUrl:events[0].image!.trim(),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                  child: Text(
                                      events[0].classes![index].title!
                                  ),
                              ),
                              Center(
                                  child: Text(
                                      events[0].classes![index].availableTicket! != 1?
                                      '${events[0].classes![index].availableTicket!} available tickets'
                                          :
                                      '${events[0].classes![index].availableTicket!} available ticket'
                                  ),
                              ),
                            ],
                          )

                        ],
                      ),
                    ],
                  ),
                );
              }
          )
              :Center (
            child: Image.network('https://i.postimg.cc/VkBQ3FS6/na-logo.png'),
          ):Center (
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
        view: widget.event.desc=='0'||widget.event.desc==null?Center(
            child: Center (
              child: Image.network('https://i.postimg.cc/VkBQ3FS6/na-logo.png'),
            )
        ):Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              child: Text(
                widget.event.desc!,
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
        view: EventReview(event: widget.event),
      ),
    ];

    double? deviceheight =MediaQuery.of(context).size.height;
    double? devicewidth =MediaQuery.of(context).size.width;
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
            Container(
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(onPressed: (){Navigator.pop(context);},
                      icon: Icon(Icons.chevron_left)),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      widget.event.title!,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: devicewidth * 0.04
                      ),
                    ),

                  )
                ],
              ),
            ),
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

                    if (coverimages.isNotEmpty) {
                      return
                        Container(
                          height: deviceheight*0.3,
                          width: devicewidth,
                          child: !coverimages[index].coverimage!.trim().endsWith('.mp4')?
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
                          ) : Container(
                            height: deviceheight*0.3,
                            width: devicewidth,
                            child: VideoPlayerWidget(videoUrl: coverimages[index].coverimage!.trim()),
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
                  Container(
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
                          widget.event.title!,
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
      ),
    );
  }
}


