


import '../constants/app_constants.dart';

class Class {
  int? id;
  String? eventId;
  String? title;
  int? availableTicket;
  int? price;

  Class({
    this.id,
    this.eventId,
    this.title,
    this.availableTicket,
    this.price
  });

  Class.fromJson(Map<String, dynamic> json, String language) {
    id= json['id'];
    eventId= json['event_id'];
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
      default:
        throw Exception('Invalid language: $language');
    }
    availableTicket= int.parse(json['available_ticket']);
    price= int.parse(json['price']);
  }
}


class CoverImage {
  int? id;
  String? coverimage;
  int? categoryId;
  int? subcategoryId;
  int? organizerId;
  int? eventId;
  DateTime? createdat;
  DateTime? updatedat;

  CoverImage(
      { this.id,
        this.coverimage,
        required this.categoryId,
        required this.subcategoryId,
        this.organizerId});

  CoverImage.fromJson(Map<String, dynamic> json, String language) {
    id = json["id"];
    coverimage = baseUrl + json["cover_image"];
    categoryId = json["category_id"]!=null?int.parse(json["category_id"]):0;
    subcategoryId = json["sub_category_id"]!=null?int.parse(json["sub_category_id"]):0;
    organizerId = json["organizer_id"]!=null?int.parse(json["organizer_id"]):0;
    eventId = json["event_id"]!=null?int.parse(json["event_id"]):0;
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
        required this.updatedAt});

  Event.fromJson(Map<String, dynamic> json, String language) {
    id = json['id'];
    image = json['image'] != null? baseUrl + json['image']: json['image'] != "" ?'https://i.postimg.cc/VkBQ3FS6/na-logo.png': 'https://i.postimg.cc/VkBQ3FS6/na-logo.png' ;
    popularImage = json['popular_image'] != null? baseUrl + json['popular_image']: 'https://img.freepik.com/free-vector/employee-celebration-concept-illustration_114360-14531.jpg?w=900&t=st=1696951514~exp=1696952114~hmac=f103ab36b4bed1d38df9e097be19f2cc962d37467cc7fafcee237070c9df8c25';
    categoryId = json['category_id'];
    subCategoryId = json['sub_category_id'];
    organizerId = json['organizer_id'];
    countryId = json['country_id'];
    cityId = json['city_id'];
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
      default:
        throw Exception('Invalid language: $language');
    }
    switch (language) {
      case 'am':
        desc = json['desc_am'];
        break;
      case 'en':
        desc = json['desc_en'];
        break;
      case 'en-AU':
        desc = json['desc_or'];
        break;
      default:
        throw Exception('Invalid language: $language');
    }
    switch (language) {
      case 'am':
        place = json['place_am'];
        break;
      case 'en':
        place = json['place_en'];
        break;
      case 'en-AU':
        place = json['place_or'];
        break;
      default:
        throw Exception('Invalid language: $language');
    }
    date = json['date'];
    time = json['time'];
    isPopular = json['is_popular'];
    createdAt = json["created_at"]!=null?  DateTime.parse(json["created_at"]): DateTime.parse("-000001-11-30T00:00:00.000000Z");
    updatedAt = DateTime.parse(json["updated_at"]);
    var classData = json["class"] != null? json["class"] as List: [];
    classes = classData.map((data) => Class.fromJson(data, language)).toList();
    upcomingImage = json['upcoming_image'] != null? baseUrl + json['upcoming_image']: json['upcoming_image'] != "" ?'https://i.postimg.cc/VkBQ3FS6/na-logo.png': 'https://i.postimg.cc/VkBQ3FS6/na-logo.png' ;
    var coverData = json["cover_image"] != null? json["cover_image"] as List: [];
    coverimages = coverData.map((data) => CoverImage.fromJson(data, language)).toList();
  }
}

class Ticket {
  String? className;
  String? eventImage;
  String? eventName;
  String? eventPlace;
  String? eventDate;
  String? eventTime;
  String? phone;
  String? ticket_number;
  String? price;

