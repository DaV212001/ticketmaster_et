
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ticketmaster_et/functions/functions.dart';
import 'package:ticketmaster_et/models/newmodels.dart';
import 'package:ticketmaster_et/screens/event_ticket.dart';

import '../../../provider/settings_provider.dart';



class TabBarAndTabViews extends StatefulWidget {
  final SubCategory subCategories;
  const TabBarAndTabViews({super.key, required this.subCategories});

  @override
  _TabBarAndTabViewsState createState() => _TabBarAndTabViewsState();
}

class _TabBarAndTabViewsState extends State<TabBarAndTabViews>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Event> events = [];
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
          print('VALUE OF THE events for Subcatdetails: $value');
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
                                    return EventTicket(event: events.isNotEmpty?events[index]: empty[index]);
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
        view: widget.subCategories.desc=='0'||widget.subCategories.desc==null?Center(
            child: Center (
              child: Image.network('https://i.postimg.cc/VkBQ3FS6/na-logo.png'),
            )
        ):Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              child: Text(
                widget.subCategories.desc!,
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

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Material(
              elevation: 10,
              shadowColor: Colors.black,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                height: 200,
                width: 200,
                child: Center (
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
                      imageUrl:  widget.subCategories.image!,
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
            ),
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
class TabPair {
  final Tab tab;
  final Widget view;
  TabPair({required this.tab, required this.view});
}