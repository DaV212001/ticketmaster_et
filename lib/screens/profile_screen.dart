import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticketmaster_et/screens/editprofilescreen.dart';
import 'package:ticketmaster_et/screens/privacy_policy_screen.dart';
import 'package:ticketmaster_et/screens/terms_and_conditions_screen.dart';
import 'package:ticketmaster_et/screens/videotest.dart';

import '../functions/functions.dart';
import '../models/faq.dart';
import '../models/privacy_policy.dart';
import '../models/terms_and_conditions.dart';
import '../provider/loginpersistence.dart';
import '../provider/settings_provider.dart';
import 'faq_screen.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({Key? key}) : super(key: key);

  @override
  ProfileWidgetState createState() => ProfileWidgetState();
}

class ProfileWidgetState extends State<ProfileWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<PrivacyPolicy> privacyPolicy = [];
  List<FAQ> faq = [];
  List<TermsAndConditions> termsAndConditions = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Load login data after the widget has been built
      await Provider.of<LoginDataProvider>(context, listen: false).loadLoginData();
      await getTermsAndConditions(Provider.of<SettingsProvider>(context, listen: false).languageCode)
          .then((value) => setState(() {
        termsAndConditions = value;
        print('ProfileWidget termsAndConditions: $termsAndConditions');
        print('ProfileWidget termsAndConditions title: ${termsAndConditions[0].title}');
        print('ProfileWidget termsAndConditions id: ${termsAndConditions[0].id}');
      }));
      await getPrivacyPolicy(Provider.of<SettingsProvider>(context, listen: false).languageCode)
          .then((value) => setState(() {
        privacyPolicy = value;
        print('privacyPolicy: $privacyPolicy');
        print('ProfileWidget privacyPolicy: $privacyPolicy');
        print('ProfileWidget privacyPolicy title: ${privacyPolicy[0].title}');
        print('ProfileWidget privacyPolicy id: ${privacyPolicy[0].id}');
      }));
      await getFAQ(Provider.of<SettingsProvider>(context, listen: false).languageCode)
          .then((value) => setState(() {
        faq = value;
        print('faq: $faq');
        print('ProfileWidget faq: $faq');
        print('ProfileWidget faq title: ${faq[0].title}');
        print('ProfileWidget faq id: ${faq[0].id}');
        print('ProfileWidget faq description: ${faq[0].description}');
      }));
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginDataProvider = Provider.of<LoginDataProvider>(context, listen: false);
    final themeChange = Provider.of<SettingsProvider>(context);
    final languageChange = Provider.of<SettingsProvider>(context);
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        top: true,
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 1, 0, 0),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 0.5,
                      color: Color(0x33000000),
                      offset: Offset(0, 1),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF39D2C0),
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: CachedNetworkImage(
                              fadeInDuration: const Duration(milliseconds: 500),
                              fadeOutDuration:
                                  const Duration(milliseconds: 500),
                              imageUrl:
                              'https://i.postimg.cc/VkBQ3FS6/na-logo.png',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                        loginDataProvider.loginData == null? '...' : loginDataProvider.loginData!.firstName!,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 4, 0, 0),
                              child: Text(
                                loginDataProvider.loginData == null? '...' : loginDataProvider.loginData!.email!,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(
                                      fontFamily: 'Plus Jakarta Sans',
                                      color: const Color(0xFF57636C),
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 0, 0),
              child: Text(
                tr('profile'),
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: const Color(0xFF57636C),
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
              ),
            ),
            GestureDetector(
              onTap: (){
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                      return EditProfile();
                    }));
              },
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 0.5,
                        color: Color(0x3416202A),
                        offset: Offset(0, 2),
                      )
                    ],
                    borderRadius: BorderRadius.circular(12),
                    shape: BoxShape.rectangle,
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Icon(
                          Icons.account_circle_outlined,
                          color: Color(0xFF57636C),
                          size: 24,
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                            child: Text(
                              tr('editprofile'),
                              style:
                                  Theme.of(context).textTheme.bodyLarge!.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                      ),
                            ),
                          ),
                        ),
                        const Align(
                          alignment: AlignmentDirectional(0.9, 0),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFF57636C),
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 0, 0),
              child: Text(
                tr('general'),
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      fontFamily: 'Plus Jakarta Sans',
                      color: const Color(0xFF57636C),
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 0.5,
                      color: Color(0x3416202A),
                      offset: Offset(0, 2),
                    )
                  ],
                  borderRadius: BorderRadius.circular(12),
                  shape: BoxShape.rectangle,
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Icon(
                        Icons.dark_mode,
                        color: Color(0xFF57636C),
                        size: 24,
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                          child: Text(
                            tr('darktheme'),
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(0.9, 0),
                        child: Switch(
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: const Color(0xFF9B9B9B),
                          value: themeChange.darkTheme,
                          onChanged: (bool value) {
                            setState(() {
                              themeChange.darktheme = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 0.5,
                      color: Color(0x3416202A),
                      offset: Offset(0, 2),
                    )
                  ],
                  borderRadius: BorderRadius.circular(12),
                  shape: BoxShape.rectangle,
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Icon(
                        Icons.language,
                        color: Color(0xFF57636C),
                        size: 24,
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                          child: Text(
                            tr('changelanguage'),
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(0.9, 0),
                        child:DropdownButton(
                            value: languageChange.languageCode,
                            items: const [
                              DropdownMenuItem(value: 'en', child: Text('English')),
                              DropdownMenuItem(value: 'am', child: Text('Amharic')),
                              DropdownMenuItem(value: 'en-AU', child: Text('Afaan Oromo')),
                            ],
                            onChanged: (String? value) async { // mark this function as async
                              String langCode = value!.split('-')[0];
                              String countryCode = value.contains('-') ? value.split('-')[1] : '';

                              // Save langCode and countryCode in shared preferences
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              await prefs.setString('langCode', langCode);
                              if (countryCode.isNotEmpty) {
                                await prefs.setString('countryCode', countryCode);
                              } else {
                                await prefs.remove('countryCode');
                              }

                              // Set locale for EasyLocalization
                              if (countryCode.isNotEmpty) {
                                EasyLocalization.of(context)!.setLocale(Locale(langCode, countryCode));
                              } else {
                                EasyLocalization.of(context)!.setLocale(Locale(langCode));
                              }

                              // Now call setState()
                              if(mounted){
                              setState(() {
                                languageChange.languageCode = value;
                              });
                            }}
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 0.5,
                      color: Color(0x3416202A),
                      offset: Offset(0, 2),
                    )
                  ],
                  borderRadius: BorderRadius.circular(12),
                  shape: BoxShape.rectangle,
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Icon(
                        Icons.help_outline_rounded,
                        color: Color(0xFF57636C),
                        size: 24,
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                          child: Text(
                            tr('support'),
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(0.9, 0),
                        child: IconButton(
                          icon: Icon(Icons.arrow_forward_ios),
                          color: Color(0xFF57636C),
                          onPressed: () { },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 0.5,
                      color: Color(0x3416202A),
                      offset: Offset(0, 2),
                    )
                  ],
                  borderRadius: BorderRadius.circular(12),
                  shape: BoxShape.rectangle,
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Icon(
                        Icons.privacy_tip_sharp,
                        color: Color(0xFF57636C),
                        size: 24,
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                          const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                          child: Text(
                            'Privacy Policy',
                            style:
                            Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(0.9, 0),
                        child: IconButton(
                          icon: Icon(Icons.arrow_forward_ios),
                          color: Color(0xFF57636C),
                          onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PrivacyPolicyScreen(privacyPolicy:privacyPolicy),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 0.5,
                      color: Color(0x3416202A),
                      offset: Offset(0, 2),
                    )
                  ],
                  borderRadius: BorderRadius.circular(12),
                  shape: BoxShape.rectangle,
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Icon(
                        Icons.question_mark,
                        color: Color(0xFF57636C),
                        size: 24,
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                          const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                          child: Text(
                            'FAQ',
                            style:
                            Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(0.9, 0),
                        child: IconButton(
                          icon: Icon(Icons.arrow_forward_ios),
                          color: Color(0xFF57636C),
                          onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FAQScreen(faq:faq),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 0.5,
                      color: Color(0x3416202A),
                      offset: Offset(0, 2),
                    )
                  ],
                  borderRadius: BorderRadius.circular(12),
                  shape: BoxShape.rectangle,
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Icon(
                        Icons.gavel,
                        color: Color(0xFF57636C),
                        size: 24,
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                          const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                          child: Text(
                            tr('tos'),
                            style:
                            Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(0.9, 0),
                        child: IconButton(
                          icon: Icon(Icons.arrow_forward_ios),
                          color: Color(0xFF57636C),
                          onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TermsAndConditionsScreen(termsAndConditions:termsAndConditions),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 0.5,
                      color: Color(0x3416202A),
                      offset: Offset(0, 2),
                    )
                  ],
                  borderRadius: BorderRadius.circular(12),
                  shape: BoxShape.rectangle,
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFF57636C),
                        size: 24,
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                          const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                          child: Text(
                            tr('logout'),
                            style:
                            Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(0.9, 0),
                        child: IconButton(
                          icon: Icon(Icons.arrow_forward_ios),
                          color: Color(0xFF57636C),
                          iconSize: 18, onPressed: () {
                            setState(() {
                              loginDataProvider.clear();
                            });
                        },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 0.5,
                      color: Color(0x3416202A),
                      offset: Offset(0, 2),
                    )
                  ],
                  borderRadius: BorderRadius.circular(12),
                  shape: BoxShape.rectangle,
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Icon(
                        Icons.ios_share,
                        color: Color(0xFF57636C),
                        size: 24,
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                          child: Text(
                            tr('invitefriends'),
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF57636C),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
