import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ticketmaster_et/constants/app_constants.dart';
import 'package:ticketmaster_et/models/event_providers.dart';
import 'package:ticketmaster_et/provider/settings_provider.dart';
import 'package:ticketmaster_et/screens/category_events.dart';
import 'package:ticketmaster_et/screens/event_detail.dart';
import 'package:ticketmaster_et/screens/organizerdetail.dart';
import 'package:ticketmaster_et/screens/subcategorydetails.dart';
import 'package:tiktoklikescroller/tiktoklikescroller.dart';
import 'package:video_player/video_player.dart';
import 'functions/functions.dart';
import 'models/category_model.dart';
import 'models/event_model.dart';
import 'models/newmodels.dart';

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

  final List<Event> modified;
  final Controller controller;
  final bool isZoomed;
  final VoidCallback toggleZoom;

  @override
  State<UpcomingTabWidget> createState() => _UpcomingTabWidgetState();
}

class _UpcomingTabWidgetState extends State<UpcomingTabWidget> {
  final List<VideoPlayerController?> _controllers = [];
  final List<bool> _isPlaying = [];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.modified.length; i++) {
      if (widget.modified[i].upcomingImage!.endsWith('.mp4')) {
        _controllers.add(VideoPlayerController.networkUrl(
          Uri.parse(widget.modified[i].upcomingImage!),
        )..initialize());
        _isPlaying.add(false);
      } else {
        _controllers.add(null);
        _isPlaying.add(false);
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  void _pauseAllVideos() {
    for (var i = 0; i < _controllers.length; i++) {
      if (_isPlaying[i]) {
        _controllers[i]?.pause();
        _isPlaying[i] = false;
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    int currentIndex = 0;
    return TikTokStyleFullPageScroller(
      contentSize: widget.modified.length,
      swipePositionThreshold: 0.2,
      swipeVelocityThreshold: 2000,
      animationDuration: const Duration(milliseconds: 400),
      controller: widget.controller,
      builder: (BuildContext context, int iindex) {

        if (_controllers[iindex] != null) {
          return Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: _controllers[iindex]!.value.aspectRatio,
                child: VideoPlayerWidget(controller: _controllers[iindex]!, videoUrl: widget.modified[iindex].image!,),
              ),
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    if (_isPlaying[iindex]) {
                      _controllers[iindex]?.pause();
                      _isPlaying[iindex] = false;
                    } else {
                      _pauseAllVideos();
                      _controllers[iindex]?.play();
                      _isPlaying[iindex] = true;
                    }
                  });
                },
                child: Icon(_isPlaying[iindex] ? Icons.pause : Icons.play_arrow),
              ),
              Stack(
                children: [
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.0, 0.2],
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7)
                              ])
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.transparent,
                    height: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                    itemCount: 3,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Text(
                                            widget.modified[iindex].desc!,
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          Text(
                                            widget.modified[iindex].place!,
                                            style: TextStyle(
                                                fontSize: 15, color: Colors.white),
                                          ),
                                          Text(
                                            widget.modified[iindex].date!,
                                            style: TextStyle(
                                                fontSize: 15, color: Colors.white),
                                          ),
                                        ],
                                      );
                                    }),
                              )

                            ],
                          ),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: ((context) {
                                    return EventDetail(
                                      event: widget.modified[iindex],
                                    );
                                  })));
                            },
                            style: ButtonStyle(
                                side: MaterialStatePropertyAll(BorderSide(
                                    style: BorderStyle.solid,
                                    color: Theme
                                        .of(context)
                                        .primaryColor)),
                                shadowColor: MaterialStatePropertyAll(
                                    Colors.white.withOpacity(0.5)),
                                backgroundColor: const MaterialStatePropertyAll(
                                    Colors.transparent)),
                            child: Text(tr('buy_tickets'))),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        }else {
          return Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Center(
                child: AnimatedContainer(
                  //alignment: Alignment.center,
                  transformAlignment: Alignment.topCenter,
                  duration:
                  const Duration(seconds: 2),
                  // Change the duration here
                  curve: Curves.easeInOut,
                  transform: Matrix4.identity()
                    ..scale(widget.isZoomed ? 1.1 : 1.0),
                  child: Container(
                    // color: events[index],
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(widget
                                .modified[iindex].upcomingImage !=
                                null
                                ? widget.modified[iindex].upcomingImage!.trim() ==
                                'https://admin.ticketmaster-et.com/public/storage' ||
                                widget.modified[iindex].upcomingImage!
                                    .trim() ==
                                    'https://admin.ticketmaster-et.com/public/storage/%5Bvalue-2%5D' ||
                                widget.modified[iindex].upcomingImage!
                                    .trim() ==
                                    'https://admin.ticketmaster-et.com/public/storage/aaa' ||
                                widget.modified[iindex].upcomingImage!
                                    .trim() ==
                                    'https://admin.ticketmaster-et.com/public/storage/' ||
                                widget.modified[iindex].upcomingImage!
                                    .trim() ==
                                    'https://admin.ticketmaster-et.com/public/storage/[value-2]'
                                ? 'https://i.postimg.cc/VkBQ3FS6/na-logo.png'
                                : widget.modified[iindex].image!.trim()
                                : 'https://i.postimg.cc/VkBQ3FS6/na-logo.png'))),
                  ),
                ),
              ),
              Stack(
                children: [
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.0, 0.2],
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7)
                              ])
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.transparent,
                    height: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                    itemCount: 3,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Text(
                                            widget.modified[iindex].desc!,
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          Text(
                                            widget.modified[iindex].place!,
                                            style: TextStyle(
                                                fontSize: 15, color: Colors.white),
                                          ),
                                          Text(
                                            widget.modified[iindex].date!,
                                            style: TextStyle(
                                                fontSize: 15, color: Colors.white),
                                          ),
                                        ],
                                      );
                                    }),
                              )

                            ],
                          ),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: ((context) {
                                    return EventDetail(
                                      event: widget.modified[iindex],
                                    );
                                  })));
                            },
                            style: ButtonStyle(
                                side: MaterialStatePropertyAll(BorderSide(
                                    style: BorderStyle.solid,
                                    color: Theme
                                        .of(context)
                                        .primaryColor)),
                                shadowColor: MaterialStatePropertyAll(
                                    Colors.white.withOpacity(0.5)),
                                backgroundColor: const MaterialStatePropertyAll(
                                    Colors.transparent)),
                            child: Text(tr('buy_tickets'))),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        }



      },
    );
  }
}