  Ticket({
    this.phone,
    this.price,
    this.className,
    this.eventDate,
    this.eventImage,
    this.eventName,
    this.eventPlace,
    this.eventTime,
    this.ticket_number
  });

  Ticket.fromJson(Map<String, dynamic> json, String language){
    phone = json['phone'];
    price = json['price'];
    switch (language) {
      case 'am':
        className = json['class_name_am']??" ";
        break;
      case 'en':
        className = json['class_name_en']??" ";
        break;
      case 'en-AU':
        className = json['class_name_or']??" ";
        break;
      default:
        throw Exception('Invalid language: $language');
    }
    eventTime = json['event_time'];
    switch (language) {
      case 'am':
        eventPlace = json['event_place_am']??" ";
        break;
      case 'en':
        eventPlace = json['event_place_en']??" ";
        break;
      case 'en-AU':
        eventPlace = json['event_place_or']??" ";
        break;
      default:
        throw Exception('Invalid language: $language');
    }
    ticket_number = json['ticket_number'];
    eventDate = json['event_date'];
    eventImage = json['event_image']!=null?baseUrl+json['event_image']:" ";
    switch (language) {
      case 'am':
        eventName = json['event_name_am']??" ";
        break;
      case 'en':
        eventName = json['event_name_en']??" ";
        break;
      case 'en-AU':
        eventName = json['event_name_or']??" ";
        break;
      default:
        throw Exception('Invalid language: $language');
    }
  }
}

class Category {
  int? id;
  String? image;
  String? name;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<SubCategory>? subCategory;

  Category(
      {required this.id,
        required this.image,
        required this.name,
        required this.createdAt,
        required this.updatedAt,
        required this.subCategory});

  Category.fromJson(Map<String, dynamic> json, String language) {
    id = json["id"];
    image = baseUrl + json["image"];
    switch (language) {
      case 'am':
        name = json['name_am'];
        break;
      case 'en':
        name = json['name_en'];
        break;
      case 'en-AU':
        name = json['name_or'];
        break;
      default:
        throw Exception('Invalid language: $language');
    }
    createdAt = DateTime.parse(json["created_at"]);
    updatedAt = DateTime.parse(json["updated_at"]);

    var subCategoriesData = json["sub_category"] as List;
    subCategory = subCategoriesData.map((data) => SubCategory.fromJson(data, language)).toList();
  }
}

class SubCategory {
  int? id;
  String? image;
  int? categoryId;
  String? name;
  String? desc;

  SubCategory(
      {required this.id,
        required this.image,
        required this.categoryId,
        required this.name,
        this.desc});

  SubCategory.fromJson(Map<String, dynamic> json, String language) {
    id = json["id"];
    image = baseUrl + json["image"];
    categoryId = int.parse(json["category_id"]);
    switch (language) {
      case 'am':
        name = json['name_am'];
        break;
      case 'en':
        name = json['name_en'];
        break;
      case 'en-AU':
        name = json['name_or'];
        break;
      default:
        throw Exception('Invalid language: $language');
    }
    switch (language) {
      case 'am':
        desc = json['desc_am'];
        break;
      case 'en':
        desc = json['desc_en'];
        break;
      case 'en-AU':
        desc = json['desc_or'];
        break;
      default:
        desc = '0';
    }
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
    id=json['id'];
    image=baseUrl+json['image'];
    switch (language) {
      case 'am':
        name = json['name_am'];
        break;
      case 'en':
        name = json['name_en'];
        break;
      case 'en-AU':
        name = json['name_or'];
        break;
      default:
        throw Exception('Invalid language: $language');
    }
    switch (language) {
      case 'am':
        desc = json['desc_am'];
        break;
      case 'en':
        desc = json['desc_en'];
        break;
      case 'en-AU':
        desc = json['desc_or'];
        break;
      default:
        desc = '0';
    }
    createdAt=DateTime.parse(json['created_at']);
    updatedAt=DateTime.parse(json['updated_at']);
  }
}


