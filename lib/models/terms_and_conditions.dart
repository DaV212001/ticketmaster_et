import '../controllers/theme_controller.dart';

class TermsAndConditions {
  int? id;
  String? title;
  // String? description;

  TermsAndConditions({
    required this.id,
    required this.title,
    // required this.description,
  });

  TermsAndConditions.fromJson(Map<String, dynamic> json, String language) {
    // print("TermsAndConditions.fromJson $json");
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
