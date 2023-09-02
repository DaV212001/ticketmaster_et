import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ticketmaster_et/screens/event_detail.dart';
import 'package:tiktoklikescroller/tiktoklikescroller.dart';
import 'models/category_model.dart';
import 'models/event_model.dart';

class CardEventThisMonth extends StatelessWidget {
  final EventModel eventModel;

  const CardEventThisMonth({required this.eventModel, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF603C97),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              eventModel.image,
              fit: BoxFit.cover,
              width: 60,
              height: double.infinity,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eventModel.title,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.location_pin,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    eventModel.location,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
            ],
          ),
          const Spacer(),
          Container(
            height: 50,
            width: 35,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  eventModel.date.split(" ")[0],
                ),
                Text(
                  eventModel.date.split(" ")[1],
                  style: const TextStyle(
                    color: Color(0xFF603C97),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeTabWidget extends StatelessWidget {
  const HomeTabWidget({
    super.key,
    required this.modified,
    required this.controller,
  });

  final List<EventModel> modified;
  final Controller controller;

  @override
  Widget build(BuildContext context) {
    return TikTokStyleFullPageScroller(
      contentSize: modified.length,
      swipePositionThreshold: 0.2,
      swipeVelocityThreshold: 2000,
      animationDuration: const Duration(milliseconds: 400),
      controller: controller,
      builder: (BuildContext context, int index) {
        return Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Container(
              // color: events[index],
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(modified[index].image))),
            ),
            Text(
              '${modified[index].description} $index',
              style: const TextStyle(
                fontSize: 30,
              ),
            ),
          ],
        );
      },
    );
  }
}

class UpcomingTabWidget extends StatelessWidget {
  const UpcomingTabWidget({
    super.key,
    required this.events,
  });

  final List<EventModel> events;

  @override
  Widget build(BuildContext context) {
    final List<CategoryModel> cat = [
      CategoryModel(
          imagePath:
              'https://images.pexels.com/photos/13387388/pexels-photo-13387388.jpeg?auto=compress&cs=tinysrgb&w=600',
          name: 'Sport'),
      CategoryModel(
          imagePath:
              'https://images.pexels.com/photos/13387388/pexels-photo-13387388.jpeg?auto=compress&cs=tinysrgb&w=600',
          name: 'Concert'),
      CategoryModel(
          imagePath:
              'https://images.pexels.com/photos/13387388/pexels-photo-13387388.jpeg?auto=compress&cs=tinysrgb&w=600',
          name: 'Expo'),
      CategoryModel(
          imagePath:
              'https://images.pexels.com/photos/13387388/pexels-photo-13387388.jpeg?auto=compress&cs=tinysrgb&w=600',
          name: 'Travel'),
      CategoryModel(
          imagePath:
              'https://images.pexels.com/photos/13387388/pexels-photo-13387388.jpeg?auto=compress&cs=tinysrgb&w=600',
          name: 'Dance'),
      CategoryModel(
          imagePath:
              'https://images.pexels.com/photos/13387388/pexels-photo-13387388.jpeg?auto=compress&cs=tinysrgb&w=600',
          name: 'Family'),
    ];
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          children: [
            SizedBox(
              height: 350,
              child: CarouselSlider.builder(
                options: CarouselOptions(
                  disableCenter: true,
                  viewportFraction: 0.6,
                  enlargeCenterPage: true,
                  autoPlay: true,
                ),
                itemBuilder: (BuildContext context, int index, pageViewIndex) {
                  return Container(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EventDetail()));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: CachedNetworkImage(
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
                    ),
                  );
                },
                itemCount: events.length,
              ),
            ),
            // Container(
            //   height: 300,
            //   margin: const EdgeInsets.symmetric(horizontal: 24),
            //   child: ListView.builder(
            //     itemCount: events.length,
            //     itemBuilder: ((context, indexx) {
            //       return CardEventThisMonth(eventModel: events[indexx]);
            //     }),
            //   ),
            // ),

            Container(
              padding: EdgeInsets.all(8),
              height: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('category'),
                    style: TextStyle(fontSize: 20),
                  ),
                  Expanded(
                    child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 150,
                          childAspectRatio: 0.48,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                        ),
                        itemCount: cat.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Image.network(cat[index].imagePath!),
                              Expanded(child: Text(cat[index].name!)),
                            ],
                          );
                        }),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
