import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
              child: widget.title == tr('darktheme')
                  ? Switch(
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: const Color(0xFF9B9B9B),
                      value: themeChange.darkTheme,
                      onChanged: (bool value) {
                        setState(() {
                          themeChange.darktheme = value;
                        });
                      },
                    )
                  : widget.title == tr("changelanguage")
                      ? DropdownButton(
                          value: languageChange.languageCode,
                          items: const [
                            DropdownMenuItem(
                                value: 'en', child: Text('English')),
                            DropdownMenuItem(
                                value: 'am', child: Text('Amharic')),
                            DropdownMenuItem(
                                value: 'en-AU', child: Text('Afaan Oromo')),
                            DropdownMenuItem(
                                value: 'es', child: Text('Somali')),
                            DropdownMenuItem(
                                value: 'fr', child: Text('Tigrinya')),
                          ],
                          onChanged: (String? value) async {
                            // mark this function as async
                            String langCode = value!.split('-')[0];
                            String countryCode =
                                value.contains('-') ? value.split('-')[1] : '';

                            // Save langCode and countryCode in shared preferences
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.setString('langCode', langCode);
                            if (countryCode.isNotEmpty) {
                              await prefs.setString('countryCode', countryCode);
                            } else {
                              await prefs.remove('countryCode');
                            }

                            // Set locale for EasyLocalization
                            if (countryCode.isNotEmpty) {
                              EasyLocalization.of(context)!
                                  .setLocale(Locale(langCode, countryCode));
                            } else {
                              EasyLocalization.of(context)!
                                  .setLocale(Locale(langCode));
                            }

                            // Now call setState()
                            if (mounted) {
                              setState(() {
                                languageChange.languageCode = value;
                              });
                            }
                          })
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
