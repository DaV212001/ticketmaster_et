import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../provider/settings_provider.dart';
import 'package:flutter/material.dart';

class Search extends SearchDelegate<String> {
  Search()
      : super(
          searchFieldLabel: 'Search for event',
        );

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(
          Icons.clear,
        ),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.arrow_back,
      ),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darkTheme;
    return const DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
                child: TabBarView(children: [
              Center(
                child: Text(
                  'Ticketmaster',
                ),
              )
            ])),
          ],
        ),
      ),
    );
  }

  Widget errorMessageWidget(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image.asset('assets/images/404.png'),
          Text(
            'The term you entered didn\'t bring any results',
            style: TextStyle(
                fontFamily: 'Poppins',
                color: isDark ? Colors.white : Colors.black),
          )
        ],
      ),
    );
  }

  Widget searchATermWidget(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image.asset('assets/images/search.png'),
          const Padding(padding: EdgeInsets.only(top: 10, bottom: 5)),
          Text('Enter a word to search',
              style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontFamily: 'Poppins'))
        ],
      ),
    );
  }
}

//   Widget activeMovieSearch(
//       List<Movie> moviesList, bool isDark, BuildContext context) {
//     final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
//     return Column(
//       children: [
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.only(top: 8.0),
//             child: ListView.builder(
//                 physics: const BouncingScrollPhysics(),
//                 itemCount: moviesList.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   return GestureDetector(
//                     onTap: () {
//                       mixpanel.track('Most viewed movie pages', properties: {
//                         'Movie name': '${moviesList[index].title}',
//                         'Movie id': '${moviesList[index].id}'
//                       });
//                       Navigator.push(context,
//                           MaterialPageRoute(builder: (context) {
//                         return MovieDetailPage(
//                           movie: moviesList[index],
//                           heroId: '${moviesList[index].id}',
//                         );
//                       }));
//                     },
//                     child: Container(
//                       color: Colors.transparent,
//                       child: Padding(
//                         padding: const EdgeInsets.only(
//                           top: 0.0,
//                           bottom: 3.0,
//                           left: 10,
//                         ),
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.only(right: 10.0),
//                                   child: SizedBox(
//                                     width: 85,
//                                     height: 130,
//                                     child: Hero(
//                                       tag: '${moviesList[index].id}',
//                                       child: ClipRRect(
//                                         borderRadius:
//                                             BorderRadius.circular(10.0),
//                                         child: moviesList[index].posterPath ==
//                                                 null
//                                             ? Image.asset(
//                                                 'assets/images/na_logo.png',
//                                                 fit: BoxFit.cover,
//                                               )
//                                             : CachedNetworkImage(
//                                                 cacheManager: cacheProp(),
//                                                 fadeOutDuration: const Duration(
//                                                     milliseconds: 300),
//                                                 fadeOutCurve: Curves.easeOut,
//                                                 fadeInDuration: const Duration(
//                                                     milliseconds: 700),
//                                                 fadeInCurve: Curves.easeIn,
//                                                 imageUrl: TMDB_BASE_IMAGE_URL +
//                                                     imageQuality +
//                                                     moviesList[index]
//                                                         .posterPath!,
//                                                 imageBuilder:
//                                                     (context, imageProvider) =>
//                                                         Container(
//                                                   decoration: BoxDecoration(
//                                                     image: DecorationImage(
//                                                       image: imageProvider,
//                                                       fit: BoxFit.cover,
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 placeholder: (context, url) =>
//                                                     scrollingImageShimmer(
//                                                         isDark),
//                                                 errorWidget:
//                                                     (context, url, error) =>
//                                                         Image.asset(
//                                                   'assets/images/na_logo.png',
//                                                   fit: BoxFit.cover,
//                                                 ),
//                                               ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         moviesList[index].title!,
//                                         style: TextStyle(
//                                             fontFamily: 'PoppinsSB',
//                                             fontSize: 15,
//                                             overflow: TextOverflow.ellipsis,
//                                             color: isDark
//                                                 ? Colors.white
//                                                 : Colors.black),
//                                       ),
//                                       Row(
//                                         children: <Widget>[
//                                           const Icon(
//                                             Icons.star,
//                                           ),
//                                           Text(
//                                             moviesList[index]
//                                                 .voteAverage!
//                                                 .toStringAsFixed(1),
//                                             style: TextStyle(
//                                                 fontFamily: 'Poppins',
//                                                 color: isDark
//                                                     ? Colors.white
//                                                     : Colors.black),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                               ],
//                             ),
//                             Divider(
//                               color: !isDark ? Colors.black54 : Colors.white54,
//                               thickness: 1,
//                               endIndent: 20,
//                               indent: 10,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 }),
//           ),
//         ),
//       ],
//     );
//   }
// }
