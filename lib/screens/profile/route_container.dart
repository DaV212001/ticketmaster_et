import 'package:flutter/material.dart';
import 'package:ticketmaster_et/screens/profile/route_card.dart';
import 'package:ticketmaster_et/screens/profile/route_label_card.dart';

class RouteContainer extends StatelessWidget {
  // Widget widget;
  final int indexTwo;
  final String routeName;
  final List<Map<String, dynamic>> routePart;
  const RouteContainer(
      {super.key,
      // required this.widget,
      required this.routePart,
      required this.indexTwo,
      required this.routeName});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
            ),
            decoration: BoxDecoration(
                color: theme.cardColor, borderRadius: BorderRadius.circular(5)),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: routePart.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    index == 0
                        ? RouteLabelCards(text: routeName)
                        : const SizedBox.shrink(),
                    RouteCard(
                        onTap: routePart[index]["onTap"],
                        title: routePart[index]["title"],
                        icon: routePart[index]["leadingIcon"]),
                    index == indexTwo
                        ? const SizedBox.shrink()
                        : Divider(
                            thickness: 1,
                            height: 1,
                            color: Colors.grey.withOpacity(0.5))
                  ],
                );
              },
            )));
  }
}
