// ignore_for_file: unnecessary_null_comparison, unnecessary_string_interpolations

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ticketmaster_et/models/event_model.dart';
import 'package:ticketmaster_et/screens/event_detail.dart';
import 'package:ticketmaster_et/models/newmodels.dart';
import '../constants/app_constants.dart';
import '../functions/functions.dart';
import '../provider/settings_provider.dart';

// class CategoryEvents extends StatelessWidget {
//   const CategoryEvents({
//     Key? key,
//     //  required ScrollController scrollController,
//     //  required this.moviesList,
//     // required this.isDark,
//     // required this.imageQuality,
//   }) : super(key: key);
//
//   // final List<Movie>? moviesList;
//   //final bool isDark;
//   //final String imageQuality;
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     final ScrollController scrollController = ScrollController();
//     List<EventModel> events = [
//       EventModel(
//           id: 'id',
//           title: 'Teddy Afro concert',
//           image:
//               'https://littleethiopia.files.wordpress.com/2013/07/tteedd.jpg',
//           date: '09/02/2023',
//           location: 'Addis Ababa',
//           description: 'description'),
//       EventModel(
//           id: 'id',
//           title: 'Rophnan concert',
//           image:
//               'https://www.akwaabamusic.com/wp-content/uploads/2018/09/WhatsApp-Image-2018-09-20-at-4.21.12-PM.jpeg',
//           date: '09/02/2023',
//           location: 'Addis Ababa',
//           description: 'description'),
//       EventModel(
//           id: 'id',
//           title: 'Dawit tsige concert',
//           image: 'https://i.ytimg.com/vi/ebdmbdgVbNI/maxresdefault.jpg',
//           date: '09/02/2023',
//           location: 'Addis Ababa',
//           description: 'description'),
//       EventModel(
//           id: 'id',
//           title: 'Aster Aweke concert',
//           image:
//               'https://i.pinimg.com/736x/20/8b/98/208b98f613eec4a2da08dec552ab4c1a.jpg',
//           date: '09/02/2023',
//           location: 'Addis Ababa',
//           description: 'description'),
//     ];
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('Concert events'),
//         ),
//         body: ListView.builder(
//             controller: scrollController,
//             physics: const BouncingScrollPhysics(),
//             itemCount: events.length,
//             itemBuilder: (BuildContext context, int index) {
//               return GestureDetector(
//                 onTap: () {
//                   Navigator.push(context, MaterialPageRoute(builder: (context) {
//                     return EventDetail();
//                   }));
//                 },
//                 child: Container(
//                   color: Colors.transparent,
//                   child: Padding(
//                     padding: const EdgeInsets.only(
//                       top: 8.0,
//                       bottom: 3.0,
//                       left: 10,
//                     ),
//                     child: Column(
//                       children: [
//                         Row(
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.only(right: 10.0),
//                               child: SizedBox(
//                                 width: 130,
//                                 height: 130,
//                                 child: Hero(
//                                   tag: '${events[index].id}',
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(10.0),
//                                     child: events![index].image == null
//                                         ? Image.asset(
//                                             'assets/images/na_logo.png',
//                                             fit: BoxFit.cover,
//                                           )
//                                         : CachedNetworkImage(
//                                             //  cacheManager: cacheProp(),
//                                             fadeOutDuration: const Duration(
//                                                 milliseconds: 300),
//                                             fadeOutCurve: Curves.easeOut,
//                                             fadeInDuration: const Duration(
//                                                 milliseconds: 700),
//                                             fadeInCurve: Curves.easeIn,
//                                             imageUrl: events![index].image!,
//                                             imageBuilder:
//                                                 (context, imageProvider) =>
//                                                     Container(
//                                               decoration: BoxDecoration(
//                                                 image: DecorationImage(
//                                                   image: imageProvider,
//                                                   fit: BoxFit.cover,
//                                                 ),
//                                               ),
//                                             ),
//                                             // placeholder: (context, url) =>
//                                             //     mainPageVerticalScrollImageShimmer(
//                                             //         isDark),
//                                             errorWidget:
//                                                 (context, url, error) =>
//                                                     Image.asset(
//                                               'assets/images/na_logo.png',
//                                               fit: BoxFit.cover,
//                                             ),
//                                           ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     events![index].title!,
//                                     style: const TextStyle(
//                                         fontFamily: 'PoppinsSB',
//                                         fontSize: 15,
//                                         overflow: TextOverflow.ellipsis),
//                                   ),
//                                   Row(
//                                     children: <Widget>[
//                                       const Icon(
//                                         Icons.calendar_month,
//                                       ),
//                                       Text(
//                                         events![index].date,
//                                         style: const TextStyle(
//                                             fontFamily: 'Poppins'),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             )
//                           ],
//                         ),
//                         const Divider(
//                           //  color: !isDark ? Colors.black54 : Colors.white54,
//                           color: Colors.white54,
//                           thickness: 1,
//                           endIndent: 20,
//                           indent: 10,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }));
//   }
// }
//

class CategoryEvents extends StatefulWidget {
  const CategoryEvents({super.key, required this.searchfactor, required this.organizers});
  final int searchfactor;
  final bool organizers;
  @override
  State<CategoryEvents> createState() => _CategoryEventsState();
}

