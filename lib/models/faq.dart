import '../controllers/theme_controller.dart';

class FAQ {
  int? id;
  String? title;
  String? description;

  FAQ({
    required this.id,
    required this.title,
    required this.description,
  });

  FAQ.fromJson(Map<String, dynamic> json, String language) {
    // print("FAQ.fromJson $json");
    id = json['id'];
    String? languageCode = ThemeModeController.languageCode.value == 'es'
        ? 'tg'
        : ThemeModeController.languageCode.value == 'it'
            ? 'or'
            : ThemeModeController.languageCode.value == 'fr'
                ? 'so'
                : ThemeModeController.languageCode.value;
    title = json['title_$languageCode'];
    description = json['desc_$languageCode'];
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'description': description};
  }
}
