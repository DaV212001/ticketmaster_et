
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
class HomeScreenOrganizers extends StatefulWidget {
  final ValueNotifier<int> selectedIndex;
  const HomeScreenOrganizers({super.key, required this.selectedIndex});

  @override
  State<HomeScreenOrganizers> createState() => _HomeScreenOrganizersState();
}

class _HomeScreenOrganizersState extends State<HomeScreenOrganizers> {

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            tr('organizers'),
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height:
          200, // Adjust the height of the horizontal scrollable list view
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: ep.length,
              itemBuilder: (context, index) {
                if (ep.length != 0) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                                return OrganizerDetail(organizer: ep[index], selectedIndex: widget.selectedIndex,);
                              }));
                        },
                        child: Container(
                          width: 150, // Size of the square image
                          height: 150,
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    ep[index].image!.trim() ==
                                        'https://admin.ticketmaster-et.com/public/storage/dsvdv'
                                        ? 'https://i.postimg.cc/VkBQ3FS6/na-logo.png'
                                        : ep[index].image!.trim(),
                                  ))),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(ep[index].name!),
                    ]),
                  );
                } else {
                  return Center(
                    child: Image.network(
                        'https://i.postimg.cc/VkBQ3FS6/na-logo.png'),
                  );
                }
              }
          ),
        )
      ],
    );
  }
}
