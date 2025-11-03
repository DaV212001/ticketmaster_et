import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/web.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ticketmaster_et/api_call_status.dart';
import 'package:ticketmaster_et/controllers/footer_controller.dart';
import 'package:ticketmaster_et/controllers/wallet_controller.dart';
import 'package:ticketmaster_et/functions/functions.dart';
import 'package:ticketmaster_et/screens/organizations_screen.dart';
import 'package:ticketmaster_et/screens/profile/footer.dart';
import 'package:ticketmaster_et/screens/profile/header.dart';
import 'package:ticketmaster_et/screens/profile/route_container.dart';
import 'package:ticketmaster_et/screens/wallet/wallet_screen.dart';
import 'package:ticketmaster_et/utils/update_enforcer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/newmodels.dart';
import '../prefs/routes.dart';
import '../provider/loginpersistence.dart';
import 'change_password_screen.dart';

class ProfileController extends GetxController {
  var loginData = Rxn<LoginData>();
  var freeMeals = 0.obs;
  var targetCount = 0.obs;
  var loadingMealData = ApiCallStatus.holding.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
    ever(Get.find<LoginDataProvider>(tag: 'login').loginDataObs, (value) {
      loadData();
    });
  }

  Future<void> loadData() async {
    loginData.value = Get.find<LoginDataProvider>(tag: 'login').loginData;
    loadingMealData.value = ApiCallStatus.loading;
    getFreeMeal();
    getTargetCount();
    loadingMealData.value = ApiCallStatus.success;
  }

  void getFreeMeal() async {
    try {
      var res = await http
          .get(Uri.parse('${baseUrlFunc}free-meal/${loginData.value?.id}'));
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        var dataValue =
            data['data'] is String ? int.parse(data['data']) : data['data'];
        freeMeals.value = (dataValue ?? 0) < 0 ? 0 : (dataValue ?? 0);
      }
    } catch (e, s) {
      Logger().t(e, stackTrace: s);
      loadingMealData.value = ApiCallStatus.error;
    }
  }

  void getTargetCount() async {
    try {
      var res = await http
          .get(Uri.parse('${baseUrlFunc}target-count/${loginData.value?.id}'));
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        targetCount.value = data['data'];
      }
    } catch (e, s) {
      Logger().t(e, stackTrace: s);
      loadingMealData.value = ApiCallStatus.error;
    }
  }

  void logout() async {
    await Get.find<LoginDataProvider>(tag: 'login').clear();
    Get.offAllNamed(Routes.mainLayoutRoute);
  }
}