class _CategoryEventsState extends State<CategoryEvents> {
  List<Event> events = [];
  bool _isLoading = true;
  List<Event> ep = [];
  List<Category> categories = [];
  String? categoryname = 'Default';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updatesForCatEvents();
    });
  }

  void updatesForCatEvents() async {
    setState(() {
      _isLoading = true;
    });
    await getCategorySubCategory(Provider.of<SettingsProvider>(context, listen: false).languageCode)
        .then((value) => setState(() {
      categories = value;
      print('VALUE OF THE CATEGORY for cat events: $value');
    }));
    if(widget.organizers){await getEventsByOrganizerId(widget.searchfactor, Provider.of<SettingsProvider>(context, listen: false).languageCode).then((value) => setState((){
      ep = value;
      print( 'VALUE OF THE ORGANIZERS for cat events: $value');
    }));
    setState(() {

    });}
    for(int i = 0; i<categories.length; i++){
      for(int j = 0; j<categories[i].subCategory!.length; j++){
        if(categories[i].subCategory?[j].id == widget.searchfactor){
          categoryname = categories[i].subCategory?[j].name;
        }
      }
    }
    setState(() {

    });
    !widget.organizers? getEventsBySubCategoryId(widget.searchfactor, Provider.of<SettingsProvider>(context, listen: false).languageCode).then((value) => setState((){
      events = value;
      print( 'VALUE OF THE EVENTS for cat events: $value');
    })): print('1: ${ep}');
    print(ep);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Here we start listening to changes in SettingsProvider
    Provider.of<SettingsProvider>(context).addListener(updatesForCatEvents);
  }

  @override
  void dispose() {
    if (mounted) {
      Provider.of<SettingsProvider>(context, listen: false).removeListener(updatesForCatEvents);
    }
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.organizers? 'Organizer\'s events' : categoryname!),
        ),
        body: ListView.builder(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.organizers?ep.length: events.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  !widget.organizers?print('No Organizer Detail Available'):
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return EventDetail(event: events[index],);
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
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: widget.organizers?
                                  //if organizers is true
                                  ep[index].image!.trim()=='https://admin.ticketmaster-et.com/public/storage/dsvdv'?
                                  //if organizers is true and error image is true
                                  Image.asset(
                                    'assets/images/na_logo.jpg',
                                    fit: BoxFit.cover,
                                  ):

                                  //if organizers is true and error image is false

                                  CachedNetworkImage(
                                    //  cacheManager: cacheProp(),
                                    fadeOutDuration: const Duration(
                                        milliseconds: 300),
                                    fadeOutCurve: Curves.easeOut,
                                    fadeInDuration: const Duration(
                                        milliseconds: 700),
                                    fadeInCurve: Curves.easeIn,
                                    imageUrl:  ep[index].image!.trim()=='https://admin.ticketmaster-et.com/public/storage/dsvdv'?'https://i.postimg.cc/VkBQ3FS6/na-logo.png': ep[index].image!.trim(),
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
                                          'assets/images/na_logo.jpg',
                                          fit: BoxFit.cover,
                                        ),
                                  )


                                      :
                                  //if organizers is false


                                  events[index].image == null
                                      ||events[index].image! == 'https://admin.ticketmaster-et.com/public/storage' || events[index].image! == 'https://admin.ticketmaster-et.com/public/storage/%5Bvalue-2%5D' || events[index].image! == 'https://admin.ticketmaster-et.com/public/storage/aaa'||events[index].image! == 'https://admin.ticketmaster-et.com/public/storage/'||events[index].image! == 'https://admin.ticketmaster-et.com/public/storage/[value-2]'?

                                      //if organizers is false but error image is true
                                  Image.asset(
                                    'assets/images/na_logo.jpg',
                                    fit: BoxFit.cover,
                                  )
                                      :
                                  //if organizers is false and error image is false

                                  CachedNetworkImage(
                                    //  cacheManager: cacheProp(),
                                    fadeOutDuration: const Duration(
                                        milliseconds: 300),
                                    fadeOutCurve: Curves.easeOut,
                                    fadeInDuration: const Duration(
                                        milliseconds: 700),
                                    fadeInCurve: Curves.easeIn,
                                    imageUrl: events[index].image!.trim() == 'https://admin.ticketmaster-et.com/public/storage' || events[index].image!.trim() == 'https://admin.ticketmaster-et.com/public/storage/%5Bvalue-2%5D' || events[index].image!.trim() == 'https://admin.ticketmaster-et.com/public/storage/aaa'||events[index].image!.trim() == 'https://admin.ticketmaster-et.com/public/storage/'||events[index].image!.trim() == 'https://admin.ticketmaster-et.com/public/storage/[value-2]'? 'https://i.postimg.cc/VkBQ3FS6/na-logo.png': events[index].image!.trim(),
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
                                          'assets/images/na_logo.jpg',
                                          fit: BoxFit.cover,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    children: [Text(
                                      widget.organizers? ep[index].title!: events[index].title!,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                              ]
                                  ),
                                  Row(
                                    children: <Widget>[
                                      const Icon(
                                        Icons.calendar_month,
                                      ),
                                      Text(
                                        widget.organizers? ep[index].date!:events[index].date!,
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
