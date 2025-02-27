import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/footer_controller.dart';
import '../../prefs/assets.dart';

class UserScreenFooter extends StatelessWidget {
  final FooterData footerData;

  const UserScreenFooter({super.key, required this.footerData});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    print(footerData.toString());
    Color color = Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        Text(footerData.copyWriteText ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.secondaryContainer)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (footerData.faceBookLink != "" && footerData.faceBookLink != "#")
              socialMediaButton(color, footerData.faceBookLink,
                  AssetsS.socialFacebook, false),
            if (footerData.youtubeLink != "" && footerData.youtubeLink != "#")
              socialMediaButton(
                  color, footerData.youtubeLink, AssetsS.socialYoutube, false),
            if (footerData.instagramLink != "" &&
                footerData.instagramLink != "#")
              socialMediaButton(color, footerData.instagramLink,
                  AssetsS.socialInstagram, false),
            if (footerData.linkedInLink != "" && footerData.linkedInLink != "#")
              socialMediaButton(color, footerData.linkedInLink,
                  AssetsS.socialLinkedin, false),
            if (footerData.twitterLink != "" && footerData.twitterLink != "#")
              SizedBox(
                height: 30,
                width: 30,
                child: socialMediaButton(color, footerData.twitterLink,
                    AssetsS.socialTwitter, false),
              ),
            if (footerData.telegramLink != "" && footerData.telegramLink != "#")
              socialMediaButton(color, footerData.telegramLink,
                  AssetsS.socialTelegram, false),
            if (footerData.tiktokLink != "" && footerData.tiktokLink != "#")
              socialMediaButton(
                  color,
                  footerData.tiktokLink!.startsWith('https://')
                      ? footerData.tiktokLink
                      : 'https://${footerData.tiktokLink}',
                  AssetsS.socialTiktok,
                  false),
            if (footerData.appstoreLink != "" && footerData.appstoreLink != "#")
              SizedBox(
                height: 30,
                width: 30,
                child: socialMediaButton(
                    color,
                    footerData.appstoreLink!.startsWith('https://')
                        ? footerData.appstoreLink
                        : 'https://${footerData.appstoreLink}',
                    'assets/images/social/apple_store.svg',
                    false),
              ),
            if (footerData.playstoreLink != "" &&
                footerData.playstoreLink != "#")
              SizedBox(
                height: 30,
                width: 30,
                child: socialMediaButton(
                    color,
                    footerData.playstoreLink!.startsWith('https://')
                        ? footerData.playstoreLink
                        : 'https://${footerData.playstoreLink}',
                    'assets/images/social/playstore.svg',
                    false),
              ),
          ],
        )
      ],
    );
  }

  Widget socialMediaButton(
      Color color, String? link, String image, bool isTablet) {
    if (link == null) return const SizedBox.shrink();
    return Ink(
      child: InkWell(
        onTap: () {
          _launchUrl(link, isTablet);
        },
        child: SvgIcon(
          color: color,
          image: image,
          size: 50,
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url, bool isTablet) async {
    final Uri url0 = Uri.parse(url);
    if (!await launchUrl(url0)) {
      SnackBar(
          content: Text(
        'open_link_failed'.tr(),
      ));
    }
  }
}

class SvgIcon extends StatelessWidget {
  final Color color;
  final double size;
  final String image;
  const SvgIcon(
      {super.key, required this.color, this.size = 35, required this.image});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Center(
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            color,
            BlendMode.srcIn,
          ),
          child: SvgPicture.asset(
            image,
          ),
        ),
      ),
    );
  }
}
