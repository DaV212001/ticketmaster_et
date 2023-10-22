
import 'package:flutter/cupertino.dart';

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
import '../../../event_ticket.dart';
import '../../../organizerdetail.dart';
import '../../../category/section/subcategorydetails.dart';
class HomeScreenCarouselSlider extends StatefulWidget {
  final ValueNotifier<int> selectedIndex;
  const HomeScreenCarouselSlider({super.key, required this.selectedIndex});

  @override
  State<HomeScreenCarouselSlider> createState() => _HomeScreenCarouselSliderState();
}

class _HomeScreenCarouselSliderState extends State<HomeScreenCarouselSlider> {
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
    return CarouselSlider.builder(
      options: CarouselOptions(
        disableCenter: true,
        viewportFraction: 0.6,
        enlargeCenterPage: true,
        autoPlay: true,
      ),
      itemBuilder:
          (BuildContext context, int index, pageViewIndex) {
        if (!popularevents.isEmpty) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EventTicket(
                        event: popularevents[index],
                      )));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                fadeOutDuration:
                const Duration(milliseconds: 300),
                fadeOutCurve: Curves.easeOut,
                fadeInDuration:
                const Duration(milliseconds: 700),
                fadeInCurve: Curves.easeIn,
                imageUrl: popularevents[index]
                    .popularImage!
                    .trim() ==
                    'https://admin.ticketmaster-et.com/public/storage' ||
                    popularevents[index]
                        .popularImage!
                        .trim() ==
                        'https://admin.ticketmaster-et.com/public/storage/%5Bvalue-2%5D' ||
                    popularevents[index]
                        .popularImage!
                        .trim() ==
                        'https://admin.ticketmaster-et.com/public/storage/aaa' ||
                    popularevents[index]
                        .popularImage!
                        .trim() ==
                        'https://admin.ticketmaster-et.com/public/storage/' ||
                    popularevents[index]
                        .popularImage!
                        .trim() ==
                        'https://admin.ticketmaster-et.com/public/storage/[value-2]'
                    ? 'https://i.postimg.cc/VkBQ3FS6/na-logo.png'
                    : popularevents[index]
                    .popularImage!
                    .trim(),
                imageBuilder: (context, imageProvider) =>
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                // placeholder: (context, url) =>
                //     discoverImageShimmer(isDark),
                // errorWidget: (context, url, error) => Image.asset(
                //   'assets/images/na_logo.png',
                //   fit: BoxFit.cover,
                // ),
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
      popularevents.isEmpty ? 4 : popularevents.length,
    );
  }
}
