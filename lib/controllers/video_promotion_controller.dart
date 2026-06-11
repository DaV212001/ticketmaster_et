import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../functions/functions.dart';
import '../models/newmodels.dart';
import '../provider/loginpersistence.dart';

class VideoPromotionController extends GetxController {
  final RxList<VideoPromotion> videoPromotions = <VideoPromotion>[].obs;
  final RxBool isLoading = false.obs;
  final RxMap<String, int> videoLikes = <String, int>{}.obs;
  final RxMap<String, List<Map<String, dynamic>>> videoComments =
      <String, List<Map<String, dynamic>>>{}.obs;
  final RxSet<String> likedVideos = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchVideos();
  }

  void loadVideoStats(String videoId) {
    if (!videoLikes.containsKey(videoId)) {
      fetchVideoLikes(videoId);
    }
    if (!videoComments.containsKey(videoId)) {
      fetchVideoComments(videoId);
    }
    if (!likedVideos.contains(videoId)) {
      checkIfLiked(int.parse(videoId));
    }
  }

  void checkIfLiked(int videoId) async {
    // Get.find<LoginDataProvider>(tag: 'login').loadLoginData();
    try {
      var res = await http.get(Uri.parse(
          '${baseUrlFunc}my_like/${Get.find<LoginDataProvider>(tag: 'login').loginData?.id}/$videoId'));
      if (jsonDecode(res.body)['data'] == 1) {
        likedVideos.add(videoId.toString());
      }
    } catch (e, s) {
      Logger().t(e, stackTrace: s);
    }
  }

  Future<void> fetchVideos() async {
    isLoading.value = true;
    var url = '${baseUrlFunc}video';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        videoPromotions.value =
            data.map((json) => VideoPromotion.fromJson(json)).toList();
        if (videoPromotions.isNotEmpty) {
          loadVideoStats(
              videoPromotions.first.id.toString()); // Load first video's stats
        }
        // // Fetch likes and comments for each video
        // for (var video in videoPromotions) {
        //   fetchVideoLikes(video.id.toString());
        //   checkIfLiked(video.id);
        //   fetchVideoComments(video.id.toString());
        // }
      } else {
        Get.snackbar('Error', 'Failed to load videos',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e, s) {
      Logger().t(e, stackTrace: s);
      // Get.snackbar('Error', e.toString(),
      //     backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleLike(String videoId) async {
    // Get.find<LoginDataProvider>(tag: 'login').loadLoginData();
    final userId = Get.find<LoginDataProvider>(tag: 'login').loginData?.id;
    String url = '${baseUrlFunc}video-like';

    bool isLiking = !likedVideos.contains(videoId);
    if (isLiking) {
      likedVideos.add(videoId);
    } else {
      url = '${baseUrlFunc}dis-like-video';
      likedVideos.remove(videoId);
    }

    // Optimistic update
    videoLikes.update(videoId, (value) => isLiking ? value + 1 : value - 1,
        ifAbsent: () => isLiking ? 1 : 0);

    try {
      final response = await http.post(Uri.parse(url),
          body: jsonEncode({'video_id': videoId, 'user_id': userId}),
          headers: {'content-type': 'application/json'});
      Logger().d(response.body);
      if (jsonDecode(response.body)['message'] !=
          (isLiking
              ? 'Video liked succesfuly'
              : 'Video Dis liked succesfuly')) {
        // Revert on failure
        if (isLiking) {
          likedVideos.remove(videoId);
        } else {
          likedVideos.add(videoId);
        }
        videoLikes.update(videoId, (value) => isLiking ? value - 1 : value + 1);
      }
    } catch (e) {
      Logger().e('Error toggling like: $e');
      if (isLiking) {
        likedVideos.remove(videoId);
      } else {
        likedVideos.add(videoId);
      }
      videoLikes.update(videoId, (value) => isLiking ? value - 1 : value + 1);
    }
  }

  TextEditingController textEditingController = TextEditingController();
  Future<void> fetchVideoLikes(String videoId) async {
    final url = '${baseUrlFunc}video-like/$videoId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        videoLikes[videoId] = jsonResponse['data'];
      }
    } catch (e) {
      Logger().e('Error fetching likes: $e');
    }
  }

  Future<void> fetchVideoComments(String videoId) async {
    final url = '${baseUrlFunc}video-comment-list/$videoId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        videoComments[videoId] = (jsonResponse['data'] as List<dynamic>)
            .map((comment) => {
                  'first_name': comment['first_name'],
                  'last_name': comment['last_name'],
                  'comment': comment['comment'],
                })
            .toList();
      }
    } catch (e) {
      Logger().e('Error fetching comments: $e');
    }
  }

  Future<void> addComment(String videoId, String comment) async {
    Logger().d(comment);
    // Get.find<LoginDataProvider>(tag: 'login').loadLoginData();
    final userId = Get.find<LoginDataProvider>(tag: 'login').loginData?.id;
    const url = '${baseUrlFunc}video-comment';

    final newComment = {
      'first_name':
          Get.find<LoginDataProvider>(tag: 'login').loginData?.firstName,
      'last_name':
          Get.find<LoginDataProvider>(tag: 'login').loginData?.lastName,
      'comment': comment,
    };

    // Optimistic update
    videoComments.update(videoId, (comments) => [...comments, newComment],
        ifAbsent: () => [newComment]);
    videoComments.refresh();

    try {
      final response = await http.post(Uri.parse(url),
          body: jsonEncode({
            'video_id': videoId.toString(),
            'user_id': userId.toString(),
            'comment': comment.toString()
          }),
          headers: {'content-type': 'application/json'});
      Logger().d(response.body);
      if (jsonDecode(response.body)['message'] !=
          'Video Commented succesfuly') {
        // Revert on failure
        videoComments.update(
            videoId, (comments) => comments..remove(newComment));
      }
    } catch (e, s) {
      Logger().t('Error adding comment: $e', stackTrace: s);
      videoComments.update(videoId, (comments) => comments..remove(newComment));
    }
  }
}
