// import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(80),
                    child: Image.network(
                      'https://static.vecteezy.com/system/resources/previews/019/896/008/original/male-user-avatar-icon-in-flat-design-style-person-signs-illustration-png.png',
                      width: 80,
                      height: 80,
                    )),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                        spacing: 5,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text('user'.tr),
                          // Visibility(
                          //     visible: snapshot.data!['verified'] ?? false,
                          //     child: ClipRRect(
                          //       borderRadius: BorderRadius.circular(20),
                          //       child: SvgPicture.asset(
                          //         'assets/images/checkmark.svg',
                          //         width: 20,
                          //         height: 20,
                          //         color: Theme.of(context).colorScheme.primary,
                          //       ),
                          //     ))
                        ]),
                    //  Text('@${snapshot.data!['username'] ?? 'username'}')
                  ],
                )
              ],
            ),
            // Padding(
            //   padding: const EdgeInsets.only(top: 15.0, bottom: 10),
            //   child: ElevatedButton(
            //       style: const ButtonStyle(
            //           minimumSize: MaterialStatePropertyAll(Size(250, 45))),
            //       onPressed: () {
            //         Navigator.push(context,
            //             MaterialPageRoute(builder: (context) {
            //           return const ProfileEdit();
            //         }));
            //       },
            //       child: const Text('Edit profile')),
            // ),
            const Divider(
              thickness: 1,
              color: Colors.grey,
            ),
            userListTile('Email', 'email', 0, context),
            userListTile('Email', 'email', 0, context),

            // Material(
            //   color: Colors.transparent,
            //   child: InkWell(
            //     splashColor: Theme.of(context).splashColor,
            //     child: ListTile(
            //       onTap: () async {
            //         // Navigator.canPop(context)? Navigator.pop(context):null;
            //         showDialog(
            //             context: context,
            //             builder: (BuildContext ctx) {
            //               return AlertDialog(
            //                 title: const Padding(
            //                   padding: EdgeInsets.all(8.0),
            //                   child: Text('Sign out'),
            //                 ),
            //                 content: const Text('Do you want to Sign out?'),
            //                 actions: [
            //                   ElevatedButton(
            //                       onPressed: () async {
            //                         Navigator.pop(context);
            //                       },
            //                       child: const Text('Cancel')),
            //                   TextButton(
            //                       onPressed: () async {
            //                         await _auth.signOut().then((value) {
            //                           Navigator.pushReplacement(context,
            //                               MaterialPageRoute(
            //                                   builder: ((context) {
            //                             return const LandingScreen();
            //                           })));
            //                         });
            //                       },
            //                       child: const Text(
            //                         'Ok',
            //                         style: TextStyle(color: Colors.red),
            //                       ))
            //                 ],
            //               );
            //             });
            //       },
            //       title: const Text('Logout'),
            //       leading: Icon(
            //         Icons.exit_to_app_rounded,
            //         color: Theme.of(context).colorScheme.primary,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ));
  }
}

final List<IconData> _userTileIcons = [
  Icons.email,
  Icons.phone,
  Icons.local_shipping,
  Icons.watch_later,
  Icons.exit_to_app_rounded
];

Widget userListTile(
    String title, String subTitle, int index, BuildContext context) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      splashColor: Theme.of(context).splashColor,
      child: ListTile(
        onTap: () {},
        title: Text(title),
        subtitle: Text(subTitle),
        leading: Icon(
          _userTileIcons[index],
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    ),
  );
}

Widget userTitle(String title) {
  return Padding(
    padding: const EdgeInsets.all(14.0),
    child: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
    ),
  );
}
