import 'package:get/get.dart';

class Organization {
  final int id;
  final String image;
  final String name;
  final String description;

  Organization({
    required this.id,
    required this.image,
    required this.name,
    required this.description,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    String? languageCode = Get.locale?.languageCode == 'es'
        ? 'tg'
        : Get.locale?.languageCode == 'it'
            ? 'or'
            : Get.locale?.languageCode == 'fr'
                ? 'so'
                : Get.locale?.languageCode;
    return Organization(
      id: json['id'],
      image: json['image'],
      name: json['name_$languageCode'], // Using English name as default
      description: json['description_$languageCode'],
    );
  }

  static List<Organization> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Organization.fromJson(json)).toList();
  }
}
