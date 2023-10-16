import 'package:flutter/material.dart';
import 'event_detail.dart';

class VideoTest extends StatefulWidget {
  const VideoTest({super.key});

  @override
  State<VideoTest> createState() => _VideoTestState();
}


class _VideoTestState extends State<VideoTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: VideoPlayerWidget(videoUrl: 'https://admin.ticketmaster-et.com/public/storage/upcoming/1697442366.mp4'));
  }
}
