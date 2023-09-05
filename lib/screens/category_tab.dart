import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:ticketmaster_et/screens/search_view.dart';

import '../models/event_model.dart';
import 'event_detail.dart';

class CategoryTab extends StatefulWidget {
  const CategoryTab({super.key});

  @override
  State<CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<CategoryTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 6, vsync: this);
    super.initState();
  }

  List<Tab> cat = [
    const Tab(text: 'Sport', icon: Icon(Icons.sports_soccer)),
    const Tab(text: 'Concert', icon: Icon(Icons.wine_bar)),
    const Tab(text: 'Expo', icon: Icon(Icons.star)),
    const Tab(text: 'Travel', icon: Icon(Icons.airplane_ticket)),
    const Tab(text: 'Dance', icon: Icon(Icons.dynamic_feed)),
    const Tab(text: 'Family', icon: Icon(Icons.family_restroom))
  ];

  @override
  Widget build(BuildContext context) {
    List<Widget> six = [];
    for (int i = 0; i < 6; i++) {
      six.add(Column(children: [
        ElevatedButton(
            onPressed: () {
              showSearch(context: context, delegate: Search());
            },
            child: const Row(
              children: [
                Icon(Icons.search),
                Text('Search for an event'),
              ],
            )),
        const CategoryChild(),
        const SizedBox(
          height: 15,
        ),
        const Expanded(child: CategoryChildList())
      ]));
    }
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          // give the tab bar a height [can change hheight to preferred height]
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
                // give the indicator a decoration (color and border radius)
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
          // tab bar view here
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: six,
            ),
          ),
        ]));
  }
}

class CategoryChild extends StatefulWidget {
  const CategoryChild({super.key});

  @override
  State<CategoryChild> createState() => _CategoryChildState();
}

class _CategoryChildState extends State<CategoryChild> {
  List<EventModel> events = [
    EventModel(
        id: '001',
        title: 'Rophnan Concert',
        image:
            'https://pbs.twimg.com/media/Fk8WbnRWAAI8tpB?format=jpg&name=large',
        date: 'September 10',
        location: 'Skylight Hotel',
        description:
            'Have an awesome new year eve with Rophnan at skylight hotel!'),
    EventModel(
        id: '001',
        title: 'Wazema Concert',
        image:
            'https://www.ethiobeauty.com/uploads/images/full/Ethio_Beauty_2OGKpVZnNXG84SJDqHZYsPrYQD0wiBAEtK1GBhTx8ZZslAckUhhsbZWgDIEuR+Mpcwi8zQ0G+AkhVkdKOCFDdQ.jpg',
        date: 'September 9',
        location: 'Meskel Square',
        description:
            'A group of 7 musicians are here to entertain you through 2016!'),
    EventModel(
        id: '001',
        title: 'Tesfa Concert',
        image:
            'https://scontent.fadd2-1.fna.fbcdn.net/v/t39.30808-6/305221134_148730804509859_3798409275105151661_n.jpg?_nc_cat=104&ccb=1-7&_nc_sid=cd49ab&_nc_ohc=YgKVGiUwmpkAX8p3zoI&_nc_ht=scontent.fadd2-1.fna&oh=00_AfDsydncdSMw0Ge9u70OGb3Jv4MrTJ7dDXxf8fUyIlntjw&oe=64FAE941',
        date: 'September 11',
        location: 'Millenium Hall',
        description:
            'We are bringing to you the best line up for your NYE celebration!'),
  ];

  @override
  Widget build(BuildContext context) {
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
          itemBuilder: (BuildContext context, int index, pageViewIndex) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EventDetail()));
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  height: 100,
                  fadeOutDuration: const Duration(milliseconds: 300),
                  fadeOutCurve: Curves.easeOut,
                  fadeInDuration: const Duration(milliseconds: 700),
                  fadeInCurve: Curves.easeIn,
                  imageUrl: events[index].image,
                  imageBuilder: (context, imageProvider) => Container(
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
          },
          itemCount: events.length,
        ),
      ),
    );
  }
}

class CategoryChildList extends StatefulWidget {
  const CategoryChildList({super.key});

  @override
  State<CategoryChildList> createState() => _CategoryChildListState();
}

class _CategoryChildListState extends State<CategoryChildList> {
  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    List<EventModel> events = [
      EventModel(
          id: 'id',
          title: 'Teddy Afro concert',
          image:
              'https://littleethiopia.files.wordpress.com/2013/07/tteedd.jpg',
          date: '09/02/2023',
          location: 'Addis Ababa',
          description: 'description'),
      EventModel(
          id: 'id',
          title: 'Rophnan concert',
          image:
              'https://www.akwaabamusic.com/wp-content/uploads/2018/09/WhatsApp-Image-2018-09-20-at-4.21.12-PM.jpeg',
          date: '09/02/2023',
          location: 'Addis Ababa',
          description: 'description'),
      EventModel(
          id: 'id',
          title: 'Dawit tsige concert',
          image: 'https://i.ytimg.com/vi/ebdmbdgVbNI/maxresdefault.jpg',
          date: '09/02/2023',
          location: 'Addis Ababa',
          description: 'description'),
      EventModel(
          id: 'id',
          title: 'Aster Aweke concert',
          image:
              'https://i.pinimg.com/736x/20/8b/98/208b98f613eec4a2da08dec552ab4c1a.jpg',
          date: '09/02/2023',
          location: 'Addis Ababa',
          description: 'description'),
    ];

    return ListView.builder(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        itemCount: events.length,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const EventDetail();
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
                            width: 130,
                            height: 130,
                            child: Hero(
                              tag: '${events[index].id}',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: events![index].image == null
                                    ? Image.asset(
                                        'assets/images/na_logo.png',
                                        fit: BoxFit.cover,
                                      )
                                    : CachedNetworkImage(
                                        //  cacheManager: cacheProp(),
                                        fadeOutDuration:
                                            const Duration(milliseconds: 300),
                                        fadeOutCurve: Curves.easeOut,
                                        fadeInDuration:
                                            const Duration(milliseconds: 700),
                                        fadeInCurve: Curves.easeIn,
                                        imageUrl: events![index].image!,
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        // placeholder: (context, url) =>
                                        //     mainPageVerticalScrollImageShimmer(
                                        //         isDark),
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                          'assets/images/na_logo.png',
                                          fit: BoxFit.cover,
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
                                events![index].title!,
                                style: const TextStyle(
                                    fontFamily: 'PoppinsSB',
                                    fontSize: 15,
                                    overflow: TextOverflow.ellipsis),
                              ),
                              Row(
                                children: <Widget>[
                                  const Icon(
                                    Icons.calendar_month,
                                  ),
                                  Text(
                                    events![index].date,
                                    style:
                                        const TextStyle(fontFamily: 'Poppins'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const Divider(
                      //  color: !isDark ? Colors.black54 : Colors.white54,
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
}
