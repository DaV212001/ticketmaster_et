import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ticketmaster_et/screens/search_view.dart';
import 'package:ticketmaster_et/screens/subcategorydetails.dart';

import '../constants/app_constants.dart';
import '../functions/functions.dart';
import '../models/event_model.dart';
import '../provider/settings_provider.dart';
import 'event_detail.dart';
import 'package:ticketmaster_et/models/newmodels.dart';

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












class CategoryChild extends StatefulWidget {
  const CategoryChild({required this.subCategories,super.key});
final List<SubCategory> subCategories;

  @override
  State<CategoryChild> createState() => _CategoryChildState();
}

class _CategoryChildState extends State<CategoryChild> {
  @override
  Widget build(BuildContext context) {
    if(widget.subCategories.isNotEmpty){
      return Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: SizedBox(
          height: 200,
          child: CarouselSlider.builder(
            options: CarouselOptions(
              disableCenter: true,
              viewportFraction: 0.8,
              enlargeCenterPage: true,
              autoPlay: true,
            ),
            itemBuilder:
                (BuildContext context, int index, pageViewIndex) =>
                GestureDetector(
                  onTap:
                      () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return SubCatDetail(subCategory: widget.subCategories[index],);
                            }));
                      },
                  child:
                  ClipRRect(
                    borderRadius:
                    BorderRadius.circular(8.0),
                    child:
                    CachedNetworkImage(
                      height:
                      100,
                      fadeOutDuration:
                      const Duration(milliseconds:
                      300),
                      fadeOutCurve:
                      Curves.easeOut,
                      fadeInDuration:
                      const Duration(milliseconds:
                      700),
                      fadeInCurve:
                      Curves.easeIn,
                      imageUrl:
                      widget.subCategories[index].image!.trim() == 'https://admin.ticketmaster-et.com/public/storage' || widget.subCategories[index].image!.trim() == 'https://admin.ticketmaster-et.com/public/storage/%5Bvalue-2%5D' || widget.subCategories[index].image!.trim() == 'https://admin.ticketmaster-et.com/public/storage/aaa'||widget.subCategories[index].image!.trim() == 'https://admin.ticketmaster-et.com/public/storage/'||widget.subCategories[index].image!.trim() == 'https://admin.ticketmaster-et.com/public/storage/[value-2]'? 'https://i.postimg.cc/VkBQ3FS6/na-logo.png':widget.subCategories[index].image!.trim(),
                    imageBuilder:
                          (context, imageProvider) =>
                          Container(
                            decoration:
                            BoxDecoration(
                              image:
                              DecorationImage(
                                image:
                                imageProvider,
                                fit:
                                BoxFit.cover,
                              ),
                            ),
                          ),
                    ),
                  ),
                ),
            itemCount:
            widget.subCategories.length,
          ),
        ),
      );
    }
    else{
      return Center(
        child: Container(
          height: 200,
          width: 200,
          child: Image.network(
              'https://i.postimg.cc/VkBQ3FS6/na-logo.png'
          ),
        )
      );
    }
  }
}

class CategoryChildList extends StatefulWidget {
  const CategoryChildList({required this.subCategories, super.key});
  final List<SubCategory> subCategories;
  @override
  State<CategoryChildList> createState() => _CategoryChildListState();
}

class _CategoryChildListState extends State<CategoryChildList> {
  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    if(widget.subCategories.isNotEmpty){
      return ListView.builder(
          controller: scrollController,
          physics: BouncingScrollPhysics(),
          itemCount: widget.subCategories.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                      return SubCatDetail(subCategory: widget.subCategories[index],);
                    }));
              },
              child: Container(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    bottom: 3.0,
                    left: 10,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: SizedBox(
                              width: 70,
                              height: 70,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child:
                                CachedNetworkImage(
                                  fadeOutDuration:
                                  const Duration(milliseconds:
                                  300),
                                  fadeOutCurve:
                                  Curves.easeOut,
                                  fadeInDuration:
                                  const Duration(milliseconds:
                                  700),
                                  fadeInCurve:
                                  Curves.easeIn,
                                  imageUrl:
                                  widget.subCategories[index].image!.trim() == 'https://admin.ticketmaster-et.com/public/storage' || widget.subCategories[index].image!.trim() == 'https://admin.ticketmaster-et.com/public/storage/%5Bvalue-2%5D' || widget.subCategories[index].image!.trim() == 'https://admin.ticketmaster-et.com/public/storage/aaa'||widget.subCategories[index].image!.trim() == 'https://admin.ticketmaster-et.com/public/storage/'||widget.subCategories[index].image!.trim() == 'https://admin.ticketmaster-et.com/public/storage/[value-2]'? 'https://i.postimg.cc/VkBQ3FS6/na-logo.png':widget.subCategories[index].image!.trim(),
                                  imageBuilder:
                                      (context, imageProvider) =>
                                      Container(
                                        decoration:
                                        BoxDecoration(
                                          image:
                                          DecorationImage(
                                            image:
                                            imageProvider,
                                            fit:
                                            BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.subCategories[index].name!,
                                  style: const TextStyle(
                                      fontFamily: 'PoppinsSB',
                                      fontSize: 15,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const Divider(
                        color: Colors.white54,
                        thickness: 1,
                        endIndent: 20,
                        indent: 10,
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
    }
    else {
      return Center(
          child: Container(
            height: 200,
            width: 200,
            child: Image.network(
                'https://i.postimg.cc/VkBQ3FS6/na-logo.png'
            ),
          )
      );
    }
  }
}
