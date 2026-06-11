import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:ticketmaster_et/functions/functions.dart';

import '../constants/app_constants.dart';
import '../controllers/theme_controller.dart';

class Class {
  int? id;
  String? eventId;
  String? title;
  int? availableTicket;
  int? price;

  Class({this.id, this.eventId, this.title, this.availableTicket, this.price});

  Class.fromJson(Map<String, dynamic> json, String language) {
    id = json['id'];
    eventId =
        json['event_id'] is String ? json['event_id'] : '${json['event_id']}';
    String? languageCode = ThemeModeController.languageCode.value == 'es'
        ? 'tg'
        : ThemeModeController.languageCode.value == 'it'
            ? 'or'
            : ThemeModeController.languageCode.value == 'fr'
                ? 'so'
                : ThemeModeController.languageCode.value;
    title = json['title_$languageCode'];
    availableTicket = json['available_ticket'] is String
        ? int.parse(json['available_ticket'])
        : json['available_ticket'];
    price = int.parse(json['price']);
  }
}

class CoverImage {
  int? id;
  String? coverimage;
  int? categoryId;
  int? foodId;
  int? organizerId;
  int? eventId;
  DateTime? createdat;
  DateTime? updatedat;

  CoverImage(
      {this.id,
      this.coverimage,
      required this.categoryId,
      required this.foodId,
      this.organizerId});

  CoverImage.fromJson(Map<String, dynamic> json, String language) {
    id = json["id"];
    coverimage = json["cover_image"];
    categoryId = 0;
    foodId = json["food_id"] != null
        ? json["food_id"] is String
            ? int.parse(json["food_id"])
            : json["food_id"]
        : 0;
    organizerId = 0;
    eventId = 0;
  }
}

class Event {
  int? id;
  String? image;
  String? popularImage;
  String? categoryId;
  String? subCategoryId;
  String? organizerId;
  String? countryId;
  String? cityId;
  String? title;
  String? desc;
  String? place;
  String? date;
  String? time;
  String? isPopular;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<Class>? classes;
  String? upcomingImage;
  List<CoverImage>? coverimages;
  int? like;
  int? comments;
  int? interests;

  Event(
      {required this.id,
      this.upcomingImage,
      required this.image,
      required this.popularImage,
      required this.categoryId,
      required this.subCategoryId,
      required this.organizerId,
      required this.countryId,
      required this.cityId,
      required this.title,
      required this.desc,
      required this.place,
      required this.date,
      required this.time,
      required this.isPopular,
      required this.createdAt,
      required this.updatedAt}) {
    getNumberofLikes(id!).then((value) => like = value);
    getNumberofComments(id!).then((value) => comments = value);
    getNumberofInterests(id!).then((value) => interests = value);
  }

