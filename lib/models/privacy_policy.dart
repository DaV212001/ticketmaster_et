class PrivacyPolicy{
  int? id;
  String? title;
  // String? description;

  PrivacyPolicy({
    required this.id,
    required this.title,
    // required this.description,
  });

  PrivacyPolicy.fromJson(Map<String, dynamic> json, String language) {
    print("PrivacyPolicy.fromJson $json");
    id = json['id'];
    switch (language) {
      case 'am':
        title = json['text_am'];
        break;
      case 'en':
        title = json['text_en'];
        break;
      case 'en-AU':
        title = json['text_or'];
        break;
      default:
        throw Exception('Invalid language: $language');
    }

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