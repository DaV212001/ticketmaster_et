import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ticketmaster_et/models/newmodels.dart';

import '../../../../constants/app_constants.dart';
import '../../../../functions/functions.dart';
import '../../../../provider/settings_provider.dart';
import '../../../category/section/subcategorydetails.dart';

class HomeScreenCategories extends StatefulWidget {
  final ValueNotifier<int> selectedIndex;
  const HomeScreenCategories({super.key, required this.selectedIndex});

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
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        // print("WIDGET BUILT");

        // Insert AdsCarousel in the middle
        // if (index == categories.length ~/ 2) {
        //   return const Padding(
        //     padding: EdgeInsets.symmetric(vertical: 16.0),
        //     child: AdsCarousel(), // Ensure this widget is imported
        //   );
        // }
        //
        // // Adjust index for categories
        final categoryIndex = index;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isLoading
                ? const CircularProgressIndicator()
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      categories[categoryIndex].name!,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
            if (categories[categoryIndex].subCategory!.isEmpty)
              Center(
                  child: Column(
                children: [
                  Image.asset(
                    'assets/images/THICKET_MASTER_LOGO.png',
                    height: MediaQuery.of(context).size.height * 0.1,
                    width: MediaQuery.of(context).size.width * 0.2,
                  ),
                  Text('no_food'.tr())
                ],
              ))
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories[categoryIndex].subCategory!.length,
                  itemBuilder: (context, subIndex) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return SubCatDetail(
                                  id: categories[categoryIndex]
                                      .subCategory![subIndex]
                                      .id!,
                                );
                              }));
                            },
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(15),
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                        categories[categoryIndex]
                                            .subCategory![subIndex]
                                            .image!
                                            .trim(),
                                      ))),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(categories[categoryIndex]
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