  Future<int> getNumberofLikes(int id) async {
    int likes = 0;
    try {
      var res = await retryOptions.retry(
        () => http.get(Uri.parse("${baseUrlFunc}num-of-like/$id")),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var data = jsonDecode(res.body);
      if (data['message'] == 'Number of like get successfully') {
        likes = data['data'];
      } else {
        throw Exception('Unexpected message from API: ${data['message']}');
      }
    } finally {
      client.close();
    }
    return likes;
  }

  Future<int> getNumberofInterests(int id) async {
    int interests = 0;
    try {
      var res = await retryOptions.retry(
        () => http.get(Uri.parse("${baseUrlFunc}num-of-interested/$id")),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var data = jsonDecode(res.body);
      print('CHECKING DATA OF INTEREST: ${data}');
      if (data['message'] ==
          'Number of Interested customers get successfully') {
        interests = data['data'];
      } else {
        throw Exception('Unexpected message from API: ${data['message']}');
      }
    } finally {
      client.close();
    }
    return interests;
  }

  Future<int> getNumberofComments(int id) async {
    int comments = 0;
    try {
      var res = await retryOptions.retry(
        () => http.get(Uri.parse("${baseUrlFunc}num-of-coment/$id")),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var data = jsonDecode(res.body);
      if (data['message'] == 'Number of coment get successfully') {
        comments = data['data'];
      } else {
        throw Exception('Unexpected message from API: ${data['message']}');
      }
    } finally {
      client.close();
    }
    return comments;
  }

  Event.fromJson(Map<String, dynamic> json, String language) {
    id = json['id'];
    image = json['image'] != null
        ? baseUrl + json['image']
        : json['image'] != ""
            ? 'https://i.postimg.cc/9FkTYfDq/THICKET-MASTER-LOGO.jpg'
            : 'https://i.postimg.cc/9FkTYfDq/THICKET-MASTER-LOGO.jpg';
    popularImage = json['popular_image'] != null
        ? baseUrl + json['popular_image']
        : 'https://img.freepik.com/free-vector/employee-celebration-concept-illustration_114360-14531.jpg?w=900&t=st=1696951514~exp=1696952114~hmac=f103ab36b4bed1d38df9e097be19f2cc962d37467cc7fafcee237070c9df8c25';
    categoryId = json['category_id'] is String
        ? json['category_id']
        : '${json['category_id']}';
    subCategoryId = json['sub_category_id'] is String
        ? json['sub_category_id']
        : '${json['sub_category_id']}';
    organizerId = json['organizer_id'] is String
        ? json['organizer_id']
        : '${json['organizer_id']}';
    countryId = json['country_id'] is String
        ? json['country_id']
        : '${json['country_id']}';
    cityId = json['city_id'] is String ? json['city_id'] : '${json['city_id']}';

    String? languageCode = ThemeModeController.languageCode.value == 'es'
        ? 'tg'
        : ThemeModeController.languageCode.value == 'it'
            ? 'or'
            : ThemeModeController.languageCode.value == 'fr'
                ? 'so'
                : ThemeModeController.languageCode.value;

    title = json['title_$languageCode'];

    desc = json['desc_$languageCode'];

    place = json['place_$languageCode'];

    date = json['date'];
    time = json['time'];
    isPopular = json['is_popular'] is String
        ? json['is_popular']
        : '${json['is_popular']}';

    createdAt = DateTime.parse(json["created_at"]);
    updatedAt = DateTime.parse(json["updated_at"]);

    var classData = json["class"] != null ? json["class"] as List : [];
    classes = classData.map((data) => Class.fromJson(data, language)).toList();

    upcomingImage = json['upcoming_image'] != null
        ? baseUrl + json['upcoming_image']
        : json['upcoming_image'] != ""
            ? 'https://i.postimg.cc/9FkTYfDq/THICKET-MASTER-LOGO.jpg'
            : 'https://i.postimg.cc/9FkTYfDq/THICKET-MASTER-LOGO.jpg';

    var coverData =
        json["cover_image"] != null ? json["cover_image"] as List : [];
    coverimages =
        coverData.map((data) => CoverImage.fromJson(data, language)).toList();
  }
}

class OrderItem {
  DateTime? orderDate;
  String? image;
  String? foodName;
  int? foodId;
  String? price;
  String? rating;
  int? quantity;
  String? paymentType;
  String? paymentStatus;

  OrderItem(
      {this.orderDate,
      this.image,
      this.foodName,
      this.price,
      this.foodId,
      this.quantity,
      this.rating,
      this.paymentType,
      this.paymentStatus});

  OrderItem.fromJson(Map<String, dynamic> json) {
    orderDate = DateTime.parse(json['order_date']);
    foodId = json['food_id'] is String
        ? int.parse(json['food_id'])
        : json['food_id'];
    image = json['image'];
    quantity = json['quantity'] is String
        ? int.parse(json['quantity'])
        : json['quantity'];
    String? languageCode = ThemeModeController.languageCode.value == 'es'
        ? 'tg'
        : ThemeModeController.languageCode.value == 'it'
            ? 'or'
            : ThemeModeController.languageCode.value == 'fr'
                ? 'so'
                : ThemeModeController.languageCode.value;
    foodName = json['food_name_$languageCode'];
    price = json['price'];
    rating = json['rating'];
    paymentType = json['payment_type'];
    paymentStatus = json['payment_status'];
  }
}

class Order {
  int? id;
  String? className;
  String? image;
  String? organizationId;
  String? location;
  int? mealTypeId;
  String? eventDate;
  String? date;
  String? phone;
  int? totalFoods;
  int? status;
  int? statusNum;
  int? rating;
  double? price;
  bool? paymentStatus;
  int? paymentType;
  List<OrderItem>? orderItems; // ✅ new field

  Order(
      {this.id,
      this.phone,
      this.paymentStatus,
      this.status,
      this.rating,
      this.price,
      this.mealTypeId,
      this.statusNum,
      this.className,
      this.eventDate,
      this.image,
      this.organizationId,
      this.location,
      this.paymentType,
      this.date,
      this.totalFoods,
      this.orderItems});

  Order.fromJson(Map<String, dynamic> json, String language) {
    id = json['id'] is String ? int.parse(json['id']) : json['id'];
    phone = json['date'];
    mealTypeId = json['meal_type_id'] is String
        ? int.parse(json['meal_type_id'])
        : json['meal_type_id'];
    paymentType = json['payment_type'] is String
        ? int.parse(json['payment_type'])
        : json['payment_type'];
    statusNum =
        json['status'] is String ? int.parse(json['status']) : json['status'];
    status =
        json['status'] is String ? int.parse(json['status']) : json['status'];
    paymentStatus = json['payment_status'] == 1 || json['payment_status'] == "1"
        ? true
        : false;
    rating = json['total_quantity'] is String
        ? int.parse(json['total_quantity'])
        : json['total_quantity'];
    price = json['total_price'] is String
        ? double.parse(json['total_price'])
        : json['total_price'];
    // String? languageCode = ThemeModeController.languageCode.value == 'es'
    //     ? 'tg'
    //     : ThemeModeController.languageCode.value == 'it'
    //         ? 'or'
    //         : ThemeModeController.languageCode.value == 'fr'
    //             ? 'so'
    //             : ThemeModeController.languageCode.value;
    className = '${'order_num'.tr}: ${json['id']}';
    date = json['date'];
    location = json['location'];
    totalFoods = json['total_food'] is String
        ? int.parse(json['total_food'])
        : json['total_food'];
    eventDate = json['date'];
    image = json.containsKey('image') ? json['image'] : '';
    organizationId = json['organization_id'];
  }
}

class MealType {
  int? id;
  String? name;

  MealType({this.id, this.name});

  MealType.fromJson(Map<String, dynamic> json) {
    String? languageCode = ThemeModeController.languageCode.value == 'es'
        ? 'tg'
        : ThemeModeController.languageCode.value == 'it'
            ? 'or'
            : ThemeModeController.languageCode.value == 'fr'
                ? 'so'
                : ThemeModeController.languageCode.value;

    id = json['id'];
    name = json['name_$languageCode'];
  }
}

//(
// status=0 : Ordered
// status=1 : Accepted
// status:2 preparing
// status=3: Driver On the Way
// status=4:Delivered
// status=5: Rejected
// )

String statusConverter(int status) {
  String statusString = '';
  switch (status) {
    case 0:
      statusString = "ordered".tr;
      break;
    case 1:
      statusString = "accepted".tr;
      break;
    case 2:
      statusString = "preparing".tr;
      break;
    case 3:
      statusString = "driver_on_the_way".tr;
      break;
    case 4:
      statusString = "delivered".tr;
      break;
    case 5:
      statusString = "rejected".tr;
      break;
    default:
      statusString = "invalid_status".tr;
      break;
  }
  return statusString;
}

class Category {
  int? id;
  String? image;
  String? name;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<Food>? foods;

  Category(
      {this.id,
      this.image,
      this.name,
      this.createdAt,
      this.updatedAt,
      this.foods});

  static Category get sampleCat => Category(foods: [
        Food(
          id: 0,
          image: "asdasdadadadada",
          categoryId: 0,
          name: "ofasodfbasf",
          desc: "cacacacaca",
          status: 0,
          price: 1000,
          rating: 4.0,
          discountPercentage: 0,
          isDiscounted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )
      ]);

  Category.fromJson(Map<String, dynamic> json, String language) {
    id = json["id"];
    image = baseUrl + json["image"];
    String? languageCode = ThemeModeController.languageCode.value == 'es'
        ? 'tg'
        : ThemeModeController.languageCode.value == 'it'
            ? 'or'
            : ThemeModeController.languageCode.value == 'fr'
                ? 'so'
                : ThemeModeController.languageCode.value;

    name = json['name_$languageCode'];
    createdAt = DateTime.parse(json["created_at"]);
    updatedAt = DateTime.parse(json["updated_at"]);

    var foodsD = json["event_list"] as List;
    foods = foodsD.map((data) => Food.fromJson(data)).toList();
  }
}

class FoodPortions {
  int? id;
  String? image;
  int? foodId;
  String? name;
  String? desc;
  num? price;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? amount = 1;
  bool? isSelected = false;

  final Map<String, dynamic> _descriptions = {};
  final Map<String, dynamic> _name = {};

  FoodPortions(
      {required this.id,
      required this.image,
      required this.foodId,
      required this.name,
      required this.desc,
      required this.price,
      required this.createdAt,
      required this.updatedAt});

  FoodPortions.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    image = json["cover_image"];
    foodId = json["food_id"];
    String? languageCode = ThemeModeController.languageCode.value == 'es'
        ? 'tg'
        : ThemeModeController.languageCode.value == 'it'
            ? 'or'
            : ThemeModeController.languageCode.value == 'fr'
                ? 'so'
                : ThemeModeController.languageCode.value;

    for (var lang in ['tg', 'or', 'so', 'en', 'am']) {
      _descriptions['description_$lang'] = json['description_$lang'];
      _name['name_$lang'] = json['name_$lang'];
    }

    name = json['name_$languageCode'];
    desc = json['description_$languageCode'];
    price = json["price"] is String ? num.parse(json['price']) : json['price'];
    createdAt = DateTime.parse(json["created_at"]);
    updatedAt = DateTime.parse(json["updated_at"]);
    amount = json.containsKey('amount') ? json['amount'] : 1;
    isSelected = json.containsKey('isSelected') ? json['isSelected'] : false;
  }

  String totalPrice() {
    double totalPrice = 0.00;

    // if (addons != null) {
    //   for (var addon in addons!) {
    //     totalPrice +=
    //     ((addon.price ?? 0).toDouble() * (addon.amount ?? 1).toDouble());
    //   }
    // }
    return ((totalPrice + price!) * (amount ?? 1)).toStringAsFixed(2);
  }

  Map<String, dynamic> toJson() {
    var jsonified = {
      'id': id,
      'food_id': foodId,
      ..._name,
      ..._descriptions,
      'cover_image': image,
      'price': price,
      'amount': amount,
      'isSelected': isSelected,
      'created_at': createdAt.toString(),
      'updated_at': updatedAt.toString()
    };
    Logger().f(jsonified);
    return jsonified;
  }
}

class Food {
  num? id;
  String? image;
  num? categoryId;
  String? name;
  String? desc;
  num? price;
  num? amount = 1;
  bool? isDiscounted;
  num? rating;
  num? discountPercentage;
  bool? isSelected = false;
  DateTime? createdAt;
  DateTime? updatedAt;
  num? status;

  final Map<String, dynamic> _descriptions = {};
  final Map<String, dynamic> _name = {};
  Food(
      {this.id,
      this.image,
      this.categoryId,
      this.name,
      this.desc,
      this.status,
      this.price,
      this.rating,
      this.discountPercentage,
      this.isDiscounted,
      this.createdAt,
      this.updatedAt});
  Map<String, dynamic> toJson() {
    var jsonified = {
      'id': id,
      'food_id': id,
      ..._name,
      ..._descriptions,
      'cover_image': image,
      'price': price,
      'rating': '$rating',
      'status': '$status',
      'discount_percent': discountPercentage,
      'is_discount': isDiscounted,
      'category_id': categoryId,
      'amount': amount,
      'isSelected': isSelected,
      'created_at': createdAt.toString(),
      'updated_at': updatedAt.toString()
    };
    return jsonified;
  }

  Food.fromJson(
    Map<String, dynamic> json,
  ) {
    id = json["id"];
    image = json["cover_image"];
    amount = json.containsKey('amount')
        ? json['amount'] is String
            ? num.parse(json['amount'])
            : json['amount']
        : 1;
    // Logger().d(
    //     'Rating: ${json['rating']}, ID: ${json['id']}, Name: ${json['name_en']}');
    rating = json.containsKey('rating') && (json['rating'] != null)
        ? json['rating'] is String
            ? json['rating'] == ''
                ? 3.5
                : num.parse(json['rating'])
            : json['rating']
        : 3.5;
    status = json.containsKey('status')
        ? json['status'] is String
            ? num.parse(json['status'])
            : json['status']
        : 0;
    createdAt = DateTime.parse(json["created_at"]);
    updatedAt = DateTime.parse(json["updated_at"]);
    isSelected = json.containsKey('isSelected') ? json['isSelected'] : false;
    // Logger().d(json['price']);
    price = json.containsKey('price')
        ? json['price'] is String
            ? num.parse((json['price']).toString().replaceAll(',', ''))
            : json['price']
        : 0.00;
    isDiscounted = json.containsKey('is_discount')
        ? json['is_discount'] == 1 || json['is_discount'] == '1'
        : false;
    discountPercentage = json.containsKey('discount_percent')
        ? json['discount_percent'] is String
            ? num.parse(json['discount_percent'])
            : json['discount_percent']
        : 0;
    categoryId = json["category_id"] is String
        ? num.parse(json["category_id"])
        : json["category_id"];
    String? languageCode = ThemeModeController.languageCode.value == 'es'
        ? 'tg'
        : ThemeModeController.languageCode.value == 'it'
            ? 'or'
            : ThemeModeController.languageCode.value == 'fr'
                ? 'so'
                : ThemeModeController.languageCode.value;
    for (var lang in ['tg', 'or', 'so', 'en', 'am']) {
      _descriptions['description_$lang'] = json['description_$lang'];
      _name['name_$lang'] = json['name_$lang'];
    }

    name = json['name_$languageCode'];
    desc = json['description_$languageCode'];
  }

  String totalPrice() {
    double totalPrice = 0.00;

    // if (addons != null) {
    //   for (var addon in addons!) {
    //     totalPrice +=
    //     ((addon.price ?? 0).toDouble() * (addon.amount ?? 1).toDouble());
    //   }
    // }
    return ((totalPrice + price!) * (amount ?? 1)).toStringAsFixed(2);
  }
}

class Organizer {
  int? id;
  String? image;
  String? name;
  String? desc;
  DateTime? createdAt;
  DateTime? updatedAt;

  Organizer(
      {required this.id,
      required this.image,
      required this.name,
      required this.desc,
      required this.createdAt,
      required this.updatedAt});

  Organizer.fromJson(Map<String, dynamic> json, String language) {
    id = json['id'];
    image = baseUrl + json['image'];
    String? languageCode = ThemeModeController.languageCode.value == 'es'
        ? 'tg'
        : ThemeModeController.languageCode.value == 'it'
            ? 'or'
            : ThemeModeController.languageCode.value == 'fr'
                ? 'so'
                : ThemeModeController.languageCode.value;

    name = json['name_$languageCode'];

    desc = json['desc_$languageCode'];
    createdAt = DateTime.parse(json['created_at']);
    updatedAt = DateTime.parse(json['updated_at']);
  }
}

class Signup {
  String? firstName,
      lastName,
      email,
      phoneNumber,
      password,
      confirmPassword,
      promoCode,
      cityid,
      language;
  Signup({
    required this.confirmPassword,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.promoCode,
    required this.firstName,
    required this.lastName,
    required this.cityid,
    required this.language,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['password_confirmation'] = confirmPassword;
    data['email'] = email;
    data['password'] = password;
    data['phone'] = phoneNumber;
    data['city_id'] = cityid;
    data['lang'] = language;
    if (promoCode != null) {
      data['promocode'] = promoCode;
    }
    return data;
  }
}

class SignupResponse {
  String? message;
  dynamic data;
  ErrorDataS? error;

  SignupResponse({this.message, this.error});

  SignupResponse.fromJson(Map<String, dynamic> json) {
    message = json.containsKey('message') ? json['message'] : null;
    data = json.containsKey('data') ? json['data'] : null;
    error =
        json.containsKey('error') ? ErrorDataS.fromJson(json['error']) : null;
  }
}

class ErrorDataS {
  List<String>? email;
  List<String>? phonenumber;
  List<String>? name;
  List<String>? password;

  ErrorDataS(
      {required this.email,
      required this.phonenumber,
      required this.name,
      required this.password});

  ErrorDataS.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('email')) {
      email = List<String>.from(json['email']);
    }
    if (json.containsKey('phone')) {
      phonenumber = List<String>.from(json['phone']);
    }
    if (json.containsKey('name')) {
      name = List<String>.from(json['name']);
    }
    if (json.containsKey('password')) {
      password = List<String>.from(json['password']);
    }
  }
}

class Booking {
  int? userId, foodId, foodOrderId;
  String? date;
  String? amount;
  String? paymentStatus, transaction;

