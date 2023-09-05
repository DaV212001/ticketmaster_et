// ignore_for_file: unused_element, no_leading_underscores_for_local_identifiers

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ticketmaster_et/models/event_model.dart';
import 'package:tiktoklikescroller/tiktoklikescroller.dart';

import '../widgets.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  bool isImageZoomed = false;

  void toggleImageZoom() {
    setState(() {
      isImageZoomed = !isImageZoomed;
    });
  }

  late TabController tabController;
  List<EventModel> events = [
    EventModel(
        id: '001',
        title: 'Rophnan Concert',
        image:
            'https://pbs.twimg.com/media/Fk8WbnRWAAI8tpB?format=jpg&name=large',
        date: 'September 10',
        location: 'Skylight Hotel',
        description:
            'Have an awesome new year eve with Rophnan at skylight hotel!'),
    EventModel(
        id: '001',
        title: 'Wazema Concert',
        image:
            'https://www.ethiobeauty.com/uploads/images/full/Ethio_Beauty_2OGKpVZnNXG84SJDqHZYsPrYQD0wiBAEtK1GBhTx8ZZslAckUhhsbZWgDIEuR+Mpcwi8zQ0G+AkhVkdKOCFDdQ.jpg',
        date: 'September 9',
        location: 'Meskel Square',
        description:
            'A group of 7 musicians are here to entertain you through 2016!'),
    EventModel(
        id: '001',
        title: 'Tesfa Concert',
        image:
            'https://scontent.fadd2-1.fna.fbcdn.net/v/t39.30808-6/305221134_148730804509859_3798409275105151661_n.jpg?_nc_cat=104&ccb=1-7&_nc_sid=cd49ab&_nc_ohc=YgKVGiUwmpkAX8p3zoI&_nc_ht=scontent.fadd2-1.fna&oh=00_AfDsydncdSMw0Ge9u70OGb3Jv4MrTJ7dDXxf8fUyIlntjw&oe=64FAE941',
        date: 'September 11',
        location: 'Millenium Hall',
        description:
            'We are bringing to you the best line up for your NYE celebration!'),
  ];

  int times = 50;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<EventModel> modified = [];
    for (int i = 0; i < times; i++) {
      modified.addAll(events);
    }
    final Controller controller = Controller()
      ..addListener((event) {
        _handleCallbackEvent(event.direction, event.success,
            currentIndex: event.pageNo);
      });

    super.build(context);
    print(tabController.index);
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        TabBarView(controller: tabController, children: [
          HomeTabWidget(events: events),
          UpcomingTabWidget(
              modified: modified,
              controller: controller,
              isZoomed: isImageZoomed,
              toggleZoom: toggleImageZoom),
        ]),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(
                25.0,
              ),
            ),
            height: 45,
            width: MediaQuery.of(context).size.width * 0.5,
            child: TabBar(
              indicatorSize: TabBarIndicatorSize.label,
              controller: tabController,
              indicatorWeight: 5,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black,
              tabs: [
                Tab(
                  text: tr('home'),
                ),
                Tab(
                  text: tr('upcoming'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  void _handleCallbackEvent(ScrollDirection direction, ScrollSuccess success,
      {int? currentIndex}) {
    toggleImageZoom();
    print(
        "Scroll callback received with data: {direction: $direction, success: $success and index: ${currentIndex ?? 'not given'}}");
    double scale = 1.0;
    double previousScale = 1.0;

    void _onScaleStart(ScaleStartDetails details) {
      previousScale = scale;
      print('scale start');
      setState(() {});
    }

    void _onScaleUpdate(ScaleUpdateDetails details) {
      scale = previousScale * details.scale;
      print('scale update');
      setState(() {});
    }

    void _onScaleEnd(ScaleEndDetails details) {
      previousScale = 1.0;
      print('scale end');
      setState(() {});
    }
  }
}
