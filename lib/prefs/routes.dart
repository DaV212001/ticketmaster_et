import 'package:get/get.dart';
import 'package:ticketmaster_et/main.dart';
import 'package:ticketmaster_et/main_layout_screen.dart';
import 'package:ticketmaster_et/screens/editprofilescreen.dart';
import 'package:ticketmaster_et/screens/faq_screen.dart';
import 'package:ticketmaster_et/screens/order/user_order_details.dart';
import 'package:ticketmaster_et/screens/privacy_policy_screen.dart';
import 'package:ticketmaster_et/screens/profile/how_we_cook/how_we_cook_screen.dart';
import 'package:ticketmaster_et/screens/terms_and_conditions_screen.dart';

import '../screens/category/section/subcategorydetails.dart';
import '../screens/home/cart/cart_screen.dart';
import '../screens/home/cart/checkout_screen.dart';
import '../screens/login.dart';
import '../screens/signup.dart';
import '../screens/splash_screen.dart';

class Routes {
  static const String loginRoute = '/login';
  static const String signUpRoute = '/signUp';
  static const String splashRoute = '/splash';
  static const String mainLayoutRoute = '/mainLayout';
  static const String foodDetailRoute = '/foodDetail';
  static const String orderDetailRoute = '/orderDetail';
  static const String faqRoute = '/faq';
  static const String termsRoute = '/terms';
  static const String privacyRoute = '/privacy';
  static const String howWeCookRoute = '/howWeCook';
  static const String editProfileRoute = '/editProfile';
  static const String cartRoute = '/cart';
  static const String checkoutRoute = '/checkout';
}

class Pages {
  static final pages = [
    GetPage(name: Routes.loginRoute, page: () => const LoginScreen()),
    GetPage(name: Routes.signUpRoute, page: () => const SignupScreen()),
    GetPage(name: Routes.splashRoute, page: () => const SplashScreen()),
    GetPage(
        name: Routes.mainLayoutRoute,
        page: () => const TicketMatserHomePage(),
        middlewares: [InitialNavigationMiddleware()]),
    GetPage(
      name: Routes.foodDetailRoute,
      page: () => const FoodDetail(),
      // middlewares: [TimeCheckerMiddleware()]
    ),
    GetPage(
        name: Routes.orderDetailRoute, page: () => const UserOrderDetails()),
    GetPage(name: Routes.faqRoute, page: () => FAQScreen()),
    GetPage(name: Routes.termsRoute, page: () => TermsAndConditionsScreen()),
    GetPage(name: Routes.privacyRoute, page: () => PrivacyPolicyScreen()),
    GetPage(name: Routes.howWeCookRoute, page: () => HowWeCookScreen()),
    GetPage(name: Routes.editProfileRoute, page: () => const EditProfile()),
    GetPage(name: Routes.cartRoute, page: () => CartScreen()),
    GetPage(
        name: Routes.checkoutRoute,
        page: () => CheckoutScreen(),
        middlewares: [AuthNavigationMiddleware()]),
  ];
}