  Booking(
      {required this.userId,
      required this.amount,
      required this.foodId,
      required this.foodOrderId,
      required this.paymentStatus,
      required this.transaction,
      required this.date});

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'food_id': '0',
        'food_order_id': foodOrderId,
        'payment_status': paymentStatus,
        'transaction': transaction,
        'amount': amount,
        'date': date
      };
}

class PromotionalImages {
  int? id;
  String? image;
  int? foodId;

  PromotionalImages(
      {required this.id, required this.image, required this.foodId});

  PromotionalImages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    foodId = json['food_id'] is String
        ? int.parse(json['food_id'])
        : json['food_id'];
  }
}

class BookingResponse {
  Map<String, dynamic>? error;
  String? message;
  BookingResponse({this.error, this.message});
  BookingResponse.formJson(Map<String, dynamic> json) {
    if (json.containsKey('error')) {
      error = json['error'];
    }
    if (json.containsKey('message')) {
      message = json['message'];
    }
    // Parse your response here
  }
}
// import 'package:get/get.dart';

class VideoPromotion {
  final int id;
  // final num type;
  // final int companyId;
  final String url;
  final String description;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;

  VideoPromotion({
    required this.createdAt,
    required this.updatedAt,
    // required this.type,
    required this.title,
    required this.id,
    // required this.companyId,
    required this.url,
    required this.description,
  });

