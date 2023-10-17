
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
import '../../../event_detail.dart';
import '../../../organizerdetail.dart';
import '../../../category/section/subcategorydetails.dart';
class HomeScreenCategories extends StatefulWidget {
  const HomeScreenCategories({super.key});

  @override
  State<HomeScreenCategories> createState() => _HomeScreenCategoriesState();
}

class _HomeScreenCategoriesState extends State<HomeScreenCategories> {
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
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        print("WIDGET BUILT");


        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isLoading
                ?
            CircularProgressIndicator()
                :
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                categories[index].name!, // Category name
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 200,
              // Adjust the height of the horizontal scrollable list view
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories[index].subCategory!.length,
                itemBuilder: (context, subIndex) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (context) {
                                      return SubCatDetail(
                                          subCategory: categories[index]
                                              .subCategory![subIndex]
                                      );
                                    }));
                          },
                          child: Container(
                            width: 150, // Size of the square image
                            height: 150,
                            decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                      categories[index]
                                          .subCategory![subIndex]
                                          .image!
                                          .trim(),
                                    ))),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(categories[index]
                            .subCategory![subIndex]
                            .name!),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
