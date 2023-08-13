import 'package:flutter/material.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        TabBar(
          tabs: const [
            Tab(
              text: 'Home',
            ),
            Tab(
              text: 'Upcoming',
            )
          ],
          controller: tabController,
        ),
        Expanded(
            child: TabBarView(
                controller: tabController,
                children: const [Text('hm'), Text('upc')]))
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
