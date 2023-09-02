import 'package:flutter/material.dart';

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

    return const SingleChildScrollView(child: Placeholder());
  }
}
