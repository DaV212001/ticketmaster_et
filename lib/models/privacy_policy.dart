import '../controllers/theme_controller.dart';

class PrivacyPolicy {
  int? id;
  String? title;
  // String? description;

  PrivacyPolicy({
    required this.id,
    required this.title,
    // required this.description,
  });

  PrivacyPolicy.fromJson(Map<String, dynamic> json, String language) {
    // print("PrivacyPolicy.fromJson $json");
    id = json['id'];

    String? languageCode = ThemeModeController.languageCode.value == 'es'
        ? 'tg'
        : ThemeModeController.languageCode.value == 'it'
            ? 'or'
            : ThemeModeController.languageCode.value == 'fr'
                ? 'so'
                : ThemeModeController.languageCode.value;

    title = json['text_$languageCode'];

    // description = json['description'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      // 'description': description
    };
  }
}
