import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ticketmaster_et/components/tiktokicons.dart';
import 'package:ticketmaster_et/functions/functions.dart';
import 'package:ticketmaster_et/screens/event_detail.dart';
import 'package:ticketmaster_et/screens/event_ticket.dart';
import 'package:ticketmaster_et/screens/organizerdetail.dart';
import 'package:tiktoklikescroller/tiktoklikescroller.dart';
import 'package:video_player/video_player.dart';

import '../../../../models/newmodels.dart';
import '../../../../provider/loginpersistence.dart';

class UpcomingTabWidget extends StatefulWidget {
  const UpcomingTabWidget(
      {super.key,
      required this.modified,
      required this.controller,
      required this.isZoomed,
      required this.selectedIndex,
      required this.modifiedOrg});

  final List<Event> modified;
  final Controller controller;
  final bool isZoomed;
  final ValueNotifier<int> selectedIndex;
  final List<Organizer> modifiedOrg;

  @override
  State<UpcomingTabWidget> createState() => _UpcomingTabWidgetState();
}

class _UpcomingTabWidgetState extends State<UpcomingTabWidget> {
  late List<VideoPlayerController?> _controllers = [];
  final List<bool> _isPlaying = [];
  final _pageController = PageController();
  String ds = 'asd';

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

          if (widget.modified.isNotEmpty && widget.modifiedOrg.isNotEmpty) {
            for (Organizer org in widget.modifiedOrg) {
              if (org.id == int.parse(widget.modified[iindex].organizerId!)) {
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
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.modifiedOrg.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                isPlaying.value = false;
                                Navigator.push(context,
                                    MaterialPageRoute(builder: ((context) {
                                  return OrganizerDetail(
                                    organizer: organizer!,
                                    selectedIndex: widget.selectedIndex,
                                  );
                                })));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.green, width: 2),
                                    borderRadius: BorderRadius.circular(50)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.network(
                                    organizer?.image ??
                                        'https://i.postimg.cc/4dyhqLLY/THICKET-MASTER-LOGO.png',
                                    width: 45,
                                    height: 45,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(
                            height: 30,
                          ),
                          InterestButton(event: widget.modified[iindex]),
                          SizedBox(
                            height: 20,
                          ),
                          HeartIconButton(
                            event: widget.modified[iindex],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          CommentIconButton(
                            event: widget.modified[iindex],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          ShareIconButton(
                            videoFile: widget.modified[iindex].upcomingImage!
                                .replaceFirst(
                                    "https://admin.ticketmaster-et.com/public/storage/upcoming",
                                    ''),
                            title: widget.modified[iindex].title ?? '',
                          ),
                        ],
                      ),
                    ),
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
                                  stops: [
                                0.0,
                                0.2
                              ],
                                  colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7)
                              ])),
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
                              width: MediaQuery.of(context).size.width * 0.5,
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                    fontSize: 15,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                widget.modified[iindex].date!,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          );
                                        }),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                    onPressed: () async {
                                      isPlaying.value = false;
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: ((context) {
                                        return EventDetail(
                                          event: widget.modified[iindex],
                                        );
                                      })));
                                    },
                                    style: ButtonStyle(
                                        side: WidgetStatePropertyAll(BorderSide(
                                            style: BorderStyle.solid,
                                            color: Theme.of(context)
                                                .primaryColor)),
                                        shadowColor: WidgetStatePropertyAll(
                                            Colors.white.withOpacity(0.5)),
                                        backgroundColor:
                                            const WidgetStatePropertyAll(
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
          } else {
            return Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Center(
                  child: AnimatedContainer(
                    //alignment: Alignment.center,
                    transformAlignment: Alignment.topCenter,
                    duration: const Duration(seconds: 2),
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
                                  ? widget.modified[iindex].upcomingImage!
                                                  .trim() ==
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
                                      ? 'https://i.postimg.cc/4dyhqLLY/THICKET-MASTER-LOGO.png'
                                      : widget.modified[iindex].image!.trim()
                                  : 'https://i.postimg.cc/4dyhqLLY/THICKET-MASTER-LOGO.png'))),
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
                                stops: [
                              0.0,
                              0.2
                            ],
                                colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7)
                            ])),
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
                            width: MediaQuery.of(context).size.width * 0.5,
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                  fontSize: 15,
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              widget.modified[iindex].date!,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white),
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
                                  return EventDetail(
                                    event: widget.modified[iindex],
                                  );
                                })));
                              },
                              style: ButtonStyle(
                                  side: WidgetStatePropertyAll(BorderSide(
                                      style: BorderStyle.solid,
                                      color: Theme.of(context).primaryColor)),
                                  shadowColor: WidgetStatePropertyAll(
                                      Colors.white.withOpacity(0.5)),
                                  backgroundColor: const WidgetStatePropertyAll(
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

class HeartIconButton extends StatefulWidget {
  final Event event;
  const HeartIconButton({Key? key, required this.event}) : super(key: key);

  @override
  _HeartIconButtonState createState() => _HeartIconButtonState();
}

class _HeartIconButtonState extends State<HeartIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isFavorited = false;
  final likeCount = ValueNotifier<int>(0);

  void likeEvent(int userId) async {
    var likeEvent = LikeEvent(eventId: widget.event.id!, userId: userId);
    await LikeE(likeEvent).then((value) {
      print(value);
      if (value.error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${value.error!}')));
      } else {
        likeCount.value++;
      }
    });
  }

  void dislikeEvent(int userId) async {
    var dislikeEvent = DisLikeEvent(eventId: widget.event.id!, userId: userId);
    await DisLikeE(dislikeEvent).then((value) {
      print(value);
      if (value.error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${value.error!}')));
      } else {
        likeCount.value = likeCount.value > 0 ? likeCount.value - 1 : 0;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    widget.event
        .getNumberofLikes(widget.event.id!)
        .then((value) => likeCount.value = value);
  }

  @override
  Widget build(BuildContext context) {
    final loginDataProvider = Get.find<LoginDataProvider>(tag: 'login');
    int userId = loginDataProvider.loginData!.id!;
    return GestureDetector(
      onTap: () async {
        setState(() {
          isFavorited = !isFavorited;
          if (isFavorited) {
            _controller.forward().then((_) => _controller.reverse());
            likeEvent(userId);
          } else {
            _controller.forward().then((_) => _controller.reverse());
            dislikeEvent(userId);
          }
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return Transform.scale(
                scale: 1 - (_controller.value * 0.25),
                child: Icon(
                  TikTokIcons.heart,
                  size: 25,
                  color: isFavorited ? Colors.red : Colors.white,
                ),
              );
            },
          ),
          ValueListenableBuilder<int>(
            valueListenable: likeCount,
            builder: (BuildContext context, int value, Widget? child) {
              return Text('$value', style: TextStyle(color: Colors.white));
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ShareIconButton extends StatefulWidget {
  final String? title;
  final String videoFile;
  ShareIconButton({super.key, required this.videoFile, required this.title});

  @override
  State<ShareIconButton> createState() => _ShareIconButtonState();
}

class _ShareIconButtonState extends State<ShareIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isFavorited = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isFavorited = !isFavorited;
          if (isFavorited) {
            _controller.forward().then((_) => _controller.reverse());
          } else {
            _controller.forward().then((_) => _controller.reverse());
          }
        });
        Share.share(
          'https://ticketmaster-et.com${widget.videoFile}',
          subject:
              'Check out Ticketmaster ET to book a ticket for ${widget.title}',
        );
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return Transform.scale(
            scale: 1 - (_controller.value * 0.25),
            child: Icon(
              TikTokIcons.reply,
              size: 25,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}

class CommentIconButton extends StatefulWidget {
  final Event event;
  const CommentIconButton({super.key, required this.event});

  @override
  State<CommentIconButton> createState() => _CommentIconButtonState();
}

class _CommentIconButtonState extends State<CommentIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isFavorited = false;
  ValueNotifier<int> commentCount = ValueNotifier(0);
  late Future _future;
  final TextEditingController _commentController = TextEditingController();
  List<Comment> comments = [];
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _future = widget.event
        .getNumberofComments(widget.event.id!)
        .then((value) => commentCount.value = value);
  }

  @override
  Widget build(BuildContext context) {
    final commentsModel = Provider.of<CommentsModel>(context, listen: true);
    return GestureDetector(
      onTap: () async {
        setState(() {
          isFavorited = !isFavorited;
          if (isFavorited) {
            _controller.forward().then((_) => _controller.reverse());
          } else {
            _controller.forward().then((_) => _controller.reverse());
          }
        });

        print('CHECKING EVENT ID=======================: ${widget.event.id!}');
        commentsModel
            .addAllComments(await getCommentsByEventId(widget.event.id!));

        print('CHECKING COMMENTS=======================: $comments');
        // Show modal bottom sheet
        showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          builder: (BuildContext context) {
            final loginDataProvider = Get.find<LoginDataProvider>(tag: 'login');

            ValueNotifier<String> commentText = ValueNotifier('');
            return FutureBuilder(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return SingleChildScrollView(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: ValueListenableBuilder<int>(
                                    valueListenable: commentCount,
                                    builder: (BuildContext context, int value,
                                        Widget? child) {
                                      return Text('$value comments',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold));
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      controller: _commentController,
                                      onSaved: (newValue) {
                                        commentText.value = newValue!;
                                        print(
                                            'CHECKING COMMENT1: $commentText');
                                      },
                                      onChanged: (value) {
                                        commentText.value = value;
                                        print(
                                            'CHECKING COMMENT2: $commentText');
                                      },
                                      onFieldSubmitted: (value) {
                                        setState(() {
                                          commentText.value = value;
                                        });

                                        print(
                                            'CHECKING COMMENT3: $commentText');
                                      },
                                      decoration: InputDecoration(
                                        fillColor: Colors.grey[200],
                                        hintText: 'Write a comment',
                                        border: const OutlineInputBorder(),
                                        contentPadding: EdgeInsets.all(16.0),
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                    icon: Icon(Icons.send),
                                    onPressed: () async {
                                      print(
                                          'CHECKING COMMENT3: ${_commentController.text}');
                                      if (_commentController.text.isNotEmpty) {
                                        // Get the event id, user id, first name, last name and comment from the variables
                                        int eventId = widget.event.id!;
                                        int userId =
                                            loginDataProvider.loginData!.id!;
                                        String firstName = loginDataProvider
                                            .loginData!.firstName!;
                                        String lastName = loginDataProvider
                                            .loginData!.lastName!;
                                        Comment comment = Comment();
                                        comment.comment =
                                            _commentController.text;
                                        comment.firstName = firstName;
                                        comment.lastName = lastName;

                                        // Post the comment using the API function
                                        await commentonEvent(
                                            eventId, userId, comment);

                                        // Clear the text field
                                        _commentController.clear();

                                        // Update the UI with the new comment
                                        setState(() {
                                          commentsModel.addComment(Comment(
                                              firstName: firstName,
                                              lastName: lastName,
                                              comment: comment.comment));
                                        });
                                        commentCount.value =
                                            commentCount.value + 1;
                                      }
                                    })
                              ],
                            ),
                            Expanded(
                              child: Consumer<CommentsModel>(
                                builder: (context, commentsModel, child) {
                                  return ListView.builder(
                                    itemCount: commentsModel.comments.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${commentsModel.comments[index].firstName} ${commentsModel.comments[index].lastName}',
                                                style: TextStyle(
                                                    color: Colors.black54),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                '${commentsModel.comments[index].comment}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ]),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            // Add a text field form with a rounded corner, grey fill and black54 hint color
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                });
          },
        );
      },
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return Transform.scale(
                scale: 1 - (_controller.value * 0.25),
                child: const Icon(
                  TikTokIcons.chat_bubble,
                  size: 25,
                  color: Colors.white,
                ),
              );
            },
          ),
          ValueListenableBuilder<int>(
            valueListenable: commentCount,
            builder: (BuildContext context, int value, Widget? child) {
              return Text('$value', style: TextStyle(color: Colors.white));
            },
          ),
        ],
      ),
    );
  }
}

class InterestButton extends StatefulWidget {
  final Event event;
  const InterestButton({Key? key, required this.event}) : super(key: key);

  @override
  _InterestButtonState createState() => _InterestButtonState();
}

class _InterestButtonState extends State<InterestButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isFavorited = false;
  final interestCount = ValueNotifier<int>(0);

  void interestEvent(int userId) async {
    var interestEvent =
        InterestEvent(eventId: widget.event.id!, userId: userId);
    await InterestE(interestEvent).then((value) {
      print(value);
      if (value.error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${value.error!}')));
      } else {
        interestCount.value++;
      }
    });
  }

  void disinterestEvent(int userId) async {
    var disinterestEvent =
        DisInterestEvent(eventId: widget.event.id!, userId: userId);
    await DisInterestE(disinterestEvent).then((value) {
      print(value);
      if (value.error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${value.error!}')));
      } else {
        interestCount.value =
            interestCount.value > 0 ? interestCount.value - 1 : 0;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    widget.event
        .getNumberofInterests(widget.event.id!)
        .then((value) => interestCount.value = value);
    print('CHECKING NUMBER OF INTERESTS: ${interestCount.value}');
  }

  @override
  Widget build(BuildContext context) {
    final loginDataProvider = Get.find<LoginDataProvider>(tag: 'login');
    int userId = loginDataProvider.loginData!.id!;
    return GestureDetector(
      onTap: () async {
        setState(() {
          isFavorited = !isFavorited;
          if (isFavorited) {
            _controller.forward().then((_) => _controller.reverse());
            interestEvent(userId);
          } else {
            _controller.forward().then((_) => _controller.reverse());
            disinterestEvent(userId);
          }
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return Transform.scale(
                scale: 1 - (_controller.value * 0.25),
                child: Icon(
                  Icons.star_rounded,
                  size: 40,
                  color: isFavorited ? Colors.yellow : Colors.white,
                ),
              );
            },
          ),
          ValueListenableBuilder<int>(
            valueListenable: interestCount,
            builder: (BuildContext context, int value, Widget? child) {
              return Text('$value', style: TextStyle(color: Colors.white));
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
