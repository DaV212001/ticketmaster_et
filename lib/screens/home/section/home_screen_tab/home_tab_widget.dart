
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ticketmaster_et/models/event_model.dart';
import 'package:tiktoklikescroller/tiktoklikescroller.dart';

import 'package:ticketmaster_et/models/newmodels.dart';

import '../../../../constants/app_constants.dart';
import '../../../../functions/functions.dart';
import '../../../../provider/settings_provider.dart';
import '../../../event_detail.dart';
import '../../../organizerdetail.dart';
import '../../../category/section/subcategorydetails.dart';
import 'home_screen_carousel.dart';
import 'home_screen_categories.dart';
import 'home_screen_organizers.dart';
class HomeTabWidget extends StatefulWidget {
  const HomeTabWidget({
    super.key,
  });

  @override
  State<HomeTabWidget> createState() => _HomeTabWidgetState();
}

class _HomeTabWidgetState extends State<HomeTabWidget> {
  List<Organizer> ep = [];
  List<Category> categories = [];
  List<Event> events = [];
  List<Event> popularevents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateCategories();
    });
  }
  late final  _settingsProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Now it's safe to listen to SettingsProvider
    _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _settingsProvider.addListener(updateCategories);
  }
  @override
  void dispose() {
    if (_settingsProvider != null) {
      _settingsProvider!.removeListener(updateCategories);
    }

    super.dispose();
  }
  void updateCategories() {
    setState(() {
      _isLoading = true;
    });
    getCategorySubCategory(
        Provider.of<SettingsProvider>(context, listen: false).languageCode)
        .then((value) => setState(() {
      categories = value;
   //   print('VALUE OF THE CATEGORY: $value');
    }));
    getEvents('$apiUrl/event',
        Provider.of<SettingsProvider>(context, listen: false).languageCode)
        .then((value) {
      events = value;
    //  print('VALUE OF THE EVENTS: $value');
      // Populate popularevents outside setState()
      popularevents.clear(); // Clear the list first
      for (Event eve in events) {
      //  print('POPULAR IDS: ${eve.isPopular}');
        if (eve.isPopular == '1') {
          popularevents.add(eve);
        }
      }

      // Call setState() only when popularevents changes
      setState(() {
      //  print(popularevents);
      });
    });
    getOrganizers(
        Provider.of<SettingsProvider>(context, listen: false).languageCode)
        .then((value) => setState(() {
      ep = value;
  //    print('VALUE OF THE ORGANIZERS: $value');
    }));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // If the data is still loading, show a loading indicator
      return CircularProgressIndicator();
    } else {
      // Once the data has loaded, build your widget as usual
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _isLoading
                  ? CircularProgressIndicator()
                  : SizedBox(
                height: 350,
                child: HomeScreenCarouselSlider(),
              ),
              categories.length != 0?
              HomeScreenCategories(): Center(
                child: Image.network(
                    'https://i.postimg.cc/VkBQ3FS6/na-logo.png'),
              ),
              HomeScreenOrganizers()
            ],
          ),
        ),
      );
    }
  }
}