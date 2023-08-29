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
        title: 'Bear concert',
        image:
            'https://images.pexels.com/photos/2311713/pexels-photo-2311713.jpeg?auto=compress&cs=tinysrgb&w=600',
        date: '12 Feb',
        location: 'location',
        description: 'description'),
    EventModel(
        id: '001',
        title: 'Red concert',
        image:
            'https://images.pexels.com/photos/1540406/pexels-photo-1540406.jpeg?auto=compress&cs=tinysrgb&w=600',
        date: '12 Feb',
        location: 'location',
        description: 'description'),
    EventModel(
        id: '001',
        title: 'Family event',
        image:
            'https://images.pexels.com/photos/3951652/pexels-photo-3951652.jpeg?auto=compress&cs=tinysrgb&w=600',
        date: '12 Feb',
        location: 'location',
        description: 'description'),
    EventModel(
        id: '001',
        title: 'New year EXPO',
        image:
            'https://images.pexels.com/photos/1317374/pexels-photo-1317374.jpeg?auto=compress&cs=tinysrgb&w=600',
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
        _handleCallbackEvent(event.direction, event.success,
            currentIndex: event.pageNo);
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
    // print(
    //     "Scroll callback received with data: {direction: $direction, success: $success and index: ${currentIndex ?? 'not given'}}");
    double _scale = 1.0;
    double _previousScale = 1.0;

    void _onScaleStart(ScaleStartDetails details) {
      _previousScale = _scale;
      setState(() {});
    }

    void _onScaleUpdate(ScaleUpdateDetails details) {
      _scale = _previousScale * details.scale;
      setState(() {});
    }

    void _onScaleEnd(ScaleEndDetails details) {
      _previousScale = 1.0;
      setState(() {});
    }
  }
}
