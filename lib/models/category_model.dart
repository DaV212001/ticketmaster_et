class CategoryModel {
  CategoryModel({required this.imagePath, required this.name});
  String? name;
  String? imagePath;
}

class SportActivity {
  final String name;
  final String image;

  SportActivity({required this.name, required this.image});
}

class ConcertActivity {
  final String name;
  final String image;

  ConcertActivity({required this.name, required this.image});
}

class OutdoorActivity {
  final String name;
  final String image;

  OutdoorActivity({required this.name, required this.image});
}
