import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ticketmaster_et/models/event_model.dart';

import 'event_detail.dart';

class UserTickets extends StatefulWidget {
  const UserTickets({super.key});

  @override
  State<UserTickets> createState() => _UserTicketsState();
}

class _UserTicketsState extends State<UserTickets> {
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

    return Scaffold(
        body: ListView.builder(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            itemCount: events.length,
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
                                            fadeOutDuration: const Duration(
                                                milliseconds: 300),
                                            fadeOutCurve: Curves.easeOut,
                                            fadeInDuration: const Duration(
                                                milliseconds: 700),
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
                                            errorWidget:
                                                (context, url, error) =>
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
                                        style: const TextStyle(
                                            fontFamily: 'Poppins'),
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
            }));
  }
}