  factory VideoPromotion.fromJson(Map<String, dynamic> json) {
    String? languageCode = Get.locale?.languageCode == 'es'
        ? 'tg'
        : Get.locale?.languageCode == 'it'
            ? 'or'
            : Get.locale?.languageCode == 'fr'
                ? 'so'
                : Get.locale?.languageCode;
    return VideoPromotion(
        // type: json.containsKey('type')
        //     ? json['type'] != null
        //         ? json['type'] is num
        //             ? json['type']
        //             : json['type'] is String
        //                 ? num.parse(json['type'])
        //                 : 0
        //         : 0
        //     : 0,
        title: json['title_$languageCode'] ?? '',
        id: json['id'],
        // companyId: json['company_id'] ?? 0,
        url: json['attachment'],
        description: json['description_$languageCode'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']));
  }
}

class Login {
  String? phoneNumber, password;
  Login({required this.password, required this.phoneNumber});
}

class LoginResponse {
  LoginData? responseData;
  String? token, error;

  LoginResponse(
      {required this.responseData, required this.token, required this.error});

  LoginResponse.formJson(Map<String, dynamic> json) {
    if (json.containsKey('token')) {
      token = json['token'];
    }
    if (json.containsKey('data')) {
      responseData = LoginData.fromJson(json['data']);
    }
    if (json.containsKey('error')) {
      error = json['error'];
    }
  }
}

class LoginData {
  int? id;
  String? profileImage;
  String? firstName;
  String? lastName;
  String? phone;
  String? cityId;
  String? email;
  String? emailVerifiedAt;
  String? roleId;
  String? lang;
  String? darkMode;
  String? promocode;
  String? token;
  String? loyaltyPoints;
  String? createdAt;
  String? updatedAt;
  String? password;
  num? status;

  LoginData({
    this.id,
    this.profileImage,
    this.firstName,
    this.lastName,
    this.phone,
    this.cityId,
    this.email,
    this.emailVerifiedAt,
    this.roleId,
    this.lang,
    this.darkMode,
    this.promocode,
    this.token,
    this.loyaltyPoints,
    this.createdAt,
    this.updatedAt,
    this.password,
    this.status,
  });

  LoginData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    profileImage = json['profile_image'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    phone = json['phone'];
    cityId = json['city_id'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    roleId = json['role_id'];
    lang = json['lang'];
    darkMode = '${json['dark_mode']}';
    promocode = json['promocode'];
    token = json['token'];
    loyaltyPoints = '${json['loyality_point']}';
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    status =
        json['status'] is String ? num.parse(json['status']) : json['status'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_image': profileImage,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'city_id': cityId,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'role_id': roleId,
      'lang': lang,
      'dark_mode': darkMode,
      'promocode': promocode,
      'token': token,
      'loyality_point': loyaltyPoints,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'status': status
    };
  }

  LoginData copyWith({
    int? id,
    String? profileImage,
    String? firstName,
    String? lastName,
    String? phone,
    String? cityId,
    String? email,
    String? emailVerifiedAt,
    String? roleId,
    String? lang,
    String? darkMode,
    String? promocode,
    String? token,
    String? createdAt,
    String? updatedAt,
    String? password,
  }) {
    return LoginData(
      id: id ?? this.id,
      profileImage: profileImage ?? this.profileImage,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      cityId: cityId ?? this.cityId,
      email: email ?? this.email,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      roleId: roleId ?? this.roleId,
      lang: lang ?? this.lang,
      darkMode: darkMode ?? this.darkMode,
      promocode: promocode ?? this.promocode,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      password: password ?? this.password,
    );
  }
}

class City {
  int? id;
  String? countryID;
  String? name;
  DateTime? createdAt;
  DateTime? updatedAt;

  City(
      {required this.id,
      required this.countryID,
      required this.name,
      required this.createdAt,
      required this.updatedAt});

  City.fromJson(Map<String, dynamic> json, String language) {
    id = json['id'];
    countryID = json['country_id'];
    String? languageCode = ThemeModeController.languageCode.value == 'es'
        ? 'tg'
        : ThemeModeController.languageCode.value == 'it'
            ? 'or'
            : ThemeModeController.languageCode.value == 'fr'
                ? 'so'
                : ThemeModeController.languageCode.value;

    name = json['name_$languageCode'];
    createdAt = json["created_at"] != null
        ? DateTime.parse(json["created_at"])
        : DateTime.parse("-000001-11-30T00:00:00.000000Z");
    updatedAt = DateTime.parse(json["updated_at"]);
  }
}

class UpdatedUser {
  int? id;
  String? firstName, lastName, phone, email, language;

  UpdatedUser(
      {required this.firstName,
      required this.lastName,
      required this.phone,
      required this.email,
      required this.id,
      this.language});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'lang': language
    };
  }
}

class UpdatedUserResponse {
  String? message;
  UpdateError? error;

