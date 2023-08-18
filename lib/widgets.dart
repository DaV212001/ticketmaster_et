import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:tiktoklikescroller/tiktoklikescroller.dart';
import 'models/event_model.dart';

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

class HomeTabWidget extends StatelessWidget {
  const HomeTabWidget({
    super.key,
    required this.modified,
    required this.controller,
  });

  final List<EventModel> modified;
  final Controller controller;

  @override
  Widget build(BuildContext context) {
    return TikTokStyleFullPageScroller(
      contentSize: modified.length,
      swipePositionThreshold: 0.2,
      swipeVelocityThreshold: 2000,
      animationDuration: const Duration(milliseconds: 400),
      controller: controller,
      builder: (BuildContext context, int index) {
        return Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Container(
              // color: events[index],
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(modified[index].image))),
            ),
            Text(
              '${modified[index].description} $index',
              style: const TextStyle(fontSize: 30, color: Colors.black),
            ),
          ],
        );
      },
    );
  }
}

class UpcomingTabWidget extends StatelessWidget {
  const UpcomingTabWidget({
    super.key,
    required this.events,
  });

  final List<EventModel> events;

  @override
  Widget build(BuildContext context) {
    final List<String> cat = ['Sport', 'Concert', 'EXPO', 'Travel'];
    return SingleChildScrollView(
      child: Column(
        children: [
          CarouselSlider.builder(
              itemCount: 10,
              itemBuilder: (context, index, count) {
                return Container(
                  child: Text(count.toString()),
                );
              },
              options: CarouselOptions()),
          Container(
            height: 300,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: ((context, indexx) {
                return CardEventThisMonth(eventModel: events[indexx]);
              }),
            ),
          ),
          Container(
            height: 125,
            child: ListView.builder(
                itemCount: cat.length,
                itemBuilder: (context, index) {
                  return Container(
                    color: Colors.blue,
                    child: Text(cat[index]),
                  );
                }),
          )
        ],
      ),
    );
  }
}
