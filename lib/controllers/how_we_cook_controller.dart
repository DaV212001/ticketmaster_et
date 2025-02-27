import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:ticketmaster_et/controllers/theme_controller.dart';
import 'package:ticketmaster_et/functions/functions.dart';

class HowWeCook {
  int? id;
  String? title;
  String? videoLink;

  HowWeCook({this.id, this.title, this.videoLink});

  factory HowWeCook.fromJson(Map<String, dynamic> json) {
    String? languageCode = ThemeModeController.languageCode.value == 'es'
        ? 'tg'
        : ThemeModeController.languageCode.value == 'it'
            ? 'or'
            : ThemeModeController.languageCode.value == 'fr'
                ? 'so'
                : ThemeModeController.languageCode.value;
    return HowWeCook(
      id: json['id'],
      title: json['title_$languageCode'],
      videoLink: json['video_link'],
    );
  }
}

class HowWeCookController extends GetxController {
  var howWeCook = <HowWeCook>[].obs;
  var isLoading = true.obs;

  void fetchHowWeCook() async {
    isLoading.value = true;
    try {
      var res = await retryOptions.retry(
        () => http.get(Uri.parse("${baseUrlFunc}how-we-cook")),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var data = jsonDecode(res.body);
      Logger().d(data);
      if (data['message'] == 'How We cook get successfully') {
        howWeCook.value = List<HowWeCook>.from(
            data['data'].map((x) => HowWeCook.fromJson(x)));
        isLoading.value = false;
      } else {
        throw Exception('Unexpected message from API: ${data['message']}');
      }
    } catch (e, s) {
      isLoading.value = false;
      Logger().t(e, stackTrace: s);
    } finally {
      isLoading.value = false;
      client.close();
    }
  }

  @override
  void onInit() {
    fetchHowWeCook();
    super.onInit();
  }
}
