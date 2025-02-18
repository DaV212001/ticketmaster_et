import 'package:flutter/material.dart';

class UserProfileWidget extends StatelessWidget {
  final dynamic imagePath;
  final VoidCallback onClicked;
  final bool isFile;
  final bool hasEditButton;
  final bool isUpdateScreen;
  const UserProfileWidget(
      {Key? key,
      required this.imagePath,
      required this.onClicked,
      required this.isFile,
      required this.hasEditButton,
      required this.isUpdateScreen})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        children: [
          Center(
            child: Stack(
              children: [
                buildImage(theme.cardColor, context),
                // if (hasEditButton && imagePath != null)
                //   Positioned(
                //     bottom: 0,
                //     right: 0,
                //     child: Ink(
                //       child: InkWell(
                //           onTap: onClicked,
                //           child: buildEditIcon(theme.colorScheme.primary)),
                //     ),
                //   ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImage(Color color, BuildContext context) {
    print(imagePath);
    return ClipOval(
      child: Material(
        color: color,
        child: Ink(
          width: isUpdateScreen ? 128 : 68,
          height: isUpdateScreen ? 128 : 68,
          child: InkWell(
              child: isFile
                  ? Image.file(
                      imagePath,
                      fit: BoxFit.cover,
                    )
                  : imagePath != null && imagePath.isNotEmpty
                      ? Image.network(
                          imagePath,
                          fit: BoxFit.fill,
                        )
                      : Image.asset("assets/images/THICKET_MASTER_LOGO.png",
                          width: 50, height: 50)),
        ),
      ),
    );
  }

  Widget buildEditIcon(Color color) => buildCircle(
        color: Colors.white30,
        all: 3,
        child: buildCircle(
          color: color,
          all: 8,
          child: const Icon(
            Icons.edit,
            color: Colors.black,
            size: 20,
          ),
        ),
      );

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
}