  UpdatedUserResponse({required this.message, required this.error});

  UpdatedUserResponse.fromJson(Map<String, dynamic> json) {
    message = json.containsKey('message') ? json['message'] : null;
    error =
        json.containsKey('error') ? UpdateError.fromJson(json['error']) : null;
  }
}

class UpdateError {
  List<String>? firstName;
  List<String>? LastName;
  List<String>? phone;
  List<String>? email;

  UpdateError({this.phone, this.firstName, this.LastName});

  UpdateError.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('first_name')) {
      firstName = List<String>.from(json['first_name']);
    }
    if (json.containsKey('phone')) {
      phone = List<String>.from(json['phone']);
    }
    if (json.containsKey('last_name')) {
      phone = List<String>.from(json['last_name']);
    }
    if (json.containsKey('email')) {
      phone = List<String>.from(json['email']);
    }
  }
}

class LikeEvent {
  final int? eventId;
  final int? userId;

  LikeEvent({required this.eventId, required this.userId});

  Map<String, dynamic> toJson() => {
        'event_id': eventId,
        'user_id': userId,
      };
}

class LikeEventResponse {
  Map<String, dynamic>? error;
  String? message;

  LikeEventResponse({this.error, this.message});

  LikeEventResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('error')) {
      error = json['error'];
    }
    if (json.containsKey('message')) {
      message = json['message'];
    }
  }
}

