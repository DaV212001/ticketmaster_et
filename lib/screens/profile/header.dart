import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketmaster_et/provider/loginpersistence.dart';
import 'package:ticketmaster_et/screens/profile/profile_widget.dart';

import '../editprofilescreen.dart';

class UserScreenHeader extends StatelessWidget {
  final Function() reFresh;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? loyaltyPoints;
  // UserScreenHeader({super.key, required this.user,
  // // required this.reFresh
  // });

  UserScreenHeader({
    Key? key,
    required this.reFresh,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.loyaltyPoints,
    required this.phone,
  }) : super(key: key);

  final double coverHeight = 210;
  final double imageHeight = 144;
  late var profilePicture;
  bool isFile = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            UserProfileWidget(
              isUpdateScreen: false,
              imagePath: Get.find<LoginDataProvider>(tag: 'login')
                  .loginData
                  ?.profileImage,
              hasEditButton: false,
              isFile: isFile,
              onClicked: showOptions,
            ),
            // const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("$firstName $lastName",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800)),
                Padding(
                  padding: const EdgeInsets.only(left: 34.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (phone.isNotEmpty) const SizedBox(height: 5),
                          if (phone.isNotEmpty)
                            Text(phone,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey)),
                          // if (email.isNotEmpty) const SizedBox(height: 5),
                          if (email.isNotEmpty)
                            Text(email,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey)),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: GestureDetector(
                          onTap: () => Get.to(() => const EditProfile()),
                          child: Icon(
                            EneftyIcons.edit_outline,
                            size: 18,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ],
        ));
  }

  Future showOptions() async {
    Get.bottomSheet(
      Container(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('photo_gallery'.tr),
              onTap: () async {
                // await controller.getImageFromGallery();
                Get.back();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('camera'.tr),
              onTap: () async {
                // await controller.getImageFromCamera();
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
