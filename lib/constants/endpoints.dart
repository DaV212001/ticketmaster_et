import 'app_constants.dart';

class Endpoints {
  static String categories() {
    return "$apiUrl" "/category";
  }

  static String popular({String id = "8"}) {
    return "$apiUrl" "/popular";
  }

  static String upcoming({int id = 3}) {
    return "$apiUrl" "/upcoming";
  }

  static String homecatandsubcat() {
    return "$apiUrl" "/category-sub-category";
  }

  static String eventbysubcat(String id) {
    return '$apiUrl' "/event-by-sub-category/$id";
  }

  static String organizers() {
    return '$apiUrl' '/organizer';
  }

  static String loginEndpoint() {
    return '$apiUrl' '/login';
  }

  static String registrationEndpoint() {
    return '$apiUrl' '/register';
  }

  static String eventbyorganizerid (String id){
    return '$apiUrl' '/event-by-organizer-id/$id';
  }

  static String listofeventsbycat (String id){
    return '$apiUrl' '/event-by-category-id/$id';
  }

  static String signupEndpoint() {
    return '$apiUrl' "/register";
  }


  static String paymentVerifyEndpoint() {
    return '$apiUrl' '/payment_verify';
  }
}