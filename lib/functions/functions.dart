import 'dart:async';
import 'dart:io';
import 'package:retry/retry.dart';
import 'package:ticketmaster_et/models/newmodels.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

Future<List<Category>> getCategorySubCategory(String language) async {
  List<Category> categories = [];

  try {
    var res = await retryOptions.retry(
          () => http.get(Uri.parse("https://api.ticketmaster-et.com/api/category-sub-category")),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
print(res.body);
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

    var data = jsonDecode(res.body);
    if (data['message'] == 'Event By selected Sub category get successfully') {
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

Future<List<SubCategory>> getSubCategoryByCategoryId(int id, String language) async {
  List<SubCategory> subcategories = [];

  try {
    var res = await retryOptions.retry(
          () => http.get(Uri.parse("https://api.ticketmaster-et.com/api/sub-category-by-category-id/$id")),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );

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