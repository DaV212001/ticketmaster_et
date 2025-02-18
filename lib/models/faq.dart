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
    switch (language) {
      case 'am':
        title = json['title_am'];
        break;
      case 'en':
        title = json['title_en'];
        break;
      case 'en-AU':
        title = json['title_or'];
        break;
      case 'es':
        title = json['title_so'];
        break;
      case 'fr':
        title = json['title_tg'];
        break;
      default:
        throw Exception('Invalid language: $language');
    }
    switch (language) {
      case 'am':
        description = json['desc_am'];
        break;
      case 'en':
        description = json['desc_en'];
        break;
      case 'en-AU':
        description = json['desc_or'];
        break;
      case 'es':
        description = json['desc_so'];
        break;
      case 'fr':
        description = json['desc_tg'];
        break;
      default:
        throw Exception('Invalid language: $language');
    }
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'description': description};
  }
}
