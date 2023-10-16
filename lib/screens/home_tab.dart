// ignore_for_file: unused_element, no_leading_underscores_for_local_identifiers

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ticketmaster_et/models/event_model.dart';
import 'package:tiktoklikescroller/tiktoklikescroller.dart';

import '../constants/app_constants.dart';
import '../functions/functions.dart';
import '../provider/settings_provider.dart';
import '../widgets.dart';
import 'package:ticketmaster_et/models/newmodels.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  bool isImageZoomed = false;
  late SettingsProvider languageChange;

  void toggleImageZoom() {
    setState(() {
      isImageZoomed = !isImageZoomed;
    });
  }

  late TabController tabController;
  List<Event> events = [];

  int times = 50;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    languageChange = Provider.of<SettingsProvider>(context, listen: false);
    languageChange.addListener(rebuild);
    tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateCategories();
    });
  }
  void updateCategories() {
    setState(() {
      _isLoading = true;
    });
    getEvents('$apiUrl/upcoming', Provider.of<SettingsProvider>(context, listen: false).languageCode).then((value) => setState((){
      events = value;
      print( 'VALUE OF THE EVENTS: $value');
    }));
    setState(() {
      _isLoading = false;
    });
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newLanguageChange = Provider.of<SettingsProvider>(context);
    if (languageChange != newLanguageChange) {
      languageChange.removeListener(rebuild);
      languageChange = newLanguageChange;
      languageChange.addListener(rebuild);
    }
    Provider.of<SettingsProvider>(context).addListener(updateCategories);
  }


  @override
  void dispose() {
    languageChange.removeListener(rebuild);
    Provider.of<SettingsProvider>(context).removeListener(updateCategories);
    super.dispose();
  }

  void rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    List<Event> modified = [];
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
          HomeTabWidget(),
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
