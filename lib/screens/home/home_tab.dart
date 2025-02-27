// ignore_for_file: unused_element, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:ticketmaster_et/screens/home/section/home_screen_tab/home_tab_widget.dart';

class HomeTab extends StatefulWidget {
  final ValueNotifier<int> selectedIndex;

  const HomeTab({Key? key, required this.selectedIndex}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool isImageZoomed = false;
  // late SettingsProvider languageChange;

  void toggleImageZoom() {
    setState(() {
      isImageZoomed = !isImageZoomed;
    });
  }

  // List<Organizer> modifiedOrg = [];
  // late TabController tabController;
  // List<Event> events = [];
  //
  // int times = 50;
  // bool _isLoading = true;
  // @override
  // void initState() {
  //   print("HomeTab 1");
  //   super.initState();
  //   languageChange = Provider.of<SettingsProvider>(context, listen: false);
  //   print("HomeTab 2");
  //   languageChange.addListener(rebuild);
  //   print("HomeTab 3");
  //   // tabController = TabController(length: 2, vsync: this);
  //   print("HomeTab 4");
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     updateCategories();
  //   });
  // }
  //
  // void updateCategories() {
  //   print("updateCategories Called 1");
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   print("updateCategories Called 2");
  //   getOrganizers(
  //           Provider.of<SettingsProvider>(context, listen: false).languageCode)
  //       .then((value) => setState(() {
  //             print("updateCategories Called 3.1");
  //             modifiedOrg = value;
  //             //  print( 'VALUE OF THE EVENTS: $value');
  //             print("updateCategories Called 3.2");
  //           }));
  //   getEvents('$apiUrl/upcoming',
  //           Provider.of<SettingsProvider>(context, listen: false).languageCode)
  //       .then((value) => setState(() {
  //             print("updateCategories Called 3.1");
  //             events = value;
  //             //  print( 'VALUE OF THE EVENTS: $value');
  //             print("updateCategories Called 3.2");
  //           }));
  //   print("updateCategories Called 4");
  //   setState(() {
  //     _isLoading = false;
  //   });
  //   print("updateCategories Called 5");
  // }
  //
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final newLanguageChange = Provider.of<SettingsProvider>(context);
  //   if (languageChange != newLanguageChange) {
  //     languageChange.removeListener(rebuild);
  //     languageChange = newLanguageChange;
  //     languageChange.addListener(rebuild);
  //   }
  //   Provider.of<SettingsProvider>(context).addListener(updateCategories);
  // }
  //
  // @override
  // void dispose() {
  //   if (mounted) {
  //     languageChange.removeListener(rebuild);
  //     Provider.of<SettingsProvider>(context, listen: false)
  //         .removeListener(updateCategories);
  //     super.dispose();
  //   }
  // }

  // void rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    // List<Event> modified = [];
    // for (int i = 0; i < times; i++) {
    //   modified.addAll(events);
    // }
    // final Controller controller = Controller()
    //   ..addListener((event) {
    //     _handleCallbackEvent(event.direction, event.success,
    //         currentIndex: event.pageNo);
    //   });

    // super.build(context);
    //   print(tabController.index);
    return HomeTabWidget(
      selectedIndex: widget.selectedIndex,
    );
  }

  // @override
  // bool get wantKeepAlive => true;

  // void _handleCallbackEvent(ScrollDirection direction, ScrollSuccess success,
  //     {int? currentIndex}) {
  //   toggleImageZoom();
  //   print(
  //       "Scroll callback received with data: {direction: $direction, success: $success and index: ${currentIndex ?? 'not given'}}");
  //   double scale = 1.0;
  //   double previousScale = 1.0;
  //
  //   void _onScaleStart(ScaleStartDetails details) {
  //     previousScale = scale;
  //     print('scale start');
  //     setState(() {});
  //   }
  //
  //   void _onScaleUpdate(ScaleUpdateDetails details) {
  //     scale = previousScale * details.scale;
  //     print('scale update');
  //     setState(() {});
  //   }
  //
  //   void _onScaleEnd(ScaleEndDetails details) {
  //     previousScale = 1.0;
  //     print('scale end');
  //     setState(() {});
  //   }
  // }
}