class ProfileWidget extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());
  final FooterController footerController = Get.put(FooterController());
  final WalletController walletController =
      Get.put(WalletController(), tag: WalletController.tag);

  ProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> general = [
      {
        "title": 'darktheme'.tr,
        "leadingIcon": Icons.dark_mode,
        "onTap": () {},
        "trailing": const Text("")
      },
      {
        "title": "changelanguage".tr,
        "leadingIcon": Icons.language,
        "onTap": () {},
        "trailing": const Text("")
      },
      {
        "title": "change_pass".tr,
        "leadingIcon": Icons.language,
        "onTap": () {
          Get.to(() => ChangePasswordScreen());
        },
        "trailing": const Text("")
      },
      {
        "title": "support".tr,
        "leadingIcon": Icons.help_outline_rounded,
        "onTap": () async {
          const url = "tel:6810";
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url));
          } else {
            throw 'Could not launch $url';
          }
        },
        "trailing": const Text("")
      },
      {
        "title": "privpol".tr,
        "leadingIcon": Icons.privacy_tip,
        "onTap": () {
          Get.toNamed(Routes.privacyRoute);
        },
        "trailing": const Text("")
      },
      {
        "title": "faq".tr,
        "leadingIcon": Icons.question_mark_rounded,
        "onTap": () {
          Get.toNamed(Routes.faqRoute);
        },
        "trailing": const Text("")
      },
      {
        "title": "tos".tr,
        "leadingIcon": Icons.gavel,
        "onTap": () {
          Get.toNamed(Routes.termsRoute);
        },
        "trailing": const Text("")
      },
      {
        "title": "new_version".tr,
        "leadingIcon": Icons.settings_applications,
        "onTap": () {
          Get.showOverlay(
              asyncFunction: UpdateChecker().checkForUpdates,
              loadingWidget: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(child: CircularProgressIndicator())));
        },
        "trailing": Icon(Icons.chevron_right_outlined)
      },
      {
        "title": "invitefriends".tr,
        "leadingIcon": Icons.share,
        "onTap": () {
          Share.share(
            'https://play.google.com/store/apps/details?id=com.hello.mesa',
            subject: 'Check out my app on the Play Store',
          );
        },
        "trailing": const Text("")
      },
    ];

    final List<Map<String, dynamic>> profile = [
      // {
      //   "title": 'editprofile'.tr,
      //   "leadingIcon": Icons.account_circle_outlined,
      //   "onTap": () {
      //     Get.to(() => const EditProfile());
      //   },
      //   "trailing": const Text('')
      // },
      {
        "title": "wallet".tr,
        "leadingIcon": Icons.wallet,
        "onTap": () {
          Get.to(() => const WalletScreen());
        },
        "trailing": const Text("")
      }
    ];

    return Scaffold(
      // key: controller.scaffoldKey,
      body: SafeArea(
        top: true,
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            Container(
              // color: Theme.of(context).cardColor,
              child: Column(
                children: [
                  Obx(
                    () => UserScreenHeader(
                        reFresh: controller.loadData,
                        firstName:
                            controller.loginData.value?.firstName ?? '...',
                        lastName: controller.loginData.value?.lastName ?? '...',
                        phone: controller.loginData.value?.phone ?? '...',
                        email: controller.loginData.value?.email ?? '...',
                        loyaltyPoints:
                            controller.loginData.value?.loyaltyPoints),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: GestureDetector(
                  //       onTap: () => Get.to(() => const EditProfile()),
                  //       child: Text(
                  //         'editprofile'.tr,
                  //         style: TextStyle(
                  //             color: Theme.of(context).primaryColor,
                  //             fontWeight: FontWeight.bold),
                  //       )),
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Obx(
                                  () => Text(
                                    walletController.balance.value,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                'wallet'.tr,
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.grey),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                          child: VerticalDivider(
                            thickness: 1,
                            color: Colors.black12,
                            indent: 4,
                            endIndent: 4,
                            width: 16,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  controller.targetCount.value.toString(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                'Total Orders'.tr,
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.grey),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                          child: VerticalDivider(
                            thickness: 1,
                            color: Colors.black12,
                            indent: 4,
                            endIndent: 4,
                            width: 16,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  controller.freeMeals.value.toString(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                'free_meals'.tr,
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.grey),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Obx(
                          () => Text(controller.targetCount.value.toString()),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Obx(() => AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                  height: 10,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor:
                                          (controller.targetCount.value / 10)
                                              .clamp(0.0, 1.0),
                                      child: Container(
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                          ),
                        ),
                        const Text('10'),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "target_count".trParams(
                          {"count": "${10 - controller.targetCount.value}"}),
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 8.0),
                  //   child: Column(
                  //     children: [
                  //       Text(
                  //         'free_meals'.tr,
                  //         style: const TextStyle(fontWeight: FontWeight.bold),
                  //       ),
                  //       Padding(
                  //         padding: const EdgeInsets.symmetric(vertical: 8.0),
                  //         child: Text(
                  //           controller.freeMeals.value.toString(),
                  //           style: const TextStyle(fontWeight: FontWeight.bold),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  Obx(() => controller.freeMeals.value != 0
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                  onPressed: () {
                                    Get.to(() => OrganizationScreen());
                                  },
                                  child: Text('donate_fm'.tr))),
                        )
                      : const SizedBox.shrink())
                ],
              ),
            ),
            RouteContainer(
              routePart: profile,
              indexTwo: 2,
              routeName: 'profile'.tr,
            ),
            RouteContainer(
              routePart: general,
              indexTwo: 5,
              routeName: "general".tr,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: controller.logout, child: Text("logout".tr)),
            ),
            Obx(() => footerController.footer.value.copyWriteText == null
                ? const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator())
                : UserScreenFooter(footerData: footerController.footer.value)),
          ],
        ),
      ),
    );
  }
}

