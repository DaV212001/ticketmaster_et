import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:ticketmaster_et/components/tiktokicons.dart';

import '../controllers/video_promotion_controller.dart';
import 'event_ticket.dart';

class VideoPromotionScreen extends StatelessWidget {
  final VideoPromotionController controller =
      Get.put(VideoPromotionController());

  VideoPromotionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.videoPromotions.isEmpty) {
          return const Center(
              child: Text('No videos available',
                  style: TextStyle(color: Colors.white)));
        }

        return PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: controller.videoPromotions.length,
          onPageChanged: (index) {
            final video = controller.videoPromotions[index];
            controller.loadVideoStats(video.id.toString());

            // Optionally preload the next video's stats
            if (index + 1 < controller.videoPromotions.length) {
              final nextVideo = controller.videoPromotions[index + 1];
              controller.loadVideoStats(nextVideo.id.toString());
            }
          },
          itemBuilder: (context, index) {
            final video = controller.videoPromotions[index];
            // controller.loadVideoStats(video.id.toString());
            return Stack(
              alignment: Alignment.bottomLeft,
              children: [
                VideoPlayerWidget(videoUrl: video.url),
                Positioned(
                  right: 10,
                  bottom: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(() => IconButton(
                            icon: Icon(
                              controller.likedVideos
                                      .contains(video.id.toString())
                                  ? Icons.favorite
                                  : TikTokIcons.heart,
                              color: controller.likedVideos
                                      .contains(video.id.toString())
                                  ? Theme.of(context).primaryColor
                                  : Colors.white,
                              size: 32,
                            ),
                            onPressed: () =>
                                controller.toggleLike(video.id.toString()),
                          )),
                      Obx(() => Text(
                            controller.videoLikes[video.id.toString()]
                                    ?.toString() ??
                                '0',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          )),
                      const SizedBox(height: 10),
                      IconButton(
                        icon: const Icon(TikTokIcons.chat_bubble,
                            color: Colors.white, size: 32),
                        onPressed: () {
                          showCommentsModal(context, video.id.toString());
                          // Show comments modal or navigate
                        },
                      ),
                      Obx(() => Text(
                            (controller.videoComments[video.id.toString()]
                                        ?.length ??
                                    0)
                                .toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          )),
                      // const SizedBox(height: 10),
                      // IconButton(
                      //   icon: const Icon(TikTokIcons.reply,
                      //       color: Colors.white, size: 32),
                      //   onPressed: () {
                      //     // Share functionality
                      //   },
                      // ),
                      // const Text('Share',
                      //     style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 3,
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
                                  stops: const [
                                0.0,
                                0.2
                              ],
                                  colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7)
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
                              width: MediaQuery.of(context).size.width * 3 / 4,
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // SizedBox(
                                    //   height: 120,
                                    //   child: ListView.builder(
                                    //       itemCount: 1,
                                    //       itemBuilder: (context, index) {
                                    //         return Column(
                                    //           crossAxisAlignment:
                                    //               CrossAxisAlignment.start,
                                    //           mainAxisAlignment:
                                    //               MainAxisAlignment.end,
                                    //           children: [
                                    GestureDetector(
                                      onTap: () async {
                                        // var company = await FoodService()
                                        //     .fetchFoodById(video.companyId);
                                        // UserController controller =
                                        // Get.put(UserController());
                                        // await controller.initialize();
                                        // Logger().d(controller.loggedIn.value);
                                        // if (controller.loggedIn.value) {
                                        //   Get.to(
                                        //           () => RecipeScreen(food: company),
                                        //       arguments: {'food': company});
                                        // } else {
                                        //   Get.to(
                                        //           () => const AuthScreen(
                                        //           isSignIn: true),
                                        //       arguments: company);
                                        // }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8.0, bottom: 4),
                                        child: Text(
                                          video.title,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        video.description,
                                        style: const TextStyle(
                                            fontSize: 11, color: Colors.white),
                                      ),
                                    ),
                                    //     ],
                                    //   );
                                    // }),
                                    // )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }

  void showCommentsModal(BuildContext context, String videoId) {
    showModalBottomSheet(
      context: context,
      // backgroundColor: Colors.black,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Obx(() {
          final comments = controller.videoComments[videoId] ?? [];
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Comments', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return ListTile(
                        title: Text(
                          "${comment['first_name']} ${comment['last_name']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          comment['comment'],
                          // style: const TextStyle(color: Colors.white70),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: TextField(
                    controller: controller.textEditingController,
                    // style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      // hintStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      // fillColor: Colors.grey[900],
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.send,
                        ),
                        onPressed: () {
                          final commentText =
                              controller.textEditingController.text.trim();
                          Logger()
                              .d(commentText.isEmpty ? 'Empty' : commentText);
                          if (commentText.isNotEmpty) {
                            controller.addComment(videoId, commentText);
                            controller.textEditingController.clear();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
