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
      case 'es':
        title = json['text_so'];
        break;
      case 'fr':
        title = json['text_tg'];
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