class Signup {
  String? firstName, lastName, email, phoneNumber, password, confirmPassword, promoCode, cityid;
  Signup(
      {required this.confirmPassword,
        required this.email,
        required this.password,
        required this.phoneNumber,
        required this.promoCode, required this.firstName, required this.lastName, required this.cityid});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['password_confirmation'] = confirmPassword;
    data['email'] = email;
    data['password'] = password;
    data['phone'] = phoneNumber;
    data['city_id'] = cityid;
    if (promoCode != null) {
      data['promocode'] = promoCode;
    }
    return data;
  }
}

class SignupResponse {
  String? message;
  ErrorData? error;

  SignupResponse({this.message, this.error});

  SignupResponse.fromJson(Map<String, dynamic> json) {
    message = json.containsKey('message') ? json['message'] : null;
    error =
    json.containsKey('error') ? ErrorData.fromJson(json['error']) : null;
  }
}

class ErrorData {
  List<String>? email;
  List<String>? phonenumber;
  List<String>? name;
  List<String>? password;

  ErrorData(
      {required this.email,
        required this.phonenumber,
        required this.name,
        required this.password});

  ErrorData.fromJson(Map<String, dynamic> json) {
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
  int? customerId, eventId, classId, price;
  String? phone, ticketNumber;

  Booking({
    required this.customerId,
    required this.eventId,
    required this.classId,
    required this.phone,
    required this.ticketNumber,
    required this.price
  });

  Map<String, dynamic> toJson() => {
    'customer_id': customerId,
    'event_id': eventId,
    'class_id': classId,
    'phone': phone,
    'ticket_number': ticketNumber,
    'price': price
  };
}

class BookingResponse {
  Map<String, dynamic>? error;
  String? message;
  BookingResponse({
    this.error,
    this.message
  });
  BookingResponse.formJson(Map<String, dynamic> json) {
    if(json.containsKey('error')){error = json['error'];}
    if(json.containsKey('message')){message = json['message'];}
    // Parse your response here
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
  String? createdAt;
  String? updatedAt;
  String? password;

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
    this.createdAt,
    this.updatedAt,
    this.password
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
    darkMode = json['dark_mode'];
    promocode = json['promocode'];
    token = json['token'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
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
      'created_at': createdAt,
      'updated_at': updatedAt
    };
  }
}
class City {
  int? id;
  String? countryID;
  String? name;
  DateTime? createdAt;
  DateTime? updatedAt;

  City({
    required this.id,
    required this.countryID,
    required this.name,
    required this.createdAt,
    required this.updatedAt
  });

  City.fromJson(Map<String, dynamic> json, String language) {
    id= json['id'];
    countryID= json['country_id'];
    switch (language) {
      case 'am':
        name = json['name_am'];
        break;
      case 'en':
        name = json['name_en'];
        break;
      case 'en-AU':
        name = json['name_or'];
        break;
      default:
        throw Exception('Invalid language: $language');
    }
    createdAt = json["created_at"]!=null?  DateTime.parse(json["created_at"]): DateTime.parse("-000001-11-30T00:00:00.000000Z");
    updatedAt = DateTime.parse(json["updated_at"]);
  }
}

class UpdatedUser {
  String? firstName, lastName, phone;

  UpdatedUser({required this.firstName, required this.lastName, required this.phone});

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
    };
  }
}

class UpdatedUserResponse {
  String? message;
  UpdateError? error;

  UpdatedUserResponse({required this.message, required this.error});

  UpdatedUserResponse.fromJson(Map<String, dynamic> json) {
    message = json.containsKey('message') ? json['message'] : null;
    error = json.containsKey('error') ? UpdateError.fromJson(json['error']) : null;
  }
}


class UpdateError {
  List<String>? firstName;
  List<String>? LastName;
  List<String>? phone;

  UpdateError(
      {this.phone, this.firstName, this.LastName});

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

  }
}