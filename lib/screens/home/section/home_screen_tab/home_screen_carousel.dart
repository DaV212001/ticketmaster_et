import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ticketmaster_et/models/newmodels.dart';
import 'package:ticketmaster_et/screens/category/section/subcategorydetails.dart';

import '../../../../functions/functions.dart';
import '../../../../provider/settings_provider.dart';

class HomeScreenCarouselSlider extends StatefulWidget {
  final ValueNotifier<int> selectedIndex;
  const HomeScreenCarouselSlider({super.key, required this.selectedIndex});

  @override
  State<HomeScreenCarouselSlider> createState() =>
      _HomeScreenCarouselSliderState();
}

class _HomeScreenCarouselSliderState extends State<HomeScreenCarouselSlider> {
  List<Organizer> ep = [];
  List<Category> categories = [];
  List<PromotionalImages> events = [];
  List<PromotionalImages> popularevents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateCategories();
    });
  }

  late final _settingsProvider;
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
    getPromotionalImages('${baseUrlFunc}promotional-image',
            Provider.of<SettingsProvider>(context, listen: false).languageCode)
        .then((value) {
      events = value;
      //  print('VALUE OF THE EVENTS: $value');
      // Populate popularevents outside setState()
      popularevents.clear(); // Clear the list first
      for (PromotionalImages eve in events) {
        //  print('POPULAR IDS: ${eve.isPopular}');
        popularevents.add(eve);
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
        autoPlay: true,
        aspectRatio: 2.5,
        enlargeCenterPage: true,
      ),
      itemBuilder: (BuildContext context, int index, pageViewIndex) {
        if (popularevents.isNotEmpty) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SubCatDetail(
                            id: popularevents[index].id!,
                          )));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                fadeOutDuration: const Duration(milliseconds: 300),
                fadeOutCurve: Curves.easeOut,
                fadeInDuration: const Duration(milliseconds: 700),
                fadeInCurve: Curves.easeIn,
                imageUrl: popularevents[index].image!.trim(),
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                placeholder: (context, url) => Image.asset(
                  'assets/images/na_logo.jpg',
                  fit: BoxFit.cover,
                ),
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
      itemCount: popularevents.isEmpty ? 4 : popularevents.length,
    );
  }
}