// Padding(
// padding: const EdgeInsetsDirectional.fromSTEB(16, 9, 0, 0),
// child: Text(
// tr('profile'),
// style: Theme.of(context).textTheme.labelLarge!.copyWith(
// color: const Color(0xFF57636C),
// fontSize: 16,
// fontWeight: FontWeight.normal,
// ),
// ),
// ),
// GestureDetector(
// onTap: () {
// Navigator.push(context, MaterialPageRoute(builder: (context) {
// return EditProfile();
// }));
// },
// child: Padding(
// padding: const EdgeInsetsDirectional.fromSTEB(16, 7, 16, 0),
// child: Container(
// width: double.infinity,
// height: 60,
// decoration: BoxDecoration(
// boxShadow: const [
// BoxShadow(
// blurRadius: 0.5,
// color: Color(0x3416202A),
// offset: Offset(0, 2),
// )
// ],
// borderRadius: BorderRadius.circular(12),
// shape: BoxShape.rectangle,
// ),
// child: Padding(
// padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
// child: Row(
// mainAxisSize: MainAxisSize.max,
// children: [
// const Icon(
// Icons.account_circle_outlined,
// color: Color(0xFF57636C),
// size: 24,
// ),
// Expanded(
// child: Padding(
// padding: const EdgeInsetsDirectional.fromSTEB(
// 12, 0, 0, 0),
// child: Text(
// tr('editprofile'),
// style: Theme.of(context)
//     .textTheme
//     .bodyLarge!
//     .copyWith(
// fontSize: 16,
// fontWeight: FontWeight.normal,
// ),
// ),
// ),
// ),
// const Align(
// alignment: AlignmentDirectional(0.9, 0),
// child: Icon(
// Icons.arrow_forward_ios,
// color: Color(0xFF57636C),
// size: 18,
// ),
// ),
// ],
// ),
// ),
// ),
// ),
// ),
// Padding(
// padding: const EdgeInsetsDirectional.fromSTEB(16, 9, 0, 0),
// child: Text(
// tr('general'),
// style: Theme.of(context).textTheme.labelLarge!.copyWith(
// fontFamily: 'Plus Jakarta Sans',
// color: const Color(0xFF57636C),
// fontSize: 16,
// fontWeight: FontWeight.normal,
// ),
// ),
// ),
// Padding(
// padding: const EdgeInsetsDirectional.fromSTEB(16, 7, 16, 0),
// child: Container(
// width: double.infinity,
// height: 60,
// decoration: BoxDecoration(
// boxShadow: const [
// BoxShadow(
// blurRadius: 0.5,
// color: Color(0x3416202A),
// offset: Offset(0, 2),
// )
// ],
// borderRadius: BorderRadius.circular(12),
// shape: BoxShape.rectangle,
// ),
// child: Padding(
// padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
// child: Row(
// mainAxisSize: MainAxisSize.max,
// children: [
// const Icon(
// Icons.dark_mode,
// color: Color(0xFF57636C),
// size: 24,
// ),
// Expanded(
// child: Padding(
// padding:
// const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
// child: Text(
// tr('darktheme'),
// style:
// Theme.of(context).textTheme.bodyLarge!.copyWith(
// fontSize: 16,
// fontWeight: FontWeight.normal,
// ),
// ),
// ),
// ),
// Align(
// alignment: const AlignmentDirectional(0.9, 0),
// child: Switch(
// inactiveThumbColor: Colors.white,
// inactiveTrackColor: const Color(0xFF9B9B9B),
// value: themeChange.darkTheme,
// onChanged: (bool value) {
// setState(() {
// themeChange.darktheme = value;
// });
// },
// ),
// ),
// ],
// ),
// ),
// ),
// ),
// Padding(
// padding: const EdgeInsetsDirectional.fromSTEB(16, 7, 16, 0),
// child: Container(
// width: double.infinity,
// height: 60,
// decoration: BoxDecoration(
// boxShadow: const [
// BoxShadow(
// blurRadius: 0.5,
// color: Color(0x3416202A),
// offset: Offset(0, 2),
// )
// ],
// borderRadius: BorderRadius.circular(12),
// shape: BoxShape.rectangle,
// ),
// child: Padding(
// padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
// child: Row(
// mainAxisSize: MainAxisSize.max,
// children: [
// const Icon(
// Icons.language,
// color: Color(0xFF57636C),
// size: 24,
// ),
// Expanded(
// child: Padding(
// padding:
// const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
// child: Text(
// tr('changelanguage'),
// style:
// Theme.of(context).textTheme.bodyLarge!.copyWith(
// fontSize: 16,
// fontWeight: FontWeight.normal,
// ),
// ),
// ),
// ),
// Align(
// alignment: const AlignmentDirectional(0.9, 0),
// child: DropdownButton(
// value: languageChange.languageCode,
// items: const [
// DropdownMenuItem(
// value: 'en', child: Text('English')),
// DropdownMenuItem(
// value: 'am', child: Text('Amharic')),
// DropdownMenuItem(
// value: 'en-AU', child: Text('Afaan Oromo')),
// ],
// onChanged: (String? value) async {
// // mark this function as async
// String langCode = value!.split('-')[0];
// String countryCode = value.contains('-')
// ? value.split('-')[1]
//     : '';
//
// // Save langCode and countryCode in shared preferences
// SharedPreferences prefs =
// await SharedPreferences.getInstance();
// await prefs.setString('langCode', langCode);
// if (countryCode.isNotEmpty) {
// await prefs.setString(
// 'countryCode', countryCode);
// } else {
// await prefs.remove('countryCode');
// }
//
// // Set locale for EasyLocalization
// if (countryCode.isNotEmpty) {
// EasyLocalization.of(context)!
//     .setLocale(Locale(langCode, countryCode));
// } else {
// EasyLocalization.of(context)!
//     .setLocale(Locale(langCode));
// }
//
// // Now call setState()
// if (mounted) {
// setState(() {
// languageChange.languageCode = value;
// });
// }
// }),
// ),
// ],
// ),
// ),
// ),
// ),
// Padding(
// padding: const EdgeInsetsDirectional.fromSTEB(16, 7, 16, 0),
// child: Container(
// width: double.infinity,
// height: 60,
// decoration: BoxDecoration(
// boxShadow: const [
// BoxShadow(
// blurRadius: 0.5,
// color: Color(0x3416202A),
// offset: Offset(0, 2),
// )
// ],
// borderRadius: BorderRadius.circular(12),
// shape: BoxShape.rectangle,
// ),
// child: Padding(
// padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
// child: Row(
// mainAxisSize: MainAxisSize.max,
// children: [
// const Icon(
// Icons.help_outline_rounded,
// color: Color(0xFF57636C),
// size: 24,
// ),
// Expanded(
// child: Padding(
// padding:
// const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
// child: Text(
// tr('support'),
// style:
// Theme.of(context).textTheme.bodyLarge!.copyWith(
// fontSize: 16,
// fontWeight: FontWeight.normal,
// ),
// ),
// ),
// ),
// Align(
// alignment: AlignmentDirectional(0.9, 0),
// child: IconButton(
// icon: Icon(Icons.arrow_forward_ios),
// color: Color(0xFF57636C),
// onPressed: () async {
// const url =
// "tel:6810"; // replace with the actual number
// if (await canLaunchUrl(Uri.parse(url))) {
// await launchUrl(Uri.parse(url));
// } else {
// throw 'Could not launch $url';
// }
// },
// ),
// ),
// ],
// ),
// ),
// ),
// ),
// Padding(
// padding: const EdgeInsetsDirectional.fromSTEB(16, 7, 16, 0),
// child: Container(
// width: double.infinity,
// height: 60,
// decoration: BoxDecoration(
// boxShadow: const [
// BoxShadow(
// blurRadius: 0.5,
// color: Color(0x3416202A),
// offset: Offset(0, 2),
// )
// ],
// borderRadius: BorderRadius.circular(12),
// shape: BoxShape.rectangle,
// ),
// child: Padding(
// padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
// child: Row(
// mainAxisSize: MainAxisSize.max,
// children: [
// const Icon(
// Icons.privacy_tip_sharp,
// color: Color(0xFF57636C),
// size: 24,
// ),
// Expanded(
// child: Padding(
// padding:
// const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
// child: Text(
// 'Privacy Policy',
// style:
// Theme.of(context).textTheme.bodyLarge!.copyWith(
// fontSize: 16,
// fontWeight: FontWeight.normal,
// ),
// ),
// ),
// ),
// Align(
// alignment: AlignmentDirectional(0.9, 0),
// child: IconButton(
// icon: Icon(Icons.arrow_forward_ios),
// color: Color(0xFF57636C),
// onPressed: () {
// Navigator.push(
// context,
// MaterialPageRoute(
// builder: (context) => PrivacyPolicyScreen(
// privacyPolicy: privacyPolicy),
// ),
// );
// },
// ),
// ),
// ],
// ),
// ),
// ),
// ),
// Padding(
// padding: const EdgeInsetsDirectional.fromSTEB(16, 7, 16, 0),
// child: Container(
// width: double.infinity,
// height: 60,
// decoration: BoxDecoration(
// boxShadow: const [
// BoxShadow(
// blurRadius: 0.5,
// color: Color(0x3416202A),
// offset: Offset(0, 2),
// )
// ],
// borderRadius: BorderRadius.circular(12),
// shape: BoxShape.rectangle,
// ),
// child: Padding(
// padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
// child: Row(
// mainAxisSize: MainAxisSize.max,
// children: [
// const Icon(
// Icons.question_mark,
// color: Color(0xFF57636C),
// size: 24,
// ),
// Expanded(
// child: Padding(
// padding:
// const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
// child: Text(
// 'FAQ',
// style:
// Theme.of(context).textTheme.bodyLarge!.copyWith(
// fontSize: 16,
// fontWeight: FontWeight.normal,
// ),
// ),
// ),
// ),
// Align(
// alignment: AlignmentDirectional(0.9, 0),
// child: IconButton(
// icon: Icon(Icons.arrow_forward_ios),
// color: Color(0xFF57636C),
// onPressed: () {
// Navigator.push(
// context,
// MaterialPageRoute(
// builder: (context) => FAQScreen(faq: faq),
// ),
// );
// },
// ),
// ),
// ],
// ),
// ),
// ),
// ),
// Padding(
// padding: const EdgeInsetsDirectional.fromSTEB(16, 7, 16, 0),
// child: Container(
// width: double.infinity,
// height: 60,
// decoration: BoxDecoration(
// boxShadow: const [
// BoxShadow(
// blurRadius: 0.5,
// color: Color(0x3416202A),
// offset: Offset(0, 2),
// )
// ],
// borderRadius: BorderRadius.circular(12),
// shape: BoxShape.rectangle,
// ),
// child: Padding(
// padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
// child: Row(
// mainAxisSize: MainAxisSize.max,
// children: [
// const Icon(
// Icons.gavel,
// color: Color(0xFF57636C),
// size: 24,
// ),
// Expanded(
// child: Padding(
// padding:
// const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
// child: Text(
// tr('tos'),
// style:
// Theme.of(context).textTheme.bodyLarge!.copyWith(
// fontSize: 16,
// fontWeight: FontWeight.normal,
// ),
// ),
// ),
// ),
// Align(
// alignment: AlignmentDirectional(0.9, 0),
// child: IconButton(
// icon: Icon(Icons.arrow_forward_ios),
// color: Color(0xFF57636C),
// onPressed: () {
// Navigator.push(
// context,
// MaterialPageRoute(
// builder: (context) => TermsAndConditionsScreen(
// termsAndConditions: termsAndConditions),
// ),
// );
// },
// ),
// ),
// ],
// ),
// ),
// ),
// ),
// Padding(
// padding: const EdgeInsetsDirectional.fromSTEB(16, 7, 16, 0),
// child: Container(
// width: double.infinity,
// height: 60,
// decoration: BoxDecoration(
// boxShadow: const [
// BoxShadow(
// blurRadius: 0.5,
// color: Color(0x3416202A),
// offset: Offset(0, 2),
// )
// ],
// borderRadius: BorderRadius.circular(12),
// shape: BoxShape.rectangle,
// ),
// child: Padding(
// padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
// child: Row(
// mainAxisSize: MainAxisSize.max,
// children: [
// const Icon(
// Icons.logout_rounded,
// color: Color(0xFF57636C),
// size: 24,
// ),
// Expanded(
// child: Padding(
// padding:
// const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
// child: Text(
// tr('logout'),
// style:
// Theme.of(context).textTheme.bodyLarge!.copyWith(
// fontSize: 16,
// fontWeight: FontWeight.normal,
// ),
// ),
// ),
// ),
// Align(
// alignment: AlignmentDirectional(0.9, 0),
// child: IconButton(
// icon: Icon(Icons.arrow_forward_ios),
// color: Color(0xFF57636C),
// iconSize: 18,
// onPressed: () {
// setState(() {
// loginDataProvider.clear();
// });
// },
// ),
// ),
// ],
// ),
// ),
// ),
// ),
// Padding(
// padding: const EdgeInsetsDirectional.fromSTEB(16, 7, 16, 0),
// child: Container(
// width: double.infinity,
// height: 60,
// decoration: BoxDecoration(
// boxShadow: const [
// BoxShadow(
// blurRadius: 0.5,
// color: Color(0x3416202A),
// offset: Offset(0, 2),
// )
// ],
// borderRadius: BorderRadius.circular(12),
// shape: BoxShape.rectangle,
// ),
// child: Padding(
// padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
// child: Row(
// mainAxisSize: MainAxisSize.max,
// children: [
// const Icon(
// Icons.ios_share,
// color: Color(0xFF57636C),
// size: 24,
// ),
// Expanded(
// child: Padding(
// padding:
// const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
// child: Text(
// tr('invitefriends'),
// style:
// Theme.of(context).textTheme.bodyLarge!.copyWith(
// fontSize: 16,
// fontWeight: FontWeight.normal,
// ),
// ),
// ),
// ),
// Align(
// alignment: AlignmentDirectional(0.9, 0),
// child: IconButton(
// icon: Icon(Icons.arrow_forward_ios),
// color: Color(0xFF57636C),
// onPressed: () {
// Share.share(
// 'https://play.google.com/store/apps/details?id=com.macictsolution.ticketmasteret',
// subject: 'Check out my app on the Play Store',
// );
// },
// ),
// ),
// ],
// ),
// ),
// ),
// ),
