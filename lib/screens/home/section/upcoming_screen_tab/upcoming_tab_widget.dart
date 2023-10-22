import 'dart:io';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ticketmaster_et/screens/event_ticket.dart';
import 'package:ticketmaster_et/screens/organizerdetail.dart';
import 'package:tiktoklikescroller/tiktoklikescroller.dart';
import 'package:video_player/video_player.dart';

import '../../../../models/newmodels.dart';
class UpcomingTabWidget extends StatefulWidget {
  const UpcomingTabWidget(
      {super.key,
        required this.modified,
        required this.controller,
        required this.isZoomed,
        required this.toggleZoom,
        required this.selectedIndex, required this.modifiedOrg

      });

  final List<Event> modified;
  final Controller controller;
  final bool isZoomed;
  final VoidCallback toggleZoom;
  final ValueNotifier<int> selectedIndex;
  final List<Organizer> modifiedOrg;

  @override
  State<UpcomingTabWidget> createState() => _UpcomingTabWidgetState();
}

class _UpcomingTabWidgetState extends State<UpcomingTabWidget> {
  late List<VideoPlayerController?> _controllers = [];
  final List<bool> _isPlaying = [];
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.modified.length; i++) {
      if (widget.modified[i].upcomingImage!.endsWith('.mp4')) {
        _controllers.add(VideoPlayerController.networkUrl(
          Uri.parse(widget.modified[i].upcomingImage!),
        ));
        _isPlaying.add(false);
      } else {
        _controllers.add(null);
        _isPlaying.add(false);
      }
    }
    _pageController.addListener(_onScroll);
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller?.dispose();
    }
    _controllers = [];
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

  void _onScroll() {
    final pageIndex = (_pageController.page ?? 0).round();
    _pauseAllVideos();
    if (_controllers[pageIndex] != null) {
      _controllers[pageIndex]?.play();
      _isPlaying[pageIndex] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: widget.modified.length,
        controller: _pageController,
        itemBuilder: (BuildContext context, int iindex) {
          Organizer? organizer;


if(widget.modified.isNotEmpty && widget.modifiedOrg.isNotEmpty){
  for(Organizer org in widget.modifiedOrg){

    if(org.id == int.parse(widget.modified[iindex].organizerId!) ){


  organizer = org;



      break;
    }
  }
}
          final isPlaying = ValueNotifier<bool>(true);
          if (_controllers[iindex] != null) {
            return Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayerWidget(
                    selectedIndex: widget.selectedIndex,
                    videoUrl: widget.modified[iindex].upcomingImage!,
                ),
                Positioned(
                    right: 8,
                    child: Column(
                  children: [
                    if(widget.modifiedOrg.isNotEmpty) Padding(
                      padding: const EdgeInsets.only(right: 8.0, top: 30),
                      child: GestureDetector(

                        onTap: (){
                          isPlaying.value=false;
                          Navigator.push(context,
                              MaterialPageRoute(builder: ((context) {
                                return OrganizerDetail(
                                  organizer: organizer!, selectedIndex: widget.selectedIndex,
                                );
                              })));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green, width: 2),
                              borderRadius: BorderRadius.circular(50)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(
                              organizer?.image??'https://i.postimg.cc/VkBQ3FS6/na-logo.png',
                              width: 65,
                              height: 65,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ),
                Positioned(
                  bottom: 0.5,
                  child: Stack(
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
                            SizedBox(width: MediaQuery.of(context).size.width*0.16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(onPressed: (){
                                 },
                                    icon: Icon(Icons.share,size: 40,)),
                                SizedBox(height: 25,),
                                ElevatedButton(
                                    onPressed: () async {
                                      isPlaying.value = false;
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: ((context) {
                                            return EventTicket(
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
                          ],
                        ),
                      ),
                    ],
                  ),
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
                                isPlaying.value = false;
                                Navigator.push(context,
                                    MaterialPageRoute(builder: ((context) {
                                      return EventTicket(
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
      ),
    );
  }
}