import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';

import '../models/category_model.dart';

class CategoryTab extends StatefulWidget {
  const CategoryTab({super.key});

  @override
  State<CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<CategoryTab> {
  @override
  Widget build(BuildContext context) {
    // return DefaultTabController(
    //   length: 3,
    //   child: Column(
    //     children: <Widget>[
    //       ButtonsTabBar(
    //           backgroundColor: const Color(0xFF792ABC),
    //           unselectedBackgroundColor: Colors.black38,
    //           tabs: const [
    //             Tab(
    //               child: Text(
    //                 'Sport',
    //                 style: TextStyle(color: Colors.white),
    //               ),
    //             ),
    //             Tab(
    //               child: Text(
    //                 'Festivities',
    //                 style: TextStyle(color: Colors.white),
    //               ),
    //             ),
    //             Tab(
    //               child: Text(
    //                 'Concert',
    //                 style: TextStyle(color: Colors.white),
    //               ),
    //             )
    //           ]),
    //       const Expanded(
    //         child: TabBarView(children: [
    //           Text('data'),
    //           Text('data'),
    //           Text('data'),
    //         ]),
    //       ),
    //     ],
    //   ),
    // );
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
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
              'Sports',
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
                      const SizedBox(height: 8),
                      Text(sportActivities[index].name),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
