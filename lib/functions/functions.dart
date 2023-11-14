import 'dart:async';
import 'dart:io';
import 'package:retry/retry.dart';
import 'package:ticketmaster_et/models/newmodels.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/faq.dart';
import '../models/privacy_policy.dart';
import '../models/review.dart';
import '../models/terms_and_conditions.dart';

final client = http.Client();
final retryOptions = RetryOptions(
    maxDelay: Duration(milliseconds: 300),
    delayFactor: Duration(seconds: 0),
    maxAttempts: 100000);
Future<List<Event>> getEvents(String apiUrl, String language) async {
  List<Event> events = [];

  try {
    var res = await retryOptions.retry(
          () => http.get(Uri.parse(apiUrl)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );

    var data = jsonDecode(res.body);
    if (data['message'] == 'Event get successfully'||data['message'] == 'Upcoming Event get successfully') {
      var eventsData = data['data'] as List;
      events = eventsData.map((eventData) => Event.fromJson(eventData, language)).toList();
    } else {
      throw Exception('Unexpected message from API: ${data['message']}');
    }
  } finally {
    client.close();
  }

  return events;
}

Future<List<Event>> getEventsbyID(int id, String language) async {
  List<Event> events = [];

  try {
    var res = await retryOptions.retry(
          () => http.get(Uri.parse("https://api.ticketmaster-et.com/api/event-detail/$id")),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );

    // print("=================Event============${res.body}");
    var data = jsonDecode(res.body);
    if (data['message'] == 'Event detail get successfully') {
      var eventsData = data['data'] as List;
      events = eventsData.map((eventData) => Event.fromJson(eventData, language)).toList();
    } else {
      throw Exception('Unexpected message from API: ${data['message']}');
    }
  } finally {
    client.close();
  }

  return events;
}

Future<List<CoverImage>> getCoverImagesbySubCatID(int id, String language) async {
  List<CoverImage> coverimages = [];

  try {
    var res = await retryOptions.retry(
          () => http.get(Uri.parse("https://api.ticketmaster-et.com/api/cover-image-by-sub-category/$id")),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );

    var data = jsonDecode(res.body);
    if (data['message'] == 'Cover image By selected Sub category get successfully') {
      var eventsData = data['data'] as List;
      coverimages = eventsData.map((eventData) => CoverImage.fromJson(eventData, language)).toList();
    } else {
      throw Exception('Unexpected message from API: ${data['message']}');
    }
  } finally {
    client.close();
  }

  return coverimages;
}


Future<List<CoverImage>> getCoverImagesbyEventID(int id, String language) async {
  List<CoverImage> coverimages = [];

  try {
    var res = await retryOptions.retry(
          () => http.get(Uri.parse("https://api.ticketmaster-et.com/api/cover-image-by-event/$id")),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );

    var data = jsonDecode(res.body);
    if (data['message'] == 'Cover image By selected Event get successfully') {
      var eventsData = data['data'] as List;
      coverimages = eventsData.map((eventData) => CoverImage.fromJson(eventData, language)).toList();
    } else {
      throw Exception('Unexpected message from API: ${data['message']}');
    }
  } finally {
    client.close();
  }

  return coverimages;
}



Future<List<CoverImage>> getCoverImagesbyOrganizerID(int id, String language) async {
  List<CoverImage> coverimages = [];

  try {
    var res = await retryOptions.retry(
          () => http.get(Uri.parse("https://api.ticketmaster-et.com/api/cover-image-by-organizer/$id")),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );

    var data = jsonDecode(res.body);
    if (data['message'] == 'Cover image By selected Organizer get successfully') {
      var eventsData = data['data'] as List;
      coverimages = eventsData.map((eventData) => CoverImage.fromJson(eventData, language)).toList();
    } else {
      throw Exception('Unexpected message from API: ${data['message']}');
    }
  } finally {
    client.close();
  }

  return coverimages;
}

Future<List<Category>> getCategorySubCategory(String language) async {
  List<Category> categories = [];

  try {
    var res = await retryOptions.retry(
          () => http.get(Uri.parse("https://api.ticketmaster-et.com/api/category-sub-category")),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    print("res.statusCode  == = == = = = == = = = ${res.statusCode}");
  //  print("=================Category============${res.body}");
     // print(res.body);
    var data = jsonDecode(res.body);
    if (data['message'] == 'Event By category get successfully') {
      var categoriesData = data['data'] as List;
      categories = categoriesData.map((categoryData) => Category.fromJson(categoryData, language)).toList();
    } else {
      throw Exception('Unexpected message from API: ${data['message']}');
    }
  } finally {
    client.close();
  }

  return categories;
}

Future<List<Organizer>> getOrganizers(String language) async {
  List<Organizer> organizers = [];

  try {
    var res = await retryOptions.retry(
          () => http.get(Uri.parse("https://api.ticketmaster-et.com/api/organizer")),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    //  print("=================ORGANIZER============${res.body}");
    var data = jsonDecode(res.body);
    if (data['message'] == 'organizer get successfully') {
      var organizersData = data['data'] as List;
      organizers = organizersData.map((organizerData) => Organizer.fromJson(organizerData, language)).toList();
    } else {
      throw Exception('Unexpected message from API: ${data['message']}');
    }
  } finally {
    client.close();
  }

  return organizers;
}

Future<List<Event>> getEventsBySubCategoryId(int id, String language) async {
  List<Event> events = [];

  try {
    var res = await retryOptions.retry(
          () => http.get(Uri.parse("https://api.ticketmaster-et.com/api/event-by-sub-category/$id")),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );

    //  print("=================getEventsBySubCategoryId============${res.body}");
    var data = jsonDecode(res.body);
    if (data['message'] == 'Event By selected Sub category get successfully') {
      var eventsData = data['data'] as List;
      // print(eventsData);
      events = eventsData.map((eventData) => Event.fromJson(eventData, language)).toList();
    } else {
      throw Exception('Unexpected message from API: ${data['message']}');
    }
  } finally {
    client.close();
  }

  return events;
}

Future<List<SubCategory>> getSubCategoryByCategoryId(int id, String language) async {
  List<SubCategory> subcategories = [];

  try {
    var res = await retryOptions.retry(
          () => http.get(Uri.parse("https://api.ticketmaster-et.com/api/sub-category-by-category-id/$id")),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );

    // print("=================getSubCategoryByCategoryId============${res.body}");
    var data = jsonDecode(res.body);
    if (data['message'] == 'Event By category get successfully') {
      var dataList = data['data'] as List;
      for (var item in dataList) {
        var subcategoryData = item['sub_category'] as List;
        subcategories += subcategoryData.map((eventData) => SubCategory.fromJson(eventData, language)).toList();
      }
    } else {
      throw Exception('Unexpected message from API with id $id: ${data['message']}');
    }
  } finally {
    client.close();
  }

  return subcategories;
}




Future<List<Event>> getEventsByOrganizerId(int id, String language) async {
  List<Event> events = [];

  try {
    var res = await retryOptions.retry(
          () => http.get(Uri.parse("https://api.ticketmaster-et.com/api/event-by-organizer-id/$id")),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );

    // print("=================getEventsByOrganizerId============${res.body}");
    var data = jsonDecode(res.body);
    if (data['message'] == 'Event By selected organizer get successfully') {
      var eventsData = data['data'] as List;
      events = eventsData.map((eventData) => Event.fromJson(eventData, language)).toList();
    } else {
      throw Exception('Unexpected message from API: ${data['message']}');
    }
  } finally {
    client.close();
  }

  return events;
}

Future<List<Event>> getEventsByCategoryId(int id, String language) async {
  List<Event> events = [];

  try {
    var res = await retryOptions.retry(
          () => http.get(Uri.parse("https://api.ticketmaster-et.com/api/event-by-category-id/$id")),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );

    //  print("=================getEventsByCategoryId============${res.body}");
    var data = jsonDecode(res.body);

    if (data['message'] == 'Event By category get successfully') {
      var categoriesData = data['data'] as List;

      for (var categoryData in categoriesData) {
        var eventsData = categoryData['event_list'] as List;
        for (var eventData in eventsData) {
          events.add(Event.fromJson(eventData, language));
        }
      }
    } else {
      throw Exception('Unexpected message from API: ${data['message']}');
    }
  } finally {
    client.close();
  }

  return events;
}


Future<SignupResponse> signupResponse(Signup data, String uri) async {
  SignupResponse response;

  Map<String, dynamic> jsonData = {
    'first_name': data.firstName,
    'last_name' : data.lastName,
    'password_confirmation': data.confirmPassword,
    'email': data.email,
    'password': data.password,
    'phone': data.phoneNumber,
    'city_id' : data.cityid
  };

  String requestBody = jsonEncode(jsonData);

  try {
    print(data.toJson());
    var res = await retryOptions.retry(
          () => http.post(
        Uri.parse(uri),
        body: requestBody,
        headers: <String, String>{
          'content-type': 'application/json',
        },
      ),
      retryIf: (p0) => p0 is SocketException || p0 is TimeoutException,
    );
    print(res.body);
    var decodeRes = jsonDecode(res.body);
    response = SignupResponse.fromJson(decodeRes);
  } finally {
    client.close();
  }

  return response;
}


Future<LoginResponse> loginResponse(String uri, Login data) async {
  LoginResponse loginData;
  Map<String, dynamic> jsonData = {
    'password': data.password,
    'phone': data.phoneNumber,
  };

  String requestBody = jsonEncode(jsonData);
  try {
    var res = await retryOptions.retry(
          () => http.post(
        Uri.parse(uri),
        body: requestBody,
        headers: <String, String>{
          'content-type': 'application/json',
        },
      ),
      retryIf: (p0) => p0 is SocketException || p0 is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    print("loginResponse");
    print(res.body);
    loginData = LoginResponse.formJson(decodeRes);
  } finally {
    client.close();
  }
  return loginData;
}

String errorMessageConcatenator(List list) {
  String conc = "";
  for (int i = 0; i < list.length; i++) {
    conc += list[i];
  }
  conc += '\n';

  return conc;
}

Future<List<City>> getCity(String language) async {
  List<City> cities = [];

  try {
    var res = await retryOptions.retry(
          () => http.get(Uri.parse("https://api.ticketmaster-et.com/api/city")),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );

    var data = jsonDecode(res.body);
    if (data['message'] == 'City get successfully') {
      var organizersData = data['data'] as List;
      cities = organizersData.map((organizerData) => City.fromJson(organizerData, language)).toList();
    } else {
      throw Exception('Unexpected message from API: ${data['message']}');
    }
  } finally {
    client.close();
  }

  return cities;
}


Future<BookingResponse> bookEvent(Booking data) async {
  BookingResponse bookingData;
  Map<String, dynamic> jsonData = data.toJson();

  String requestBody = jsonEncode(jsonData);
  var client = http.Client();
  var retryOptions = RetryOptions(maxAttempts: 3);

  try {
    var res = await retryOptions.retry(
          () => client.post(
        Uri.parse('https://api.ticketmaster-et.com/api/book'),
        body: requestBody,
        headers: <String, String>{
          'content-type': 'application/json',
        },
      ),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    print(res.body);
    bookingData = BookingResponse.formJson(decodeRes);
  } finally {
    client.close();
  }

  return bookingData;
}



Future<CommentResponse> commentonEvent(int eventID, int userID, Comment data) async {
  CommentResponse commentData;
  Map<String, dynamic> jsonData = {
    'event_id': eventID,
    'user_id': userID,
    'coment': data.comment,
  };

  String requestBody = jsonEncode(jsonData);
  var client = http.Client();
  var retryOptions = RetryOptions(maxAttempts: 3);
  print('${data.comment}, ${data.firstName}, ${data.lastName}');
  try {
    var res = await retryOptions.retry(
          () => client.post(
        Uri.parse('https://api.ticketmaster-et.com/api/coment-event'),
        body: requestBody,
        headers: <String, String>{
          'content-type': 'application/json',
        },
      ),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    print(res.body);
    commentData = CommentResponse.fromJson(decodeRes);
  } finally {
    client.close();
  }
 print(commentData);
  return commentData;
}



Future<UpdatedUserResponse> updateUser( UpdatedUser data) async {
  UpdatedUserResponse updatedUserData;
  String requestBody = jsonEncode(data.toJson());
  try {
    var res = await retryOptions.retry(
          () => http.post(
        Uri.parse("https://api.ticketmaster-et.com/api/update_user"),
        body: requestBody,
        headers: <String, String>{
          'content-type': 'application/json',
        },
      ),
      retryIf: (p0) => p0 is SocketException || p0 is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    print(res.body);
    updatedUserData = UpdatedUserResponse.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return updatedUserData;
}



Future<List<PrivacyPolicy>> getPrivacyPolicy(String language) async {
  print("getPrivacyPolicy");
  List<PrivacyPolicy> privacyPolicy = [];



  try {
    print("http.get 1");
    var res = await retryOptions.retry(
          () => http.get(Uri.parse("https://api.ticketmaster-et.com/api/privacy")),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );


    print("http.get 2");

    var data = jsonDecode(res.body);
    if (data['message'] == 'Privacy Policy get successfully') {
      // print("if");
      // print("data['message'] ${data['message']}");
      var privacyPolicyData = data['data'] as List;
      // print("privacyPolicyData ${privacyPolicyData}");
      privacyPolicy = privacyPolicyData.map((privacyData) => PrivacyPolicy.fromJson(privacyData, language)).toList();
      // print("privacyPolicy ${privacyPolicy[0]}");
      // print("privacyPolicy id ${privacyPolicy[0].id}");
      // print("privacyPolicy title ${privacyPolicy[0].title}");
    } else {
      throw Exception('Unexpected message from API: ${data['message']}');
    }
  } finally {
    client.close();
  }

  return privacyPolicy;
}
Future<List<FAQ>> getFAQ(String language) async {
  print("getFAQ");
  List<FAQ> faq = [];

  try {
    var res = await retryOptions.retry(
          () => http.get(Uri.parse("https://api.ticketmaster-et.com/api/faq")),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );

    var data = jsonDecode(res.body);
    if (data['message'] == 'Faq get successfully') {
      var faqData = data['data'] as List;
      faq = faqData.map((faqData) => FAQ.fromJson(faqData, language)).toList();
      // print("faq id ${faq[0].id}");
      // print("faq title ${faq[0].title}");
      // print("faq description ${faq[0].description}");
    } else {
      throw Exception('Unexpected message from API: ${data['message']}');
    }
  } finally {
    client.close();
  }

  return faq;
}
Future<List<TermsAndConditions>> getTermsAndConditions(String language) async {
  print("getTermsAndConditions");
  List<TermsAndConditions> termsAndConditions = [];

  try {
    var res = await retryOptions.retry(
          () => http.get(Uri.parse("https://api.ticketmaster-et.com/api/term_and_condition")),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var data = jsonDecode(res.body);
    if (data['message'] == 'Term and Condition get successfully') {
      var termsAndConditionsData = data['data'] as List;
      termsAndConditions = termsAndConditionsData.map((termData) => TermsAndConditions.fromJson(termData, language)).toList();
    } else {
      throw Exception('Unexpected message from API: ${data['message']}');
    }
  } finally {
    client.close();
  }

  return termsAndConditions;
}


Future<List<Ticket>> getTickets(String phone, String language) async {
  List<Ticket> tickets = [];

  try {
    var res = await retryOptions.retry(
          () => http.get(Uri.parse("https://api.ticketmaster-et.com/api/my-ticket/${int.parse(phone)}")),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
  print("My Tickets ${res.body}");
    var data = jsonDecode(res.body);
    if (data['message'] == 'Event detail get successfully') {
      var eventsData = data['data'] as List;
      tickets = eventsData.map((eventData) => Ticket.fromJson(eventData, language)).toList();
    } else {
      throw Exception('Unexpected message from API: ${data['message']}');
    }
  } finally {
    client.close();
  }

  return tickets;
}
// https://api.ticketmaster-et.com/api/review-by-organizer/3
// https://api.ticketmaster-et.com/api/review-by-sub-category/4
// https://api.ticketmaster-et.com/api/review-by-organizer/3
// https://api.ticketmaster-et.com/api/review


Future<List<Review>> getReviewByEvent(String id) async {
  List<Review> review = [];

  try {
    var res = await retryOptions.retry(
          () => http.get(Uri.parse("https://api.ticketmaster-et.com/api/review-by-event/${int.parse(id)}")),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    print("getReviewByEvent ${res.body}");
    var data = jsonDecode(res.body);
    if (data['message'] == 'Review By selected Event get successfully') {
      var eventsData = data['data'] as List;
      review = eventsData.map((eventData) => Review.fromEventJson(eventData)).toList();
    } else {
      throw Exception('Unexpected message from API: ${data['message']}');
    }
  } finally {
    client.close();
  }

  return review;
}

Future<List<Review>> getReviewBySubCategory(String id) async {
  List<Review> review = [];

  try {
    var res = await retryOptions.retry(
          () => http.get(Uri.parse("https://api.ticketmaster-et.com/api/review-by-sub-category/${int.parse(id)}")),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    print("getReviewBySubCategory ${res.body}");
    var data = jsonDecode(res.body);
    if (data['message'] == 'review By selected sub category get successfully') {
      var eventsData = data['data'] as List;
      review = eventsData.map((eventData) => Review.fromSubCategoryJson(eventData)).toList();
    } else {
      throw Exception('Unexpected message from API: ${data['message']}');
    }
  } finally {
    client.close();
  }

  return review;
}
Future<List<Review>> getReviewByOrganizer(String id) async {
  List<Review> review = [];

  try {
    var res = await retryOptions.retry(
          () => http.get(Uri.parse("https://api.ticketmaster-et.com/api/review-by-organizer/${int.parse(id)}")),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    print("getReviewByOrganizer ${res.body}");
    var data = jsonDecode(res.body);
    if (data['message'] == 'Review By selected Organizer get successfully') {
      var eventsData = data['data'] as List;
      review = eventsData.map((eventData) => Review.fromOrganizerJson(eventData)).toList();
    } else {
      throw Exception('Unexpected message from API: ${data['message']}');
    }
  } finally {
    client.close();
  }

  return review;
}


Future<LikeEventResponse> LikeE(LikeEvent data) async {
  LikeEventResponse likeEventData;
  Map<String, dynamic> jsonData = data.toJson();

  String requestBody = jsonEncode(jsonData);
  var client = http.Client();
  var retryOptions = RetryOptions(maxAttempts: 3);

  try {
    var res = await retryOptions.retry(
          () => client.post(
        Uri.parse('https://api.ticketmaster-et.com/api/like-event'),
        body: requestBody,
        headers: <String, String>{
          'content-type': 'application/json',
        },
      ),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    print(res.body);
    likeEventData = LikeEventResponse.fromJson(decodeRes);
  } finally {
    client.close();
  }

  return likeEventData;
}


Future<DisLikeEventResponse> DisLikeE(DisLikeEvent data) async {
  DisLikeEventResponse DislikeEventData;
  Map<String, dynamic> jsonData = data.toJson();

  String requestBody = jsonEncode(jsonData);
  var client = http.Client();
  var retryOptions = RetryOptions(maxAttempts: 3);

  try {
    var res = await retryOptions.retry(
          () => client.post(
        Uri.parse('https://api.ticketmaster-et.com/api/dis-like-event'),
        body: requestBody,
        headers: <String, String>{
          'content-type': 'application/json',
        },
      ),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    print(res.body);
    DislikeEventData = DisLikeEventResponse.fromJson(decodeRes);
  } finally {
    client.close();
  }

  return DislikeEventData;
}


Future<List<Comment>> getCommentsByEventId(int id) async {
  List<Comment> comments = [];

  try {
    var res = await retryOptions.retry(
          () => http.get(Uri.parse("https://api.ticketmaster-et.com/api/coment-list/$id")),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );

    var data = jsonDecode(res.body);
    if (data['message'] == 'coment on specific event get successfully') {
      var commentsData = data['data'] as List;
      comments = commentsData.map((commentData) => Comment.fromJson(commentData)).toList();
    } else {
      throw Exception('Unexpected message from API: ${data['message']}');
    }
  } finally {
    client.close();
  }

  return comments;
}



Future<InterestEventResponse> InterestE(InterestEvent data) async {
  InterestEventResponse InterestEventData;
  Map<String, dynamic> jsonData = data.toJson();

  String requestBody = jsonEncode(jsonData);
  var client = http.Client();
  var retryOptions = RetryOptions(maxAttempts: 3);

  try {
    var res = await retryOptions.retry(
          () => client.post(
        Uri.parse('https://api.ticketmaster-et.com/api/interested-event'),
        body: requestBody,
        headers: <String, String>{
          'content-type': 'application/json',
        },
      ),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    print(res.body);
    InterestEventData = InterestEventResponse.fromJson(decodeRes);
  } finally {
    client.close();
  }

  return InterestEventData;
}


Future<DisInterestEventResponse> DisInterestE(DisInterestEvent data) async {
  DisInterestEventResponse DisInterestEventData;
  Map<String, dynamic> jsonData = data.toJson();

  String requestBody = jsonEncode(jsonData);
  var client = http.Client();
  var retryOptions = RetryOptions(maxAttempts: 3);

  try {
    var res = await retryOptions.retry(
          () => client.post(
        Uri.parse('https://api.ticketmaster-et.com/api/dis-interested-event'),
        body: requestBody,
        headers: <String, String>{
          'content-type': 'application/json',
        },
      ),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    print(res.body);
    DisInterestEventData = DisInterestEventResponse.fromJson(decodeRes);
  } finally {
    client.close();
  }

  return DisInterestEventData;
}
