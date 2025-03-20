import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:ticketmaster_et/functions/functions.dart';

class FooterController extends GetxController {
  var footer = FooterData().obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    fetchFooter();
    super.onInit();
  }

  Future<void> fetchFooter() async {
    footer.value = await getFooterData();
    isLoading.value = false;
  }
}

Future<FooterData> getFooterData() async {
  try {
    final response = await http.get(
      Uri.parse("${baseUrlFunc}footer"),
      headers: {
        "Content-type": "application/json",
      },
    );
    Logger().d('STATCODE: ${response.statusCode}');
    dynamic jsonData = json.decode(response.body);
    Logger().d(jsonData);
    if (response.statusCode == 200) {
      final FooterData footerData = FooterData.fromJson(jsonData["data"]);
      return footerData;
    } else {
      throw Exception(response.statusCode.toString());
    }
  } catch (error) {
    rethrow;
  }
}

class FooterData {
  String? copyWriteText;
  String? faceBookLink;
  String? linkedInLink;
  String? youtubeLink;
  String? instagramLink;
  String? twitterLink;
  String? telegramLink;
  String? tiktokLink;
  String? playstoreLink;
  String? appstoreLink;

  FooterData(
      {this.copyWriteText,
      this.faceBookLink,
      this.instagramLink,
      this.linkedInLink,
      this.twitterLink,
      this.youtubeLink,
      this.telegramLink,
      this.tiktokLink,
      this.appstoreLink,
      this.playstoreLink});

  factory FooterData.fromJson(json) {
    return FooterData(
        copyWriteText: json["copyright"],
        faceBookLink: json["facebook"],
        instagramLink: json["instagram"],
        linkedInLink: json["linkedin"],
        twitterLink: json["twitter"],
        youtubeLink: json["youtube"],
        telegramLink: json["telegram"],
        appstoreLink: json["app_store_link"],
        playstoreLink: json["play_store_link"],
        tiktokLink: json["tiktok"]);
  }

  @override
  String toString() {
    return 'FooterData{copyWriteText: $copyWriteText, '
        'faceBookLink: $faceBookLink, '
        'linkedInLink: $linkedInLink, '
        'youtubeLink: $youtubeLink, '
        'instagramLink: $instagramLink, '
        'twitterLink: $twitterLink, '
        'telegramLink: $telegramLink, '
        'tiktokLink: $tiktokLink}';
  }
}
