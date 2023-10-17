import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ticketmaster_et/screens/category/section/category_child_list_screen.dart';
import 'package:ticketmaster_et/screens/category/section/category_child_screen.dart';


import 'package:ticketmaster_et/models/newmodels.dart';

import '../../functions/functions.dart';
import '../../provider/settings_provider.dart';

class CategoryTab extends StatefulWidget {
  const CategoryTab({super.key});

  @override
  State<CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<CategoryTab>
    with TickerProviderStateMixin {
  TabController? _tabController;
  List<Category> categories = [];
  List<SubCategory> subcategories = [];
  Map<int, List<SubCategory>> subcategoriesMap = {};
  // Declare a Future variable to store the result of updateCategories
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {

      updateCategoiesAndSubCategories();
    });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Now it's safe to listen to SettingsProvider
    Provider.of<SettingsProvider>(context).addListener(updateCategoiesAndSubCategories);
  }


  @override
  void dispose() {
    if (mounted) {
      Provider.of<SettingsProvider>(context, listen: false).removeListener(updateCategoiesAndSubCategories);
    }
    _tabController?.dispose();
    super.dispose();
  }


  Future<void> updateCategoiesAndSubCategories() async {
    await getCategorySubCategory(Provider.of<SettingsProvider>(context, listen: false).languageCode)
        .then((value) => setState(() {
      categories = value;
      print('VALUE OF THE CATEGORY for Catpage: $value');
    }));
for(Category cat in categories) {
  await getSubCategoryByCategoryId(cat.id!, Provider
      .of<SettingsProvider>(context, listen: false)
      .languageCode).then((value) =>
      setState(() {
        // Add the subcategories to the map with the category id as the key
        subcategoriesMap[cat.id!] = value;
        print('VALUE OF SUBCATEGORIES of category ${cat.id} FOR CATPAGE: $value');
      })
  );
}
    print(categories);
    print(subcategories);
    _tabController = TabController(length: categories.length, vsync: this);
    setState(() {
      _isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Tab> cat = categories.map((category) => Tab(
      text: category.name,
      icon: Icon(Icons.event),
    )).toList();

    List<Widget> six = [];
    for (int i = 0; i < cat.length; i++) { int categoryId = categories[i].id!; // Get the subcategories from the map using the category id
    List<SubCategory> filteredSubcategories = subcategoriesMap[categoryId] ?? [];
    six.add(
        Column(
            children: [
              CategoryChild(
                  subCategories: filteredSubcategories
              ),
              const SizedBox( height: 15,
              ),
              Expanded(
                  child:
                  CategoryChildList(
                      subCategories: filteredSubcategories))
            ]
        )
    );
    }

    return
      Consumer<SettingsProvider>(
          builder: (context, settingsProvider, child)
          {
            if(_isLoaded) {
              print('CAT PAGE WIDGET BUILT');
              return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: [
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(
                          25.0,
                        ),
                      ),
                      child: TabBar(
                          isScrollable: true,
                          controller: _tabController,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              25.0,
                            ),
                            color: Colors.green,
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.black,
                          tabs: cat.toList()),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: six,
                      ),
                    ),
                  ]));
            }else{
              return Column(
                children: [
              Center (
              child: Image.network('https://i.postimg.cc/VkBQ3FS6/na-logo.png'),
            ),
                  CircularProgressIndicator()
                ],
              );
            }


          });

  }
}