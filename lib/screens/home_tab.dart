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
  late TabController tabController;
  List<EventModel> events = [
    EventModel(
        id: '001',
        title: 'New year EXPO',
        image:
            'https://img.freepik.com/free-photo/town-famous-attraction-landmark-village_1417-388.jpg?w=1060&t=st=1662380712~exp=1662381312~hmac=fd853eae11f31c295ee48bedc286ebc0534e289be71ae93c4f8d21d7003daa6e',
        date: '12 Feb',
        location: 'location',
        description: 'description'),
    EventModel(
        id: '001',
        title: 'New year EXPO',
        image:
            'https://img.freepik.com/free-photo/town-famous-attraction-landmark-village_1417-388.jpg?w=1060&t=st=1662380712~exp=1662381312~hmac=fd853eae11f31c295ee48bedc286ebc0534e289be71ae93c4f8d21d7003daa6e',
        date: '12 Feb',
        location: 'location',
        description: 'description'),
    EventModel(
        id: '001',
        title: 'New year EXPO',
        image:
            'https://img.freepik.com/free-photo/town-famous-attraction-landmark-village_1417-388.jpg?w=1060&t=st=1662380712~exp=1662381312~hmac=fd853eae11f31c295ee48bedc286ebc0534e289be71ae93c4f8d21d7003daa6e',
        date: '12 Feb',
        location: 'location',
        description: 'description'),
    EventModel(
        id: '001',
        title: 'New year EXPO',
        image:
            'https://img.freepik.com/free-photo/town-famous-attraction-landmark-village_1417-388.jpg?w=1060&t=st=1662380712~exp=1662381312~hmac=fd853eae11f31c295ee48bedc286ebc0534e289be71ae93c4f8d21d7003daa6e',
        date: '12 Feb',
        location: 'location',
        description: 'description'),
  ];

  int times = 20;

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
        _handleCallbackEvent(event.direction, event.success);
      });

    super.build(context);
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width / 1.5,
          height: 45,
          child: TabBar(
            tabs: const [
              Tab(
                child: Text(
                  'Home',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Tab(
                child: Text(
                  'Upcoming',
                  style: TextStyle(color: Colors.black),
                ),
              )
            ],
            controller: tabController,
          ),
        ),
        Expanded(
            child: TabBarView(controller: tabController, children: [
          HomeTabWidget(modified: modified, controller: controller),
          UpcomingTabWidget(events: events),
        ]))
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  void _handleCallbackEvent(ScrollDirection direction, ScrollSuccess success,
      {int? currentIndex}) {
    print(
        "Scroll callback received with data: {direction: $direction, success: $success and index: ${currentIndex ?? 'not given'}}");
  }
}
