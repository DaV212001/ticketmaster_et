import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:ticketmaster_et/prefs/language_selector.dart';

import '../../controllers/theme_controller.dart';
import '../../provider/settings_provider.dart';

class RouteCard extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  RouteCard(
      {super.key,
      required this.onTap,
      required this.icon,
      required this.title});

  @override
  State<RouteCard> createState() => _RouteCardState();
}

class _RouteCardState extends State<RouteCard> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final themeChange = Provider.of<SettingsProvider>(context);
    final languageChange = Provider.of<SettingsProvider>(context);
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        height: 50,
        child: Row(
          children: [
            Icon(
              widget.icon,
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              // child: widget.title == "change_language".tr()? LanguageSelectorButton(
              //   onChange: (){

              //   },
              // ):
              child: widget.title == 'darktheme'.tr
                  ? Obx(() => Switch(
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: const Color(0xFF9B9B9B),
                        value: ThemeModeController.isDark.value,
                        onChanged: (bool value) {
                          ThemeModeController.toggleThemeMode(); // Toggle theme
                        },
                      ))
                  : widget.title == "changelanguage".tr
                      ? LanguageSelectorButton(onChange: () {})
                      : const Icon(
                          Icons.chevron_right_outlined,
                        ),
            )
          ],
        ),
      ),
    );
  }
}
