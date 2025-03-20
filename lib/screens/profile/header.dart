import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketmaster_et/provider/loginpersistence.dart';
import 'package:ticketmaster_et/screens/profile/profile_widget.dart';

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
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.25,
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
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text("$firstName $lastName",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800)),
                    ),
                    if (phone.isNotEmpty) const SizedBox(height: 5),
                    if (phone.isNotEmpty)
                      Expanded(
                        child: Text(phone,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            )),
                      ),
                    if (email.isNotEmpty) const SizedBox(height: 5),
                    if (email.isNotEmpty)
                      Expanded(
                        child: Text(email,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            )),
                      ),
                  ],
                ),
              ),
              // const SizedBox(width: 5),
              // Expanded(
              //   child: Container(
              //       decoration: BoxDecoration(
              //           color: theme.colorScheme.primary,
              //           borderRadius: BorderRadius.circular(10)),
              //       // style: ButtonStyle(
              //       //     backgroundColor:
              //       //         WidgetStatePropertyAll(theme.colorScheme.primary)),
              //       // onPressed: () {
              //       //   Get.to(
              //       //     () => const EditProfile(),
              //       //   );
              //       // },
              //       child: Padding(
              //         padding: const EdgeInsets.all(16.0),
              //         child: Center(
              //           child: Text(loyaltyPoints ?? '',
              //               style: const TextStyle(
              //                 fontSize: 15,
              //                 color: Colors.white,
              //                 fontWeight: FontWeight.w800,
              //               )),
              //         ),
              //       )),
              // )
            ],
          ),
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