class HomeTabWidget extends StatefulWidget {
  const HomeTabWidget({
    super.key,
  });

  @override
  State<HomeTabWidget> createState() => _HomeTabWidgetState();
}

class _HomeTabWidgetState extends State<HomeTabWidget> {
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
      print('VALUE OF THE CATEGORY: $value');
    }));
    getEvents('$apiUrl/event',
        Provider.of<SettingsProvider>(context, listen: false).languageCode)
        .then((value) {
      events = value;
      print('VALUE OF THE EVENTS: $value');
      // Populate popularevents outside setState()
      popularevents.clear(); // Clear the list first
      for (Event eve in events) {
        print('POPULAR IDS: ${eve.isPopular}');
        if (eve.isPopular == '1') {
          popularevents.add(eve);
        }
      }

      // Call setState() only when popularevents changes
      setState(() {
        print(popularevents);
      });
    });
    getOrganizers(
        Provider.of<SettingsProvider>(context, listen: false).languageCode)
        .then((value) => setState(() {
      ep = value;
      print('VALUE OF THE ORGANIZERS: $value');
    }));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // If the data is still loading, show a loading indicator
      return CircularProgressIndicator();
    } else {
      // Once the data has loaded, build your widget as usual
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _isLoading
                  ? CircularProgressIndicator()
                  : SizedBox(
                height: 350,
                child: CarouselSlider.builder(
                  options: CarouselOptions(
                    disableCenter: true,
                    viewportFraction: 0.6,
                    enlargeCenterPage: true,
                    autoPlay: true,
                  ),
                  itemBuilder:
                      (BuildContext context, int index, pageViewIndex) {
                    if (!popularevents.isEmpty) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EventDetail(
                                    event: popularevents[index],
                                  )));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            fadeOutDuration:
                            const Duration(milliseconds: 300),
                            fadeOutCurve: Curves.easeOut,
                            fadeInDuration:
                            const Duration(milliseconds: 700),
                            fadeInCurve: Curves.easeIn,
                            imageUrl: popularevents[index]
                                .popularImage!
                                .trim() ==
                                'https://admin.ticketmaster-et.com/public/storage' ||
                                popularevents[index]
                                    .popularImage!
                                    .trim() ==
                                    'https://admin.ticketmaster-et.com/public/storage/%5Bvalue-2%5D' ||
                                popularevents[index]
                                    .popularImage!
                                    .trim() ==
                                    'https://admin.ticketmaster-et.com/public/storage/aaa' ||
                                popularevents[index]
                                    .popularImage!
                                    .trim() ==
                                    'https://admin.ticketmaster-et.com/public/storage/' ||
                                popularevents[index]
                                    .popularImage!
                                    .trim() ==
                                    'https://admin.ticketmaster-et.com/public/storage/[value-2]'
                                ? 'https://i.postimg.cc/VkBQ3FS6/na-logo.png'
                                : popularevents[index]
                                .popularImage!
                                .trim(),
                            imageBuilder: (context, imageProvider) =>
                                Container(
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
                    } else {
                      return Image.asset(
                        'assets/images/na_logo.jpg',
                        fit: BoxFit.cover,
                      );
                    }
                  },
                  itemCount:
                  popularevents.isEmpty ? 4 : popularevents.length,
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
              categories.length != 0?
              ListView.builder(
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
              ): Center(
                child: Image.network(
                    'https://i.postimg.cc/VkBQ3FS6/na-logo.png'),
              ),
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
                                      return OrganizerDetail(organizer: ep[index]);
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
              ),
            ],
          ),
        ),
      );
    }
  }
}