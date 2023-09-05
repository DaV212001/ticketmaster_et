import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ticketmaster_et/models/event_providers.dart';
import 'package:ticketmaster_et/screens/category_events.dart';
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

class UpcomingTabWidget extends StatefulWidget {
  const UpcomingTabWidget(
      {super.key,
      required this.modified,
      required this.controller,
      required this.isZoomed,
      required this.toggleZoom});

  final List<EventModel> modified;
  final Controller controller;
  final bool isZoomed;
  final VoidCallback toggleZoom;

  @override
  State<UpcomingTabWidget> createState() => _UpcomingTabWidgetState();
}

class _UpcomingTabWidgetState extends State<UpcomingTabWidget> {
  @override
  Widget build(BuildContext context) {
    return TikTokStyleFullPageScroller(
      contentSize: widget.modified.length,
      swipePositionThreshold: 0.2,
      swipeVelocityThreshold: 2000,
      animationDuration: const Duration(milliseconds: 400),
      controller: widget.controller,
      builder: (BuildContext context, int index) {
        return Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Center(
              child: AnimatedContainer(
                //alignment: Alignment.center,
                transformAlignment: Alignment.topCenter,
                duration:
                    const Duration(seconds: 2), // Change the duration here
                curve: Curves.easeInOut,
                transform: Matrix4.identity()
                  ..scale(widget.isZoomed ? 1.1 : 1.0),
                child: Container(
                  // color: events[index],
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(widget.modified[index].image))),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.modified[index].description,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.modified[index].location,
                          style: const TextStyle(fontSize: 15),
                        ),
                        Text(
                          widget.modified[index].date,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: ((context) {
                          return const EventDetail();
                        })));
                      },
                      child: const Text('BUY TICKETS'),
                      style: ButtonStyle(
                          side: MaterialStatePropertyAll(BorderSide(
                              style: BorderStyle.solid,
                              color: Theme.of(context).primaryColor)),
                          shadowColor: const MaterialStatePropertyAll(
                              Colors.transparent),
                          backgroundColor: const MaterialStatePropertyAll(
                              Colors.transparent))),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class HomeTabWidget extends StatelessWidget {
  const HomeTabWidget({
    super.key,
    required this.events,
  });

  final List<EventModel> events;

  @override
  Widget build(BuildContext context) {
    List<SportActivity> sportActivities = [
      SportActivity(
          name: 'Football',
          image:
              'https://images.pexels.com/photos/140039/pexels-photo-140039.jpeg?auto=compress&cs=tinysrgb&w=600'),
      SportActivity(
          name: 'Basketball',
          image:
              'https://images.pexels.com/photos/1080884/pexels-photo-1080884.jpeg?auto=compress&cs=tinysrgb&w=600'),
      SportActivity(
          name: 'Soccer',
          image:
              'https://images.pexels.com/photos/1198172/pexels-photo-1198172.jpeg?auto=compress&cs=tinysrgb&w=600'),
      SportActivity(
          name: 'Tennis',
          image:
              'https://images.pexels.com/photos/1103833/pexels-photo-1103833.jpeg?auto=compress&cs=tinysrgb&w=600'),
      // Add more activities here
    ];

    List<ConcertActivity> concertActivity = [
      ConcertActivity(
          name: 'Ethiopian music',
          image:
              'https://littleethiopia.files.wordpress.com/2013/07/tteedd.jpg'),
      ConcertActivity(
          name: 'African music',
          image:
              'https://www.musicinafrica.net/sites/default/files/images/article/201905/winyo.jpg'),
      ConcertActivity(
          name: 'Spiritual',
          image:
              'https://images.pexels.com/photos/10024790/pexels-photo-10024790.jpeg?auto=compress&cs=tinysrgb&w=400'),
    ];

    List<OutdoorActivity> outdoorActivities = [
      OutdoorActivity(
          name: 'Hiking',
          image:
              'https://images.pexels.com/photos/2480554/pexels-photo-2480554.jpeg?auto=compress&cs=tinysrgb&w=400'),
      OutdoorActivity(
          name: 'Group travel',
          image:
              'https://images.pexels.com/photos/1274592/pexels-photo-1274592.jpeg?auto=compress&cs=tinysrgb&w=400')
    ];

    final List<CategoryModel> cat = [
      CategoryModel(
          imagePath:
              'https://images.pexels.com/photos/13387388/pexels-photo-13387388.jpeg?auto=compress&cs=tinysrgb&w=600',
          name: 'Sport'),
      CategoryModel(
          imagePath:
              'https://images.pexels.com/photos/625644/pexels-photo-625644.jpeg?auto=compress&cs=tinysrgb&w=400',
          name: 'Concert'),
      CategoryModel(
          imagePath:
              'https://media.istockphoto.com/id/1058909060/photo/blurred-business-people.jpg?b=1&s=612x612&w=0&k=20&c=NVG9BIprpucdnw1E3oRWHkGPw5a0hH_2Q6hW779BF6s=',
          name: 'Expo'),
      CategoryModel(
          imagePath:
              'https://images.pexels.com/photos/17636489/pexels-photo-17636489/free-photo-of-man-in-hat-and-with-backpack-standing-with-hills-behind.jpeg?auto=compress&cs=tinysrgb&w=400',
          name: 'Travel'),
      CategoryModel(
          imagePath:
              'https://images.pexels.com/photos/4046265/pexels-photo-4046265.jpeg?auto=compress&cs=tinysrgb&w=400',
          name: 'Dance'),
      CategoryModel(
          imagePath:
              'https://images.pexels.com/photos/4262173/pexels-photo-4262173.jpeg?auto=compress&cs=tinysrgb&w=400',
          name: 'Family'),
    ];

    List<EventProviders> ep = [
      EventProviders(
          imagePath:
              'https://scontent-lhr8-1.xx.fbcdn.net/v/t39.30808-1/327198307_549535743782007_5008466511557648326_n.jpg?stp=c22.0.275.275a_dst-jpg&_nc_cat=106&ccb=1-7&_nc_sid=754033&_nc_ohc=HaclEAV3F6IAX9P2rfN&_nc_ht=scontent-lhr8-1.xx&oh=00_AfCiFmDKCWv8IMS9u3-Y4uNffamkwyr1jMQVEw1VMahazg&oe=64FBF726',
          name: 'Adika'),
      EventProviders(
          imagePath:
              'https://www.sortlist.com/_next/image?url=https%3A%2F%2Fsortlist.gumlet.io%2Fsortlist-core-api%2Fxmsxdysf7w55mvylydzuq9xwtkcz%3Fw%3D150%26q%3D95%26format%3Dauto&w=96&q=75',
          name: 'Bloom Event Organizer'),
      EventProviders(
          imagePath:
              'https://www.sortlist.com/_next/image?url=https%3A%2F%2Fsortlist.gumlet.io%2Fsortlist-core-api%2Fxx6ydti8cosjmmw7kihejo9dq3lb%3Fw%3D150%26q%3D95%26format%3Dauto&w=96&q=75',
          name: 'Parna Events')
    ];
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Sports', // Category name
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height:
                      200, // Adjust the height of the horizontal scrollable list view
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: sportActivities.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const CategoryEvents();
                                }));
                              },
                              child: CachedNetworkImage(
                                fadeOutDuration:
                                    const Duration(milliseconds: 300),
                                fadeOutCurve: Curves.easeOut,
                                fadeInDuration:
                                    const Duration(milliseconds: 700),
                                fadeInCurve: Curves.easeIn,
                                imageUrl: events[index].image,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  width: 150, // Size of the square image
                                  height: 150,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                            sportActivities[index].image,
                                          ))),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(sportActivities[index].name),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Concert',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height:
                      200, // Adjust the height of the horizontal scrollable list view
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: concertActivity.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const CategoryEvents();
                                }));
                              },
                              child: CachedNetworkImage(
                                fadeOutDuration:
                                    const Duration(milliseconds: 300),
                                fadeOutCurve: Curves.easeOut,
                                fadeInDuration:
                                    const Duration(milliseconds: 700),
                                fadeInCurve: Curves.easeIn,
                                imageUrl: concertActivity[index].image,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  width: 150, // Size of the square image
                                  height: 150,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                            concertActivity[index].image,
                                          ))),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(concertActivity[index].name),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Travel', // Category name
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height:
                      200, // Adjust the height of the horizontal scrollable list view
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: outdoorActivities.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const CategoryEvents();
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
                                          outdoorActivities[index].image,
                                        ))),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(outdoorActivities[index].name),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Concert',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height:
                      200, // Adjust the height of the horizontal scrollable list view
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: concertActivity.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const CategoryEvents();
                                }));
                              },
                              child: CachedNetworkImage(
                                fadeOutDuration:
                                    const Duration(milliseconds: 300),
                                fadeOutCurve: Curves.easeOut,
                                fadeInDuration:
                                    const Duration(milliseconds: 700),
                                fadeInCurve: Curves.easeIn,
                                imageUrl: concertActivity[index].image,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  width: 150, // Size of the square image
                                  height: 150,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                            concertActivity[index].image,
                                          ))),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(concertActivity[index].name),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Event Providers', // Category name
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
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const CategoryEvents();
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
                                          ep[index].imagePath!,
                                        ))),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(ep[index].name!),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