class DisLikeEvent {
  final int? eventId;
  final int? userId;

  DisLikeEvent({required this.eventId, required this.userId});

  Map<String, dynamic> toJson() => {
        'event_id': eventId,
        'user_id': userId,
      };
}

class DisLikeEventResponse {
  Map<String, dynamic>? error;
  Map<String, dynamic>? message;

  DisLikeEventResponse({this.error, this.message});

  DisLikeEventResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('error')) {
      error = json['error'];
    } else {
      message = json;
    }
  }
}

class Comment {
  String? firstName;
  String? lastName;
  String? comment;

  Comment({this.firstName, this.lastName, this.comment});

  Comment.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
    comment = json['coment'];
  }
}

class CommentResponse {
  Map<String, dynamic>? error;
  Map<String, dynamic>? message;

  CommentResponse({this.error, this.message});

  CommentResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('error')) {
      error = json['error'];
    } else {
      message = json;
    }
  }
}

class InterestEvent {
  final int? eventId;
  final int? userId;

  InterestEvent({required this.eventId, required this.userId});

  Map<String, dynamic> toJson() => {
        'event_id': eventId,
        'user_id': userId,
      };
}

class InterestEventResponse {
  Map<String, dynamic>? error;
  String? message;

  InterestEventResponse({this.error, this.message});

  InterestEventResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('error')) {
      error = json['error'];
    }
    if (json.containsKey('message')) {
      message = json['message'];
    }
  }
}

class DisInterestEvent {
  final int? eventId;
  final int? userId;

  DisInterestEvent({required this.eventId, required this.userId});

  Map<String, dynamic> toJson() => {
        'event_id': eventId,
        'user_id': userId,
      };
}

class DisInterestEventResponse {
  Map<String, dynamic>? error;
  Map<String, dynamic>? message;

  DisInterestEventResponse({this.error, this.message});

  DisInterestEventResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('error')) {
      error = json['error'];
    } else {
      message = json;
    }
  }
}
